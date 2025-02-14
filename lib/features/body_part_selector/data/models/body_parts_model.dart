import 'package:hive/hive.dart';
import 'package:body_part_selector/body_part_selector.dart';

part 'body_parts_model.g.dart';

@HiveType(typeId: 0)
class BodyPartsHiveWrapper {
  @HiveField(0)
  final Map<String, bool> selectedBodyParts;

  BodyPartsHiveWrapper(this.selectedBodyParts);

  factory BodyPartsHiveWrapper.fromBodyParts(BodyParts bodyParts) {
    return BodyPartsHiveWrapper(bodyParts.toMap());
  }

  BodyParts toBodyParts() {
    return BodyParts.fromJson(selectedBodyParts);
  }
}
