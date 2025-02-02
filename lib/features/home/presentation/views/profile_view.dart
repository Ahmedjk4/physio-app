import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colorize_text_avatar/colorize_text_avatar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/service_locator.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/core/widgets/custom_button.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo_impl.dart';
import 'package:physio_app/features/body_part_selector/data/models/body_parts_model.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white12,
      body: const ProfileViewBody(),
    );
  }
}

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  late final Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    // Start the one-time fetch of the user's data (name and role).
    _userDataFuture = _fetchUserData();
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    // Get the current user email.
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    // Fetch the user document from Firestore.
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail)
        .get();
    print(doc);
    final data = doc.data();
    final name = data?['name'] as String? ?? 'No Name';
    final role = data?['role'] as String? ?? 'user';
    return {'name': name, 'role': role};
  }

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
    // Random color generator
    Color getRandomColor() {
      final Random random = Random();
      return Color.fromARGB(
        255, // Fully opaque color
        random.nextInt(256), // Red
        random.nextInt(256), // Green
        random.nextInt(256), // Blue
      );
    }

    return Center(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const CircularProgressIndicator();
          }

          final userData = snapshot.data!;
          final userName = userData['name'] as String;
          final role = userData['role'] as String;
          // Decide what to display based on role
          final displayRole =
              (role.toLowerCase() == 'admin') ? 'Doctor' : 'User';

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              // Display the user's name in a circular avatar with a random background color.
              TextAvatar(
                fontSize: 28,
                size: 64,
                text: userName,
                backgroundColor: getRandomColor(),
              ),
              const SizedBox(height: 10),
              // Display the user's name.
              Text(
                userName,
                style: TextStyles.headline1
                    .copyWith(color: AppColors.textColorPrimary),
              ),
              const SizedBox(height: 5),
              // Display the role as "Doctor" for admin or "User" otherwise.
              Text(
                displayRole,
                style: TextStyles.headline2
                    .copyWith(color: AppColors.textColorSecondary),
              ),
              const SizedBox(height: 20),
              CustomButton(
                  text: 'Change Name',
                  callback: () {
                    context.push(AppRouter.nameChangePage);
                  }),
              const SizedBox(height: 20),
              CustomButton(
                  text: 'Change Password',
                  callback: () {
                    context.push(AppRouter.passwordChangePage);
                  }),
              Spacer(),
              CustomButton(
                text: 'Logout',
                callback: () {
                  getIt.get<AuthRepoImpl>().signOut();
                },
                color: Colors.red,
              ),
              SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
