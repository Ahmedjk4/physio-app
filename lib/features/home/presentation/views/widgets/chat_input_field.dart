import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatInputField extends StatefulWidget {
  final String userEmail;
  final ScrollController scrollController;
  const ChatInputField({
    super.key,
    required this.userEmail,
    required this.scrollController,
  });

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();

  // FlutterSoundRecorder instance for audio recording.
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
  }

  Future<void> _initRecorder() async {
    // Request microphone permission using permission_handler.
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Microphone permission is required")),
      );
      return;
    }
    await _recorder.openRecorder();
    // Optionally set audio focus and other configurations here.
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _controller.dispose();
    super.dispose();
  }

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

        String uniqueFileName =
            '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';

        // Upload image file to Supabase Storage.
        final storageClient = Supabase.instance.client.storage;
        await storageClient.from('uploads').upload(
              'public/$uniqueFileName.png',
              file,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        // Dismiss loading dialog if still mounted.
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );

        // Update Firestore with the image message.
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.userEmail)
            .update({
          'lastMessageTimeStamp': DateTime.now(),
          'messages': FieldValue.arrayUnion([
            {
              'message': _controller.text,
              'link': storageClient
                  .from('uploads')
                  .getPublicUrl('public/$uniqueFileName.png'),
              'emailOfSender': FirebaseAuth.instance.currentUser?.email ?? '',
              'type': 'image',
              'timestamp': DateTime.now(),
            }
          ])
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No file selected')),
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  /// Toggle recording audio: start recording if not recording, otherwise stop and upload.
  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      try {
        // Obtain a writable directory.
        Directory appDocDir = await getApplicationDocumentsDirectory();
        // Build a unique file path.
        String filePath =
            '${appDocDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

        // Start recording to the specified file path.
        await _recorder.startRecorder(
          codec: Codec.aacMP4,
          toFile: filePath,
        );
        setState(() {
          _isRecording = true;
          _recordedFilePath = filePath;
        });
      } catch (e) {
        debugPrint("Error starting recorder: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error starting recorder: $e")),
        );
      }
    } else {
      try {
        // Stop recording. Since we provided a file path, the recorder returns that same path.
        String? filePath = await _recorder.stopRecorder();
        setState(() {
          _isRecording = false;
          _recordedFilePath = filePath;
        });
        debugPrint("Recording stopped: $filePath");

        if (filePath == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Recording failed")),
          );
          return;
        }

        File audioFile = File(filePath);
        if (!await audioFile.exists()) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Audio file not found")),
          );
          return;
        }

        // Show loading dialog while uploading audio.
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }

        // Create a unique file name for the audio.
        String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
        final storageClient = Supabase.instance.client.storage;

        final uploadResponse = await storageClient.from('audios').upload(
              'public/$uniqueFileName',
              audioFile,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        // Dismiss loading dialog.
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Check for errors in the upload response.
        if (uploadResponse != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Audio Uploaded Successfully")),
          );
        }

        // Retrieve public URL for the uploaded audio.
        final publicUrl =
            storageClient.from('audios').getPublicUrl('public/$uniqueFileName');

        // Update Firestore with the audio message.
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.userEmail)
            .update({
          'lastMessageTimeStamp': DateTime.now(),
          'messages': FieldValue.arrayUnion([
            {
              'message': '', // Optional empty text field for audio messages
              'link': publicUrl,
              'emailOfSender': FirebaseAuth.instance.currentUser?.email ?? '',
              'type': 'audio',
              'timestamp': DateTime.now(),
            }
          ])
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Audio message uploaded successfully")),
        );
      } catch (e) {
        debugPrint("Error stopping recorder or uploading audio: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  /// Shows attachment options (currently only image is provided).
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
          // Toggle button for recording audio.
          IconButton(
            icon: Icon(
              _isRecording ? Icons.stop : Icons.mic,
              color: Colors.black54,
            ),
            onPressed: _toggleRecording,
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
