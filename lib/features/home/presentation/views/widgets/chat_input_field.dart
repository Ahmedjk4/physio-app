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

// update
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
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _isRecording = false;
  String? _recordedFilePath;

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _controller.addListener(() {
      setState(() {}); // Update UI when text changes
    });
  }

  Future<void> _initRecorder() async {
    try {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission is required")),
        );
        return;
      }
      await _recorder.openRecorder();
    } catch (e) {
      debugPrint("Error requesting microphone permission: $e");
    }
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
        final storageClient = Supabase.instance.client.storage;
        await storageClient.from('uploads').upload(
              'public/$uniqueFileName.png',
              file,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.userEmail)
            .set({
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
        }, SetOptions(merge: true));
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

  Future<void> _toggleRecording() async {
    if (!_isRecording) {
      try {
        // Obtain a writable directory.
        Directory appDocDir = await getApplicationDocumentsDirectory();
        // Build a unique file path.
        String filePath =
            '${appDocDir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
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
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
        }
        String uniqueFileName = '${DateTime.now().millisecondsSinceEpoch}.m4a';
        final storageClient = Supabase.instance.client.storage;
        await storageClient.from('audios').upload(
              'public/$uniqueFileName',
              audioFile,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Audio Uploaded Successfully")),
        );

        final publicUrl =
            storageClient.from('audios').getPublicUrl('public/$uniqueFileName');
        await FirebaseFirestore.instance
            .collection('rooms')
            .doc(widget.userEmail)
            .set({
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
        }, SetOptions(merge: true));

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

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Color(0xFF0f3460),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'إرفاق ملف',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOption(
                    icon: Icons.image,
                    label: 'صورة',
                    color: const Color(0xFF83332e),
                    onPressed: () async {
                      Navigator.pop(context);
                      await _uploadImage();
                    },
                  ),
                  _buildOption(
                    icon: Icons.camera_alt,
                    label: 'كاميرا',
                    color: const Color(0xFFb11ccf),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Camera feature coming soon'),
                        ),
                      );
                    },
                  ),
                  _buildOption(
                    icon: Icons.insert_drive_file,
                    label: 'ملف',
                    color: const Color(0xFF1a73e8),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File picker coming soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;
    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.userEmail)
        .set({
      'lastMessageTimeStamp': DateTime.now(),
      'messages': FieldValue.arrayUnion([
        {
          'message': _controller.text,
          'emailOfSender': FirebaseAuth.instance.currentUser?.email ?? '',
          'type': 'text',
          'timestamp': DateTime.now(),
        }
      ])
    }, SetOptions(merge: true));
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0f3460),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black26,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a1a2e),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white12,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  style: TextStyles.bodyText1.copyWith(color: Colors.white),
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: "اكتب رسالة...",
                    border: InputBorder.none,
                    hintStyle: TextStyles.bodyText1.copyWith(
                      color: Colors.white38,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Recording indicator
            if (_isRecording)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fiber_manual_record,
                  color: Colors.red,
                  size: 12,
                ),
              ),
            // Toggle button for recording audio
            Material(
              color: _isRecording
                  ? Colors.red.withOpacity(0.2)
                  : Colors.transparent,
              shape: const CircleBorder(),
              child: IconButton(
                icon: Icon(
                  _isRecording ? Icons.stop_circle : Icons.mic,
                  color: _isRecording ? Colors.red : Colors.white70,
                  size: 26,
                ),
                onPressed: _toggleRecording,
                tooltip: _isRecording ? 'إيقاف التسجيل' : 'تسجيل صوتي',
              ),
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: IconButton(
                icon: const Icon(
                  Icons.attach_file,
                  color: Colors.white70,
                  size: 24,
                ),
                onPressed: _showAttachmentOptions,
                tooltip: 'إرفاق ملف',
              ),
            ),
            Material(
              color: _controller.text.isEmpty
                  ? Colors.transparent
                  : const Color(0xFF83332e),
              shape: const CircleBorder(),
              child: IconButton(
                icon: Icon(
                  Icons.send_rounded,
                  color:
                      _controller.text.isEmpty ? Colors.white38 : Colors.white,
                  size: 24,
                ),
                onPressed: _controller.text.isEmpty ? null : _sendMessage,
                tooltip: 'إرسال',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
