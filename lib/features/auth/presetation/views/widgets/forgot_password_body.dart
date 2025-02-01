import 'package:flutter/material.dart';
import 'package:physio_app/core/types/text_form_field_types.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/service_locator.dart';
import 'package:physio_app/core/widgets/custom_button.dart';
import 'package:physio_app/core/widgets/custom_text_form_field.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo_impl.dart';

class ForgotPasswordBody extends StatefulWidget {
  const ForgotPasswordBody({super.key});

  @override
  State<ForgotPasswordBody> createState() => _ForgotPasswordBodyState();
}

class _ForgotPasswordBodyState extends State<ForgotPasswordBody> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      getIt.get<AuthRepoImpl>().resetPassword(_emailController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Password reset link sent to ${_emailController.text}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        iconTheme: IconThemeData(color: AppColors.textColorPrimary),
        title: Text('Forgot Password',
            style: TextStyle(color: AppColors.textColorPrimary)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Enter your email to reset your password',
                style:
                    TextStyle(fontSize: 16, color: AppColors.textColorPrimary),
              ),
              SizedBox(height: 16),
              CustomTextField(
                hintText: 'Email',
                label: 'Email',
                controller: _emailController,
                type: TextFormFieldTypes.email,
                icon: Icons.email,
                iconColor: Colors.amber,
              ),
              SizedBox(height: 16),
              SizedBox(
                  height: 50,
                  child: CustomButton(
                      text: "Reset Password", callback: _resetPassword)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
