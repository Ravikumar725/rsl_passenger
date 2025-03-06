import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsl_passenger/widget/utils/global_utils.dart';
import '../../assets/assets.dart';
import '../../network/services.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/enums.dart';
import '../../widget/utils/map_style.dart';
import '../../widget/utils/safe_area_container.dart';
import '../controller/taxi_controller.dart';
import '../widget/booking_details_widget.dart';
import '../widget/cancel_bottom_alert_widget.dart';
import '../widget/custom_map_marker.dart';
import '../widget/map_satellite_button_widget.dart';
import '../widget/need_our_help_widget.dart';
import '../widget/pickup_drop_item_widget.dart';
import '../widget/traffic_button_widget.dart';
import 'destination/view/destination_page.dart';

class BookingLoadingPage extends GetView<TaxiController> {
  const BookingLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double mapPinHeight = screenHeight * 0.71; // 30% height

    // controller.moveToTrackingPage();
    return SafeAreaContainer(
      child: Scaffold(
        body: Stack(
          children: [
            SizedBox(
                height: MediaQuery.of(Get.context!).size.height / 1.5,
                child: _googleMap()),
            SizedBox(
              height: screenHeight * 0.67,
              child: SpinKitPulse(
                duration: const Duration(seconds: 2),
                color: AppColor.kPrimaryColor.value,
                size: double.maxFinite,
              ),
            ),
            Positioned(
              right: 0.w,
              left: 0.w,
              bottom: 0.h,
              child: SizedBox(
                height: mapPinHeight,
                child: _mapPin(),
              ),
            ),
            Positioned(
              bottom: MediaQuery.of(Get.context!).size.height / 2,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Obx(
                    () => MapSatelliteButtonWidget(
                      onTap: () {
                        controller.changeMapType();
                      },
                      iconSize: 18.r,
                      activeColor: AppColor.kPrimaryColor.value,
                      currentMapType: controller.mapType.value,
                      inactiveColor:
                          AppColor.kLightTextPrimary.value.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Obx(
                    () => TrafficButtonWidget(
                      onTap: () {
                        controller.changeTrafficView();
                      },
                      isTrafficEnabled: controller.trafficEnabled.value,
                      iconSize: 18.r,
                      activeColor: AppColor.kPrimaryColor.value,
                      inactiveColor:
                          AppColor.kPrimaryTextColor.value.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            _bottomDraggableSheet(),
          ],
        ),
      ),
    );
  }

  Widget _bottomDraggableSheet() {
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: true,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: AppColor.kStatusBarPrimaryColor.value,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: ScrollConfiguration(
              behavior: NoGlowScrollBehavior(),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const ScrollPhysics(),
                child: Column(
                  children: [
                    _line(),
                    sizedBox(height: 14.h),
                    _confirmPickUp(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget sizedBox({double? height}) {
    return SizedBox(
      height: height ?? 8.h,
    );
  }

  Widget _confirmPickUp() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bookingCreateWidget(),
        sizedBox(),
        _divider(),
        _bookingDetails(),
        sizedBox(),
        _divider(),
        _manageRide(),
      ],
    );
  }

  Widget _bookingCreateWidget() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textView(
            text: "Create a booking", // Display the booking status
            fontSize: AppFontSize.dashboardDescription.value,
            fontWeight: AppFontWeight.semibold.value,
          ),
          sizedBox(height: 12.h),
          Obx(() {
            return LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8.r),
              backgroundColor: Colors.grey[300],
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColor.kPrimaryColor.value),
              value: controller.progressValue.value,
            );
          }),
          sizedBox(height: 12.h),
          _pickUpDropWidget(),
        ],
      ),
    );
  }

  Widget _pickUpDropWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, right: 8.w),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      height: 10.h,
                      width: 10.w,
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColor.kPrimaryColor.value),
                          color: AppColor.kStatusBarPrimaryColor.value,
                          shape: BoxShape.circle),
                    ),
                    Obx(
                      () => controller
                                  .commonPlaceController.dropLocation.value !=
                              ''
                          ? Column(
                              children: [
                                _verticalDivider(
                                    AppColor.kContainerBorder.value, 40.h),
                                Container(
                                  height: 10.h,
                                  width: 10.w,
                                  decoration: BoxDecoration(
                                      color: AppColor.kContainerBorder.value,
                                      shape: BoxShape.circle),
                                ),
                              ],
                            )
                          : const SizedBox(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => PickupDropItemWidget(
                    title:
                        controller.commonPlaceController.pickUpLocation.value,
                    subtitle:
                        controller.commonPlaceController.pickUpSubtitle.value,
                    onEditTap: () {
                      controller.commonPlaceController.getPosition?.value =
                          GetPoistion.pin;
                    },
                    isEditShow: false,
                  ),
                ),
                sizedBox(height: 11.h),
                Obx(
                  () =>
                      controller.commonPlaceController.dropLocation.value == ''
                          ? _divider(height: 1.h)
                          : sizedBox(),
                ),
                Obx(
                  () =>
                      controller.commonPlaceController.dropLocation.value == ''
                          ? sizedBox(height: 11.h)
                          : sizedBox(height: 0.h),
                ),
                Obx(() =>
                    (controller.commonPlaceController.dropLocation.value != '')
                        ? PickupDropItemWidget(
                            title: controller
                                .commonPlaceController.dropLocation.value,
                            subtitle: controller
                                .commonPlaceController.dropSubtitle.value,
                            onEditTap: () {
                              controller.commonPlaceController.getPosition
                                  ?.value = GetPoistion.drop;
                            },
                            isEditShow: false,
                          )
                        : const SizedBox())
              ],
            ),
          )
        ],
      ),
    );
  }

  String bookingStatus({int? status}) {
    switch (status) {
      case 1:
        return "Finding your Captain";
      case 2:
        return "Checking optimal routes";
      case 3:
        return "Locating nearest Captain";
      default:
        return "Create a booking";
    }
  }

  Widget _divider({double? height}) {
    return Container(
      height: height ?? 4.h,
      color: AppColor.kLightPrimary.value,
    );
  }

  Widget _manageRide() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 12.h),
            child: textView(
                color: AppColor.kLightTextPrimary.value.withOpacity(0.5),
                text: 'Manage Ride'),
          ),
          BookingDetailsWidget(
              title: 'Need our help?',
              iconData: Icons.support_agent_outlined,
              iconSize: 25.r,
              onTab: () {
                needOurHelp(onCall: () {
                  Get.back();
                  // controller.dashboardController.launchPhoneDialPad(
                  //   phone:
                  //       "${controller.dashboardController.getApiData.value.adminContactPhone}",
                  // );
                }, onChat: () {
                  Get.back();
                  String input = controller.dashboardController.getApiData.value
                          .adminContactWhatsApp ??
                      "";
                  String result = input.replaceAll(RegExp(r'\s+'), '');
                  // controller.dashboardController.launchWhatsApp(phone: result);
                }, onHelpCenter: () {
                  Get.back();
                  // Get.toNamed(AppRoutes.helpCenter);
                });
              }),
          sizedBox(height: 2.h),
          Divider(
            indent: 35.w,
            color: AppColor.kLightPrimary.value,
          ),
          sizedBox(height: 2.h),
          BookingDetailsWidget(
              title: 'Cancel ride',
              iconData: Icons.cancel_outlined,
              iconColor: AppColor.kRedColour.value,
              iconSize: 25.r,
              titleColor: AppColor.kRedColour.value,
              onTab: () {
                cancelBottomAlert(cancelOnTab: (value) {
                  controller.onCancelClicked();
                });
              }),
        ],
      ),
    );
  }

  Widget _bookingDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
            child: textView(
              color: AppColor.kLightTextPrimary.value.withOpacity(0.5),
              text: 'Booking Details',
            ),
          ),
          Obx(
            () => BookingDetailsWidget(
              title: '${controller.selectedCarModelList.value.modelName}',
              imageUrl: '${controller.selectedCarModelList.value.focusImage}',
              imageHeight: 30.h,
              imageWidth: 30.w,
            ),
          ),
          Divider(
            indent: 35.w,
            color: AppColor.kLightPrimary.value,
          ),
          Obx(
            () => BookingDetailsWidget(
              title: controller.paymentType.value ==
                      controller.PAYMENT_ID_CARD.value
                  ? "Card"
                  : "Cash",
              imagePath: controller.paymentType.value ==
                      controller.PAYMENT_ID_CARD.value
                  ? Assets.creditCard
                  : Assets.money,
              imageHeight: 30.h,
              imageWidth: 30.w,
              iconColor: AppColor.kLightTextPrimary.value.withOpacity(0.7),
            ),
          ),
          Divider(
            indent: 35.w,
            color: AppColor.kLightPrimary.value,
          ),
          Obx(() {
            printLogs(
                "hii tripFare: ${controller.tripFare.value} ${controller.approximateFare.value}");
            return BookingDetailsWidget(
              title: 'Fare',
              fare:
                  "${GlobalUtils.currency} ${controller.isPromoApplied.value ? (controller.tripFare.value != "" && !controller.tripFare.value.contains("null") ? controller.tripFare.value : 0) : (controller.approximateFare.value != "" && !controller.approximateFare.value.contains("null") ? controller.approximateFare.value : 0)}",
              imagePath: Assets.moneyImg,
              imageHeight: 30.h,
              imageWidth: 30.w,
            );
          }),
        ],
      ),
    );
  }

  Widget _verticalDivider(Color color, double height) {
    return SizedBox(
      height: height,
      child: VerticalDivider(
        color: color,
        thickness: 1.2,
        endIndent: 0,
        indent: 0,
      ),
    );
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

  Widget _mapPin() {
    return pickDropMarker(
        color: AppColor.kPrimaryColor.value,
        textColor: AppColor.kPrimaryTextColor.value,
        backgroundColor: AppColor.kStatusBarPrimaryColor.value,
        style: TextStyle(fontSize: AppFontSize.medium.value));
  }

  Obx _googleMap() {
    return Obx(() => GoogleMap(
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: true,
        trafficEnabled: controller.trafficEnabled.value,
        mapType: controller.mapType.value,
        initialCameraPosition: CameraPosition(
          target: controller.commonPlaceController.pickUpLatLng.value,
          zoom: 12,
        ),
        onMapCreated: (GoogleMapController mapController) {
          mapController.setMapStyle(MapStyle.json);
          controller.mapController = mapController;
        },
        markers: controller.confirmPickupController.loadingMarkers,
        onCameraIdle: () {
          // controller.googleMapLocationController.isCameraIdle.value
          //     ? controller.googleMapLocationController.onCameraIdle()
          //     : null;
        },
        onCameraMove: (CameraPosition position) {},
        onCameraMoveStarted: () {}));
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
      ),
    );
  }
}
