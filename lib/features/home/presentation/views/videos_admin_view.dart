import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/widgets/custom_button.dart';

class VideosAdminView extends StatefulWidget {
  const VideosAdminView({super.key});

  @override
  State<VideosAdminView> createState() => _VideosAdminViewState();
}

class _VideosAdminViewState extends State<VideosAdminView> {
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  bool isAdding = false;
  String? _category;
  List<String> bodyParts = [
    'head',
    'neck',
    'leftShoulder',
    'leftUpperArm',
    'leftElbow',
    'leftLowerArm',
    'leftHand',
    'rightShoulder',
    'rightUpperArm',
    'rightElbow',
    'rightLowerArm',
    'rightHand',
    'upperBody',
    'lowerBody',
    'leftUpperLeg',
    'leftKnee',
    'leftLowerLeg',
    'leftFoot',
    'rightUpperLeg',
    'rightKnee',
    'rightLowerLeg',
    'rightFoot',
    'abdomen',
    'vestibular',
  ];

  Future<void> _addVideo() async {
    final String link = _linkController.text.trim();

    if (link.isEmpty || _category == null || _category!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Both fields are required.")),
      );
      return;
    }

    setState(() {
      isAdding = true;
    });

    try {
      // Save to the "videos" collection.
      await FirebaseFirestore.instance.collection('videos').add({
        'link': link,
        'category': _category,
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Video added successfully!")));
      _linkController.clear();
      _categoryController.clear();
    } catch (e) {
      debugPrint("Error adding video: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Failed to add video.")));
    } finally {
      setState(() {
        isAdding = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Video")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              style: TextStyle(color: Colors.white),
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: "YouTube Video Link",
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              iconEnabledColor: AppColors.textColorPrimary,
              value: _category,
              hint: Text(
                'Category',
                style: TextStyle(color: AppColors.textColorPrimary),
              ),
              onChanged: (String? newValue) {
                setState(() {
                  _category = newValue;
                });
              },
              items: bodyParts.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: AppColors.textColorPrimary),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            isAdding
                ? const CircularProgressIndicator()
                : CustomButton(text: 'Add Video', callback: _addVideo)
          ],
        ),
      ),
    );
  }
}
