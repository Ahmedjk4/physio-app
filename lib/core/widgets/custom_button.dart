import 'package:flutter/material.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback callback;
  const CustomButton({
    super.key,
    required this.text,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        child: InkWell(
          enableFeedback: true,
          borderRadius: BorderRadius.circular(10),
          splashColor: AppColors.secondaryColor,
          onTap: callback,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(top: 1),
            width: 200,
            height: 50,
            child: Center(
              child: Text(text,
                  style: TextStyles.bodyText1.copyWith(
                      color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
