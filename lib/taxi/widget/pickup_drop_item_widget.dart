import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import 'now_booking_widget.dart';

class PickupDropItemWidget extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final VoidCallback? onEditTap;
  final bool isEditShow;

  const PickupDropItemWidget({
    super.key,
    this.title,
    this.subtitle,
    this.onEditTap,
    this.isEditShow = true
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textView(
                text: title,
                fontWeight: AppFontWeight.semibold.value,
              ),
              textView(
                text: subtitle,
              ),
            ],
          ),
        ),
        const Spacer(),
        isEditShow == false ? const SizedBox.shrink():InkWell(
          onTap: onEditTap,
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Row(
              children: [
                textView(
                  text: 'Edit',
                  color: AppColor.kPrimaryColor.value,
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14.r,
                  color: AppColor.kPrimaryColor.value,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
