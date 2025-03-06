import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rsl_passenger/network/services.dart';
import 'package:rsl_passenger/widget/utils/global_utils.dart';
import '../../assets/assets.dart';
import '../../dashboard/data/get_core_api_data.dart';
import '../../routes/routes.dart';
import '../../widget/custom_button.dart';
import '../../widget/utils/enums.dart';
import '../../widget/utils/safe_area_container.dart';
import '../../widget/app_loader.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/map_style.dart';
import '../controller/taxi_controller.dart';
import '../data/nearest_drivers_list_api_data.dart';
import '../widget/back_button.dart';
import '../../shimmer_layout/car_model_shimmer_widget.dart';
import '../widget/bottom_sheet_payment_methods.dart';
import '../widget/bottom_sheet_promo_code.dart';
import '../widget/now_booking_widget.dart';
import 'booking_loading_page.dart';
import 'destination/view/destination_page.dart';

class TaxiHomePage extends GetView<TaxiController> {
  const TaxiHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: controller.isSheetFullyExpanded,
        builder: (context, isExpanded, child) {
          return SafeAreaContainer(
            statusBarColor: isExpanded
                ? AppColor.kStatusBarPrimaryColor.value
                : Colors.transparent,
            themedark: false,
            // ignore: deprecated_member_use
            child: WillPopScope(
              onWillPop: () async {
                // controller.onBackPressed;
                controller.onBackToConfirmPickUp;
                return true;
              },
              child: Scaffold(
                backgroundColor: AppColor.kBackGroundColor.value,
                body: Stack(
                  children: [
                    _googleMapWidget(),
                    _backButtonWidget(),
                    _draggableSheetWidget(),
                  ],
                ),
              ),
            ),
          );
        });
  }

  _draggableSheetWidget() {
    return Obx(
      () => controller.bookingState.value == BookingState.kBookingStateTwo
          ? const BookingLoadingPage()
          : Stack(
              children: [
                // First Draggable Sheet
                ValueListenableBuilder<double>(
                    valueListenable: controller.draggableSheetHeight,
                    builder: (context, draggableHeight, child) {
                      return SafeArea(
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.48,
                          minChildSize: 0.48,
                          maxChildSize: 1.0,
                          controller: controller.isControllerAttached.value
                              ? controller.draggableScrollableController
                              : controller.draggableScrollableController =
                                  DraggableScrollableController(),
                          builder: (context, scrollController) {
                            controller.isControllerAttached.value = true;
                            controller.draggableScrollableController
                                .addListener(() {
                              final position =
                                  controller.draggableScrollableController.size;
                              if (position == 1.0) {
                                controller.isSheetFullyExpanded.value = true;
                                controller.updateSheetHeight(position);
                                if (controller
                                        .bottomDraggableScrollableController
                                        .size >
                                    0.05) {
                                  controller.bottomDraggableScrollableController
                                      .animateTo(
                                    0.01,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                }
                              } else if (position >= 0.65) {
                                // If position is 0.65 or more, reduce to 0.08
                                controller.isSheetFullyExpanded.value = false;
                                controller.bottomDraggableScrollableController
                                    .animateTo(
                                  0.01,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                controller.isSheetFullyExpanded.value = false;
                                controller.bottomDraggableScrollableController
                                    .animateTo(
                                  0.13,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                            return _bottomSheetWidget(
                                controller, scrollController);
                          },
                        ),
                      );
                    }),
                // Second Draggable Sheet (Floating Button Style)
                Obx(
                  () {
                    double initialSize = controller.secondSheetSize.value;
                    return DraggableScrollableSheet(
                      initialChildSize: initialSize,
                      minChildSize: 0.01,
                      maxChildSize: 0.14,
                      controller:
                          controller.bottomDraggableScrollableController,
                      builder: (context, scrollController) {
                        return _buttonWidget(controller, scrollController);
                      },
                    );
                  },
                )
              ],
            ),
    );
  }

  Container _buttonWidget(
      TaxiController controller, ScrollController scrollController) {
    return Container(
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColor.kBackGroundColor.value,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(20.r), topLeft: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: AppColor.kPrimaryTextColor.value.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: scrollController,
        child: Column(
          children: [
            SizedBox(height: 4.h),
            _cardAndPromoCodeView(),
            SizedBox(height: 8.h),
            Obx(
              () => controller.isLaterBooking
                  ? CustomButton(
                      onTap: () {
                        !controller.showButtonLoader.value
                            ? controller.onBookTaxiClicked()
                            : const SizedBox.shrink();
                      },
                      color: Colors.grey,
                      text:
                          "${'Schedule'.tr} ${controller.selectedCarModelList.value.modelName?.toUpperCase()}",
                      secondaryText: controller.laterBookingDateTime,
                      height: 35.h,
                      width: double.maxFinite,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      linearColor: redLinearColor,
                      isLoader: controller.showButtonLoader.value,
                      isTaxiLoader: true,
                    )
                  : controller.availableCarCount.value > 0
                      ? CustomButton(
                          onTap: () {
                            !controller.showButtonLoader.value
                                ? controller.onBookTaxiClicked()
                                : const SizedBox.shrink();
                          },
                          text:
                              "${'Book a'.tr} ${controller.selectedCarModelList.value.modelName?.toUpperCase()}",
                          height: 35.h,
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          isLoader: controller.showButtonLoader.value,
                          isTaxiLoader: true,
                        )
                      : CustomButton(
                          onTap: () {
                            controller.showTaxiBookingTimer();
                          },
                          color: Colors.grey,
                          text: "Schedule a ride".tr,
                          height: 35.h,
                          width: double.maxFinite,
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          linearColor: redLinearColor,
                          isLoader: controller.showButtonLoader.value,
                          isTaxiLoader: true,
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Padding _cardAndPromoCodeView() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: _card()),
          Expanded(flex: 2, child: _promoCode())
        ],
      ),
    );
  }

  Material _card() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(5.r),
        onTap: () => bottomSheetPaymentMethods(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: AppColor.kPrimaryButtonBackGround.value,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Obx(
                    () => controller.paymentType == controller.PAYMENT_ID_CARD
                        ? Icon(
                            Icons.credit_card,
                            color: AppColor.kWhiteIconColor.value,
                            size: 12.r,
                          )
                        : Image.asset(
                            Assets.moneyImg,
                            height: 12,
                            width: 12,
                            color: AppColor.kWhiteIconColor.value,
                          )),
              ),
              SizedBox(
                width: 8.w,
              ),
              Obx(
                () => Text(
                  controller.paymentType == controller.PAYMENT_ID_CARD
                      ? "Card"
                      : "Cash",
                  style: TextStyle(
                      color: AppColor.kPrimaryButtonBackGround.value,
                      fontSize: AppFontSize.medium.value),
                ),
              ),
              SizedBox(
                width: 45.w,
              ),
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 18.r,
                  color: AppColor.kSecondaryContainerBorder.value,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Material _promoCode() {
    return Material(
      color: Colors.transparent,
      child: Obx(
        () => InkWell(
          borderRadius: BorderRadius.circular(5.r),
          onTap: () => bottomSheetPromoCode(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.h),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    color: AppColor.kPrimaryButtonBackGround.value,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: controller.appliedPromoCode.value.isNotEmpty
                      ? InkWell(
                          child: Icon(
                            CupertinoIcons.clear_thick,
                            color: AppColor.kWhiteIconColor.value,
                            size: 11.r,
                          ),
                          onTap: () => controller.clearPromoCode(),
                        )
                      : SvgPicture.asset(
                          Assets.promocode,
                          height: 10.h,
                          width: 10.w,
                          color: AppColor.kWhiteIconColor.value,
                        ),
                ),
                SizedBox(width: 8.w),
                Text(
                  controller.appliedPromoCode.value.isNotEmpty
                      ? controller.appliedPromoCode.value
                      : "PROMO CODE",
                  maxLines: 1,
                  style: TextStyle(
                      color: AppColor.kPrimaryButtonBackGround.value,
                      fontSize: AppFontSize.medium.value),
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18.r,
                    color: AppColor.kSecondaryContainerBorder.value,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _downButton({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.h),
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 1)
              ]),
          child: Icon(
            Icons.arrow_downward_sharp,
            color: AppColor.kPrimaryColor.value,
          )),
    );
  }

  _bottomSheetWidget(
      TaxiController controller, ScrollController scrollController) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0.w),
      child: ValueListenableBuilder<bool>(
          valueListenable: controller.isSheetFullyExpanded,
          builder: (context, isExpanded, child) {
            return Container(
              decoration: BoxDecoration(
                color: AppColor.kBackGroundColor.value,
                borderRadius: BorderRadius.only(
                  topRight:
                      isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
                  topLeft:
                      isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
                ),
              ),
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ValueListenableBuilder<bool>(
                          valueListenable: controller.isSheetFullyExpanded,
                          builder: (context, isExpanded, child) {
                            return isExpanded
                                ? const SizedBox.shrink()
                                : _divider();
                          }),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ValueListenableBuilder<bool>(
                                    valueListenable:
                                        controller.isSheetFullyExpanded,
                                    builder: (context, isExpanded, child) {
                                      return isExpanded
                                          ? _downButton(onTap: () {
                                              if (controller
                                                  .draggableScrollableController
                                                  .isAttached) {
                                                if (controller
                                                    .isSheetFullyExpanded
                                                    .value) {
                                                  controller
                                                      .isSheetFullyExpanded
                                                      .value = false;
                                                  controller
                                                      .draggableScrollableController
                                                      .animateTo(
                                                    0.45, // Or any desired size
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                }
                                              }

                                              if (controller
                                                  .bottomDraggableScrollableController
                                                  .isAttached) {
                                                if (controller
                                                        .bottomDraggableScrollableController
                                                        .size >
                                                    0.13) {
                                                  controller
                                                      .bottomDraggableScrollableController
                                                      .animateTo(
                                                    0.13, // Or any desired size
                                                    duration: const Duration(
                                                        milliseconds: 300),
                                                    curve: Curves.easeInOut,
                                                  );
                                                }
                                              }
                                            })
                                          : Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 0.w,
                                                  vertical: 0.h),
                                              child: textView(
                                                  text: "Ride details",
                                                  fontWeight: AppFontWeight
                                                      .semibold.value,
                                                  fontSize: AppFontSize
                                                      .dashboardTitle.value));
                                    }),
                                ValueListenableBuilder<bool>(
                                    valueListenable:
                                        controller.isSheetFullyExpanded,
                                    builder: (context, isExpanded, child) {
                                      return isExpanded
                                          ? const SizedBox.shrink()
                                          : _switchRider();
                                    }),
                              ],
                            ),
                            ValueListenableBuilder<bool>(
                                valueListenable:
                                    controller.isSheetFullyExpanded,
                                builder: (context, isExpanded, child) {
                                  return isExpanded
                                      ? Padding(
                                          padding: EdgeInsets.only(top: 4.h),
                                          child: _switchRider(),
                                        )
                                      : const SizedBox.shrink();
                                }),
                            // const Spacer(),
                            Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Obx(
                                () => NowBookingWidget(
                                  isLaterBooking: controller.isLaterBooking,
                                  laterBookingDateTime:
                                      controller.laterBookingDateTime,
                                  onTab: () {
                                    controller.showTaxiBookingTimer();
                                  },
                                ),
                              ),
                              // child: _timePickButtonWidget(),
                            )
                          ],
                        ),
                      ),
                      Obx(() => _getResponseStatusFromApi(
                            status: controller.carModelApiStatus.value.status,
                            msg: controller.carModelApiStatus.value.message,
                          )),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget _getResponseStatusFromApi({String? msg, int? status}) {
    if (status == 15) {
      printLogs("status$status");
      return Column(
        children: [
          SizedBox(
            height: 200.h,
            child: const CarModelShimmer(),
          ),
        ],
      );
    } else if (status == 0 || status == 1) {
      printLogs("status$status");
      return ListView.builder(
          padding: EdgeInsets.only(top: 4.h),
          shrinkWrap: true,
          itemCount: controller.carModelList.length,
          physics: const ClampingScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return _carModelListWidget(
                controller, controller.carModelList[index], index);
          });
    } else if (status == 400) {
      printLogs("status$status");
      return Expanded(
        child: apiStatusWidget(
          text: "Check your connection".tr,
          backArrow: false,
        ),
      );
    } else {
      return Expanded(
        child: apiStatusWidget1(
          backArrow: false,
          text: "${controller.carModelApiStatus.value.message}",
        ),
      );
    }
  }

  Obx _carModelListWidget(
      TaxiController controller, CarModelData carModel, int index) {
    return Obx(
      () {
        final CarModelData carModelData = carModel;
        final bool isSelected = carModel.isSelected ?? false;

        final String aed =
            "${carModelData.approximateFare}${(carModelData.approximateFareWithWaitingFare != 0) ? " - "
                "${carModelData.approximateFareWithWaitingFare}" : ""}";
        final String originalFare = "${carModelData.originalFare} ";
        final String fareRange = "${carModelData.fareRange}";
        final String? imageUrl = carModel.isSelected == true
            ? carModel.focusImage
            : carModel.unfocusImage;

        if (index == 0) {
          Future.microtask(() {
            controller.approximateFare.value = aed;
            controller.tripFare.value = fareRange;
            controller.tripFare.refresh();
          });
        }
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(10.r),
                onTap: () {
                  controller.bottomDraggableScrollableController.animateTo(
                    0.13,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  controller.draggableScrollableController.animateTo(
                    0.45,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                  controller.onCarModelSelected(index, aed);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                  margin: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 1,
                              spreadRadius: 1,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : [],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 90.w,
                          height: 45.h,
                          padding: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage("$imageUrl"),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 12.w,
                        ),
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "${carModelData.modelName}",
                                    style: TextStyle(
                                        color: isSelected
                                            ? AppColor.kPrimaryColor.value
                                            : AppColor.kPrimaryTextColor.value,
                                        fontSize: AppFontSize.medium.value,
                                        fontWeight:
                                            AppFontWeight.semibold.value),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 6.h,
                              ),
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      size: 14.r,
                                      color: AppColor.kBlack.value
                                          .withOpacity(0.4)),
                                  SizedBox(
                                    width: 4.w,
                                  ),
                                  Text(
                                    " ${carModelData.modelSize}",
                                    style: TextStyle(
                                        color: AppColor.kPrimaryTextColor.value
                                            .withOpacity(0.7),
                                        fontSize: AppFontSize.verySmall.value,
                                        fontWeight: AppFontWeight.normal.value),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 4.h,
                              ),
                              Text(
                                "${carModel.description} ",
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColor.kLightTextPrimary.value
                                        .withOpacity(0.7)),
                              ),
                            ],
                          ),
                        ),
                        if (controller.commonPlaceController.dropLatLng.value
                                    .latitude !=
                                0 &&
                            controller.isDistanceCalcCompleted) ...[
                          Expanded(
                            flex: 2,
                            child: controller.isPromoApplied.value
                                ? Column(
                                    children: [
                                      Text(
                                        '${GlobalUtils.currency} $fareRange',
                                        style: TextStyle(
                                            color: AppColor
                                                .kPrimaryTextColor.value,
                                            fontSize:
                                                AppFontSize.verySmall.value,
                                            fontWeight:
                                                AppFontWeight.semibold.value),
                                      ),
                                      SizedBox(
                                        height: 3.h,
                                      ),
                                      Text(
                                        '${GlobalUtils.currency} $originalFare',
                                        style: TextStyle(
                                            decoration:
                                                TextDecoration.lineThrough,
                                            color: AppColor
                                                .kSecondaryContainerBorder
                                                .value,
                                            fontSize:
                                                AppFontSize.verySmall.value,
                                            fontWeight:
                                                AppFontWeight.semibold.value),
                                      )
                                    ],
                                  )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        ' ${GlobalUtils.currency} $aed',
                                        style: TextStyle(
                                            color: AppColor
                                                .kPrimaryTextColor.value,
                                            fontSize: AppFontSize.small.value,
                                            fontWeight:
                                                AppFontWeight.semibold.value),
                                      ),
                                      SizedBox(height: 2.h),
                                    ],
                                  ),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 110.w),
              child: Container(
                height: 1.h,
                width: double.maxFinite,
                color: isSelected
                    ? AppColor.kLightPrimary.value.withOpacity(0.4)
                    : Colors.transparent,
              ),
            )
          ],
        );
      },
    );
  }

  InkWell _switchRider() {
    return InkWell(
      onTap: () {
        // bottomSheetGuestList();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 5.h),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.all(0.r),
              child: Icon(
                Icons.person_2_outlined,
                color: AppColor.kLightTextPrimary.value,
                size: 18.r,
              ),
            ),
            SizedBox(
              width: 8.w,
            ),
            Text(
              "Switch Rider".tr,
              style: TextStyle(
                  color: AppColor.kLightTextPrimary.value,
                  fontSize: AppFontSize.small.value),
            ),
            Padding(
              padding: EdgeInsets.only(top: 2.h),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 18.r,
                color: AppColor.kBlack.value.withOpacity(0.5),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 2.h,
            width: 40.w,
            decoration: BoxDecoration(
                color: AppColor.kBlack.value.withOpacity(0.4),
                borderRadius: BorderRadius.circular(20.r)),
          )
        ],
      ),
    );
  }

  Widget _googleMapWidget() {
    return _googleMap();
  }

  Widget _backButtonWidget() {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaxiCustomBackButton(
            onTap: () {
              Get.back();
              controller.placeSearchPageController.pickController.text = '';
              controller.commonPlaceController.pickUpLocation.value =
                  controller.commonPlaceController.currentAddress.value;
              controller.commonPlaceController.pickUpSubtitle.value = '';
              controller.placeSearchPageController.destinationController.text =
                  '';
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (controller.confirmPickupController
                    .draggableScrollableControllerPick.isAttached) {
                  controller
                      .confirmPickupController.draggableScrollableControllerPick
                      .animateTo(
                    0.28,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                } else {
                  printLogs("DraggableScrollableController is NOT attached!");
                }
              });
              controller.confirmPickupController.isSheetFullyExpandedPick
                  .value = false;
              controller.confirmPickupController.initialCameraPosition();
            },
            color: AppColor.kPrimaryTextColor.value,
          ),
        ],
      ),
    );
  }

  Widget _googleMap() {
    return Obx(
      () => GoogleMap(
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: false,
        tiltGesturesEnabled: false,
        padding: EdgeInsets.only(bottom: 10.h, left: 6.w),
        trafficEnabled: controller.trafficEnabled.value,
        mapType: controller.mapType.value,
        initialCameraPosition: CameraPosition(
          target: controller.commonPlaceController.pickUpLatLng.value,
          zoom: 15,
        ),
        polylines: Set<Polyline>.from(controller.polyline),
        markers: <Marker>{
          ...controller.markers,
          ...controller.pickUpDropMarkers
        },
        onMapCreated: (GoogleMapController controller) {
          controller.setMapStyle(MapStyle.json);
          this.controller.mapController = controller;
          this.controller.addPickUpDropMarkers(fetchRoute: true);
        },
        onCameraMove: (CameraPosition position) {
          // Update the animation value based on the camera position
          controller.animationValue.value = position.zoom / 20;
        },
      ),
    );
  }
}

Widget apiStatusWidget1(
    {String? text, bool? loder = false, bool backArrow = true}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      backArrow == true
          ? CustomBackButton(
              color: AppColor.kPrimaryColor.value,
            )
          : const SizedBox.shrink(),
      Expanded(
        child: loder == true
            ? const Center(child: AppLoader())
            : Center(
                child: Text("$text"),
              ),
      ),
    ],
  );
}

Widget apiStatusWidget(
    {String? text, bool? loder = false, bool backArrow = true}) {
  return SafeArea(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        backArrow == true
            ? CustomBackButton(
                color: AppColor.kPrimaryColor.value,
              )
            : const SizedBox.shrink(),
        Expanded(
          child: loder == true
              ? const Center(child: AppLoader())
              : Center(
                  child: Text("$text"),
                ),
        ),
      ],
    ),
  );
}
