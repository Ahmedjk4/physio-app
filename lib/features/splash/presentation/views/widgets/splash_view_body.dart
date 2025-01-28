import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/assets.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.go(AppRouter.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            Assets.assetsLottieSplash,
            width: 300.0.w,
            height: 300.0.h,
          ),
          Text(
            'Physio',
            style: TextStyles.headline1.copyWith(
              color: AppColors.textColorPrimary,
            ),
          ),
          Text(
            'Your personal fitness trainer',
            style: TextStyles.bodyText1
                .copyWith(color: AppColors.textColorSecondary),
          ),
        ],
      ),
    );
  }
}
