// ignore_for_file: file_names

extension StartsWithCapitalLetter on String {
  bool startsWithCapitalLetter() {
    if (isEmpty) {
      return false;
    }
    return RegExp(r'^[A-Z]').hasMatch(this[0]);
  }
}
