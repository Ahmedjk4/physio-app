import 'package:flutter/material.dart';
import 'package:physio_app/features/body_part_selector/presentation/views/widgets/body_part_selector_body.dart';

class BodyPartSelectorView extends StatelessWidget {
  const BodyPartSelectorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BodyPartSelectorBody(),
    );
  }
}
