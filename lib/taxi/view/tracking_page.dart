import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../assets/assets.dart';
import '../../network/services.dart';
import '../../routes/routes.dart';
import '../../shimmer_layout/tracking_shimmer_widget.dart';
import '../../widget/custom_button.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/enums.dart';
import '../../widget/utils/global_utils.dart';
import '../../widget/utils/make_call.dart';
import '../../widget/utils/map_style.dart';
import '../../widget/utils/safe_area_container.dart';
import '../controller/tracking_controller.dart';
import '../widget/back_button.dart';
import '../widget/booking_details_widget.dart';
import '../widget/cancel_trip_reason_widget_new.dart';
import '../widget/need_our_help_widget.dart';
import '../widget/pickup_drop_item_widget.dart';
import 'destination/view/destination_page.dart';

class TrackingPage extends GetView<TrackingController> {
  const TrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.dashboardPage);
        return false;
      },
      child: SafeAreaContainer(
        child: Scaffold(
          body: Stack(
            children: [
              SizedBox(
                  height: MediaQuery.of(Get.context!).size.height / 1.5,
                  child: _googleMapWidget()),
              TaxiCustomBackButton(
                color: AppColor.kLightTextPrimary.value,
                onTap: () {
                  controller.onBackPressed();
                },
              ),
              _bottomDraggableSheet(),
            ],
          ),
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
                child: Obx(() {
                  return Column(
                    children: [
                      _line(),
                      sizedBox(height: 14.h),
                      Visibility(
                          visible: controller.getTripUpdateApiSuccess.value,
                          child: _confirmPickUp()),
                      Visibility(
                          visible: controller.isLoading.value &&
                              !controller.getTripUpdateApiSuccess.value,
                          child: const DriverShimmerWidget()),
                      Visibility(
                          visible: !controller.isLoading.value &&
                              !controller.getTripUpdateApiSuccess.value,
                          child: textView(
                              text: "Something went wrong.",
                              fontWeight: AppFontWeight.medium.value))
                    ],
                  );
                }),
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
        Obx(
          () => Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: textView(
                      text:
                          controller.getTripUpdateResponseData.value.message ??
                              controller.travelStatusMsg.value,
                      fontWeight: AppFontWeight.semibold.value,
                      fontSize: AppFontSize.info.value),
                ),
                controller.getTripUpdateResponseData.value.status == 12
                    ? textView(
                        text: "ETA : ${controller.estimatedTime.value}",
                        fontWeight: AppFontWeight.medium.value)
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
        sizedBox(),
        _driverWidget(),
        sizedBox(),
        _divider(),
        _pickUpDropWidget(),
        _divider(),
        _bookingDetails(),
        sizedBox(),
        _divider(),
        _manageRide(),
      ],
    );
  }

  Widget _driverWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: Row(
            children: [
              Obx(
                () => CircleAvatar(
                  radius: 30.r,
                  backgroundImage: NetworkImage(
                      controller.bookingDetailInfo.value?.driverImage ?? ""),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => Expanded(
                            child: textView(
                                text:
                                    "${controller.bookingDetailInfo.value?.driverName ?? "Test "}  ${/*controller.bookingDetailInfo.value?.driverRating ??*/ "5"} ★",
                                fontSize: AppFontSize.medium.value,
                                color: AppColor.kPrimaryTextColor.value
                                    .withOpacity(0.5)),
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: textView(
                                // fontWeight: AppFontWeight.semibold.value,
                                text:
                                    "${controller.bookingDetailInfo.value?.modelName ?? 'Sedan'} "),
                          ),

                          Container(
                            margin: EdgeInsets.only(left: 4.w),
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColor.kLightPrimary.value,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: textView(
                                text: controller
                                        .bookingDetailInfo.value?.taxiNumber ??
                                    "TN 33 AE 1234",
                                fontSize: AppFontSize.small.value,
                                fontWeight: AppFontWeight.semibold.value),
                          )
                          // : const SizedBox.shrink(),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _callWidget(
                text: "Call",
                icon: Icons.call_outlined,
                onTab: () {
                  makePhoneCall(
                      phone:
                          "${controller.bookingDetailInfo.value?.driverPhone}");
                }),
            Obx(
              () => Visibility(
                visible: controller.launchChat.value == true,
                child: _callWidget(
                    text: "Chat",
                    icon: Icons.messenger_outline,
                    onTab: () {
                      // controller.navigateChatPage(Get.context!);
                    }),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget _pickUpDropWidget() {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 10.h),
            child: textView(
              color: AppColor.kLightTextPrimary.value.withOpacity(0.5),
              text: 'Trip Details',
            ),
          ),
          Row(
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
                              border: Border.all(
                                  color: AppColor.kPrimaryColor.value),
                              color: AppColor.kStatusBarPrimaryColor.value,
                              shape: BoxShape.circle),
                        ),
                        Obx(() => (controller.commonPlaceController.dropLocation
                                        .value !=
                                    '' ||
                                controller.bookingDetailResponse?.value.detail
                                        ?.dropLocation !=
                                    '')
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
                            : const SizedBox.shrink())
                      ],
                    ),
                  ],
                ),
              ),
              Obx(() {
                printLogs(
                    "Hii ravi tracking page is ${controller.commonPlaceController.pickUpLocation.value} ${controller.getTripUpdateResponseData.value.status}");
                return Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PickupDropItemWidget(
                        isEditShow: (controller.getTripUpdateResponseData.value
                                        .detail?.driverdetails?.travelStatus ==
                                    9 ||
                                controller.getTripUpdateResponseData.value
                                        .detail?.driverdetails?.travelStatus ==
                                    12)
                            ? true
                            : false,
                        title: controller.commonPlaceController.pickUpLocation
                                    .value !=
                                ""
                            ? controller
                                .commonPlaceController.pickUpLocation.value
                            : controller.bookingDetailResponse?.value.detail
                                ?.currentLocation,
                        subtitle: controller
                            .commonPlaceController.pickUpSubtitle.value,
                        onEditTap: () {
                          controller.commonPlaceController.getPosition?.value =
                              GetPoistion.pin;
                          controller.commonPlaceController.pickUpLatLng.value =
                              LatLng(
                                  double.tryParse(controller
                                              .bookingDetailResponse
                                              ?.value
                                              .detail
                                              ?.pickupLatitude ??
                                          "") ??
                                      0.0,
                                  double.tryParse(controller
                                              .bookingDetailResponse
                                              ?.value
                                              .detail
                                              ?.pickupLongitude ??
                                          "") ??
                                      0.0);
                          controller.commonPlaceController.dropLatLng.refresh();
                          // Get.toNamed(NewAppRoutes.pickupEditPage);
                        },
                      ),
                      sizedBox(height: 23.h),
                      (controller.commonPlaceController.dropLocation.value !=
                                  '' ||
                              controller.bookingDetailResponse?.value.detail
                                      ?.dropLocation !=
                                  '')
                          ? PickupDropItemWidget(
                              isEditShow: (controller
                                              .getTripUpdateResponseData
                                              .value
                                              .detail
                                              ?.driverdetails
                                              ?.travelStatus ==
                                          9 ||
                                      controller
                                              .getTripUpdateResponseData
                                              .value
                                              .detail
                                              ?.driverdetails
                                              ?.travelStatus ==
                                          3 ||
                                      controller
                                              .getTripUpdateResponseData
                                              .value
                                              .detail
                                              ?.driverdetails
                                              ?.travelStatus ==
                                          2 ||
                                      controller
                                              .getTripUpdateResponseData
                                              .value
                                              .detail
                                              ?.driverdetails
                                              ?.travelStatus ==
                                          12)
                                  ? /*true*/ false
                                  : false,
                              title: controller
                                  .bookingDetailResponse
                                  ?.value
                                  .detail
                                  ?.dropLocation /*controller
                                  .commonPlaceController.dropLocation.value*/
                              ,
                              subtitle: controller
                                  .commonPlaceController.dropSubtitle.value,
                              onEditTap: () {
                                controller.commonPlaceController.getPosition
                                    ?.value = GetPoistion.drop;
                                controller.commonPlaceController.dropLatLng
                                        .value =
                                    LatLng(
                                        double.tryParse(controller
                                                    .bookingDetailResponse
                                                    ?.value
                                                    .detail
                                                    ?.dropLatitude ??
                                                "") ??
                                            0.0,
                                        double.tryParse(controller
                                                    .bookingDetailResponse
                                                    ?.value
                                                    .detail
                                                    ?.dropLongitude ??
                                                "") ??
                                            0.0);
                                controller.commonPlaceController.dropLatLng
                                    .refresh();
                                // Get.toNamed(NewAppRoutes.dropEditPage);
                              },
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _callWidget({Function()? onTab, IconData? icon, String? text}) {
    return InkWell(
      onTap: onTab,
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColor.kPrimaryTextColor.value.withOpacity(0.7),
            size: 20.r,
          ),
          SizedBox(width: 8.w),
          textView(
              text: text,
              fontSize: AppFontSize.medium.value,
              fontWeight: AppFontWeight.semibold.value)
        ],
      ),
    );
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
          sizedBox(height: 8.h),
          BookingDetailsWidget(
            title: 'Need our help?',
            iconData: Icons.support_agent_outlined,
            iconSize: 26.r,
            onTab: () {
              needOurHelp(onCall: () {
                Get.back();
                // controller.taxiPageController.dashboardController
                //     .launchPhoneDialPad(
                //   phone:
                //       "${controller.taxiPageController.dashboardController.getApiData.value.adminContactPhone}",
                // );
              }, onChat: () {
                Get.back();
                String input = controller.taxiPageController.dashboardController
                        .getApiData.value.adminContactWhatsApp ??
                    "";
                String result = input.replaceAll(RegExp(r'\s+'), '');
                // controller.taxiPageController.dashboardController
                //     .launchWhatsApp(phone: result);
              }, onHelpCenter: () {
                Get.back();
                // Get.toNamed(AppRoutes.helpCenter);
              });
            },
          ),
          sizedBox(height: 12.h),
          Obx(
            () => (controller.getTripUpdateResponseData.value.detail
                            ?.driverdetails?.travelStatus ==
                        2 ||
                    controller.getTripUpdateResponseData.value.status == 4)
                ? const SizedBox()
                : BookingDetailsWidget(
                    title: 'Cancel ride',
                    titleColor: AppColor.kRedColour.value,
                    iconData: Icons.cancel_outlined,
                    iconColor: AppColor.kRedColour.value,
                    iconSize: 26.r,
                    onTab: () {
                      _cancelBottomAlert();
                    },
                  ),
          )
        ],
      ),
    );
  }

  Future _cancelBottomAlert() {
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
                                cancelTripAction: (reason) {
                                  controller.onCancelClicked();
                                },
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
              title: '${controller.bookingDetailInfo.value?.modelName}',
              imageUrl:
                  '${controller.taxiPageController.selectedCarModelList.value.focusImage}',
              imageHeight: 26.h,
              imageWidth: 26.w,
            ),
          ),
          sizedBox(height: 4.h),
          Obx(
            () => BookingDetailsWidget(
                title:
                    '${controller.bookingDetailInfo.value?.paymentTypeLabel}',
                imagePath:
                    controller.bookingDetailInfo.value?.paymentTypeLabel ==
                            "Card"
                        ? Assets.creditCard
                        : Assets.money,
                imageHeight: 26.h,
                imageWidth: 26.w,
                iconColor: AppColor.kLightTextPrimary.value.withOpacity(0.7)),
          ),
          sizedBox(height: 4.h),
          Obx(
            () => BookingDetailsWidget(
              title: 'Fare',
              fare:
                  "${GlobalUtils.currency} ${controller.bookingDetailResponse?.value.detail?.approxFare}",
              imagePath: Assets.moneyImg,
              imageHeight: 26.h,
              imageWidth: 26.w,
            ),
          ),
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

  Widget _googleMapWidget() {
    return Obx(
      () => GoogleMap(
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        //mapType: MapType.hybrid,
        initialCameraPosition: CameraPosition(
          target: controller.commonPlaceController.pickUpLatLng
              .value /*controller.driverLatLng.value*/,
          zoom: 15,
        ),
        polylines: {...controller.polyline, ...controller.polylines},
        markers: <Marker>{
          ...controller.vehicleMarker,
          ...controller.pickUpDropMarkers
        },
        onMapCreated: (GoogleMapController controller) {
          // ignore: deprecated_member_use
          controller.setMapStyle(MapStyle.json);
          this.controller.mapController = controller;
        },
      ),
    );
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

  Widget textView1(
      {String? text,
      double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      int? maxLines}) {
    return Text(
      text ?? "",
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontSize ?? AppFontSize.medium.value,
        fontWeight: fontWeight ?? AppFontWeight.medium.value,
        color: color ?? AppColor.kPrimaryTextColor.value,
      ),
    );
  }
}
