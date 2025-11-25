import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 280.w),
        margin: EdgeInsets.symmetric(vertical: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSentByMe
                ? [
                    const Color(0xFF83332e),
                    const Color(0xFF9d3f38),
                  ]
                : [
                    const Color(0xFFb11ccf),
                    const Color(0xFFc931e5),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft:
                isSentByMe ? Radius.circular(18.r) : Radius.circular(4.r),
            bottomRight:
                isSentByMe ? Radius.circular(4.r) : Radius.circular(18.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
