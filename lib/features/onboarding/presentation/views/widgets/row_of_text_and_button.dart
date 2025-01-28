import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';
import 'package:physio_app/core/widgets/custom_button.dart';

class RowOfTextAndButton extends StatelessWidget {
  const RowOfTextAndButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercise Regularly,\nRelease Pain,\nBy Dr.Rana Kadry',
              style: TextStyles.headline1.copyWith(
                color: AppColors.textColorPrimary,
              ),
            ),
            SizedBox(
              height: 20.0.h,
            ),
            CustomButton(
              text: 'Get Started',
              callback: () => {
                context.push(AppRouter.auth),
              },
            ),
          ],
        ),
      ],
    );
  }
}
