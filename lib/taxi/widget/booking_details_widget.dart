import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widget/styles/colors.dart';
import 'now_booking_widget.dart';

class BookingDetailsWidget extends StatelessWidget {
  final String? imagePath;
  final IconData? iconData;
  final double? iconSize;
  final Color? iconColor;
  final String? title;
  final double? imageHeight;
  final double? imageWidth;
  final FontWeight? fontWeight;
  final String? fare;
  final String? imageUrl;
  final Color? titleColor;
  final Function()? onTab;

  const BookingDetailsWidget({
    super.key,
    this.imagePath,
    this.iconData,
    this.iconSize,
    this.iconColor,
    this.title,
    this.imageHeight,
    this.imageWidth,
    this.fontWeight,
    this.fare,
    this.imageUrl,
    this.titleColor,
    this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTab,
      child: Row(
        children: [
          (imageUrl != '' && imageUrl != null)
              ? Container(
            width: imageWidth,
            height: imageHeight,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.contain,
                image: NetworkImage(imageUrl!),
              ),
            ),
          )
              : const SizedBox.shrink(),
          (imagePath != '' && imagePath != null)
              ? Image.asset(
            imagePath!,
            height: imageHeight,
            width: imageWidth,
            color: iconColor,
          )
              : const SizedBox.shrink(),
          iconData != null
              ? Icon(iconData, size: iconSize, color: iconColor)
              : const SizedBox.shrink(),
          SizedBox(width: 10.w), // Spacing between image and text
          textView(
              text: '$title',
              fontWeight: fontWeight,
              color: titleColor ?? AppColor.kPrimaryTextColor.value),
          const Spacer(),
          (fare != '' && fare != null)
              ? textView(text: fare)
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}

