import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe
              ? const Color.fromARGB(255, 131, 51, 46)
              : const Color.fromARGB(255, 177, 28, 207),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
