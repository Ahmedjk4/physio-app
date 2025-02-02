import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio_app/features/home/presentation/views/chat_admin_view.dart';
import 'widgets/chat_view_body.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, this.email});
  final String? email;
  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  late String currentUserEmail;

  @override
  void initState() {
    super.initState();
    currentUserEmail =
        widget.email ?? FirebaseAuth.instance.currentUser?.email ?? '';
  }

  final ScrollController scrollController = ScrollController();
  bool _hasScrolled = false; // Flag to run scrolling only once

  Future<Widget> _selectBodyBasedOnRole() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .get();
    final role = snapshot.data()?['role'] as String?;
    if (role == 'admin') {
      // Return a different widget for admin
      return ChatAdminView();
    } else {
      return ChatViewBody(
        currentUserEmail: currentUserEmail,
        scrollController: scrollController,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      appBar: AppBar(
        leading: Container(),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            SizedBox(width: 10.w),
            const Text("Dr Rana Kadry"),
            SizedBox(width: 30.w),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 166, 166, 184),
      ),
      body: FutureBuilder<Widget>(
        future: _selectBodyBasedOnRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // Schedule scroll to the bottom only once when the widget is first built
            if (!_hasScrolled) {
              _hasScrolled = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }
            return snapshot.data!;
          }
        },
      ),
    );
  }
}
