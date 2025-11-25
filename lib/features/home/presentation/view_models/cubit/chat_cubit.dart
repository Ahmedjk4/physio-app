import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final String email;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final StreamSubscription<DocumentSnapshot> _subscription;

  ChatCubit(this.email) : super(ChatLoading()) {
    _initializeChat();
  }

  void _initializeChat() {
    _subscription = firestore.collection('rooms').doc(email).snapshots().listen(
      (event) {
        if (!isClosed) {
          try {
            if (!event.exists) {
              emit(ChatLoaded(messages: []));
              return;
            }
            final data = event.data();
            if (data == null) {
              emit(ChatLoaded(messages: []));
              return;
            }
            final messages = data['messages'] as List<dynamic>? ?? [];
            emit(ChatLoaded(messages: messages));
          } catch (e) {
            if (!isClosed) {
              emit(ChatError(message: 'Failed to load messages'));
            }
          }
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(ChatError(
              message: 'Connection error. Please check your internet.'));
        }
      },
    );

    // Add timeout for initial load
    Future.delayed(const Duration(seconds: 10), () {
      if (!isClosed && state is ChatLoading) {
        emit(ChatError(
            message: 'Loading timeout. Please check your connection.'));
      }
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
