import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/widgets/custom_button.dart';

class ChangeNameView extends StatefulWidget {
  const ChangeNameView({super.key});

  @override
  State<ChangeNameView> createState() => _ChangeNameViewState();
}

class _ChangeNameViewState extends State<ChangeNameView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseAuth.instance.currentUser
          ?.updateDisplayName(_nameController.text);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(
            FirebaseAuth.instance.currentUser?.email,
          )
          .update({
        'name': _nameController.text,
      });
      if (context.mounted) {
        showSnackBar(context, 'Name changed to: ${_nameController.text}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Change Name'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'New Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomButton(text: 'Submit', callback: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
