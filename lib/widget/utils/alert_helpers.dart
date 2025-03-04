import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../app_loader.dart';
import '../custom_button.dart';
import '../styles/app_style.dart';
import '../styles/colors.dart';

showAppDialog({
  required String message,
  String? title,
  Widget? confirm,
  Widget? cancel,
  TextStyle titleStyle = const TextStyle(color: Colors.black),
  TextStyle middleTextStyle = const TextStyle(color: Colors.black54),
  radius = 16,
}) {
  return Get.defaultDialog(
    title: title ?? 'kConfirm'.tr,
    middleText: message,
    backgroundColor: Colors.white,
    titleStyle: TextStyle(color: Colors.black),
    middleTextStyle: TextStyle(color: Colors.black54),
    cancel: cancel,
    confirm: confirm,
    radius: 16,
  );
}

Widget defaultAlertConfirm(
        {String? text, VoidCallback? onPressed, TextStyle? style}) =>
    TextButton(
      onPressed: onPressed ??
          () {
            Get.back();
          },
      child: Text(
        text ?? 'kOkay'.tr,
        style: style ??
            TextStyle(
              color: AppColor.kPrimaryColor.value,
            ),
      ),
    );

Widget defaultAlertConfirmOutline(
        {String? text,
        VoidCallback? onPressed,
        TextStyle? style,
        RxBool? isLoader}) =>
    Obx(() => CustomButton(
          text: text ?? 'kOkay'.tr,
          height: 28.h,
          width: 100.w,
          borderRadius: 14.r,
          isLoader: isLoader?.value,
          onTap: onPressed ??
              () {
                Get.back();
              },
        ));

Widget defaultAlertCancelOutlined({
  String text = 'Cancel',
  VoidCallback? onPressed,
  RxBool? isLoader, // Ensure that isLoader is reactive
}) =>
    Obx(() => InkWell(
          onTap: onPressed ??
              () {
                Get.back();
              },
          child: Container(
            height: 28.h,
            width: 80.w,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColor.kLightTextPrimary.value)),
            child: Center(
              child: isLoader?.value == true
                  ? AppLoader(color: AppColor.kPrimaryTextColor.value)
                  : Text("$text"),
            ),
          ),
        ));

Widget defaultAlertCancel({String text = 'Cancel', VoidCallback? onPressed}) =>
    TextButton(
      onPressed: onPressed ??
          () {
            Get.back();
          },
      child: Text(
        text,
        style: TextStyle(
          color: AppColor.kLightTextPrimary.value,
        ),
      ),
    );

showDialogBox({
  required String message,
  String title = 'Confirm',
  Widget? confirm,
  Widget? cancel,
  TextStyle titleStyle = const TextStyle(color: Colors.black),
  TextStyle middleTextStyle = const TextStyle(color: Colors.black54),
  radius = 16,
  bool dismiss = false,
  double horizontal = 40,
}) {
  return Get.dialog(
    barrierDismissible: dismiss,
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(20.r),
              ),
            ),
            child: Material(
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      "$title",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColor.kPrimaryTextColor.value,
                          fontSize: AppFontSize.large.value,
                          fontWeight: AppFontWeight.semibold.value),
                    ),
                    SizedBox(height: 15.h),
                    Text(
                      "$message",
                      textAlign: TextAlign.center,
                      style: middleTextStyle,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        cancel ?? SizedBox.shrink(),
                        SizedBox(width: 10.w),
                        confirm ?? SizedBox.shrink()
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
