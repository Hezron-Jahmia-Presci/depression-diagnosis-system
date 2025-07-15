import 'package:flutter/material.dart';
import 'package:depression_diagnosis_system/service/lib/message_service.dart';
import 'package:depression_diagnosis_system/service/lib/health_worker_service.dart';

import '../../../../widget/widget_exporter.dart';

class MessageInboxScreen extends StatefulWidget {
  final VoidCallback onBack;
  const MessageInboxScreen({super.key, required this.onBack});

  @override
  State<MessageInboxScreen> createState() => _MessageInboxScreenState();
}

class _MessageInboxScreenState extends State<MessageInboxScreen> {
  final HealthWorkerService _healthWorkerService = HealthWorkerService();
  final MessageService _messageService = MessageService();

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  List<Map<String, dynamic>> _healthWorkers = [];
  List<Map<String, dynamic>> _filteredWorkers = [];
  List<Map<String, dynamic>> _messages = [];

  Map<String, dynamic>? _selectedWorker;
  int? _loggedInUserId;

  bool _isLoading = true;
  bool _hasError = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initialize();
    _searchController.addListener(() {
      _onSearchChanged(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      final user = await _healthWorkerService.getHealthWorkerById();
      if (user == null || user['ID'] == null) {
        throw Exception("Failed to retrieve logged-in user.");
      }

      final loggedInId = user['ID'];

      final workers = await _healthWorkerService.getAllHealthWorkers();
      final filtered = workers.where((w) => w['ID'] != loggedInId).toList();

      setState(() {
        _loggedInUserId = loggedInId;
        _healthWorkers = filtered;
        _filteredWorkers = filtered;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error in init: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMessagesWith(int otherUserId) async {
    if (_loggedInUserId == null) return;
    final messages = await _messageService.getMessagesBetween(
      senderId: _loggedInUserId!,
      receiverId: otherUserId,
    );
    setState(() => _messages = messages);
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _selectedWorker == null || _loggedInUserId == null) {
      return;
    }

    setState(() => _isSending = true);

    final result = await _messageService.sendMessage(
      senderId: _loggedInUserId!,
      receiverId: _selectedWorker!['ID'],
      message: message,
    );

    setState(() => _isSending = false);

    if (result != null && result.containsKey('message')) {
      _messageController.clear();
      // Instead of appending, reload all messages to keep in sync:
      await _fetchMessagesWith(_selectedWorker!['ID']);
    }
  }

  void _onSearchChanged(String query) {
    final lower = query.toLowerCase();
    final filtered =
        _healthWorkers.where((hw) {
          final name = '${hw['first_name']} ${hw['last_name']}'.toLowerCase();
          final email = (hw['email'] ?? '').toLowerCase();
          return name.contains(lower) || email.contains(lower);
        }).toList();

    setState(() => _filteredWorkers = filtered);
  }

  void _selectHealthWorker(Map<String, dynamic> worker) async {
    setState(() {
      _selectedWorker = worker;
      _messages = [];
    });
    await _fetchMessagesWith(worker['ID']);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_hasError) {
      return const Center(child: Text('Error fetching health workers'));
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 8),
            const Text(
              "Inbox",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),

        const SizedBox(height: 24),

        Expanded(
          child: Row(
            children: [
              // LEFT PANE – CONTACTS
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 55,
                        left: 24,
                        right: 24,
                      ),
                      child: ReusableSearchBarWidget(
                        controller: _searchController,
                        label: 'Search health workers',
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _filteredWorkers.length,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          return _buildHealthWorkerCard(
                            _filteredWorkers[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const VerticalDivider(width: 1),

              // RIGHT PANE – CHAT
              Expanded(
                flex: 4,
                child:
                    _selectedWorker != null
                        ? _buildChatWindow(_selectedWorker!, colorScheme)
                        : _buildChatPlaceholder(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthWorkerCard(Map<String, dynamic> worker) {
    final imageUrl = worker['image_url']?.toString() ?? '';
    final name = '${worker['first_name']} ${worker['last_name']}';
    final email = worker['email'] ?? '';

    return ReusableCardWidget(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
          child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Text(name),
        subtitle: Text(email),
        trailing: const Icon(Icons.chat_bubble_outline_rounded),
        onTap: () => _selectHealthWorker(worker),
      ),
    );
  }

  Widget _buildChatPlaceholder() {
    return const Center(
      child: Text(
        "Select a health worker to start a conversation",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildChatWindow(
    Map<String, dynamic> recipient,
    ColorScheme colorScheme,
  ) {
    final name = '${recipient['first_name']} ${recipient['last_name']}';
    final imageUrl = recipient['image_url'] ?? '';

    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert_rounded),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // CHAT MESSAGES
        Expanded(
          child:
              _messages.isEmpty
                  ? Center(child: Text("No messages with $name yet."))
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMine = msg['sender_id'] == _loggedInUserId;
                      return Align(
                        alignment:
                            isMine
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isMine
                                    ? colorScheme.tertiaryContainer.withValues(
                                      alpha: 0.5,
                                    )
                                    : colorScheme.secondaryContainer.withValues(
                                      alpha: 0.5,
                                    ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(msg['message']),
                        ),
                      );
                    },
                  ),
        ),

        // MESSAGE COMPOSER
        ReusableCardWidget(
          addSpaceAfter: false,
          child: Row(
            children: [
              Expanded(
                child: ReusableTextFieldWidget(
                  controller: _messageController,
                  label: 'Type your message...',
                  autofillHints: const [],
                ),
              ),
              const SizedBox(width: 12),
              _isSending
                  ? const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                  : IconButton(
                    icon: const Icon(Icons.send_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _sendMessage,
                  ),
            ],
          ),
        ),
      ],
    );
  }
}
