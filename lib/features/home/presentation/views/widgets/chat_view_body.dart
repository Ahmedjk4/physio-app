import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:physio_app/core/helpers/getAudioDuration.dart';
import 'package:physio_app/core/utils/assets.dart';
import 'package:physio_app/features/home/presentation/view_models/cubit/chat_cubit.dart';
import 'package:physio_app/features/home/presentation/views/widgets/chat_bubble.dart';
import 'package:physio_app/features/home/presentation/views/widgets/chat_input_field.dart';
import 'package:voice_message_package/voice_message_package.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({
    Key? key,
    required this.currentUserEmail,
    this.scrollController,
    required this.hasAnsweredQuestions,
  }) : super(key: key);
  final String currentUserEmail;
  final ScrollController? scrollController;
  final bool hasAnsweredQuestions;
  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  final Map<String, Future<Duration?>> _audioDurationCache = {};
  bool hasAnsweredQuestions = false;
  Map<String, String> userAnswers = {};

  @override
  void initState() {
    super.initState();
    _checkIfUserAnswered();
  }

  Future<void> _checkIfUserAnswered() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserEmail)
        .get();
    if (doc.exists && doc.data()?['hasAnsweredQuestions'] == true) {
      setState(() {
        hasAnsweredQuestions = true;
      });
    } else {
      _askUserQuestions();
    }
  }

  void _askUserQuestions() async {
    final answers = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) {
        final TextEditingController nameController = TextEditingController();
        final TextEditingController ageController = TextEditingController();
        final TextEditingController heightController = TextEditingController();
        final TextEditingController weightController = TextEditingController();
        final TextEditingController medsController = TextEditingController();
        final TextEditingController diseasesController =
            TextEditingController();
        final TextEditingController surgeriesController =
            TextEditingController();
        final TextEditingController jobController = TextEditingController();

        bool isMarried = false;
        bool isSmoker = false;
        bool doesExercise = false;

        return AlertDialog(
          title: const Text("الرجاء إدخال بياناتك"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: "الاسم")),
                TextField(
                    controller: ageController,
                    decoration: const InputDecoration(labelText: "السن")),
                TextField(
                    controller: heightController,
                    decoration: const InputDecoration(labelText: "الطول")),
                TextField(
                    controller: weightController,
                    decoration: const InputDecoration(labelText: "الوزن")),
                TextField(
                    controller: medsController,
                    decoration: const InputDecoration(labelText: "الأدوية")),
                TextField(
                    controller: diseasesController,
                    decoration: const InputDecoration(labelText: "الأمراض")),
                TextField(
                    controller: surgeriesController,
                    decoration:
                        const InputDecoration(labelText: "العمليات الجراحية")),
                TextField(
                    controller: jobController,
                    decoration: const InputDecoration(labelText: "الوظيفة")),
                SwitchListTile(
                    value: isMarried,
                    onChanged: (val) => isMarried = val,
                    title: const Text("متزوج؟")),
                SwitchListTile(
                    value: isSmoker,
                    onChanged: (val) => isSmoker = val,
                    title: const Text("مدخن؟")),
                SwitchListTile(
                    value: doesExercise,
                    onChanged: (val) => doesExercise = val,
                    title: const Text("تمارس الرياضة؟")),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, {
                  'الاسم': nameController.text,
                  'السن': ageController.text,
                  'الطول': heightController.text,
                  'الوزن': weightController.text,
                  'الأدوية': medsController.text,
                  'الأمراض': diseasesController.text,
                  'العمليات الجراحية': surgeriesController.text,
                  'الوظيفة': jobController.text,
                  'متزوج': isMarried ? "نعم" : "لا",
                  'مدخن': isSmoker ? "نعم" : "لا",
                  'يمارس الرياضة': doesExercise ? "نعم" : "لا",
                });
              },
              child: const Text("حفظ"),
            ),
          ],
        );
      },
    );

    if (answers != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserEmail)
          .set(
        {
          ...answers,
          'hasAnsweredQuestions': true,
        },
        SetOptions(merge: true),
      );
      setState(() {
        hasAnsweredQuestions = true;
      });
    }
  }

  Future<Duration?> _getCachedAudioDuration(String url) {
    return _audioDurationCache.putIfAbsent(url, () => getAudioDuration(url));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(widget.currentUserEmail),
      child: Column(
        children: [
          Expanded(
            child: ChatInputField(
              userEmail: widget.currentUserEmail,
              scrollController: widget.scrollController ?? ScrollController(),
            ),
          ),
        ],
      ),
    );
  }
}
