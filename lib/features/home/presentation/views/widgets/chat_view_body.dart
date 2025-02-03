import 'package:cached_network_image/cached_network_image.dart';
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

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({
    super.key,
    required this.currentUserEmail,
    this.scrollController,
  });

  final String currentUserEmail;
  final ScrollController? scrollController;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(currentUserEmail),
      child: Stack(
        children: [
          // Background Lottie Animation
          Center(child: Lottie.asset(Assets.assetsLottieSplash)),
          // Chat messages and input field
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(10),
                  child: BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      if (state is ChatLoaded) {
                        final messages = state.messages;
                        return Column(
                          children: messages.map((message) {
                            if (message['type'] == 'text') {
                              return ChatBubble(
                                text: message['message'],
                                isSentByMe: message['emailOfSender'] ==
                                    currentUserEmail,
                              );
                            } else if (message['type'] == 'audio') {
                              return Row(
                                mainAxisAlignment:
                                    message['emailOfSender'] == currentUserEmail
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  FutureBuilder<Duration?>(
                                    future: getAudioDuration(message['link']),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const CircularProgressIndicator(); // Show a loading indicator
                                      } else if (snapshot.hasError) {
                                        return const Text(
                                            "Error loading audio duration");
                                      } else if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return const Text(
                                            "Failed to retrieve duration");
                                      }

                                      // Build VoiceMessageView with the retrieved duration
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: VoiceMessageView(
                                          controller: VoiceController(
                                            audioSrc: message['link'],
                                            maxDuration: snapshot.data!,
                                            isFile: false,
                                            onComplete: () {},
                                            onPause: () {},
                                            onPlaying: () {},
                                            onError: (err) {},
                                          ),
                                          innerPadding: 12,
                                          cornerRadius: 20,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            } else {
                              return Row(
                                mainAxisAlignment:
                                    message['emailOfSender'] == currentUserEmail
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Container(
                                            width: double.infinity,
                                            height: double.infinity,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                        message['link']),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      height: 128.h,
                                      width: 128.w,
                                      child: Image.network(
                                        message['link'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }).toList(),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ),
              ChatInputField(
                userEmail: currentUserEmail,
                scrollController: scrollController ?? ScrollController(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
