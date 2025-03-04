import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';

import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';

Future<BitmapDescriptor> getWidgetMarker({required Widget widget}) async {
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List iconData = await screenshotController.captureFromWidget(
    widget,
    delay: const Duration(seconds: 0),
  );
  BitmapDescriptor icon = BitmapDescriptor.fromBytes(iconData);
  return icon;
}

Widget pickDropMarker(
    {required Color color,
    String? time,
    String? location,
    int isShow = 0,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? style}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      isShow == 1
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColor.kPrimaryColor.value,
                borderRadius: BorderRadius.circular(8.r), // Rounded corners
                border: Border.all(
                    color: AppColor.kStatusBarPrimaryColor.value, width: 0.5.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          time != ""
                              ? Text(
                                  "$time",
                                  style: style ??
                                      TextStyle(
                                        color: textColor ??
                                            AppColor
                                                .kStatusBarPrimaryColor.value,
                                        fontSize: 8.sp,
                                        fontWeight: AppFontWeight.medium.value,
                                      ),
                                )
                              : const SizedBox.shrink(),
                          (location != "" && location != null)
                              ? Text(
                                  location ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: textColor ??
                                        AppColor.kStatusBarPrimaryColor.value,
                                    fontSize: AppFontSize.verySmall.value,
                                    fontWeight: AppFontWeight.medium.value,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                  (location != "" && location != null)
                      ? Padding(
                          padding: EdgeInsets.only(left: 15.w),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 12.r,
                            color: textColor ??
                                AppColor.kStatusBarPrimaryColor.value,
                          ),
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            )
          : const SizedBox.shrink(),
      Container(
        height: 33.h,
        width: 32.w,
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
                height: 20.h,
                // width: 40.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: color, width: 2.r),
                    shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Center(
                      child: Container(
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  )),
                )),
            Stack(
              children: [
                Positioned(
                  left: 3.w,
                  child: Container(
                    height: 8.h,
                    margin: EdgeInsets.zero,
                    width: 2.w,
                    color: color,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2.w)),
                    margin: EdgeInsets.zero,
                    child: Container(
                      height: 5.h,
                      width: 4.w,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget pickDropMarkerNew(
    {required Color color,
    String? title,
    String? image,
    Color? backgroundColor,
    TextStyle? style}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      (title != "" && title != null && image != null)
          ? Container(
              margin: EdgeInsets.only(left: 40.w, bottom: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: backgroundColor ?? AppColor.kPrimaryColor.value,
                borderRadius: BorderRadius.circular(8.r), // Rounded corners
                border: Border.all(
                    color: AppColor.kStatusBarPrimaryColor.value, width: 0.5.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    decoration: BoxDecoration(
                        color: AppColor.kPrimaryColor.value,
                        borderRadius: BorderRadius.circular(6.r)),
                    child: Image.asset(
                      image,
                      color: AppColor.kStatusBarPrimaryColor.value,
                      height: 22.h,
                      width: 22.w,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, right: 2.w),
                    child: Text(
                      title,
                      style: style ??
                          TextStyle(
                            color: AppColor.kStatusBarPrimaryColor.value,
                            fontSize: 8.sp,
                            fontWeight: AppFontWeight.semibold.value,
                          ),
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
      Container(
        height: 33.h,
        width: 32.w,
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
                height: 20.h,
                // width: 40.w,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: color, width: 2.r),
                    shape: BoxShape.circle),
                child: Padding(
                  padding: EdgeInsets.all(2.r),
                  child: Center(
                      child: Container(
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  )),
                )),
            Stack(
              children: [
                Positioned(
                  left: 3.w,
                  child: Container(
                    height: 8.h,
                    margin: EdgeInsets.zero,
                    width: 2.w,
                    color: color,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.h),
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2.w)),
                    margin: EdgeInsets.zero,
                    child: Container(
                      height: 5.h,
                      width: 4.w,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

Widget pickDistanceMarker({required Color color, required text}) {
  return Container(
    height: 50.h,
    width: 55.w,
    color: Colors.transparent,
    child: Column(
      children: [
        Container(
            height: 37.h,
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: color, width: 2.r),
                shape: BoxShape.circle),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Center(
                  child: Text(
                "$text \n Mins",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColor.kPrimaryTextColor.value,
                    fontSize: AppFontSize.verySmall.value),
              )),
            )),
        Stack(
          children: [
            Positioned(
              left: 3.w,
              child: Container(
                height: 8.h,
                margin: EdgeInsets.zero,
                width: 2.w,
                color: color,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 3.h),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2.w)),
                margin: EdgeInsets.zero,
                child: Container(
                  height: 5.h,
                  width: 4.w,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ],
    ),
  );
}

Widget polygonMarker({required text, required type}) {
  return Container(
    height: 35.h,
    width: 100.w,
    color: Colors.transparent,
    child: Column(
      children: [
        Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color:
                      type == 1 ? Colors.black : AppColor.kPrimaryColor.value,
                  width: 3.w)),
          child: Container(
            height: 8.h,
            width: 7.w,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Colors.white),
          ),
        ),
        Expanded(
          child: Container(
            height: 35.h,
            decoration: BoxDecoration(
              color: type == 1 ? Colors.black : AppColor.kPrimaryColor.value,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(2.r),
              child: Center(
                child: Text(
                  "$text",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: AppFontSize.verySmall.value),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget locationNotAvailableMarker(
    {required Color color,
    String? title,
    Color? backgroundColor,
    Color? textColor,
    TextStyle? style}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColor.kPrimaryColor.value,
          borderRadius: BorderRadius.circular(10.r), // Rounded corners
          border: Border.all(
              color: AppColor.kStatusBarPrimaryColor.value, width: 0.5.r),
        ),
        child: (title != "" && title != null)
            ? Text(
                title,
                style: style,
              )
            : const SizedBox.shrink(),
      ),
      Container(
        height: 33.h,
        width: 32.w,
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              height: 16.h,
              margin: EdgeInsets.zero,
              width: 2.w,
              color: color,
            ),
            Container(
                height: 10.h,
                // width: 40.w,
                decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2.r),
                    shape: BoxShape.circle),
                child: Center(
                    child: Container(
                  decoration: BoxDecoration(
                      color: AppColor.kStatusBarPrimaryColor.value,
                      shape: BoxShape.circle),
                ))),
          ],
        ),
      ),
    ],
  );
}
