import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/core/types/text_form_field_types.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/core/widgets/custom_button.dart';
import 'package:physio_app/core/widgets/custom_text_form_field.dart';

class LoginViewBody extends StatelessWidget {
  const LoginViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(height: 50.0.h),
            const _Header(),
            SizedBox(height: 100.0.h),
            const _Logo(),
            SizedBox(height: 100.0.h),
            const _SocialButtons(),
            SizedBox(height: 20.0.h),
            const _DividerWithText(),
            SizedBox(height: 20.0.h),
            const _LoginForm(),
            SizedBox(height: 20.0.h),
            CustomButton(
              text: 'Continue',
              callback: () {
                context.push(AppRouter.bodyPartSelector);
              },
            ),
            SizedBox(height: 20.0.h),
            RegisterText(),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            FontAwesomeIcons.arrowLeft,
            color: AppColors.textColorPrimary,
          ),
        ),
        SizedBox(width: 20.0.w),
        Text(
          "Login",
          style: TextStyles.headline2.copyWith(
            color: AppColors.textColorPrimary,
          ),
        ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Logo',
      child: DefaultTextStyle(
        style: TextStyles.headline1
            .copyWith(color: AppColors.secondaryColor, fontFamily: 'DynaPuff'),
        child: Text(
          'Physio',
        ),
      ),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          color: AppColors.accentColor,
          icon: FontAwesomeIcons.google,
          onPressed: () {},
        ),
        SizedBox(width: 20.0.w),
        _buildSocialButton(
          color: AppColors.accentColor,
          icon: FontAwesomeIcons.facebookF,
          onPressed: () {},
        ),
        SizedBox(width: 20.0.w),
        _buildSocialButton(
          color: AppColors.accentColor,
          icon: FontAwesomeIcons.xTwitter,
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ClipOval(
      child: SizedBox(
        height: 50.0.h,
        width: 50.0.w,
        child: MaterialButton(
          onPressed: onPressed,
          color: color,
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }
}

class _DividerWithText extends StatelessWidget {
  const _DividerWithText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: AppColors.textColorPrimary)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            "Or Using Email",
            style: TextStyles.bodyText1.copyWith(
              color: AppColors.textColorPrimary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.textColorPrimary)),
      ],
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Column(
      children: [
        CustomTextField(
          hintText: 'Enter Your Email',
          label: 'Email',
          controller: emailController,
          type: TextFormFieldTypes.email,
          icon: Icons.mail,
          iconColor: Colors.amber,
        ),
        SizedBox(height: 10.0.h),
        CustomTextField(
          hintText: 'Enter Your Password',
          label: 'Password',
          controller: passwordController,
          type: TextFormFieldTypes.password,
          icon: Icons.lock,
          iconColor: Colors.purple,
        ),
      ],
    );
  }
}

class RegisterText extends StatelessWidget {
  const RegisterText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account?',
          style:
              TextStyles.bodyText1.copyWith(color: AppColors.textColorPrimary),
        ),
        TextButton(
          onPressed: () {
            context.push(AppRouter.register);
          },
          child: Text(
            'Register',
            style: TextStyles.bodyText1.copyWith(
              color: AppColors.accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
