import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/utils/service_locator.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo_impl.dart';
import 'package:physio_app/features/body_part_selector/data/models/body_parts_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileViewBody(),
    );
  }
}

class ProfileViewBody extends StatelessWidget {
  const ProfileViewBody({super.key});

  Future<void> _resetBodyParts() async {
    final box = await Hive.openBox<BodyPartsHiveWrapper>('bodyPartsBox');
    await box.clear();
  }

  Future<void> _resetOnboarding() async {
    final settingsBox = Hive.box('settings');
    await settingsBox.put('finishedOnboarding', false);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              await _resetBodyParts();
              showSnackBar(context, 'Body parts reset successfully');
            },
            child: const Text('Reset Body Parts'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await _resetOnboarding();
              showSnackBar(context, 'Onboarding reset successfully');
            },
            child: const Text('Reset Onboarding'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => getIt<AuthRepoImpl>().signOut(),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
