// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<String?> showPrompt(
  BuildContext context, {
  Widget? title,
  Widget? textOK,
  Widget? textCancel,
  String? initialValue,
  bool isSelectedInitialValue = true,
  String? hintText,
  String? Function(String?)? validator,
  int minLines = 1,
  int maxLines = 1,
  bool autoFocus = true,
  TextInputType? keyboardType,
  TextInputAction? textInputAction,
  bool obscureText = false,
  String obscuringCharacter = '•',
  bool showPasswordIcon = false,
  bool barrierDismissible = false,
  TextCapitalization textCapitalization = TextCapitalization.none,
  TextAlign textAlign = TextAlign.start,
  TextEditingController? controller,
  InputDecoration? decoration,
  EdgeInsets? insetPadding,
  EdgeInsets? contentPadding,
  EdgeInsets? actionsPadding,
  EdgeInsets? titlePadding,
  EdgeInsets? buttonPadding,
  EdgeInsets? iconPadding,
  bool canPop = false,
  void Function(bool)? onPopInvoked,
  int? maxLength,
  List<TextInputFormatter>? inputFormatters,
  Color? backgroundColor,
  bool showTextField = true, // New parameter added
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      return _PromptDialog(
        title: title,
        textOK: textOK,
        textCancel: textCancel,
        initialValue: initialValue,
        isSelectedInitialValue: isSelectedInitialValue,
        hintText: hintText,
        validator: validator,
        minLines: minLines,
        maxLines: maxLines,
        autoFocus: autoFocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        obscureText: obscureText,
        obscuringCharacter: obscuringCharacter,
        showPasswordIcon: showPasswordIcon,
        textCapitalization: textCapitalization,
        textAlign: textAlign,
        controller: controller,
        decoration: decoration ?? const InputDecoration(),
        insetPadding: insetPadding ?? EdgeInsets.zero,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        titlePadding: titlePadding,
        buttonPadding: buttonPadding,
        iconPadding: iconPadding,
        canPop: canPop,
        onPopInvoked: onPopInvoked,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        backgroundColor: backgroundColor,
        showTextField: showTextField, // Pass it down to the dialog
      );
    },
  );
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.backgroundColor,
    required this.isSelectedInitialValue,
    required this.minLines,
    required this.maxLines,
    required this.autoFocus,
    required this.obscureText,
    required this.obscuringCharacter,
    required this.showPasswordIcon,
    required this.textCapitalization,
    required this.textAlign,
    required this.decoration,
    required this.insetPadding,
    required this.canPop,
    this.title,
    this.textOK,
    this.textCancel,
    this.initialValue,
    this.hintText,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.contentPadding,
    this.actionsPadding,
    this.titlePadding,
    this.buttonPadding,
    this.iconPadding,
    this.onPopInvoked,
    this.maxLength,
    this.inputFormatters,
    required this.showTextField, // New parameter added
  });

  final Color? backgroundColor;
  final Widget? title;
  final Widget? textOK;
  final Widget? textCancel;
  final String? initialValue;
  final bool isSelectedInitialValue;
  final String? hintText;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;
  final bool autoFocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final String obscuringCharacter;
  final bool showPasswordIcon;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextEditingController? controller;
  final InputDecoration decoration;
  final EdgeInsets insetPadding;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final EdgeInsets? titlePadding;
  final EdgeInsets? buttonPadding;
  final EdgeInsets? iconPadding;
  final bool canPop;
  final void Function(bool)? onPopInvoked;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool showTextField; // New parameter added

  @override
  __PromptDialogState createState() => __PromptDialogState();
}

class __PromptDialogState extends State<_PromptDialog> {
  late TextEditingController controller;
  late bool stateObscureText = widget.obscureText;

  String? value;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.canPop,
      onPopInvoked: widget.onPopInvoked,
      child: AlertDialog(
        backgroundColor: widget.backgroundColor,
        insetPadding: widget.insetPadding,
        contentPadding: widget.contentPadding,
        actionsPadding: widget.actionsPadding,
        titlePadding: widget.titlePadding,
        buttonPadding: widget.buttonPadding,
        iconPadding: widget.iconPadding,
        title: widget.title,
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: widget.showTextField // Conditional rendering
                ? TextFormField(
                    controller: controller,
                    inputFormatters: widget.inputFormatters,
                    decoration: widget.decoration.copyWith(
                      hintText: widget.hintText,
                      suffixIcon: widget.showPasswordIcon
                          ? IconButton(
                              icon: Icon(
                                Icons.remove_red_eye,
                                color: stateObscureText
                                    ? Colors.grey
                                    : Colors.blueGrey,
                              ),
                              onPressed: () {
                                setState(() {
                                  stateObscureText = !stateObscureText;
                                });
                              },
                            )
                          : null,
                    ),
                    validator: widget.validator,
                    minLines: widget.minLines,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    autofocus: widget.autoFocus,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: (String text) => value = text,
                    obscureText: stateObscureText,
                    obscuringCharacter: widget.obscuringCharacter,
                    textCapitalization: widget.textCapitalization,
                    onEditingComplete: () {
                      if (_formKey.currentState!.validate()) {
                        Navigator.pop(context, value);
                      }
                    },
                    textAlign: widget.textAlign,
                  )
                : const SizedBox
                    .shrink(), // Render an empty widget when not showing the text field
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: (widget.textCancel != null)
                ? widget.textCancel!
                : Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context, value);
              }
            },
            child: (widget.textOK != null)
                ? widget.textOK!
                : Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}
