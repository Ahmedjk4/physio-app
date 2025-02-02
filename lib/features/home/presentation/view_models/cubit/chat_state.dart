part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoaded extends ChatState {
  final List<dynamic> messages;

  ChatLoaded({
    required this.messages,
  });
}
