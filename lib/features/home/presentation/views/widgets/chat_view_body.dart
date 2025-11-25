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
  int _previousMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _checkIfUserAnswered();
  }

  void _scrollToBottom() {
    if (widget.scrollController != null &&
        widget.scrollController!.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.scrollController!.hasClients) {
          widget.scrollController!.animateTo(
            widget.scrollController!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _checkIfUserAnswered() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserEmail)
        .get();

    final role = doc.data()?['role']?.toString().toLowerCase();
    if (role == 'admin') {
      return;
    }
    if (doc.exists && doc.data()?['hasAnsweredQuestions'] == true && mounted) {
      setState(() {
        hasAnsweredQuestions = true;
      });
    } else {
      if (role != 'admin') _askUserQuestions();
    }
  }

  void _askUserQuestions() async {
    if (!mounted) return;

    // Check user role first; if admin, don't show the modal sheet
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUserEmail)
        .get();

    final role = userDoc.data()?['role']?.toString().toLowerCase();
    if (role == 'admin') {
      return;
    }

    final answers = await (mounted
        ? showDialog<Map<String, String>>(
            context: context,
            builder: (context) {
              final TextEditingController nameController =
                  TextEditingController();
              final TextEditingController ageController =
                  TextEditingController();
              final TextEditingController heightController =
                  TextEditingController();
              final TextEditingController weightController =
                  TextEditingController();
              final TextEditingController medsController =
                  TextEditingController();
              final TextEditingController diseasesController =
                  TextEditingController();
              final TextEditingController surgeriesController =
                  TextEditingController();
              final TextEditingController jobController =
                  TextEditingController();

              bool isMarried = false;
              bool isSmoker = false;
              bool doesExercise = false;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: const Text("الرجاء إدخال بياناتك"),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                              controller: nameController,
                              decoration:
                                  const InputDecoration(labelText: "الاسم")),
                          TextField(
                              controller: ageController,
                              decoration:
                                  const InputDecoration(labelText: "السن")),
                          TextField(
                              controller: heightController,
                              decoration:
                                  const InputDecoration(labelText: "الطول")),
                          TextField(
                              controller: weightController,
                              decoration:
                                  const InputDecoration(labelText: "الوزن")),
                          TextField(
                              controller: medsController,
                              decoration:
                                  const InputDecoration(labelText: "الأدوية")),
                          TextField(
                              controller: diseasesController,
                              decoration:
                                  const InputDecoration(labelText: "الأمراض")),
                          TextField(
                              controller: surgeriesController,
                              decoration: const InputDecoration(
                                  labelText: "العمليات الجراحية")),
                          TextField(
                              controller: jobController,
                              decoration:
                                  const InputDecoration(labelText: "الوظيفة")),
                          SwitchListTile(
                            value: isMarried,
                            onChanged: (val) => setState(() => isMarried = val),
                            title: const Text("متزوج؟"),
                          ),
                          SwitchListTile(
                            value: isSmoker,
                            onChanged: (val) => setState(() => isSmoker = val),
                            title: const Text("مدخن؟"),
                          ),
                          SwitchListTile(
                            value: doesExercise,
                            onChanged: (val) =>
                                setState(() => doesExercise = val),
                            title: const Text("تمارس الرياضة؟"),
                          ),
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
            },
          )
        : Future.value(null));

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
      if (mounted) {
        setState(() {
          hasAnsweredQuestions = true;
        });
      }
    }
  }

  Future<Duration?> _getCachedAudioDuration(String url) {
    return _audioDurationCache.putIfAbsent(url, () => getAudioDuration(url));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(widget.currentUserEmail),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a1a2e),
              const Color(0xFF16213e),
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: BlocConsumer<ChatCubit, ChatState>(
                listener: (context, state) {
                  if (state is ChatLoaded) {
                    // Auto-scroll when new messages arrive
                    if (state.messages.length > _previousMessageCount) {
                      _scrollToBottom();
                    }
                    _previousMessageCount = state.messages.length;
                  }
                },
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }

                  if (state is ChatError) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 80.w,
                              color: Colors.red.shade300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'حدث خطأ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Recreate the cubit to retry
                                setState(() {});
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF83332e),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    final messages = state.messages;

                    if (messages.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80.w,
                              color: Colors.white38,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'لا توجد رسائل بعد',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18.sp,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'ابدأ المحادثة الآن',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: widget.scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final type = message['type'] ?? 'text';
                        final isSentByMe =
                            message['emailOfSender'] == widget.currentUserEmail;

                        if (type == 'text') {
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: ChatBubble(
                              text: message['message'] ?? '',
                              isSentByMe: isSentByMe,
                            ),
                          );
                        } else if (type == 'image') {
                          return _buildImageMessage(
                            message['link'] ?? '',
                            isSentByMe,
                            message['message'] ?? '',
                          );
                        } else if (type == 'audio') {
                          return _buildAudioMessage(
                            message['link'] ?? '',
                            isSentByMe,
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            ChatInputField(
              userEmail: widget.currentUserEmail,
              scrollController: widget.scrollController ?? ScrollController(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String imageUrl, bool isSentByMe, String caption) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 250.w),
        child: Column(
          crossAxisAlignment:
              isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _showFullScreenImage(context, imageUrl);
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200.h,
                    color: Colors.white12,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200.h,
                    color: Colors.white12,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
            ),
            if (caption.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isSentByMe
                      ? const Color(0xFF83332e)
                      : const Color(0xFFb11ccf),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  caption,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAudioMessage(String audioUrl, bool isSentByMe) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 280.w),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSentByMe
                ? [
                    const Color(0xFF83332e),
                    const Color(0xFF9d3f38),
                  ]
                : [
                    const Color(0xFFb11ccf),
                    const Color(0xFFc931e5),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: FutureBuilder<Duration?>(
          future: _getCachedAudioDuration(audioUrl),
          builder: (context, snapshot) {
            // Use a default duration if fetching fails
            final duration = snapshot.data ?? const Duration(seconds: 60);

            return VoiceMessageView(
              backgroundColor: Colors.transparent,
              activeSliderColor: Colors.white,
              notActiveSliderColor: Colors.white54,
              playPauseButtonLoadingColor: Colors.white,
              circlesColor: Colors.black87,
              playPauseButtonDecoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              playIcon: const Icon(
                Icons.play_arrow,
                color: Colors.black87,
                size: 28,
              ),
              pauseIcon: const Icon(
                Icons.pause,
                color: Colors.black87,
                size: 28,
              ),
              controller: VoiceController(
                audioSrc: audioUrl,
                maxDuration: duration,
                isFile: false,
                onComplete: () {},
                onPause: () {},
                onPlaying: () {},
              ),
              innerPadding: 8.w,
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                  errorWidget: (context, url, error) => const Center(
                    child: Icon(
                      Icons.error_outline,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
