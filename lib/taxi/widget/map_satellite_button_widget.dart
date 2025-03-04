import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../widget/styles/colors.dart';

class MapSatelliteButtonWidget extends StatelessWidget {
  final VoidCallback onTap; // Function to handle the button tap
  final MapType currentMapType; // Current map type to determine the icon color
  final Color activeColor; // Color for the active map type
  final Color inactiveColor; // Color for the inactive map type
  final double iconSize; // Icon size
  final Color? backgroundColor;

  const MapSatelliteButtonWidget({
    super.key,
    required this.onTap,
    required this.currentMapType,
    required this.activeColor,
    required this.inactiveColor,
    required this.iconSize,
    this.backgroundColor
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8.r)),
          color: backgroundColor ?? AppColor.kStatusBarPrimaryColor.value, // Background color
        ),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Icon(
          Icons.layers_outlined,
          color: currentMapType != MapType.normal ? activeColor : inactiveColor,
          size: iconSize,
        ),
      ),
    );
  }
}

