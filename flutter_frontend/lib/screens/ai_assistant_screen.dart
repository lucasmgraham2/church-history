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
    // Clear conversation history when chat is closed
    _aiService.clearHistory();
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
        title: const Text('AI Assistant'),
        centerTitle: true,
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
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFD4AF37),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.smart_toy,
                              size: 60,
                              color: Color(0xFF6B5344),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Meet Your AI Guide',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C1810),
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Ask about church history, historical events, key figures, theological concepts, and pivotal moments in Christian tradition. This AI is trained to help you explore and understand these topics.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFAF0),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD4AF37).withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'Ask your questions below...',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B5344),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AI is thinking...',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 13,
                    ),
                  ),
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
        ? const Color(0xFF6B5344)
        : const Color(0xFFFFFAF0);
    final textColor = message.isUser ? const Color(0xFFFFFAF0) : const Color(0xFF2C1810);

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: message.isUser 
                ? const Color(0xFFD4AF37).withOpacity(0.3)
                : const Color(0xFFD4AF37).withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: message.isUser
              ? Text(
                  message.text,
                  style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                )
              : (message.isMarkdown
                  ? MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(color: textColor, fontSize: 15, height: 1.5),
                        h1: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
                        h2: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                        h3: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                        strong: const TextStyle(color: Color(0xFF4A3C2E), fontWeight: FontWeight.bold),
                        em: TextStyle(color: textColor, fontStyle: FontStyle.italic),
                      ),
                    )
                  : Text(
                      message.text,
                      style: TextStyle(color: textColor, fontSize: 15, height: 1.4),
                    )),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildTextInputArea() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8DCC4),
            Color(0xFFF4EAD5),
          ],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFD4AF37).withOpacity(0.3),
            width: 2,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
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
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFAF0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(
                    color: Color(0xFF2C1810),
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Pose your inquiry to the scholar...',
                    hintStyle: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    filled: false,
                  ),
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF2C1810),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Color(0xFFD4AF37)),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}