import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:physio_app/core/helpers/startsWithCapitalLetter.dart';
import 'package:physio_app/core/types/text_form_field_types.dart';
import 'package:physio_app/core/utils/colors.dart';

class CustomTextField extends StatefulWidget {
  final String hintText, label;
  final bool obsecure, autoFocus;
  final TextEditingController controller;
  final TextFormFieldTypes type;
  final IconData? icon;
  final Color? iconColor;
  const CustomTextField({
    super.key,
    required this.hintText,
    required this.label,
    this.obsecure = false,
    this.autoFocus = false,
    required this.controller,
    required this.type,
    this.icon,
    this.iconColor,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  Color _labelColor = Colors.grey.shade500;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = Colors.white.withOpacity(0.1);
    final borderColor = Colors.black;
    final labelDefaultColor = Colors.grey.shade500;
    final errorColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        keyboardType: getInputType(widget.type),
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              _labelColor = errorColor;
            });
            return 'This Field Is Required';
          } else if (widget.type == TextFormFieldTypes.email &&
              !EmailValidator.validate(widget.controller.text)) {
            setState(() {
              _labelColor = errorColor;
            });
            return 'Invalid Email';
          } else if (widget.type == TextFormFieldTypes.password &&
              value.length < 8) {
            setState(() {
              _labelColor = errorColor;
            });
            return 'Password must be at least 8 characters';
          } else if (widget.type == TextFormFieldTypes.name &&
              value.startsWithCapitalLetter() == false) {
            setState(() {
              _labelColor = errorColor;
            });
            return 'Name Must Start With Capital Letter';
          } else if (widget.type == TextFormFieldTypes.number) {
            if (value.length != 11 || !value.startsWith('01')) {
              setState(() {
                _labelColor = errorColor;
              });
              return 'Phone Number Must Be 11 Characters And Start With 01';
            }
          }

          setState(() {
            _labelColor = labelDefaultColor;
          });

          return null;
        },
        controller: widget.controller,
        decoration: InputDecoration(
          prefix: widget.icon != null
              ? SizedBox(
                  height: 30,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Align items vertically
                    mainAxisSize: MainAxisSize
                        .min, // Minimize the Row width to its content
                    children: [
                      Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: 20.sp, // Adjust icon size to match text
                      ),
                      SizedBox(width: 8), // Space between icon and text
                      Text(
                        '',
                        style: TextStyle(
                          fontSize: 14.sp, // Adjust font size as needed
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8), // Space between text and divider
                      Container(
                        width: 1.w, // Thin vertical line
                        height: 20.h, // Height of the divider
                        color: Colors.black, // Divider color
                      ),
                      SizedBox(width: 8), // Space after divider
                    ],
                  ),
                )
              : null,
          filled: true,
          fillColor: backgroundColor,
          errorStyle: TextStyle(color: Colors.red),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor),
            borderRadius: BorderRadius.circular(3),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor, width: 3),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: errorColor, width: 3),
            borderRadius: BorderRadius.circular(2),
          ),
          labelText: widget.label,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppColors.secondaryColor,
          ),
          labelStyle: TextStyle(
            color: _labelColor,
          ),
        ),
        obscureText: widget.obsecure,
        obscuringCharacter: '*',
        autofocus: widget.autoFocus,
      ),
    );
  }
}

TextInputType? getInputType(TextFormFieldTypes type) {
  switch (type) {
    case TextFormFieldTypes.email:
      return TextInputType.emailAddress;
    case TextFormFieldTypes.password:
      return TextInputType.visiblePassword;
    case TextFormFieldTypes.number:
      return TextInputType.number;
    case TextFormFieldTypes.name:
      return TextInputType.name;
  }
}
