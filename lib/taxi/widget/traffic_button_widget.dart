import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widget/styles/colors.dart';

class TrafficButtonWidget extends StatelessWidget {
  final VoidCallback onTap; // Function to handle the button tap
  final bool isTrafficEnabled; // Current traffic view state
  final Color activeColor; // Color for the active traffic state
  final Color inactiveColor; // Color for the inactive traffic state
  final double iconSize; // Icon size
  final Color? backgroundColor;

  const TrafficButtonWidget(
      {super.key,
      required this.onTap,
      required this.isTrafficEnabled,
      required this.activeColor,
      required this.inactiveColor,
      required this.iconSize,
      this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          color: backgroundColor ??
              AppColor.kStatusBarPrimaryColor.value, // Background color
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Icon(
          Icons.traffic_outlined,
          color: isTrafficEnabled ? activeColor : inactiveColor,
          size: iconSize,
        ),
      ),
    );
  }
}
