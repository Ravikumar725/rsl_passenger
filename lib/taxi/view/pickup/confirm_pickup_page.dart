import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsl_passenger/routes/routes.dart';
import '../../../assets/assets.dart';
import '../../../controller/common_place_controller.dart';
import '../../../controller/place_search_page_controller.dart';
import '../../../network/services.dart';
import '../../../widget/utils/safe_area_container.dart';
import '../../../widget/custom_button.dart';
import '../../../widget/styles/app_style.dart';
import '../../../widget/styles/colors.dart';
import '../../../widget/utils/map_style.dart';
import '../../controller/city_selection_controller.dart';
import '../../controller/confirm_pickup_controller.dart';
import '../../widget/back_button.dart';
import '../../widget/current_location_button_widget.dart';
import '../../widget/custom_map_marker.dart';
import '../../widget/destination_suggestions_list_widget.dart';
import '../../widget/map_satellite_button_widget.dart';
import '../../widget/now_booking_widget.dart';
import '../../../shimmer_layout/taxi_location_list_shimmer.dart';
import '../../widget/taxi_timer_widget.dart';
import '../../../widget/utils/text_field.dart';
import '../../widget/traffic_button_widget.dart';
import '../destination/view/destination_page.dart';

class PickupScreen extends GetView<ConfirmPickupController> {
  const PickupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (controller.isPickUpEdit.value == true) {
          Get.back();
        } else {
          controller.onPickUpOnPress();
        }
        return false;
      },
      child: /*Obx(
        () =>*/ SafeAreaContainer(
          // statusBarColor: controller.isSheetFullyExpandedPick.value == true
          //     ? AppColor.kStatusBarPrimaryColor.value
          //     : Colors.transparent,
          child: Scaffold(
            body: Stack(
              children: [
                _googleMap(),
                _mapPin(),
                _headerWidget(onTab: () {
                  if (controller.isPickUpEdit.value == true) {
                    printLogs("Hii ravi taxi is drop edit value is ${controller.isPickUpEdit.value}");
                    Get.back();
                  } else {
                    printLogs("Hii ravi taxi is drop edit value is else ${controller.isPickUpEdit.value}");
                    controller.onPickUpOnPress();
                  }
                }),
                Positioned(
                  bottom: MediaQuery.of(Get.context!).size.height / 3.4,
                  left: 14.w,
                  right: 14.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CurrentLocationButtonWidget(
                        onTap: () {
                          controller.moveToCurrentLocation();
                        },
                        backgroundColor: AppColor.kStatusBarPrimaryColor.value,
                        iconSize: 18.r,
                        iconColor:
                            AppColor.kLightTextPrimary.value.withOpacity(0.9),
                      ),
                      SizedBox(height: 4.h),
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
                      SizedBox(height: 4.h),
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
                      SizedBox(height: 4.h),
                    ],
                  ),
                ),
                _bottomDraggableSheet(favOnTab: () {
                  controller.saveLocationController.setSelectedLocation(
                      controller.getAddress.value,
                      controller.getAddress.value,
                      controller.target.value);
                  Get.toNamed(AppRoutes.saveLocationPage);
                }, confirmTab: () {
                  try {
                    if (!Get.isRegistered<CitySelectionController>()) {
                      Get.put(CitySelectionController());
                    }
                    controller.commonPlaceController.getPosition?.value =
                        GetPoistion.pin;
                    controller.saveLocationController.setSelectedLocation(
                      controller.getAddress.value,
                      controller.getAddress.value,
                      controller.target.value,
                    );
                    Get.toNamed(AppRoutes.taxiHomePageNew);
                  } catch (e, stackTrace) {
                    printLogs("Error occurred in confirmTab: $e");
                    printLogs(stackTrace);
                  }
                }, nowOnTab: () {
                  showTaxiBookingTimerWidgetNew(
                      searchEnable: true,
                      laterEnable: controller.isLaterBooking,
                      setCurrentTime: () {
                        controller.commonPlaceController.laterBookingDateTime
                            .value = "";
                        Get.back();
                      },
                      onTap: (selectDateTime) {
                        controller.commonPlaceController.setBookLaterDateTime(
                          dateTime: selectDateTime,
                        );
                        return;
                      });
                }),
              ],
            ),
          ),
        ),
      // ),
    );
  }

  Widget _bottomDraggableSheet({
    Function()? favOnTab,
    required Function() confirmTab,
    required Function() nowOnTab,
  }) {
    if (controller.draggableScrollableControllerPick.isAttached) {
      controller.draggableScrollableControllerPick.dispose();
      controller.draggableScrollableControllerPick =
          DraggableScrollableController();
    }
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize:
            controller.isSheetFullyExpandedPick.value ? 1.0 : 0.28,
        minChildSize: 0.28,
        maxChildSize: 1,
        expand: true,
        controller: controller.draggableScrollableControllerPick,
        builder: (BuildContext context, ScrollController scrollController) {
          return Obx(() {
            bool isExpanded = controller.isSheetFullyExpandedPick.value;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColor.kStatusBarPrimaryColor.value,
                borderRadius: BorderRadius.only(
                  topLeft:
                      isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
                  topRight:
                      isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
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
                  controller:
                      scrollController, // Pass the scroll controller here
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    children: [
                      if (!isExpanded) _line(),
                      _pickupDetails(
                        nowOnTab: nowOnTab,
                        scrollController: scrollController,
                      ),
                      SizedBox(height: 16.h),
                      isExpanded
                          ? _locationSearchWidget(scrollController)
                          : _confirmPickUp(
                              confirmTab: confirmTab,
                              favOnTab: favOnTab,
                              listOnTab: () {
                                controller.isSheetFullyExpandedPick.value =
                                    true;
                                if (controller.draggableScrollableControllerPick
                                    .isAttached) {
                                  controller.draggableScrollableControllerPick
                                      .animateTo(
                                    1,
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                } else {
                                  printLogs(
                                      "DraggableScrollableControllerPick is not attached yet.");
                                }
                              }),
                    ],
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _locationSearchWidget(ScrollController scrollController) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _searchBar(),
        SizedBox(height: 10.h),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: Get.put(PlaceSearchPageController()).pickController,
          builder: (context, value, child) {
            printLogs("Hii taxi PickController Value: ${value.text}");
            return value.text != ""
                ? DestinationSuggestions(
                    type: 1,
                    scrollController: scrollController,
                  )
                : Obx(
                    () => _locationsListApiStatus(
                        scrollController: scrollController,
                        msg: controller.citySelectionController
                            .knownLocationsResponseStatus.value.message,
                        status: controller.citySelectionController
                            .knownLocationsResponseStatus.value.status),
                  );
          },
        ),
      ],
    );
  }

  Widget _locationsListApiStatus(
      {int? status, String? msg, required ScrollController scrollController}) {
    switch (status) {
      case 0:
        return const LocationListShimmer();
      case 1:
        return _locationsList(scrollController, msg);

      case -1:
        return SizedBox(
          height: 200.h,
          width: ScreenUtil().screenWidth,
          child: Center(child: textView(text: msg)),
        );

      case 400:
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _searchBar() {
    if (!Get.isRegistered<PlaceSearchPageController>()) {
      Get.put(PlaceSearchPageController());
    }
    final placeSearchController = Get.find<PlaceSearchPageController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          Expanded(
            child: _start(
                pickController: placeSearchController,
                hintText: "Enter your Pickup",
                onChanged: (value) {
                  if (value.isEmpty) {
                    placeSearchController.clearPickText();
                    placeSearchController.pickUpSuffixEnabled.value = false;
                  } else {
                    placeSearchController.pickUpSuffixEnabled.value = true;
                  }
                  placeSearchController.searchLocation(value: value);
                },
                onSubmitted: (value) {},
                suffixOnTab: () {
                  Get.toNamed(AppRoutes.citySelectionPage, arguments: 1);
                },
                pickFocus: placeSearchController.pickFocusNode.value),
          ),
        ],
      ),
    );
  }

  Widget _start({
    String? hintText,
    void Function(String)? onChanged,
    void Function(String)? onSubmitted,
    PlaceSearchPageController? pickController,
    FocusNode? pickFocus,
    void Function()? suffixOnTab,
  }) {
    pickController?.pickController.text = "";
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: CustomTextField(
            textController: pickController?.pickController,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            enable: true,
            //autofocus: true,
            focusNode: pickFocus,
            style: _textStyle(),
            decoration: _textFieldDecoration(
              hintText: hintText,
              onTab: suffixOnTab,
              clearButtonVisible:
                  pickController?.pickController.text.isNotEmpty ?? false,
              onClear: () {
                pickController?.pickController.clear();
                if (onChanged != null) onChanged(''); // Clear callback
              },
            ),
          ),
        ),
      ],
    );
  }

  _textFieldDecoration({
    String? hintText,
    bool clearButtonVisible = false,
    Function()? onTab,
    void Function()? onClear,
  }) {
    return InputDecoration(
      hintText: "$hintText",
      hintStyle: TextStyle(
          fontSize: AppFontSize.medium.value,
          fontWeight: AppFontWeight.medium.value,
          color: AppColor.kLightTextPrimary.value),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(12.r),
      ),
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: SvgPicture.asset(
          Assets.search,
          height: 10.h,
          width: 10.w,
          color: AppColor.kLightTextPrimary.value,
        ),
      ),
      suffixIcon: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Take only the necessary space
          children: [
            if (clearButtonVisible)
              InkWell(
                onTap: onClear,
                child: Container(
                  padding: EdgeInsets.all(2.r),
                  decoration: BoxDecoration(
                      color: AppColor.kLightTextPrimary.value.withOpacity(0.8),
                      shape: BoxShape.circle),
                  child: Icon(Icons.clear,
                      color: AppColor.kStatusBarPrimaryColor.value, size: 15.r),
                ),
              ),
            SizedBox(
              width: 8.w,
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Obx(() {
                return InkWell(
                  onTap: onTab,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      textView(
                        text: controller
                            .citySelectionController.selectedCity.value,
                        fontSize: AppFontSize.smallMedium.value,
                        fontWeight: AppFontWeight.light.value,
                        color:
                            AppColor.kLightTextPrimary.value.withOpacity(0.8),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 1.h, left: 4.w),
                        child: Icon(
                          Icons.keyboard_arrow_down_sharp,
                          size: 22.r,
                          color:
                              AppColor.kLightTextPrimary.value.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(16.r),
      ),
      isDense: true,
      contentPadding: EdgeInsets.only(right: 8.w), // Added this
    );
  }

  _textStyle() {
    return TextStyle(
        fontSize: AppFontSize.medium.value,
        fontWeight: AppFontWeight.medium.value,
        color: AppColor.kPrimaryTextColor.value);
  }

  Widget _locationsList(ScrollController scrollController, String? msg) {
    return Obx(
      () => ListView.builder(
        itemCount: controller.citySelectionController.locations?.length,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final location = controller.citySelectionController.locations?[index];
          return InkWell(
            onTap: () {
              controller.commonPlaceController.pickUpLatLng.value = LatLng(
                  location?.latitude?.toDouble() ?? 0.0,
                  location?.longitude?.toDouble() ?? 0.0);
              controller.commonPlaceController.pickUpLocation.value =
                  location?.locationName ?? "";
              controller.commonPlaceController.pickUpSubtitle.value =
                  location?.address ?? "";
              if (controller.pickupEdit.value == 2) {
                // Get.toNamed(AppRoutes.bookingLoadingPage);
              } else {
                controller.commonPlaceController.getPosition?.value ==
                    GetPoistion.pin;
                Get.toNamed(AppRoutes.taxiHomePageNew);
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColor.kLightPrimary.value,
                    child: Icon(
                      size: 25.r,
                      Icons.location_pin,
                      // _getIcon(location["icon"]!),
                      color: AppColor.kPrimaryColor.value,
                    ),
                  ),
                  SizedBox(
                      width: 10.w), // Add spacing between the icon and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textView(
                            text: location?.locationName,
                            fontWeight: AppFontWeight.semibold.value),
                        textView(
                          text: location?.address,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: () {
                      controller.saveLocationController.setSelectedLocation(
                          location?.locationName ?? "",
                          location?.address ?? "",
                          LatLng(location?.latitude?.toDouble() ?? 0.0,
                              location?.longitude?.toDouble() ?? 0.0));
                      Get.toNamed(AppRoutes.saveLocationPage);
                    },
                    child: const Icon(
                        /*location["favorite"] == "true"
                          ? Icons.favorite
                          :*/
                        Icons.favorite_outline,
                        color: /*location["favorite"] == "true"
                          ? Colors.teal
                          :*/
                            Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIcon(String iconType) {
    switch (iconType) {
      case "location_pin":
        return Icons.location_pin;
      case "store":
        return Icons.store;
      case "home":
        return Icons.home;
      default:
        return Icons.location_pin;
    }
  }

  Widget _confirmPickUp(
      {Function()? favOnTab,
      required Function() confirmTab,
      required Function() listOnTab}) {
    printLogs(
        "Hii taxi confirm pick up location is ${controller.commonPlaceController.pickUpLatLng.value} ** ${controller.commonPlaceController.pickUpLocation.value}");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: AppColor.kLightPrimary.value,
              child: Icon(
                Icons.location_pin,
                color: AppColor.kPrimaryColor.value,
                size: 24.r,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: InkWell(
                onTap: listOnTab,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(
                      () => textView(
                        text: controller
                            .commonPlaceController.pickUpLocation.value,
                        fontWeight: AppFontWeight.semibold.value,
                      ),
                    ),
                    Obx(
                      () => textView(
                        text: controller
                            .commonPlaceController.pickUpSubtitle.value,
                        fontWeight: AppFontWeight.medium.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: favOnTab,
              child: Icon(
                Icons.favorite_outline,
                size: 20.r,
              ),
            ),
          ],
        ),
        SizedBox(height: 30.h),
        Obx(() {
          printLogs(
              "Hii ravi location isOutsideUAE ${controller.isOutsideUAE.value}");
          return controller.isOutsideUAE.value != true
              ? CustomButton(
                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                  height: 35.h,
                  width: double.maxFinite,
                  text: "Confirm pickup",
                  onTap: confirmTab,
                )
              : CustomButton(
                  height: 35.h,
                  padding: EdgeInsets.symmetric(horizontal: 0.w),
                  linearColor: whiteButtonLinearColorSecondary,
                  style: TextStyle(color: AppColor.kLightTextPrimary.value),
                  width: double.maxFinite,
                  text: "Confirm pickup",
                );
        })
      ],
    );
  }

  Widget _pickupDetails({
    required Function() nowOnTab,
    ScrollController? scrollController,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          Obx(() {
            bool isExpanded = controller.isSheetFullyExpandedPick.value;
            return isExpanded
                ? _downButton(onTap: () {
                    controller.draggableScrollableControllerPick.animateTo(
                      0.28,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn, // Animation curve
                    );
                    controller.isSheetFullyExpandedPick.value = false;
                  })
                : textView(
                    text: "Pickup details",
                    fontSize: AppFontSize.dashboardDescription.value,
                    fontWeight: AppFontWeight.semibold.value,
                  );
          }),
          const Spacer(),
          Obx(
            () => NowBookingWidget(
              isLaterBooking: controller.isLaterBooking,
              laterBookingDateTime: controller.laterBookingDateTime,
              onTab: nowOnTab,
            ),
          ),
        ],
      ),
    );
  }

  Widget _downButton({VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
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

  Widget _nowBookingWidget({Function()? onTab}) {
    return InkWell(
      onTap: onTab,
      child: Row(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 20.r,
            color: AppColor.kPrimaryColor.value,
          ),
          Padding(
            padding: EdgeInsets.only(left: 4.w, right: 2.w),
            child: textView(
                text: "kNow".tr,
                color: AppColor.kPrimaryIconColor.value,
                fontSize: AppFontSize.medium.value,
                fontWeight: AppFontWeight.semibold.value),
          ),
          Icon(
            Icons.keyboard_arrow_down_outlined,
            size: 20.r,
            color: AppColor.kPrimaryTextColor.value,
          ),
        ],
      ),
    );
  }

  Widget _headerWidget({required Function() onTab}) {
    return Positioned(
      top: 0.h,
      left: 0.w,
      child: Row(
        children: [
          TaxiCustomBackButton(
            color: AppColor.kPrimaryTextColor.value,
            onTap: onTab,
          ),
        ],
      ),
    );
  }

  Widget _mapPin() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(bottom: 45.h),
        child: Obx(() {
          if (controller.isOutsideUAE.value) {
            // Render the default marker for outside UAE
            return locationNotAvailableMarker(
              color: AppColor.kPrimaryColor.value,
              title: "RSL does not operate in this area",
              backgroundColor: AppColor.kStatusBarPrimaryColor.value,
              style: TextStyle(
                  fontSize: AppFontSize.medium.value,
                  color: AppColor.kPrimaryTextColor.value),
            );
          } else {
            // Render the custom pickDropMarkerNew for UAE
            return pickDropMarkerNew(
              color: AppColor.kPrimaryColor.value,
              title: "Pick-up",
              image: Assets.pickupHand,
              backgroundColor: AppColor.kStatusBarPrimaryColor.value,
              style: TextStyle(fontSize: AppFontSize.medium.value),
            );
          }
        }),
      ),
    );
  }

  Obx _googleMap() {
    return Obx(() {
      return GoogleMap(
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          trafficEnabled: controller.trafficEnabled.value,
          mapType: controller.mapType.value,
          initialCameraPosition:
              controller.initialCameraPosition(getPoistion: GetPoistion.pin),
          onMapCreated: (GoogleMapController mapController) {
            mapController.setMapStyle(MapStyle.json);
            controller.mapController = mapController;
          },
          markers: <Marker>{
            ...controller.markers,
            ...controller.dashboardController.markers,
          },
          onCameraIdle: () {
            controller.isCameraIdle.value = true;
            controller.setTarget(getTarget: controller.target.value);
            controller.isCameraDragging.value = false;
            // controller.onCameraIdle();
          },
          onCameraMove: (CameraPosition position) {
            printLogs("Hii taxi camera position ${position.target}");
            controller.target.value = position.target;
            controller.isCameraDragging.value = true;
          },
          polygons: {
            if (controller.showPolygon.value)
              Polygon(
                polygonId: const PolygonId('myPolygon'),
                // ignore: invalid_use_of_protected_member
                points: controller.polygon.value,
                strokeWidth: 2,
                strokeColor: AppColor.kPrimaryColor.value,
                fillColor: AppColor.kPrimaryColor.value.withOpacity(0.4),
              )
          },
          onCameraMoveStarted: () {
            controller.isCameraDragging.value = true;
          });
    });
  }

  Widget textView(
      {String? text, double? fontSize, FontWeight? fontWeight, Color? color}) {
    return Text(
      text ?? "",
      style: TextStyle(
        fontSize: fontSize ?? AppFontSize.medium.value,
        fontWeight: fontWeight ?? AppFontWeight.medium.value,
        color: color ?? AppColor.kPrimaryTextColor.value,
      ),
    );
  }
}
