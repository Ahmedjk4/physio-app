import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatAdminView extends StatelessWidget {
  const ChatAdminView({super.key});

  Future<bool> _hasNewMessages(
      String roomId, Timestamp lastMessageTimeStamp) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenKey = 'last_seen_$roomId';
    final lastSeenTimestamp = prefs.getInt(lastSeenKey) ?? 0;

    final lastMessageTime = lastMessageTimeStamp.millisecondsSinceEpoch;

    // Return true if there's a new message
    return lastMessageTime > lastSeenTimestamp;
  }

  Future<void> _updateLastSeen(String roomId) async {
    final prefs = await SharedPreferences.getInstance();
    final lastSeenKey = 'last_seen_$roomId';
    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;

    await prefs.setInt(lastSeenKey, currentTimestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Rooms'),
        backgroundColor: Colors.blueGrey,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('rooms').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No chat rooms available'));
          }
          final rooms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final roomId = room.id;
              final lastMessageTimeStamp =
                  room['lastMessageTimeStamp'] as Timestamp;

              return FutureBuilder<bool>(
                future: _hasNewMessages(roomId, lastMessageTimeStamp),
                builder: (context, snapshot) {
                  final hasNewMessages = snapshot.data ?? false;

                  return ListTile(
                    tileColor: Colors.black26,
                    title: Text(roomId),
                    trailing: hasNewMessages
                        ? const Icon(Icons.notifications, color: Colors.green)
                        : null,
                    onTap: () async {
                      await _updateLastSeen(roomId);
                      if (context.mounted) {
                        context.push(AppRouter.chatPage, extra: roomId);
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
