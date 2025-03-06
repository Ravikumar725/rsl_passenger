import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../network/services.dart';
import '../../widget/custom_button.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';

showTaxiBookingTimerWidgetNew(
    {bool searchEnable = false,
    bool laterEnable = false,
    Function()? setCurrentTime,
    required VoidCallback? Function(DateTime selectDateTime) onTap}) {
  final minDate = DateTime.now();
  const difference = 30;
  final initialDate = minDate.add(const Duration(minutes: difference));
  var selectDateTime = initialDate.add(const Duration(milliseconds: 100));

  Get.bottomSheet(
    SingleChildScrollView(child:
    Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Text(
                    laterEnable
                        ? "Change your pickup time"
                         : 'Select your pickup time'.tr,
                    style: TextStyle(
                        fontSize: AppFontSize.info.value,
                        fontWeight: AppFontWeight.bold.value,
                        fontFamily: "Poppins"),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 250.w,
          width: double.maxFinite,
          child: CupertinoTheme(
            data: CupertinoThemeData(
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(
                    textStyle:
                        TextStyle(fontSize: AppFontSize.smallMedium.value))),
            child: CupertinoDatePicker(
              minimumYear: 2010,
              maximumYear: 2025,
              minuteInterval: 1,
              minimumDate: initialDate,
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: initialDate,
              onDateTimeChanged: (DateTime selectedTime) {
                selectDateTime = selectedTime;
              },
            ),
          ),
        ),
        CustomButton(
            height: 33.h,
            width: double.maxFinite,
            color: AppColor.kPrimaryColor.value,
            text: "Select this DateTime".tr,
            onTap: () {
              printLogs("Select date is $selectDateTime");
              if (selectDateTime.isAfter(initialDate)) {
                Get.back();
                onTap(selectDateTime);
              } else {
                Get.snackbar(
                    'error'.tr, 'Booking After 30Minutes of CurrentTime'.tr,
                    backgroundColor: AppColor.kGetSnackBarColor.value);
              }
            }),
        laterEnable
            ? InkWell(
                onTap: setCurrentTime,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: AppColor.kLightTextPrimary.value
                              .withOpacity(0.5))),
                  margin:
                      EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Center(
                      child: Text(
                    "Set to current date and time",
                    style: TextStyle(fontFamily: "Poppins"),
                  )),
                ),
              )
            : InkWell(
                onTap: () {
                  Get.back();
                },
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                          color: AppColor.kLightTextPrimary.value
                              .withOpacity(0.5))),
                  margin:
                      EdgeInsets.symmetric(horizontal: 12.h, vertical: 10.w),
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: const Center(child: Text("Cancel")),
                ),
              ),
        SizedBox(
          height: 20.h,
        ),
      ],
    )),
    isDismissible: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12.r),
        topLeft: Radius.circular(12.r),
      ),
    ),
    backgroundColor: Colors.white,
    enableDrag: true,
  );

// print("BOTTOM VALUE ${onTap(initialDate)}");

// return onTap(initialDate,selectDateTime,changeValue);
}
