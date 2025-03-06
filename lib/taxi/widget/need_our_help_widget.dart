import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';

Future needOurHelp({Function()? onCall, Function()? onChat, Function()? onHelpCenter}) {
  return Get.bottomSheet(
      Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r))),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 14.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                sizedBox(height: 8.h),
                Row(
                  children: [
                    textView(
                        text: "Need our help?",
                        fontSize: AppFontSize.info.value,
                        fontWeight: AppFontWeight.semibold.value),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.r),
                            color: AppColor.kLightPrimary.value),
                        child: Icon(Icons.close, size: 18.r),
                      ),
                    ),
                  ],
                ),
                sizedBox(height: 16.h),
                _helpRowWidget(
                    onTab: onCall,
                    icon: Icons.support_agent,
                    title: "Give us a call",
                    subTitle: "Reach the team for urgent help."),
                _helpRowWidget(
                    onTab: onChat,
                    icon: Icons.chat,
                    title: "Chat with us",
                    subTitle: "We can help with non-safety related issues"),
                _helpRowWidget(
                    onTab: onHelpCenter,
                    icon: Icons.sports_volleyball_sharp,
                    title: "Visit our Help Center",
                    subTitle: "Learn more about RSL and how it work"),
              ],
            ),
          )),
      isScrollControlled: true);
}

Widget sizedBox({double? height}) {
  return SizedBox(
    height: height ?? 8.h,
  );
}

Widget _helpRowWidget(
    {IconData? icon, String? title, String? subTitle, Function()? onTab}) {
  return InkWell(
    onTap: onTab,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 25.r,
          color: AppColor.kLightTextPrimary.value,
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textView(
                  text: "$title",
                  fontWeight: AppFontWeight.semibold.value,
                  fontSize: AppFontSize.large.value),
              sizedBox(height: 2.h),
              textView(
                  text: "$subTitle",
                  fontWeight: AppFontWeight.medium.value,
                  fontSize: AppFontSize.medium.value,
                  color: AppColor.kLightTextPrimary.value.withOpacity(0.7)),
              sizedBox(height: 8.h),
              _divider(height: 1.h),
              sizedBox(height: 8.h),
            ],
          ),
        )
      ],
    ),
  );
}

Widget _divider({double? height}) {
  return Container(
    height: height ?? 4.h,
    color: AppColor.kLightPrimary.value,
  );
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
