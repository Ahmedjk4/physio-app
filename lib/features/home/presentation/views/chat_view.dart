import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio_app/core/utils/colors.dart';
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
  bool hasAnsweredQuestions = false;

  @override
  void initState() {
    super.initState();
    currentUserEmail =
        widget.email ?? FirebaseAuth.instance.currentUser?.email ?? '';
    _checkIfQuestionsAnswered();
  }

  final ScrollController scrollController = ScrollController();
  bool _hasScrolled = false;

  Future<void> _checkIfQuestionsAnswered() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .get();
    setState(() {
      hasAnsweredQuestions = snapshot.data()?['hasAnsweredQuestions'] ?? false;
    });
  }

  Future<Widget> _selectBodyBasedOnRole() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .get();
    final role = snapshot.data()?['role'] as String?;
    if (role == 'admin') {
      return ChatAdminView();
    } else {
      return ChatViewBody(
        currentUserEmail: currentUserEmail,
        scrollController: scrollController,
        hasAnsweredQuestions: hasAnsweredQuestions,
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
        backgroundColor: AppColors.secondaryColor,
      ),
      body: FutureBuilder<Widget>(
        future: _selectBodyBasedOnRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
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
