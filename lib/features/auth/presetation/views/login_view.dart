import 'package:flutter/material.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/features/auth/presetation/views/widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      body: LoginViewBody(),
    );
  }
}
