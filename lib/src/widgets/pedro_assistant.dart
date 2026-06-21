import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/pedro_models.dart';
import '../services/pedro_navigation.dart';
import '../services/pedro_service.dart';
import '../theme/theme.dart';
import '../utils/localization.dart';

class PedroAssistant extends StatefulWidget {
  const PedroAssistant({super.key, required this.child});

  final Widget child;

  @override
  State<PedroAssistant> createState() => _PedroAssistantState();
}

class _PedroAssistantState extends State<PedroAssistant> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<PedroMessage> _messages = <PedroMessage>[];
  String? _lastGreeting;

  bool _showWelcome = true;
  bool _panelOpen = false;
  bool _isSending = false;
  late final OverlayEntry _assistantEntry;

  @override
  void initState() {
    super.initState();
    _assistantEntry = OverlayEntry(builder: _buildAssistantOverlay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final greeting = context.l10n.pedroGreeting;
    if (_messages.isEmpty) {
      _messages.add(PedroMessage.assistant(greeting));
    } else if (_messages.first.text == _lastGreeting) {
      _messages[0] = PedroMessage.assistant(greeting);
    }
    _lastGreeting = greeting;
    _assistantEntry.markNeedsBuild();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openPanel() {
    _updateOverlay(() {
      _panelOpen = true;
    });
    _scrollToBottom();
  }

  void _updateOverlay(VoidCallback update) {
    setState(update);
    _assistantEntry.markNeedsBuild();
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty || _isSending) {
      return;
    }

    _updateOverlay(() {
      _messages.add(PedroMessage.user(question));
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await pedroService.recommend(question);
      if (!mounted) return;
      _updateOverlay(() {
        _messages.add(
          PedroMessage.assistant(response.answer, response: response),
        );
      });
    } catch (_) {
      if (!mounted) return;
      _updateOverlay(() {
        _messages.add(
          PedroMessage.assistant(context.l10n.pedroError, isError: true),
        );
      });
    } finally {
      if (mounted) {
        _updateOverlay(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: Overlay(initialEntries: <OverlayEntry>[_assistantEntry]),
        ),
      ],
    );
  }

  Widget _buildAssistantOverlay(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardInset = media.viewInsets.bottom;

    return Stack(
      children: [
        if (_panelOpen)
          Positioned(
            right: 12,
            bottom: 84 + keyboardInset,
            child: _ConversationPanel(
              messages: _messages,
              controller: _controller,
              scrollController: _scrollController,
              isSending: _isSending,
              onClose: () => _updateOverlay(() => _panelOpen = false),
              onSend: _send,
            ),
          ),
        if (_showWelcome && !_panelOpen)
          Positioned(
            right: 82,
            bottom: 22,
            child: _WelcomeBubble(
              onClose: () => _updateOverlay(() => _showWelcome = false),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 14,
          child: SafeArea(
            child: Semantics(
              button: true,
              label: context.l10n.pedroOpen,
              child: GestureDetector(
                onTap: _openPanel,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: const [AppShadows.panel],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/resources/icons/IA.gif',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.smart_toy_rounded, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeBubble extends StatelessWidget {
  const _WelcomeBubble({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width - 110;
    final bubbleWidth = maxWidth.clamp(180.0, 330.0);
    return Material(
      color: Colors.transparent,
      child: Container(
        width: bubbleWidth,
        padding: const EdgeInsets.fromLTRB(16, 10, 6, 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: const [AppShadows.panel],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.pedroGreeting,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              tooltip: context.l10n.pedroCloseGreeting,
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded, size: 19),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel({
    required this.messages,
    required this.controller,
    required this.scrollController,
    required this.isSending,
    required this.onClose,
    required this.onSend,
  });

  final List<PedroMessage> messages;
  final TextEditingController controller;
  final ScrollController scrollController;
  final bool isSending;
  final VoidCallback onClose;
  final Future<void> Function() onSend;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = (size.width - 24).clamp(280.0, 410.0);
    final height = (size.height * 0.68).clamp(360.0, 620.0);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x350F1219),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
              color: AppColors.primary,
              child: Row(
                children: [
                  ClipOval(
                    child: Image.asset(
                      'assets/resources/icons/IA.gif',
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pedro',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                          ),
                        ),
                        Text(
                          context.l10n.pedroSubtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.pedroCloseConversation,
                    color: Colors.white,
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(14),
                itemCount: messages.length + (isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return const _ThinkingBubble();
                  }
                  return _MessageBubble(message: messages[index]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        enabled: !isSending,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => unawaited(onSend()),
                        decoration: InputDecoration(
                          hintText: context.l10n.pedroAskHint,
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      tooltip: context.l10n.send,
                      onPressed: isSending ? null : () => unawaited(onSend()),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final PedroMessage message;

  @override
  Widget build(BuildContext context) {
    final response = message.response;
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : message.isError
              ? const Color(0xFFFFEEEE)
              : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
          border: message.isUser
              ? null
              : Border.all(
                  color: message.isError
                      ? const Color(0xFFF1B5B5)
                      : AppColors.border,
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (response == null)
              Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : AppColors.text,
                  height: 1.35,
                ),
              )
            else
              _LinkedAnswer(answer: message.text, routes: response.routes),
            if (response?.selectedRoute != null) ...[
              const SizedBox(height: 12),
              _RouteCard(route: response!.selectedRoute!, featured: true),
            ],
            if (response != null &&
                _alternativeRoutes(response).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.otherOptions,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 128,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _alternativeRoutes(response).length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) => SizedBox(
                    width: 180,
                    child: _RouteCard(
                      route: _alternativeRoutes(response)[index],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<PedroRoute> _alternativeRoutes(PedroResponse response) {
    final selectedId = response.selectedRoute?.id;
    return response.routes
        .where((route) => selectedId == null || route.id != selectedId)
        .toList(growable: false);
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 9),
            Text(
              context.l10n.pedroThinking,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.route, this.featured = false});

  final PedroRoute route;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => unawaited(pedroNavigation.openRoute(route.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: featured ? AppColors.positive : AppColors.border,
            width: featured ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: featured
            ? Row(
                children: [
                  _RouteImage(route: route, width: 82, height: 88),
                  Expanded(child: _RouteDetails(route: route)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _RouteImage(route: route, height: 68),
                  Expanded(child: _RouteDetails(route: route)),
                ],
              ),
      ),
    );
  }
}

class _RouteImage extends StatelessWidget {
  const _RouteImage({required this.route, this.width, required this.height});

  final PedroRoute route;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (route.coverImage.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppColors.surfaceSubtle,
        child: const Icon(Icons.landscape_rounded),
      );
    }
    return Image.network(
      route.coverImage,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceSubtle,
        child: const Icon(Icons.landscape_rounded),
      ),
    );
  }
}

class _RouteDetails extends StatelessWidget {
  const _RouteDetails({required this.route});

  final PedroRoute route;

  @override
  Widget build(BuildContext context) {
    final location = <String>[
      route.city,
      route.country,
    ].where((part) => part.trim().isNotEmpty).join(', ');
    return Padding(
      padding: const EdgeInsets.all(9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            route.name.isEmpty ? context.l10n.viewRoute : route.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              location,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }
}

class _LinkedAnswer extends StatefulWidget {
  const _LinkedAnswer({required this.answer, required this.routes});

  final String answer;
  final List<PedroRoute> routes;

  @override
  State<_LinkedAnswer> createState() => _LinkedAnswerState();
}

class _LinkedAnswerState extends State<_LinkedAnswer> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();

    final matches = <({int start, int end, PedroRoute route})>[];
    for (final route in widget.routes) {
      if (route.name.isEmpty || route.id.isEmpty) continue;
      final needle = '${route.name} (${route.id})';
      var start = widget.answer.indexOf(needle);
      while (start >= 0) {
        matches.add((start: start, end: start + needle.length, route: route));
        start = widget.answer.indexOf(needle, start + needle.length);
      }
    }
    matches.sort((a, b) => a.start.compareTo(b.start));

    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final match in matches) {
      if (match.start < cursor) continue;
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.answer.substring(cursor, match.start)));
      }
      final recognizer = TapGestureRecognizer()
        ..onTap = () => unawaited(pedroNavigation.openRoute(match.route.id));
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: match.route.name,
          recognizer: recognizer,
          style: const TextStyle(
            color: AppColors.positive,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.underline,
          ),
        ),
      );
      cursor = match.end;
    }
    if (cursor < widget.answer.length) {
      spans.add(TextSpan(text: widget.answer.substring(cursor)));
    }

    return Text.rich(
      TextSpan(
        style: const TextStyle(color: AppColors.text, height: 1.35),
        children: spans.isEmpty
            ? <InlineSpan>[TextSpan(text: widget.answer)]
            : spans,
      ),
    );
  }
}
