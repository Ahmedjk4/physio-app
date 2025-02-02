import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatInputField extends StatefulWidget {
  final String userEmail;
  const ChatInputField(
      {super.key, required this.userEmail, required this.scrollController});
  final ScrollController scrollController;
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
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) =>
                const Center(child: CircularProgressIndicator()),
          );
        }

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
          'lastMessageTimeStamp': DateTime.now(),
          'messages': FieldValue.arrayUnion([
            {
              "message": _controller.text,
              "link": storageClient
                  .from('uploads')
                  .getPublicUrl('public/$uniqueFileName.png'),
              'emailOfSender': FirebaseAuth.instance.currentUser?.email ?? '',
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
          icon: Icon(icon, size: 30, color: Colors.white),
          onPressed: onPressed,
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.userEmail)
        .update({
      'lastMessageTimeStamp': DateTime.now(),
      'messages': FieldValue.arrayUnion([
        {
          'message': _controller.text,
          'emailOfSender': FirebaseAuth.instance.currentUser?.email ?? '',
          'type': 'text',
          // Add a unique timestamp field so messages are not considered duplicates
          'timestamp': DateTime.now(),
        }
      ])
    });
    _controller.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.scrollController.hasClients) {
        widget.scrollController.animateTo(
          widget.scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
            icon: const Icon(Icons.send, color: Colors.black54),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
