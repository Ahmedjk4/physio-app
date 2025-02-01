import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio_app/core/utils/assets.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/features/onboarding/presentation/views/widgets/row_of_text_and_button.dart';

class OnboardingViewBody extends StatelessWidget {
  const OnboardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: Hero(
          tag: 'Logo',
          child: DefaultTextStyle(
            style: TextStyles.headline1.copyWith(
                color: AppColors.secondaryColor, fontFamily: 'DynaPuff'),
            child: const Text(
              'Physio',
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight, // Ensures full height is used
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.0.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          Assets.assetsImagesStretch,
                          width: 300.0.w,
                          height: 300.0.h,
                        ),
                      ],
                    ),
                    const Spacer(),
                    const RowOfTextAndButton(),
                    SizedBox(
                      height: 120.0.h,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
