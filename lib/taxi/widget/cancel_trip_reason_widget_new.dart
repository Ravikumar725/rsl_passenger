import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../widget/custom_button.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import 'back_button.dart';
import 'custom_app_bar.dart';

class CancelReasonsBottomSheet extends StatefulWidget {
  final Function(String) cancelTripAction;
  final bool? buttonLoader;
  final VoidCallback backBtnAction;

  const CancelReasonsBottomSheet({
    super.key,
    required this.cancelTripAction,
    required this.backBtnAction,
    this.buttonLoader,
  });

  @override
  _CancelReasonsBottomSheetState createState() =>
      _CancelReasonsBottomSheetState(
        cancelTripAction: cancelTripAction,
        backBtnAction: backBtnAction,
      );
}

class _CancelReasonsBottomSheetState extends State<CancelReasonsBottomSheet> {
  final List<String> cancelReasonArray = [
    "Captain is too far away",
    "I don't need a ride anymore",
    "Captain asked me to cancel",
    "I found another ride",
    "Car wasn't suitable",
    "Captain had low rating",
    "I wasn't ready",
    "I booked by mistake",
    "Other",
    "Captain not moving",
    "I want to change my booking details",
    "I want to change my booking",
    "I want to change my details",
  ];

  String cancellingReason = "";
  String otherReason = "";
  final Function(String) cancelTripAction;
  final VoidCallback backBtnAction;

  _CancelReasonsBottomSheetState({
    required this.cancelTripAction,
    required this.backBtnAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures it adjusts to content size
        children: [
          Container(
            height: 5,
            width: 50,
            margin: EdgeInsets.only(top: 10.h, bottom: 20.h),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Reason of cancel",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: ListView.builder(
              physics: const ScrollPhysics(),
              itemCount: cancelReasonArray.length +
                  (cancellingReason == "Other Reason" ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < cancelReasonArray.length) {
                  // Render RadioButtonField for each reason
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 0.h),
                    child: RadioButtonField(
                      id: index,
                      label: cancelReasonArray[index],
                      color: Colors.black,
                      textSize: 16.sp,
                      isMarked: cancellingReason == cancelReasonArray[index],
                      callback: (selected) {
                        setState(() {
                          cancellingReason = cancelReasonArray[selected];
                          if (cancellingReason != "Other Reason") {
                            otherReason = "";
                          }
                        });
                      },
                    ),
                  );
                } else {
                  // Render TextField for "Other Reason"
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: "Reason",
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          otherReason = value;
                        });
                      },
                    ),
                  );
                }
              },
            ),
          ),
          SizedBox(height: 30.h),
          _cancelButton(),
        ],
      ),
    );
  }

  Widget _cancelButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SizedBox(
        width: double.infinity,
        child: CustomButton(
          onTap: () {
            if ((cancellingReason == "Other Reason") && (otherReason == "")) {
              Get.snackbar("Message", "Please enter cancelling reason",
                  backgroundColor: Colors.grey);
            } else if (cancellingReason == "") {
              Get.snackbar("Message", "Please select cancelling reason",
                  backgroundColor: Colors.grey);
            } else {
              cancelTripAction((cancellingReason == "Other Reason")
                  ? otherReason
                  : cancellingReason);
            }
          },
          text: "Submit",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 16.sp,
          ),
          height: 40.h,
          isLoader: widget.buttonLoader,
        ),
      ),
    );
  }
}

class CancelReasonsWidgetNew extends StatefulWidget {
  final Function(String) cancelTripAction;
  final bool? buttonLoader;
  final VoidCallback backBtnAction;

  const CancelReasonsWidgetNew({
    super.key,
    required this.cancelTripAction,
    required this.backBtnAction,
    this.buttonLoader,
  });
  @override
  _CancelReasonsWidgetNewState createState() => _CancelReasonsWidgetNewState(
        cancelTripAction: cancelTripAction,
        backBtnAction: backBtnAction,
      );
}

class _CancelReasonsWidgetNewState extends State<CancelReasonsWidgetNew> {
  List<String> cancelReasonArray = [
    "Cab delay",
    "Changed travel plan",
    "Booking placed error",
    "Driver didn't show up",
    "Driver asked to cancel the trip",
    "Other Reason"
  ];
  String cancellingReason = "";
  String otherReason = "";
  final Function(String) cancelTripAction;
  final VoidCallback backBtnAction;

  _CancelReasonsWidgetNewState({
    required this.cancelTripAction,
    required this.backBtnAction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: MyAppBar(
        themedark: false,
        title: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 5.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomBackButton(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 15.h),
                    color: AppColor.kPrimaryColor.value,
                  ),
                  Text(
                    "Reason of cancel",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: AppFontWeight.bold.value,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 30.w,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              for (int i = 0; i < cancelReasonArray.length; i++)
                RadioButtonField(
                  id: i,
                  label: cancelReasonArray[i],
                  color: Colors.black,
                  textSize: 16.sp,
                  isMarked: cancellingReason == cancelReasonArray[i],
                  callback: (selected) {
                    setState(() {
                      cancellingReason = cancelReasonArray[selected];
                      if (cancellingReason != "Other Reason") {
                        otherReason = "";
                      }
                    });
                  },
                ),
              if (cancellingReason == "Other Reason")
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Reason",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          otherReason = value;
                        },
                      );
                    },
                  ),
                ),
              SizedBox(
                height: 30.h,
              ),
              _cancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cancelButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Container(
        color: AppColor.kBackGroundColor.value,
        width: 150.w,
        child: CustomButton(
          onTap: () {
            if ((cancellingReason == "Other Reason") && (otherReason == "")) {
              Get.snackbar("Message", "Please enter cancelling reason",
                  backgroundColor: AppColor.kGetSnackBarColor.value);
            } else if (cancellingReason == "") {
              Get.snackbar("Message", "Please select cancelling reason",
                  backgroundColor: AppColor.kGetSnackBarColor.value);
            } else {
              cancelTripAction((cancellingReason == "Other Reason")
                  ? otherReason
                  : cancellingReason);
            }
          },
          text: "Submit",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 16.sp),
          height: 35.h,
          isLoader: widget.buttonLoader,
        ),
      ),
    );
  }
}

class RadioButtonField extends StatelessWidget {
  final int id;
  final String label;
  final double size;
  final Color color;
  final double textSize;
  final bool isMarked;
  final Function(int) callback;

  const RadioButtonField({
    super.key,
    required this.id,
    required this.label,
    this.size = 22,
    this.color = Colors.black,
    this.textSize = 14,
    this.isMarked = false,
    required this.callback,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        callback(id);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Icon(
              isMarked ? Icons.check_circle_outline : Icons.circle_outlined,
              color: isMarked ? Colors.yellow : AppColor.kPrimaryColor.value,
              size: 25.sp,
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: textSize,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
