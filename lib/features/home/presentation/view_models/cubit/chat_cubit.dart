import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final String email;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final StreamSubscription<DocumentSnapshot> _subscription;

  ChatCubit(this.email) : super(ChatInitial()) {
    _subscription =
        firestore.collection('rooms').doc(email).snapshots().listen((event) {
      if (!event.exists) return;
      final data = event.data() as Map<String, dynamic>;
      final messages = data['messages'] as List<dynamic>? ?? [];
      if (!isClosed) {
        try {
          emit(ChatLoaded(messages: messages));
        } catch (e) {
          // In case an error occurs while emitting (e.g., after closing),
          // we catch it so it doesn't crash the app.
          // You can log the error if needed.
          // print('Emit failed: $e');
        }
      }
    });
  }

  @override
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
