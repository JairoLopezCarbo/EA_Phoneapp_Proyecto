import 'dart:async';

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
  const ChatPage({
    super.key,
    this.isActive = true,
    this.initialChatId,
    this.onUnreadCountChanged,
  });

  final bool isActive;
  final String? initialChatId;
  final VoidCallback? onUnreadCountChanged;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService _chatService = ChatService(apiClient: apiClient);
  final ScrollController _messagesScrollController = ScrollController();

  io.Socket? _socket;

  bool _isLoading = true;
  String _loadError = '';

  List<ChatSummary> _allChats = <ChatSummary>[];
  List<String> _participantChatIds = <String>[];
  Map<String, int> _unreadCounts = <String, int>{};
  Map<String, int> _unreadMarkers = <String, int>{};

  ChatDetail? _selectedChat;
  String _selectedChatId = '';

  List<ChatHistoryMessage> _messages = <ChatHistoryMessage>[];

  final TextEditingController _messageController = TextEditingController();

  String _joiningChatId = '';
  String? _lastLoadedUserId;
  bool _hasLoadedOnce = false;
  bool _isSendingMessage = false;

  Set<String> get _participantSet => _participantChatIds.toSet();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isActive) {
        _tryInitialize(forceReload: true);
      }
      _openInitialChatIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.isActive && widget.isActive) {
      _tryInitialize(forceReload: true);
    }
    if (widget.initialChatId != oldWidget.initialChatId) {
      _openInitialChatIfNeeded();
    }
  }

  @override
  void dispose() {
    _removeSocketListeners();
    _messagesScrollController.dispose();
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
        _unreadCounts = <String, int>{};
        _unreadMarkers = <String, int>{};
        _selectedChat = null;
        _selectedChatId = '';
        _messages = <ChatHistoryMessage>[];
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
        _unreadCounts = <String, int>{
          for (final chat in availableChats) chat.id: chat.unreadCount,
        };
        _isLoading = false;
      });

      _setupSocket(token);

      if (_selectedChatId.isNotEmpty &&
          _participantSet.contains(_selectedChatId)) {
        await _loadChat(_selectedChatId);
      } else {
        final unreadChats =
            availableChats
                .where(
                  (chat) => myChatIds.contains(chat.id) && chat.unreadCount > 0,
                )
                .toList()
              ..sort(
                (first, second) =>
                    second.unreadCount.compareTo(first.unreadCount),
              );

        if (unreadChats.isNotEmpty) {
          _setUnreadMarker(unreadChats.first.id, unreadChats.first.unreadCount);
          await _loadChat(unreadChats.first.id);
        }
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

  Future<void> _openInitialChatIfNeeded() async {
    final chatId = widget.initialChatId;

    if (chatId == null || chatId.trim().isEmpty) {
      return;
    }

    if (!widget.isActive) {
      return;
    }

    if (_selectedChatId == chatId && _selectedChat != null) {
      return;
    }

    final appState = context.read<AppState>();
    final user = appState.currentUser;
    final token = appState.sessionToken;

    if (user == null || token == null) {
      return;
    }

    if (!_hasLoadedOnce) {
      _tryInitialize(forceReload: true);
      return;
    }

    await _loadChat(chatId);
  }

  void _setUnreadMarker(String chatId, int unreadCount) {
    _unreadMarkers = <String, int>{..._unreadMarkers, chatId: unreadCount};
  }

  void _setupSocket(String token) {
    _removeSocketListeners();

    _socket = chatSocketService.getOrCreateSocket(token);

    _socket!.on('connect', _handleSocketConnect);
    _socket!.on('connect_error', _handleSocketConnectError);
    _socket!.on('chat:message', _handleSocketMessage);
    _socket!.on('chat:participants', _handleSocketParticipants);
    _socket!.on('chat:reload', _handleSocketReload);
  }

  void _removeSocketListeners() {
    _socket?.off('connect', _handleSocketConnect);
    _socket?.off('connect_error', _handleSocketConnectError);
    _socket?.off('chat:message', _handleSocketMessage);
    _socket?.off('chat:participants', _handleSocketParticipants);
    _socket?.off('chat:reload', _handleSocketReload);
  }

  void _handleSocketConnect(dynamic _) {
    debugPrint('Chat socket connected');
  }

  void _handleSocketConnectError(dynamic error) {
    debugPrint('Chat socket connect_error: $error');
  }

  void _handleSocketMessage(dynamic data) {
    if (!mounted || data is! Map) return;

    final event = ChatMessageEvent.fromJson(Map<String, dynamic>.from(data));
    final appState = context.read<AppState>();
    final user = appState.currentUser;
    final isMine = event.userId == user?.id || event.username == user?.username;

    if (event.chatId != _selectedChatId) {
      if (!isMine) {
        setState(() {
          _unreadCounts = <String, int>{
            ..._unreadCounts,
            event.chatId: (_unreadCounts[event.chatId] ?? 0) + 1,
          };
        });
      }
      return;
    }

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
      if (!isMine) {
        _unreadMarkers = <String, int>{..._unreadMarkers, event.chatId: 0};
        _unreadCounts = <String, int>{..._unreadCounts, event.chatId: 0};
      }
    });

    if (!isMine) {
      final token = appState.sessionToken;
      if (token != null) {
        unawaited(
          _chatService
              .markChatAsRead(event.chatId, token: token)
              .then((_) => widget.onUnreadCountChanged?.call())
              .catchError((_) {}),
        );
      }
    }
  }

  void _handleSocketParticipants(dynamic data) {
    if (!mounted || data is! Map) return;

    final event = ChatParticipantsEvent.fromJson(
      Map<String, dynamic>.from(data),
    );

    if (event.chatId != _selectedChatId) return;
  }

  void _handleSocketReload(dynamic _) {
    unawaited(_reloadChatLists());
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
        _unreadCounts = <String, int>{
          for (final chat in availableChats) chat.id: chat.unreadCount,
        };
      });

      widget.onUnreadCountChanged?.call();
    } catch (_) {}
  }

  Future<void> _selectChat(ChatSummary chat) async {
    if (_participantSet.contains(chat.id)) {
      _setUnreadMarker(chat.id, _unreadCounts[chat.id] ?? chat.unreadCount);
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
    final unreadAtOpen = _unreadMarkers[chatId] ?? _unreadCounts[chatId] ?? 0;

    setState(() {
      _selectedChatId = chatId;
      _selectedChat = null;
      _messages = <ChatHistoryMessage>[];
      _loadError = '';
    });

    try {
      final chat = await _chatService.getChatById(chatId, token: token);

      if (!mounted) return;

      setState(() {
        _selectedChat = chat;
        _messages = chat.chatHistory;
        _unreadMarkers = <String, int>{..._unreadMarkers, chatId: unreadAtOpen};
        _unreadCounts = <String, int>{..._unreadCounts, chatId: 0};
      });

      unawaited(
        _chatService
            .markChatAsRead(chatId, token: token)
            .then((_) => widget.onUnreadCountChanged?.call())
            .catchError((_) {}),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _selectedChat = null;
        _messages = <ChatHistoryMessage>[];
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
        _unreadMarkers = <String, int>{..._unreadMarkers, chat.id: 0};
        _unreadCounts = <String, int>{..._unreadCounts, chat.id: 0};
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
    final password = await showDialog<String>(
      context: context,
      builder: (_) => _JoinPasswordDialog(chatName: chat.name),
    );

    if (password != null) {
      await _joinChat(chat, password);
    }
  }

  Future<void> _showCreateGroupDialog() async {
    final result = await showDialog<({String name, String? password})>(
      context: context,
      builder: (_) => const _CreateGroupDialog(),
    );

    if (result == null || !mounted) return;

    await Future<void>.delayed(Duration.zero);
    if (!mounted) return;

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
            unreadCount: 0,
          ),
        ];

        _selectedChatId = newChat.id;
        _selectedChat = newChat;
        _messages = newChat.chatHistory;
        _unreadMarkers = <String, int>{..._unreadMarkers, newChat.id: 0};
      });
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    final appState = context.read<AppState>();
    final user = appState.currentUser;

    if (content.isEmpty ||
        _selectedChatId.isEmpty ||
        user == null ||
        _isSendingMessage) {
      return;
    }

    final token = appState.sessionToken;

    if (token == null || token.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You need to log in to send messages.')),
      );
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final optimisticMessage = ChatHistoryMessage(
      userId: user.username,
      message: content,
      timestamp: timestamp,
    );

    _messageController.clear();
    setState(() {
      _isSendingMessage = true;
      _messages = <ChatHistoryMessage>[..._messages, optimisticMessage];
    });

    try {
      if (_socket?.connected == true) {
        _socket!.emit('chat:message', <String, dynamic>{
          'chat_id': _selectedChatId,
          'username': user.username,
          'message': content,
        });
        return;
      }

      final updatedChat = await _chatService.sendMessage(
        _selectedChatId,
        content,
        token: token,
      );

      if (!mounted) return;

      setState(() {
        _selectedChat = updatedChat;
        _messages = updatedChat.chatHistory;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _messages = _messages
            .where((message) => message != optimisticMessage)
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message could not be sent: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSendingMessage = false;
        });
      }
    }
  }

  String _formatMessageTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _dateKey(String timestamp) {
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }

  String _formatMessageDate(String timestamp) {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    try {
      final date = DateTime.parse(timestamp).toLocal();
      final month = months[date.month - 1];
      return '$month ${date.day}, ${date.year}';
    } catch (_) {
      return '';
    }
  }

  bool _isMessageFromCurrentUser(ChatHistoryMessage message, AppUser user) {
    final author = message.author;
    return author.id == user.id || author.username == user.username;
  }

  int _unreadSeparatorIndex(AppUser user) {
    final unreadCount = _unreadMarkers[_selectedChatId] ?? 0;

    if (unreadCount <= 0 || _messages.isEmpty) {
      return -1;
    }

    var remainingUnreadMessages = unreadCount;

    for (var index = _messages.length - 1; index >= 0; index -= 1) {
      if (!_isMessageFromCurrentUser(_messages[index], user)) {
        remainingUnreadMessages -= 1;
      }

      if (remainingUnreadMessages == 0) {
        return index;
      }
    }

    return 0;
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
              if (_selectedChat == null) _buildHeader(),
              if (_isLoading)
                LinearProgressIndicator(
                  minHeight: 2,
                  color: accessibility.textColor,
                  backgroundColor: accessibility.secondarySurfaceColor,
                ),
              if (_loadError.isNotEmpty) _buildError(),
              if (_selectedChat == null)
                _buildAvailableChats()
              else
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
      padding: const EdgeInsets.fromLTRB(16, 52, 16, 8),
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
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
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
      return Expanded(
        child: Center(
          child: CircularProgressIndicator(color: accessibility.textColor),
        ),
      );
    }

    if (_allChats.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'There are no chats available.',
            style: TextStyle(color: accessibility.textColor),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
        itemCount: _allChats.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final chat = _allChats[index];
          final isSelected = chat.id == _selectedChatId;
          final isParticipant = _participantSet.contains(chat.id);
          final requiresPassword = !isParticipant && chat.hasPassword;
          final isJoining = _joiningChatId == chat.id;
          final unreadCount = _unreadCounts[chat.id] ?? chat.unreadCount;

          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: isJoining ? null : () => _selectChat(chat),
            child: Container(
              constraints: const BoxConstraints(minHeight: 78),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : accessibility.surfaceColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.black : accessibility.borderColor,
                ),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 23,
                    backgroundColor: isSelected
                        ? Colors.white.withValues(alpha: 0.18)
                        : Colors.black.withValues(alpha: 0.08),
                    child: Icon(
                      requiresPassword ? Icons.lock_outline : Icons.groups_2,
                      color: isSelected
                          ? Colors.white
                          : accessibility.textColor,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          chat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : accessibility.textColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
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
                                ? Colors.white.withValues(alpha: 0.75)
                                : accessibility.secondaryTextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (isJoining)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isSelected
                            ? Colors.white
                            : accessibility.textColor,
                      ),
                    )
                  else if (isParticipant && unreadCount > 0)
                    Container(
                      constraints: const BoxConstraints(minWidth: 24),
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEF4444),
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        unreadCount > 99 ? '99+' : unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
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
            'Select a chat to view its messages.',
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
      height: 92,
      padding: const EdgeInsets.fromLTRB(10, 36, 12, 8),
      decoration: BoxDecoration(
        color: accessibility.pageBackgroundColor,
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              setState(() {
                _selectedChat = null;
                _selectedChatId = '';
                _messages = <ChatHistoryMessage>[];
              });
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: accessibility.textColor,
              size: 26,
            ),
          ),
          CircleAvatar(
            radius: 23,
            backgroundColor: Colors.black.withValues(alpha: 0.08),
            child: Text(
              chat.name.isNotEmpty ? chat.name[0].toUpperCase() : '?',
              style: TextStyle(
                color: accessibility.textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              chat.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: accessibility.textColor,
              ),
            ),
          ),
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
          style: TextStyle(color: accessibility.secondaryTextColor),
        ),
      );
    }

    return ListView(
      controller: _messagesScrollController,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
      children: List<Widget>.generate(
        _messages.length,
        (index) => _buildMessageItem(user, index, accessibility),
      ),
    );
  }

  Widget _buildMessageItem(
    AppUser user,
    int index,
    AccessibilityState accessibility,
  ) {
    final message = _messages[index];
    final previousMessage = index > 0 ? _messages[index - 1] : null;
    final showDate =
        index == 0 ||
        _dateKey(previousMessage?.timestamp ?? '') !=
            _dateKey(message.timestamp);
    final author = message.author;
    final isMine = _isMessageFromCurrentUser(message, user);
    final unreadCount = _unreadMarkers[_selectedChatId] ?? 0;
    final showUnreadSeparator =
        unreadCount > 0 && _unreadSeparatorIndex(user) == index;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showDate) _buildDateSeparator(message.timestamp),
        if (showUnreadSeparator) _buildUnreadSeparator(unreadCount),
        Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: isMine
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              if (!isMine) ...<Widget>[
                CircleAvatar(
                  radius: 13,
                  backgroundColor: Colors.black.withValues(alpha: 0.08),
                  child: Text(
                    author.username.isNotEmpty
                        ? author.username[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isMine ? Colors.black : const Color(0xFFE9E9EB),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: Radius.circular(isMine ? 22 : 6),
                      bottomRight: Radius.circular(isMine ? 6 : 22),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        message.message,
                        style: TextStyle(
                          color: isMine ? Colors.white : Colors.black,
                          fontSize: 16,
                          height: accessibility.lineHeight ?? 1.25,
                          wordSpacing: accessibility.wordSpacingValue,
                          letterSpacing: accessibility.letterSpacingValue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _formatMessageTime(message.timestamp),
                          style: TextStyle(
                            color: isMine
                                ? Colors.white.withValues(alpha: 0.72)
                                : Colors.black.withValues(alpha: 0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSeparator(String timestamp) {
    final accessibility = context.watch<AccessibilityState>();
    final label = _formatMessageDate(timestamp);

    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: accessibility.secondarySurfaceColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accessibility.borderColor),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: accessibility.secondaryTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnreadSeparator(int unreadCount) {
    final label = unreadCount == 1
        ? '1 unread message'
        : '$unreadCount unread messages';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          const Expanded(child: Divider(color: Color(0x55EF4444), height: 1)),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x55EF4444)),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFB42318),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Color(0x55EF4444), height: 1)),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final accessibility = context.watch<AccessibilityState>();

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      decoration: BoxDecoration(
        color: accessibility.pageBackgroundColor,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                height: 54,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        minLines: 1,
                        maxLines: 1,
                        cursorColor: Colors.black,
                        textInputAction: TextInputAction.send,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _sendMessage(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Mensaje...',
                          hintStyle: TextStyle(
                            color: Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (_messageController.text.trim().isNotEmpty) ...<Widget>[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _sendMessage,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _JoinPasswordDialog extends StatefulWidget {
  const _JoinPasswordDialog({required this.chatName});

  final String chatName;

  @override
  State<_JoinPasswordDialog> createState() => _JoinPasswordDialogState();
}

class _JoinPasswordDialogState extends State<_JoinPasswordDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

    return AlertDialog(
      backgroundColor: accessibility.surfaceColor,
      title: Text(
        'Enter in ${widget.chatName}',
        style: TextStyle(color: accessibility.textColor),
      ),
      content: TextField(
        controller: _controller,
        obscureText: true,
        cursorColor: accessibility.textColor,
        style: TextStyle(color: accessibility.textColor),
        decoration: _chatDialogInputDecoration(
          accessibility,
          labelText: 'Password of the group',
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
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text('Enter'),
        ),
      ],
    );
  }
}

class _CreateGroupDialog extends StatefulWidget {
  const _CreateGroupDialog();

  @override
  State<_CreateGroupDialog> createState() => _CreateGroupDialogState();
}

class _CreateGroupDialogState extends State<_CreateGroupDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accessibility = context.watch<AccessibilityState>();

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
            controller: _nameController,
            cursorColor: accessibility.textColor,
            style: TextStyle(color: accessibility.textColor),
            decoration: _chatDialogInputDecoration(
              accessibility,
              labelText: 'Name of the group',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            cursorColor: accessibility.textColor,
            style: TextStyle(color: accessibility.textColor),
            decoration: _chatDialogInputDecoration(
              accessibility,
              labelText: 'Optional password',
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
            final name = _nameController.text.trim();

            if (name.length < 2) return;

            final password = _passwordController.text.trim();

            Navigator.of(
              context,
            ).pop((name: name, password: password.isEmpty ? null : password));
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

InputDecoration _chatDialogInputDecoration(
  AccessibilityState accessibility, {
  required String labelText,
}) {
  return InputDecoration(
    labelText: labelText,
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
      borderSide: BorderSide(color: accessibility.borderColor, width: 2),
    ),
  );
}
