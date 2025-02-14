import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:physio_app/features/auth/presetation/views/login_view.dart';
import 'package:physio_app/features/body_part_selector/data/models/body_parts_model.dart';
import 'package:physio_app/features/body_part_selector/presentation/views/body_part_selector_view.dart';
import 'package:physio_app/features/home/presentation/views/page_view.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  Future<bool> _hasSelectedBodyParts() async {
    final box = await Hive.openBox<BodyPartsHiveWrapper>('bodyPartsBox');
    final storedWrapper = box.get('selectedParts');
    return storedWrapper?.selectedBodyParts.containsValue(true) ?? false;
  }

  Widget _authStateHandler(AsyncSnapshot snapshot) {
    if (snapshot.hasData) {
      return FutureBuilder<bool>(
        future: _hasSelectedBodyParts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return snapshot.data == true
                ? const SelectorPageView()
                : const BodyPartSelectorView();
          }
        },
      );
    } else {
      return const LoginView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return _authStateHandler(snapshot);
      },
    );
  }
}
