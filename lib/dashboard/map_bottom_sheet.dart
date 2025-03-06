import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../assets/assets.dart';
import '../taxi/widget/taxi_timer_widget.dart';
import '../widget/styles/app_style.dart';
import '../widget/styles/colors.dart';
import 'controller/dashboard_page_controller.dart';

class MapBottomSheet extends StatelessWidget {
  const MapBottomSheet({super.key, required this.skipTap});

  final VoidCallback? skipTap;

  @override
  Widget build(BuildContext context) {
    final DashBoardController controller = Get.find();
    return _bottomWidget(controller);
  }

  Widget _bottomWidget(DashBoardController controller) {
    return Container(
      color: AppColor.kSplashStatusBar.value,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: 15.w, top: 4.h, bottom: 10.h, right: 15.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: Text(
                    "Book A Ride".tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppColor.kPrimaryTextColor.value,
                        fontSize: AppFontSize.medium.value,
                        fontWeight: AppFontWeight.semibold.value),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          // gradient: secondaryLinearColor,
                          color: AppColor.kLightPrimary.value,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 15.w, right: 1.w, top: 3.h, bottom: 3.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => controller.moveToDropPage(),
                                  child: Row(
                                    children: [
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: SvgPicture.asset(
                                          Assets.search,
                                          height: 10.h,
                                          width: 10.w,
                                          color:
                                              AppColor.kLightTextPrimary.value,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Text(
                                        "Where To".tr,
                                        style: TextStyle(
                                            fontSize: AppFontSize.small.value,
                                            fontWeight:
                                                AppFontWeight.normal.value,
                                            color: AppColor
                                                .kLightTextPrimary.value),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 15.w, right: 15.w),
                                child: Material(
                                  color: AppColor.kBackGroundColor.value,
                                  borderRadius: BorderRadius.circular(25.r),
                                  child: InkWell(
                                    onTap: () {
                                      showTaxiBookingTimerWidgetNew(
                                          searchEnable: true,
                                          onTap: (selectDateTime) {
                                            controller.commonPlaceController
                                                .setBookLaterDateTime(
                                              dateTime: selectDateTime,
                                            );
                                            controller.moveToDropPage();
                                            return;
                                          });
                                    },
                                    borderRadius: BorderRadius.circular(25.r),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(25.r)),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.w,
                                            right: 5.w,
                                            top: 4.h,
                                            bottom: 4.h),
                                        child: Row(
                                          children: [
                                            Icon(
                                                Icons
                                                    .access_time_filled_rounded,
                                                size: 12.r),
                                            SizedBox(width: 4.w),
                                            Text(
                                              "Now".tr,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColor
                                                      .kPrimaryIconColor.value,
                                                  fontSize:
                                                      AppFontSize.medium.value,
                                                  fontWeight: AppFontWeight
                                                      .semibold.value),
                                            ),
                                            SizedBox(width: 4.w),
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(top: 2.h),
                                              child: Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 15.r),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Material(
                      borderRadius: BorderRadius.circular(16.r),
                      color: AppColor.kLightPrimary.value,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(25.r),
                        onTap: skipTap,
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: 8.w, left: 8.w, top: 5.h, bottom: 5.h),
                          child: Text(
                            "Skip".tr,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColor.kPrimaryTextColor.value,
                                fontSize: AppFontSize.medium.value,
                                fontWeight: AppFontWeight.semibold.value),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 15.w),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _lineWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 2.h,
            width: 25.w,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(25.r)),
          )
        ],
      ),
    );
  }
}
