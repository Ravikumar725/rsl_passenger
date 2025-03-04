import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';

class NowBookingWidget extends StatelessWidget {
  final Function()? onTab;
  final bool isLaterBooking;
  final String? laterBookingDateTime;
  const NowBookingWidget(
      {super.key,
      this.onTab,
      this.isLaterBooking = false,
      this.laterBookingDateTime});

  @override
  Widget build(BuildContext context) {
    if (laterBookingDateTime!.isNotEmpty) {
      String formattedDate = formatDateString(laterBookingDateTime ?? "");
      return InkWell(
        onTap: onTab,
        child: Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: isLaterBooking
              ? Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20.r,
                      color: AppColor.kPrimaryColor.value,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, right: 2.w),
                      child: textView(
                          text: formattedDate,
                          color: AppColor.kPrimaryIconColor.value,
                          fontSize: AppFontSize.medium.value,
                          fontWeight: AppFontWeight.semibold.value),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 20.r,
                      color: AppColor.kPrimaryColor.value,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, right: 2.w),
                      child: textView(
                          text: "Now".tr,
                          color: AppColor.kPrimaryIconColor.value,
                          fontSize: AppFontSize.medium.value,
                          fontWeight: AppFontWeight.semibold.value),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_outlined,
                      size: 20.r,
                      color: AppColor.kPrimaryTextColor.value,
                    ),
                  ],
                ),
        ),
      );
    } else {
      // Handle the case where the date is empty
      return InkWell(
        onTap: onTab,
        child: Row(
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 20.r,
              color: AppColor.kPrimaryColor.value,
            ),
            Padding(
              padding: EdgeInsets.only(left: 4.w, right: 2.w),
              child: textView(
                  text: "Now".tr,
                  color: AppColor.kPrimaryIconColor.value,
                  fontSize: AppFontSize.medium.value,
                  fontWeight: AppFontWeight.semibold.value),
            ),
            Icon(
              Icons.keyboard_arrow_down_outlined,
              size: 20.r,
              color: AppColor.kPrimaryTextColor.value,
            ),
          ],
        ),
      );
    }
  }

  String formatDateString(String dateString) {
    if (dateString.isEmpty) {
      return "Invalid Date";
    }

    try {
      // Define the format for parsing the input string
      DateFormat inputFormat = DateFormat("yyyy-MM-dd hh:mm:ss a");

      // Parse the string into a DateTime object
      DateTime dateTime = inputFormat.parse(dateString);

      // Format the DateTime into your desired format
      return DateFormat("dd MMM, hh:mm a").format(dateTime);
    } catch (e) {
      // Handle any parsing errors
      return "Invalid Date";
    }
  }
}
Widget textView(
    {String? text,
      double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      int? maxLines}) {
  return Text(
    text ?? "",
    maxLines: maxLines ?? 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: fontSize ?? AppFontSize.medium.value,
      fontWeight: fontWeight ?? AppFontWeight.medium.value,
      color: color ?? AppColor.kPrimaryTextColor.value,
      // fontFamily: "Poppins"
    ),
  );
}