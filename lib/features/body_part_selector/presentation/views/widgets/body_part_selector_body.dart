import 'package:body_part_selector/body_part_selector.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:physio_app/core/utils/app_router.dart';
import 'package:physio_app/core/utils/colors.dart';
import 'package:physio_app/core/utils/text_styles.dart';

class BodyPartSelectorBody extends StatefulWidget {
  const BodyPartSelectorBody({super.key});

  @override
  State<BodyPartSelectorBody> createState() => _BodyPartSelectorBodyState();
}

class _BodyPartSelectorBodyState extends State<BodyPartSelectorBody> {
  BodyParts _bodyParts = const BodyParts();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainColor,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
          'Select Your Pain Part',
          style: TextStyles.bodyText1.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.mainColor,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BodyPartSelectorTurnable(
                selectedColor: Colors.red,
                unselectedColor: Color(0xFFFAC2B0),
                bodyParts: _bodyParts,
                onSelectionUpdated: (p) => setState(() => _bodyParts = p),
                labelData: const RotationStageLabelData(
                  front: 'Fornt',
                  left: 'Left',
                  right: 'Right',
                  back: 'Back',
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                  color: Colors.blue,
                  onPressed: () {
                    debugPrint(_bodyParts.toString());
                    context.push(AppRouter.pageView);
                  },
                  child: const Text('Print Body Parts'),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
