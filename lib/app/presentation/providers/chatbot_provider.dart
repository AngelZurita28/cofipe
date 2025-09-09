import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import '../../../data/models/chat_message_model.dart';
import 'financial_context_provider.dart';

class ChatbotNotifier extends StateNotifier<List<ChatMessageModel>> {
  final Gemini _gemini;
  final Ref _ref;

  ChatbotNotifier(this._gemini, this._ref) : super([]);

  Future<void> sendMessage(String message) async {
    // Añade el mensaje del usuario y un indicador de "escribiendo"
    state = [
      ...state,
      ChatMessageModel(text: message, author: ChatMessageAuthor.user),
    ];
    state = [
      ...state,
      ChatMessageModel(text: '...', author: ChatMessageAuthor.bot),
    ];
    updateState();

    try {
      // --- LÓGICA DE HISTORIAL AÑADIDA ---
      // 1. Construye el historial a partir de los mensajes anteriores en el estado.
      final conversationHistory = state.sublist(0, state.length - 2).map((msg) {
        return Content(
          parts: [Parts(text: msg.text)],
          // Asigna el rol correcto a cada mensaje del historial
          role: msg.author == ChatMessageAuthor.user ? 'user' : 'model',
        );
      }).toList();
      // ------------------------------------

      final financialContext = _ref.read(financialContextProvider);
      final systemPrompt =
          """
      Actúa como un asistente financiero amigable y juvenil.
      Usa un tono casual y cercano, como si estuvieras hablando con un amigo.
      intenta dar respuestas utiles basadas en el contexto financiero del usuario, manteniendolas breves y claras. no des respuestas demasiado largas. 
      Piensa que mas largo que un tweet ya es bastante largo.
      responde mas detalladamente si el usuario te pregunta por mas detalles o que le expliques algo.
      RESPONDE EN ESPAÑOL.
      Si no sabes la respuesta, sé honesto y di que no lo sabes.

      --- CONTEXTO FINANCIERO DEL USUARIO ---
      $financialContext
      -------------------------------------
      """;

      // 2. Combina el prompt del sistema con la pregunta actual del usuario
      final userQuestion = "$systemPrompt\nPREGUNTA DEL USUARIO:\n\"$message\"";

      // 3. Envía el historial y el nuevo mensaje a la API
      final response = await _gemini.chat([
        ...conversationHistory, // Envía todos los mensajes anteriores
        Content(
          parts: [Parts(text: userQuestion)],
          role: 'user',
        ), // Envía la nueva pregunta con contexto
      ], modelName: 'models/gemini-2.5-flash-lite');

      final botResponse =
          response?.output ?? 'Lo siento, no pude procesar eso.';
      state.last = ChatMessageModel(
        text: botResponse,
        author: ChatMessageAuthor.bot,
      );
    } catch (e) {
      print('Error de Gemini: $e');
      state.last = ChatMessageModel(
        text: 'Error de conexión con el asistente.',
        author: ChatMessageAuthor.bot,
      );
    } finally {
      updateState();
    }
  }

  void updateState() {
    state = List.from(state);
  }
}

final chatbotProvider =
    StateNotifierProvider<ChatbotNotifier, List<ChatMessageModel>>((ref) {
      return ChatbotNotifier(Gemini.instance, ref);
    });
