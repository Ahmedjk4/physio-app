import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/core/helpers/showSnackBar.dart';
import 'package:physio_app/core/types/text_form_field_types.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/service_locator.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/core/widgets/custom_button.dart';
import 'package:physio_app/core/widgets/custom_text_form_field.dart';
import 'package:physio_app/features/auth/data/repos/auth_repo_impl.dart';

class RegisterViewBody extends StatefulWidget {
  const RegisterViewBody({super.key});

  @override
  State<RegisterViewBody> createState() => _RegisterViewBodyState();
}

class _RegisterViewBodyState extends State<RegisterViewBody> {
  final TextEditingController nameController = TextEditingController();
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
            SizedBox(height: 50.0.h),
            // const _SocialButtons(),
            // SizedBox(height: 20.0.h),
            const _DividerWithText(),
            SizedBox(height: 20.0.h),
            _RegisterForm(nameController, emailController, passwordController,
                _formKey, _autovalidateMode),
            SizedBox(height: 20.0.h),
            CustomButton(
              text: 'Continue',
              callback: () async {
                if (mounted) {
                  if (_formKey.currentState!.validate()) {
                    await getIt
                        .get<AuthRepoImpl>()
                        .signUp(
                          nameController.text,
                          emailController.text,
                          passwordController.text,
                        )
                        .then((value) {
                      value.fold((f) {
                        showSnackBar(context, f.message);
                      }, (s) {
                        showSnackBar(context, s.message);
                        context.pop();
                      });
                    });
                  } else {
                    setState(() {
                      _autovalidateMode = AutovalidateMode.always;
                    });
                  }
                }
              },
            ),
            SizedBox(height: 20.0.h),
            LoginText(),
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
          "Register",
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
          color: Colors.yellow,
          icon: FontAwesomeIcons.google,
          onPressed: () async {
            await getIt.get<AuthRepoImpl>().signInWithGoogle().then((value) {
              value.fold((f) {
                showSnackBar(context, f.message);
              }, (s) {
                showSnackBar(context, s.message);
              });
            });
          },
        ),
        SizedBox(width: 20.0.w),
        _buildSocialButton(
          color: Colors.yellow,
          icon: FontAwesomeIcons.facebookF,
          onPressed: () {},
        ),
        SizedBox(width: 20.0.w),
        _buildSocialButton(
          color: Colors.yellow,
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

class _RegisterForm extends StatelessWidget {
  const _RegisterForm(this.nameController, this.emailController,
      this.passwordController, this._formKey, this.autovalidateMode);
  final TextEditingController nameController,
      emailController,
      passwordController;
  final GlobalKey<FormState> _formKey;
  final AutovalidateMode autovalidateMode;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: autovalidateMode,
      child: Column(
        children: [
          CustomTextField(
            hintText: 'Enter Your Name',
            label: 'Name',
            controller: nameController,
            type: TextFormFieldTypes.name,
            icon: Icons.person,
            iconColor: Colors.blue,
          ),
          CustomTextField(
            hintText: 'Enter Your Email',
            label: 'Email',
            controller: emailController,
            type: TextFormFieldTypes.email,
            icon: Icons.lock,
            iconColor: Colors.amber,
          ),
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

class LoginText extends StatelessWidget {
  const LoginText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already Have An Account ?',
          style: TextStyles.bodyText1.copyWith(
            color: AppColors.textColorPrimary,
            fontSize: 15.sp,
          ),
        ),
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: Text(
            'Go Back To Login',
            overflow: TextOverflow.ellipsis,
            style: TextStyles.bodyText1.copyWith(
              color: AppColors.accentColor,
              fontSize: 15.sp,
            ),
          ),
        ),
      ],
    );
  }
}
