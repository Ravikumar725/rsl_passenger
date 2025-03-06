import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../widget/custom_button.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/text_field.dart';
import '../controller/taxi_controller.dart';


bottomSheetPromoCode() {
  final controller = Get.find<TaxiController>();

  return Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.r),
                topRight: Radius.circular(10.r))),
        child: Padding(
          padding:
              EdgeInsets.only(top: 12.h, left: 14.w, right: 14.w, bottom: 8.w),
          child: Obx(
            () => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controller.showActivePromo.value
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Active promo code",
                            style: TextStyle(
                                color: AppColor.kPrimaryTextColor.value,
                                fontSize: AppFontSize.large.value,
                                fontWeight: AppFontWeight.semibold.value),
                          ),
                          _spacer(),
                          Container(
                            width: double.maxFinite,
                            decoration: BoxDecoration(
                              color:
                                  AppColor.kPrimaryColor.value.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 0.h,
                                  left: 10.w,
                                  right: 0.w,
                                  bottom: 0.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: Text(
                                      controller.activePromoCode.value
                                          .toUpperCase(),
                                      style: TextStyle(
                                          color: AppColor.kBlack.value,
                                          fontSize: AppFontSize.medium.value),
                                    ),
                                  ),
                                  Center(
                                    child: CustomButton(
                                      onTap: () => {
                                        Get.back(),
                                        // controller.callApplyPromoApi(controller
                                        //     .activePromoCode.value
                                        //     .trim()
                                        //     .toUpperCase())
                                      },
                                      color: Colors.transparent,
                                      borderRadius: 0,
                                      borderColor: Colors.transparent,
                                      linearColor: trans,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5.w, vertical: 5.h),
                                      height: 25.h,
                                      width: 60.h,
                                      text: "Use this".toUpperCase(),
                                      style: TextStyle(
                                        color: AppColor.kPrimaryColor.value,
                                        fontSize: AppFontSize.medium.value,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          _spacer(),
                          Center(
                            child: Text(
                              "Or".toUpperCase(),
                              style: TextStyle(
                                  color:
                                      AppColor.kSecondaryContainerBorder.value,
                                  fontSize: AppFontSize.small.value,
                                  fontWeight: AppFontWeight.normal.value),
                            ),
                          ),
                          _spacer(),
                          Text(
                            "Enter manually",
                            style: TextStyle(
                                color: AppColor.kPrimaryTextColor.value,
                                fontSize: AppFontSize.large.value,
                                fontWeight: AppFontWeight.semibold.value),
                          ),
                          _spacer(),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Add Promo",
                                style: TextStyle(
                                    color: AppColor.kPrimaryTextColor.value,
                                    fontSize: AppFontSize.dashboardDescription.value,
                                    fontWeight: AppFontWeight.semibold.value),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 6.h,horizontal: 6.w),
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColor
                                          .kLightPrimary.value),
                                  child: Icon(
                                    size: 22.r,
                                    Icons.clear,
                                    color: AppColor.kPrimaryTextColor.value.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          _spacer(),
                          _divider(),
                          _spacer(),
                          _spacer(),
                        ],
                      ),
                CustomTextField(
                  autofocus: true,
                  enable: true,
                  textController: controller.promoCodeController,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.characters,
                  style: TextStyle(
                      fontSize: AppFontSize.medium.value,
                      fontWeight: AppFontWeight.normal.value,
                      color: AppColor.kPrimaryTextColor.value),
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
                    hintText: "Enter Promo code",
                    hintStyle: TextStyle(
                        color: AppColor.kLightTextPrimary.value,
                        fontWeight: AppFontWeight.semibold.value,
                        fontSize: AppFontSize.medium.value),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColor.kLightTextPrimary.value),
                        borderRadius: BorderRadius.circular(8.r)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppColor.kSecondaryContainerBorder.value),
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                _spacer(),
                _spacer(),
                _divider(),
                _spacer(),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () => {
                          Get.back(),
                          controller.validatePromoCode(),
                        },
                        borderRadius: 20.r,
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 4.h),
                        height: 35.h,
                        text: "Apply".toUpperCase(),
                        style: TextStyle(
                          color: AppColor.kPrimaryTextColor.value,
                          fontSize: AppFontSize.medium.value,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true);
}

Container _divider() {
  return Container(
    height: 0.5.h,
    width: double.maxFinite,
    color: AppColor.kPrimaryColor.value.withOpacity(0.2),
  );
}

SizedBox _spacer() {
  return SizedBox(
    height: 12.h,
  );
}
