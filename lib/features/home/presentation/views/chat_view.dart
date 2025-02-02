import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/utils/assets.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: Stack(
        children: [
          // Background Lottie Animation
          Center(child: Lottie.asset(Assets.assetsLottieSplash)),
          // Chat messages and input field
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(currentUserEmail)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        final messages =
                            data?['messages'] as List<dynamic>? ?? [];
                        return Column(
                          spacing: 20,
                          children: messages.map((message) {
                            if (message['type'] == 'text') {
                              return ChatBubble(
                                text: message['message'],
                                isSentByMe: message['emailOfSender'] ==
                                    currentUserEmail,
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
              ChatInputField(userEmail: currentUserEmail),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSentByMe
              ? const Color.fromARGB(255, 131, 51, 46)
              : const Color.fromARGB(255, 177, 28, 207),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class ChatInputField extends StatefulWidget {
  final String userEmail;
  const ChatInputField({super.key, required this.userEmail});

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  /// Uploads an image from the gallery and shows a loading indicator during the process.
  Future<void> _uploadImage() async {
    try {
      FilePickerResult? result =
          await FilePicker.platform.pickFiles(type: FileType.image);

      if (result != null && result.files.single.path != null) {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        File file = File(result.files.single.path!);
        // Optionally check that the file exists
        if (!await file.exists()) {
          if (mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file does not exist.')),
          );
          return;
        }

        // Create a unique file name by prepending a timestamp
        String uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

        // Upload file to Firebase Storage

        // Get the download URL
        final storageClient = Supabase.instance.client.storage;
        await storageClient.from('uploads').upload(
              'public/$uniqueFileName.png',
              file,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        // Dismiss loading dialog if still mounted
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful!')),
        );

        // Optionally add the image URL as a message in Firestore
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.userEmail)
            .update({
          'messages': FieldValue.arrayUnion([
            {
              "message": _controller.text,
              "link": storageClient
                  .from('uploads')
                  .getPublicUrl('public/$uniqueFileName.png'),
              'emailOfSender': widget.userEmail,
              'type': 'image',
            }
          ])
        });
      } else {
        // User canceled file picking
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      // Dismiss loading dialog if it's still open
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          height: 200,
          child: GridView.count(
            crossAxisCount: 4,
            children: [
              _buildOption(
                icon: Icons.image,
                label: 'Gallery',
                onPressed: () async {
                  Navigator.pop(context); // Close bottom sheet
                  await _uploadImage();
                },
              ),
              _buildOption(
                icon: Icons.camera_alt,
                label: 'Camera',
                onPressed: () {
                  // TODO: Implement Camera functionality
                  Navigator.pop(context);
                },
              ),
              _buildOption(
                icon: Icons.insert_drive_file,
                label: 'Document',
                onPressed: () {
                  // TODO: Implement Document functionality
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 30, color: Colors.black54),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.userEmail)
        .update({
      'messages': FieldValue.arrayUnion([
        {
          'message': _controller.text.trim(),
          'emailOfSender': widget.userEmail,
          'type': 'text',
        }
      ])
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.shade300)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: TextStyles.bodyText1.copyWith(color: Colors.black54),
              decoration: InputDecoration(
                hintText: "Send Message",
                border: InputBorder.none,
                hintStyle: TextStyles.bodyText1.copyWith(color: Colors.black54),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.attach_file, color: Colors.black54),
            onPressed: _showAttachmentOptions,
          ),
          IconButton(
            icon: const Icon(Icons.voice_chat, color: Colors.black54),
            onPressed: () {
              // TODO: Implement voice messaging
            },
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.black54),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
