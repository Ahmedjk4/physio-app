import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/types/text_form_field_types.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/service_locator.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/core/widgets/custom_button.dart';
import 'package:physio_app/core/widgets/custom_text_form_field.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo_impl.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
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
            // const _SocialButtons(),
            // SizedBox(height: 20.0.h),
            const _DividerWithText(),
            SizedBox(height: 20.0.h),
            _LoginForm(
              emailController,
              passwordController,
              _formKey,
              _autovalidateMode,
            ),
            ForgotPasswordText(),
            CustomButton(
                text: 'Continue',
                callback: () async {
                  if (mounted) {
                    if (_formKey.currentState!.validate()) {
                      await getIt
                          .get<AuthRepoImpl>()
                          .signInWithEmailAndPassword(
                              emailController.text, passwordController.text)
                          .then(
                        (value) {
                          value.fold((f) {
                            showSnackBar(context, f.message);
                          }, (s) {
                            showSnackBar(context, s.message);
                          });
                        },
                      );
                    } else {
                      setState(() {
                        _autovalidateMode = AutovalidateMode.always;
                      });
                    }
                  }
                }),
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
        Hive.box('settings').get('finsihedOnboarding', defaultValue: false)
            ? IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  FontAwesomeIcons.arrowLeft,
                  color: AppColors.textColorPrimary,
                ),
              )
            : Container(),
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
          onPressed: () async {
            await getIt.get<AuthRepoImpl>().signInWithGoogle().then(
                  (value) => {
                    value.fold((f) {
                      showSnackBar(context, f.message);
                    }, (s) {
                      showSnackBar(context, s.message);
                    }),
                  },
                );
          },
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
            "Using Email And Password",
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
  const _LoginForm(this.emailController, this.passwordController, this.formKey,
      this.autovalidateMode);

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final GlobalKey<FormState> formKey;
  final AutovalidateMode autovalidateMode;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
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
      ),
    );
  }
}

class ForgotPasswordText extends StatelessWidget {
  const ForgotPasswordText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
            onPressed: () async {
              context.push(AppRouter.forgotPassword);
            },
            child: Text(
              'Forgot Password',
              style: TextStyles.bodyText1.copyWith(
                color: AppColors.accentColor,
              ),
            ))
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
