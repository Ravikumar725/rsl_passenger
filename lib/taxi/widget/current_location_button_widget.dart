import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrentLocationButtonWidget extends StatelessWidget {
  final VoidCallback onTap; // Function to handle the button tap
  final Color backgroundColor; // Background color for the button
  final Color iconColor; // Color of the icon
  final double iconSize; // Size of the icon

  const CurrentLocationButtonWidget({
    super.key,
    required this.onTap,
    required this.backgroundColor,
    required this.iconColor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          color: backgroundColor,
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Icon(
          Icons.my_location,
          color: iconColor,
          size: iconSize,
        ),
      ),
    );
  }
}
