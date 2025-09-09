enum ChatMessageAuthor { user, bot }

class ChatMessageModel {
  final String text;

  final ChatMessageAuthor author;

  ChatMessageModel({required this.text, required this.author});
}
