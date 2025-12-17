import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:church_history_explorer/services/ai_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// A simple model for a chat message
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isMarkdown;

  ChatMessage({required this.text, required this.isUser, this.isMarkdown = false});
}

class AiAssistantScreen extends StatefulWidget {
  final String? initialContext;

  const AiAssistantScreen({
    super.key,
    this.initialContext,
  });

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiService _aiService = AiService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final FocusNode _textFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.initialContext != null) {
      // Add a context message if coming from an event
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _messages.add(ChatMessage(
            text:
                '📖 Context: You\'re asking about "**${widget.initialContext}**".\n\nI\'m here to help you understand this important event in church history!',
            isUser: false,
            isMarkdown: true,
          ));
        });
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Add user message to list
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isTyping = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Call AI service
    final result = await _aiService.sendMessage(message: text);

    setState(() {
      _isTyping = false;
      if (result['success']) {
        final md = result['response_markdown'];
        if (md != null && md is String && md.isNotEmpty) {
          _messages.add(ChatMessage(text: md, isUser: false, isMarkdown: true));
        } else {
          _messages.add(ChatMessage(text: result['response'] ?? '', isUser: false));
        }
      } else {
        _messages.add(ChatMessage(
          text: '❌ Error: ${result['error']}',
          isUser: false,
        ));
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // A small delay to allow the list to update before scrolling
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church History AI Assistant'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to Church History Assistant!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ask me anything about church history, historical events, key figures, or theological concepts. I\'m here to help you learn!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          // "Typing" indicator
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Church History AI is typing...'),
                ],
              ),
            ),
          // Text input field
          _buildTextInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final align =
        message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = message.isUser
        ? Theme.of(context).primaryColor.withOpacity(0.8)
        : Colors.grey[200];
    final textColor = message.isUser ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: message.isUser
              ? Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 16),
                )
              : (message.isMarkdown
                  ? MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: textColor, fontSize: 16),
                        h1: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Text(
                      message.text,
                      style: TextStyle(color: textColor, fontSize: 16),
                    )),
        ),
      ],
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: 8 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Focus(
              onKey: (FocusNode node, RawKeyEvent event) {
                if (event is RawKeyDownEvent) {
                  final isShiftPressed = RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftLeft) ||
                      RawKeyboard.instance.keysPressed.contains(LogicalKeyboardKey.shiftRight);

                  if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
                    if (isShiftPressed) {
                      // Insert newline at current cursor position
                      final text = _textController.text;
                      final sel = _textController.selection;
                      final start = sel.start >= 0 ? sel.start : text.length;
                      final end = sel.end >= 0 ? sel.end : text.length;
                      final newText = text.replaceRange(start, end, '\n');
                      final newOffset = start + 1;
                      _textController.text = newText;
                      _textController.selection = TextSelection.fromPosition(TextPosition(offset: newOffset));
                      return KeyEventResult.handled;
                    } else {
                      _sendMessage();
                      return KeyEventResult.handled;
                    }
                  }
                }
                return KeyEventResult.ignored;
              },
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Ask about church history, events, figures, theology...',
                  border: InputBorder.none,
                  filled: false,
                ),
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}