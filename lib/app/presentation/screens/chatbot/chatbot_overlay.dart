import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../data/models/chat_message_model.dart';
import '../../providers/chatbot_provider.dart';

class ChatbotOverlay extends ConsumerStatefulWidget {
  const ChatbotOverlay({super.key});

  @override
  ConsumerState<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends ConsumerState<ChatbotOverlay> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(chatbotProvider.notifier).sendMessage(_controller.text.trim());
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  void _scrollToBottom() {
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
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatbotProvider);
    ref.listen(chatbotProvider, (_, __) => _scrollToBottom());
    final theme = Theme.of(context);

    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16, // Añadimos un padding superior
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.05,
              ), // Reducimos el espacio superior

              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.white),
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      // --- CAMBIO PRINCIPAL AQUÍ ---
                      // Aumentamos la altura de la lista de mensajes del 50% al 65% de la pantalla
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.isEmpty ? 1 : messages.length,
                        itemBuilder: (context, index) {
                          if (messages.isEmpty) {
                            return _buildMessageItem(
                              ChatMessageModel(
                                text: '¡Hola! 👋 ¡Pregúntame lo que quieras!',
                                author: ChatMessageAuthor.bot,
                              ),
                              theme,
                            );
                          }
                          final message = messages[index];
                          return _buildMessageItem(message, theme);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextInput(theme),
                  ],
                ),
              ),
              // --- CAMBIO: Eliminamos el SizedBox inferior para que el chat quede más abajo ---
            ],
          ),
        ),
      ),
    );
  }

  // --- MÉTODO RESTAURADO ---
  Widget _buildMessageItem(ChatMessageModel message, ThemeData theme) {
    final isUser = message.author == ChatMessageAuthor.user;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.asset('assets/ai-logo.png'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(message.text, style: theme.textTheme.bodyLarge),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 12),
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.grey),
            ),
          ],
        ],
      ),
    );
  }

  // --- MÉTODO RESTAURADO ---
  Widget _buildTextInput(ThemeData theme) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Preguntar a la IA',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_forward),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              shape: const CircleBorder(),
            ),
            onPressed: _sendMessage,
          ),
        ),
      ),
      onSubmitted: (_) => _sendMessage(),
    );
  }
}
