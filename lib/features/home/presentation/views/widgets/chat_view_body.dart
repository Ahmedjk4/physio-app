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

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({
    Key? key,
    required this.currentUserEmail,
    this.scrollController,
  }) : super(key: key);

  final String currentUserEmail;
  final ScrollController? scrollController;

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  // Cache for audio duration futures: key is audio URL.
  final Map<String, Future<Duration?>> _audioDurationCache = {};

  Future<Duration?> _getCachedAudioDuration(String url) {
    return _audioDurationCache.putIfAbsent(url, () => getAudioDuration(url));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(widget.currentUserEmail),
      child: Stack(
        children: [
          // Background Lottie Animation
          Center(child: Lottie.asset(Assets.assetsLottieSplash)),
          // Chat messages and input field
          Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatLoaded) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (widget.scrollController!.hasClients) {
                          widget.scrollController!.animateTo(
                            widget.scrollController!.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                      final messages = state.messages;
                      return ListView.builder(
                        controller: widget.scrollController,
                        padding: const EdgeInsets.all(10),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          // For text messages
                          if (message['type'] == 'text') {
                            return ChatBubble(
                              text: message['message'],
                              isSentByMe: message['emailOfSender'] ==
                                  widget.currentUserEmail,
                            );
                          }
                          // For audio messages
                          else if (message['type'] == 'audio') {
                            return Row(
                              mainAxisAlignment: message['emailOfSender'] ==
                                      widget.currentUserEmail
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                FutureBuilder<Duration?>(
                                  future:
                                      _getCachedAudioDuration(message['link']),
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
                          }
                          // For image messages (using CachedNetworkImage)
                          else {
                            return Row(
                              mainAxisAlignment: message['emailOfSender'] ==
                                      widget.currentUserEmail
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
                                              image: CachedNetworkImageProvider(
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
                                    child: CachedNetworkImage(
                                      imageUrl: message['link'],
                                      fit: BoxFit.fill,
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      );
                    }
                    // Loading state
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ),
              ChatInputField(
                userEmail: widget.currentUserEmail,
                scrollController: widget.scrollController ?? ScrollController(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
