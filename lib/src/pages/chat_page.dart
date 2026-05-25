import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../models/app_models.dart';
import '../services/api_client.dart';
import '../services/api_config.dart';
import '../services/chat_service.dart';
import '../services/chat_socket.dart';
import '../state/accessibility_state.dart';
import '../state/app_state.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, this.isActive = true});

  final bool isActive;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService(apiClient: apiClient);

  io.Socket? _socket;

  bool _isLoading = true;
  String _loadError = '';

  List<ChatSummary> _allChats = <ChatSummary>[];
  List<String> _participantChatIds = <String>[];

  ChatDetail? _selectedChat;
  String _selectedChatId = '';

  List<ChatHistoryMessage> _messages = <ChatHistoryMessage>[];
  List<String> _onlineParticipants = <String>[];

  final TextEditingController _messageController = TextEditingController();

  String _joiningChatId = '';
  String? _lastLoadedUserId;
  bool _hasLoadedOnce = false;

  Set<String> get _participantSet => _participantChatIds.toSet();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActive) {
        _tryInitialize(forceReload: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _tryInitialize(forceReload: true);
    }
  }

  @override
  void dispose() {
    _socket?.off('chat:message');
    _socket?.off('chat:participants');
    _socket?.off('chat:reload');
    _messageController.dispose();
    super.dispose();
  }

  void _tryInitialize({bool forceReload = false}) {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    final token = appState.sessionToken;

    if (user == null || token == null) {
      setState(() {
        _isLoading = false;
        _loadError = '';
        _allChats = <ChatSummary>[];
        _participantChatIds = <String>[];
        _selectedChat = null;
        _selectedChatId = '';
        _messages = <ChatHistoryMessage>[];
        _onlineParticipants = <String>[];
      });
      return;
    }

    final shouldLoad =
        forceReload || !_hasLoadedOnce || _lastLoadedUserId != user.id;

    if (!shouldLoad) {
      return;
    }

    _lastLoadedUserId = user.id;
    _hasLoadedOnce = true;
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    final token = appState.sessionToken;

    if (user == null || token == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _loadError = '';
    });

    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        _chatService.getAllChats(token: token),
        _chatService.getChatsByUser(user.id, token: token),
      ]);

      final availableChats = results[0] as List<ChatSummary>;
      final myChats = results[1] as List<ChatDetail>;
      final myChatIds = myChats.map((chat) => chat.id).toList(growable: false);

      if (!mounted) return;

      setState(() {
        _allChats = availableChats;
        _participantChatIds = myChatIds;
        _isLoading = false;
      });

      _setupSocket(token);

      if (_selectedChatId.isNotEmpty &&
          _participantSet.contains(_selectedChatId)) {
        await _loadChat(_selectedChatId);
      } else if (myChats.isNotEmpty) {
        await _loadChat(myChats.first.id);
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loadError =
            'It cannot load the chats.\n$error\n\nBackend: ${ApiConfig.apiBaseUrl}';
        _isLoading = false;
      });
    }
  }

  void _setupSocket(String token) {
    _socket?.off('chat:message');
    _socket?.off('chat:participants');
    _socket?.off('chat:reload');

    _socket = chatSocketService.getOrCreateSocket(token);

    _socket!.on('connect', (_) {
      debugPrint('Chat socket connected');
    });

    _socket!.on('connect_error', (error) {
      debugPrint('Chat socket connect_error: $error');
    });

    _socket!.on('chat:message', (data) {
      if (!mounted || data is! Map) return;

      final event = ChatMessageEvent.fromJson(Map<String, dynamic>.from(data));

      if (event.chatId != _selectedChatId) return;

      final alreadyExists = _messages.any((message) {
        final author = message.author;

        return message.message == event.message &&
            author.username == event.username;
      });

      if (alreadyExists) return;

      setState(() {
        _messages = <ChatHistoryMessage>[
          ..._messages,
          ChatHistoryMessage(
            userId: event.username,
            message: event.message,
            timestamp: event.timestamp,
          ),
        ];
      });
    });

    _socket!.on('chat:participants', (data) {
      if (!mounted || data is! Map) return;

      final event = ChatParticipantsEvent.fromJson(
        Map<String, dynamic>.from(data),
      );

      if (event.chatId != _selectedChatId) return;

      setState(() {
        _onlineParticipants = event.participants;
      });
    });

    _socket!.on('chat:reload', (_) async {
      await _reloadChatLists();
    });
  }

  Future<void> _reloadChatLists() async {
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    final token = appState.sessionToken;

    if (user == null || token == null) return;

    try {
      final availableChats = await _chatService.getAllChats(token: token);
      final myChats = await _chatService.getChatsByUser(user.id, token: token);

      if (!mounted) return;

      setState(() {
        _allChats = availableChats;
        _participantChatIds = myChats.map((chat) => chat.id).toList();
      });
    } catch (_) {}
  }

  Future<void> _selectChat(ChatSummary chat) async {
    if (_participantSet.contains(chat.id)) {
      await _loadChat(chat.id);
      return;
    }

    if (chat.hasPassword) {
      await _showJoinPasswordDialog(chat);
      return;
    }

    await _joinChat(chat, '');
  }

  Future<void> _loadChat(String chatId) async {
    final token = context.read<AppState>().sessionToken;

    if (token == null) return;

    setState(() {
      _selectedChatId = chatId;
      _selectedChat = null;
      _messages = <ChatHistoryMessage>[];
      _onlineParticipants = <String>[];
      _loadError = '';
    });

    try {
      final chat = await _chatService.getChatById(chatId, token: token);

      if (!mounted) return;

      setState(() {
        _selectedChat = chat;
        _messages = chat.chatHistory;
        _onlineParticipants = chat.participants
            .map((participant) => participant.username)
            .where((username) => username.trim().isNotEmpty)
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _selectedChat = null;
        _messages = <ChatHistoryMessage>[];
        _onlineParticipants = <String>[];
        _loadError = error.toString();
      });
    }
  }

  Future<void> _joinChat(ChatSummary chat, String password) async {
    final token = context.read<AppState>().sessionToken;

    if (token == null) return;

    setState(() {
      _joiningChatId = chat.id;
      _loadError = '';
    });

    try {
      final joinedChat = await _chatService.joinChat(
        chat.id,
        password,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _participantChatIds = <String>{
          ..._participantChatIds,
          chat.id,
        }.toList();

        _selectedChatId = chat.id;
        _selectedChat = joinedChat;
        _messages = joinedChat.chatHistory;
        _onlineParticipants = joinedChat.participants
            .map((participant) => participant.username)
            .where((username) => username.trim().isNotEmpty)
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _joiningChatId = '';
        });
      }
    }
  }

  Future<void> _showJoinPasswordDialog(ChatSummary chat) async {
    final controller = TextEditingController();
    final accessibility = context.read<AccessibilityState>();

    final password = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: accessibility.surfaceColor,
          title: Text(
            'Enter in ${chat.name}',
            style: TextStyle(color: accessibility.textColor),
          ),
          content: TextField(
            controller: controller,
            obscureText: true,
            cursorColor: accessibility.textColor,
            style: TextStyle(color: accessibility.textColor),
            decoration: InputDecoration(
              labelText: 'Password of the group',
              labelStyle: TextStyle(color: accessibility.secondaryTextColor),
              filled: true,
              fillColor: accessibility.inputFillColor,
              border: OutlineInputBorder(
                borderSide: BorderSide(color: accessibility.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: accessibility.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: accessibility.borderColor,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: accessibility.textColor),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Enter'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (password != null) {
      await _joinChat(chat, password);
    }
  }

  Future<void> _showCreateGroupDialog() async {
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    final accessibility = context.read<AccessibilityState>();

    final result = await showDialog<({String name, String? password})>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: accessibility.surfaceColor,
          title: Text(
            'Create group',
            style: TextStyle(color: accessibility.textColor),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                cursorColor: accessibility.textColor,
                style: TextStyle(color: accessibility.textColor),
                decoration: InputDecoration(
                  labelText: 'Name of the group',
                  labelStyle: TextStyle(
                    color: accessibility.secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: accessibility.inputFillColor,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: accessibility.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accessibility.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: accessibility.borderColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                obscureText: true,
                cursorColor: accessibility.textColor,
                style: TextStyle(color: accessibility.textColor),
                decoration: InputDecoration(
                  labelText: 'Optional password',
                  labelStyle: TextStyle(
                    color: accessibility.secondaryTextColor,
                  ),
                  filled: true,
                  fillColor: accessibility.inputFillColor,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: accessibility.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accessibility.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: accessibility.borderColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: accessibility.textColor),
              ),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();

                if (name.length < 2) return;

                Navigator.of(context).pop((
                  name: name,
                  password: passwordController.text.trim().isEmpty
                      ? null
                      : passwordController.text.trim(),
                ));
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    passwordController.dispose();

    if (result == null) return;

    await _createGroup(result.name, result.password);
  }

  Future<void> _createGroup(String name, String? password) async {
    final token = context.read<AppState>().sessionToken;

    if (token == null) return;

    try {
      final newChat = await _chatService.createChat(
        name,
        password,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _participantChatIds = <String>{
          ..._participantChatIds,
          newChat.id,
        }.toList();

        _allChats = <ChatSummary>[
          ..._allChats,
          ChatSummary(
            id: newChat.id,
            name: newChat.name,
            hasPassword: password != null && password.trim().isNotEmpty,
          ),
        ];

        _selectedChatId = newChat.id;
        _selectedChat = newChat;
        _messages = newChat.chatHistory;
        _onlineParticipants = newChat.participants
            .map((participant) => participant.username)
            .where((username) => username.trim().isNotEmpty)
            .toList(growable: false);
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    final appState = context.read<AppState>();
    final user = appState.currentUser;

    if (content.isEmpty ||
        _selectedChatId.isEmpty ||
        _socket == null ||
        user == null) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();

    _socket!.emit('chat:message', <String, dynamic>{
      'chat_id': _selectedChatId,
      'username': user.username,
      'message': content,
    });

    setState(() {
      _messages = <ChatHistoryMessage>[
        ..._messages,
        ChatHistoryMessage(
          userId: user.username,
          message: content,
          timestamp: timestamp,
        ),
      ];
    });

    _messageController.clear();
  }

  String _formatMessageTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final accessibility = context.watch<AccessibilityState>();

    final user = appState.currentUser;
    final token = appState.sessionToken;

    if (user == null || token == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'You need to log in to use the chats.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: accessibility.textColor,
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Container(
        color: accessibility.pageBackgroundColor,
        child: RefreshIndicator(
          onRefresh: _initializeChat,
          color: accessibility.textColor,
          backgroundColor: accessibility.surfaceColor,
          child: Column(
            children: <Widget>[
              _buildHeader(),
              if (_isLoading)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: accessibility.textColor,
                  backgroundColor: accessibility.secondarySurfaceColor,
                ),
              if (_loadError.isNotEmpty) _buildError(),
              SizedBox(height: 130, child: _buildAvailableChats()),
              Expanded(child: _buildSelectedChat(user)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final accessibility = context.watch<AccessibilityState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              'Chats',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: accessibility.textColor,
              ),
            ),
          ),
          IconButton(
            onPressed: _initializeChat,
            icon: Icon(Icons.refresh, color: accessibility.textColor),
          ),
          FilledButton.icon(
            onPressed: _showCreateGroupDialog,
            style: FilledButton.styleFrom(
              backgroundColor: accessibility.buttonColor,
              foregroundColor: accessibility.buttonTextColor,
            ),
            icon: const Icon(Icons.add),
            label: const Text('New group'),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        _loadError,
        style: const TextStyle(color: Colors.red, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAvailableChats() {
    final accessibility = context.watch<AccessibilityState>();

    if (_isLoading && _allChats.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: accessibility.textColor),
      );
    }

    if (_allChats.isEmpty) {
      return Center(
        child: Text(
          'There are no chats available.',
          style: TextStyle(color: accessibility.textColor),
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      itemCount: _allChats.length,
      separatorBuilder: (context, index) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final chat = _allChats[index];
        final isSelected = chat.id == _selectedChatId;
        final isParticipant = _participantSet.contains(chat.id);
        final requiresPassword = !isParticipant && chat.hasPassword;
        final isJoining = _joiningChatId == chat.id;

        final selectedBackground = accessibility.buttonColor;
        final selectedText = accessibility.buttonTextColor;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: isJoining ? null : () => _selectChat(chat),
          child: Container(
            width: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? selectedBackground
                  : accessibility.surfaceColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? accessibility.buttonColor
                    : accessibility.borderColor,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      requiresPassword
                          ? Icons.lock_outline
                          : Icons.forum_outlined,
                      color: isSelected
                          ? selectedText
                          : accessibility.textColor,
                    ),
                    const Spacer(),
                    if (isJoining)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: isSelected
                              ? selectedText
                              : accessibility.textColor,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  chat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? selectedText : accessibility.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isParticipant
                      ? 'You are already a member'
                      : requiresPassword
                      ? 'Password required'
                      : 'Open group',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? selectedText.withValues(alpha: 0.75)
                        : accessibility.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedChat(AppUser user) {
    final accessibility = context.watch<AccessibilityState>();
    final selectedChat = _selectedChat;

    if (selectedChat == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Select a chat to view its messages and participants.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: accessibility.textColor,
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        _buildChatInfo(selectedChat),
        Expanded(child: _buildMessages(user)),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatInfo(ChatDetail chat) {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accessibility.borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            chat.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accessibility.textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${chat.participants.length} participants · ${_onlineParticipants.length} online',
            style: TextStyle(color: accessibility.secondaryTextColor),
          ),
          if (chat.participants.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: chat.participants.map((participant) {
                final currentUser = context.read<AppState>().currentUser;

                final isMe =
                    currentUser != null &&
                    (participant.id == currentUser.id ||
                        participant.username == currentUser.username);

                return Chip(
                  avatar: isMe
                      ? Icon(
                          Icons.person,
                          size: 16,
                          color: accessibility.buttonTextColor,
                        )
                      : null,
                  label: Text(
                    isMe
                        ? '${participant.username} · Tú'
                        : participant.username,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isMe ? FontWeight.w800 : FontWeight.w500,
                      color: isMe
                          ? accessibility.buttonTextColor
                          : accessibility.textColor,
                    ),
                  ),
                  backgroundColor: isMe
                      ? accessibility.buttonColor
                      : accessibility.surfaceColor,
                  side: BorderSide(color: accessibility.borderColor),
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessages(AppUser user) {
    final accessibility = context.watch<AccessibilityState>();

    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'There are no messages in this chat yet.',
          style: TextStyle(color: accessibility.textColor),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final author = message.author;
        final isMine = author.id == user.id || author.username == user.username;

        final bubbleColor = isMine
            ? accessibility.buttonColor
            : accessibility.surfaceColor;
        final bubbleTextColor = isMine
            ? accessibility.buttonTextColor
            : accessibility.textColor;
        final bubbleSecondaryTextColor = isMine
          ? accessibility.buttonTextColor.withValues(alpha: 0.7)
            : accessibility.secondaryTextColor;

        return Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.74,
            ),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(18).copyWith(
                bottomRight: isMine ? const Radius.circular(4) : null,
                bottomLeft: isMine ? null : const Radius.circular(4),
              ),
              border: Border.all(color: accessibility.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  isMine ? 'Tú' : author.username,
                  style: TextStyle(
                    color: bubbleSecondaryTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.message,
                  style: TextStyle(
                    color: bubbleTextColor,
                    fontSize: 15,
                    height: accessibility.lineHeight,
                    wordSpacing: accessibility.wordSpacingValue,
                    letterSpacing: accessibility.letterSpacingValue,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: bubbleSecondaryTextColor,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: accessibility.surfaceColor,
        border: Border(top: BorderSide(color: accessibility.borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                cursorColor: accessibility.textColor,
                textInputAction: TextInputAction.send,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _sendMessage(),
                style: TextStyle(
                  color: accessibility.textColor,
                  fontSize: 16,
                  height: accessibility.lineHeight ?? 1.25,
                  wordSpacing: accessibility.wordSpacingValue,
                  letterSpacing: accessibility.letterSpacingValue,
                ),
                decoration: InputDecoration(
                  hintText: 'Write a message...',
                  hintStyle: TextStyle(
                    color: accessibility.secondaryTextColor,
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: accessibility.inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: accessibility.borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: accessibility.borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: accessibility.textColor,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: _messageController.text.trim().isEmpty
                  ? null
                  : _sendMessage,
              style: FilledButton.styleFrom(
                backgroundColor: accessibility.buttonColor,
                foregroundColor: accessibility.buttonTextColor,
                disabledBackgroundColor: accessibility.secondarySurfaceColor,
                disabledForegroundColor: accessibility.secondaryTextColor,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
