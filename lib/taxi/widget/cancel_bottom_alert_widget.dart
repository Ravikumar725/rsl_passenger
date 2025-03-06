import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/custom_button.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import 'cancel_trip_reason_widget_new.dart';
import 'need_our_help_widget.dart';

Future cancelBottomAlert({required Function(String) cancelOnTab}) {
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
                _line(),
                sizedBox(height: 4.h),
                textView(
                    text: "Are you sure you want to cancel?",
                    maxLines: 2,
                    fontSize: AppFontSize.dashboardTitle.value,
                    fontWeight: AppFontWeight.semibold.value),
                sizedBox(height: 4.h),
                textView(
                    text:
                    "We know you've been waiting but your captain is on the way.",
                    maxLines: 2),
                sizedBox(height: 14.h),
                CustomButton(
                    height: 35.h,
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    width: double.maxFinite,
                    text: "Yes,cancel",
                    linearColor: redLinearColor,
                    color: AppColor.kRedColour.value,
                    onTap: () {
                      showModalBottomSheet(
                        context: Get.context!,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20.r),
                          ),
                        ),
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.9, // 90% of the screen height
                            child: CancelReasonsBottomSheet(
                              cancelTripAction: cancelOnTab/*(reason) {
                                printLogs("Selected Reason: $reason");
                                onCancelClicked();
                              }*/,
                              backBtnAction: () {
                                Navigator.pop(context);
                              },
                              buttonLoader: false,
                            ),
                          );
                        },
                      );
                    }),
                sizedBox(height: 10.h),
                CustomButton(
                  height: 35.h,
                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                  width: double.maxFinite,
                  text: "No,keep ride",
                  onTap: () {
                    Get.back();
                  },
                ),
              ],
            ),
          )),
      isScrollControlled: true);
}

Widget _line() {
  return Center(
    child: Container(
      margin: const EdgeInsets.only(top: 8),
      width: 50,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}