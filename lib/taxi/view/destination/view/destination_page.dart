import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../../assets/assets.dart';
import '../../../../controller/place_search_page_controller.dart';
import '../../../../network/services.dart';
import '../../../../routes/routes.dart';
import '../../../../widget/utils/enums.dart';
import '../../../../widget/utils/safe_area_container.dart';
import '../../../../widget/custom_button.dart';
import '../../../../widget/styles/app_style.dart';
import '../../../../widget/styles/colors.dart';
import '../../../../widget/utils/map_style.dart';
import '../../../controller/saved_location_controller.dart';
import '../../../data/known_location_list_api_data.dart';
import '../../../../widget/utils/alert_helpers.dart';
import '../../../widget/back_button.dart';
import '../../../widget/current_location_button_widget.dart';
import '../../../widget/custom_map_marker.dart';
import '../../../widget/destination_suggestions_list_widget.dart';
import '../../../widget/now_booking_widget.dart';
import '../../../../shimmer_layout/taxi_location_list_shimmer.dart';
import '../../../widget/taxi_timer_widget.dart';
import '../../../../widget/utils/text_field.dart';
import '../../../controller/destination_controller.dart';

class DestinationPage extends GetView<DestinationController> {
  const DestinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: SafeAreaContainer(
        statusBarColor: AppColor.kStatusBarPrimaryColor.value,
        themedark: false,
        child: Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: MediaQuery.of(Get.context!).size.height / 1.35,
                child: _googleMap(),
              ),
              _headerWidget(
                backTap: () {
                  if (controller.isDropEdit.value == false) {
                    controller.isMapDragged.value = false;
                    controller
                        .placeSearchController.destinationController.text = '';
                    controller.commonPlaceController.dropLocation.value = '';
                    controller.commonPlaceController.dropLatLng.value =
                        const LatLng(0.0, 0.0);
                    controller
                        .commonPlaceController.laterBookingDateTime.value = "";
                    if (Get.isRegistered<DestinationController>()) {
                      Get.delete<DestinationController>(force: true);
                    }
                    Get.offNamedUntil('/dashboardPage', (route) => false);
                    // Get.toNamed(AppRoutes.dashboardPage);
                  } else {
                    Get.back();
                    controller.isDropEdit.value = false;
                  }
                },
              ),
              Obx(() {
                double height = controller.draggableSheetHeight.value;
                return Positioned(
                  bottom: height == 0.3
                      ? MediaQuery.of(Get.context!).size.height / 3
                      : MediaQuery.of(Get.context!).size.height / 2,
                  right: 14,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CurrentLocationButtonWidget(
                      onTap: () {
                        controller.moveToCurrentLocation();
                      },
                      backgroundColor: AppColor.kStatusBarPrimaryColor.value,
                      iconSize: 18.r,
                      iconColor:
                          AppColor.kLightTextPrimary.value.withOpacity(0.9),
                    ),
                  ),
                );
              }),
              _mapPin(),
              _bottomDraggableSheet(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomDraggableSheet() {
    if (controller.draggableScrollableController.isAttached) {
      controller.draggableScrollableController.dispose();
      controller.draggableScrollableController =
          DraggableScrollableController(); // Create a new controller
    }
    return SafeArea(
      child: Obx(
        () {
          return DraggableScrollableSheet(
            initialChildSize: controller.isMapDragged.value ? 0.3 : 0.5,
            minChildSize: controller.isMapDragged.value ? 0.3 : 0.5,
            maxChildSize: 1.0,
            expand: true,
            controller: controller.draggableScrollableController,
            builder: (context, scrollController) {
              controller.draggableScrollableController.addListener(() {
                final position = controller.draggableScrollableController.size;
                if (position == 1) {
                  controller.isSheetFullyExpanded.value = true;
                } else {
                  controller.isSheetFullyExpanded.value = false;
                }
              });
              bool isExpanded = controller.isMapDragged.value;
              return isExpanded
                  ? _confirmDrop(scrollController) // When sheet is at minHeight
                  : _suggestionList(scrollController); // Normal view
            },
          );
        },
      ),
    );
  }

  Widget _confirmDrop(ScrollController scrollController) {
    return Obx(() {
      bool isExpanded = controller.isSheetFullyExpanded.value;

      return isExpanded
          ? _suggestionList(scrollController)
          : Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: AppColor.kStatusBarPrimaryColor.value,
                borderRadius: BorderRadius.only(
                  topLeft:
                      isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
                  topRight:
                      isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
                ),
              ),
              child: ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 8.h),
                      isExpanded ? const SizedBox.shrink() : _line(),
                      SizedBox(height: 8.h),
                      _whereTo(
                          nowOnTab: () {
                            showTaxiBookingTimerWidgetNew(
                                searchEnable: true,
                                laterEnable: controller.isLaterBooking,
                                setCurrentTime: () {
                                  controller.commonPlaceController
                                      .laterBookingDateTime.value = "";
                                  Get.back();
                                },
                                onTap: (selectDateTime) {
                                  controller.commonPlaceController
                                      .setBookLaterDateTime(
                                    dateTime: selectDateTime,
                                  );
                                  return;
                                });
                          },
                          downOnTab: () {}),
                      SizedBox(height: 14.h),
                      _confirmDropOff(
                        listOnTab: () {
                          if (controller
                              .draggableScrollableController.isAttached) {
                            controller.draggableScrollableController.animateTo(
                              1.0,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.fastOutSlowIn,
                            );
                          }
                        },
                        confirmTab: () {
                          if (controller.isDropEdit.value == true) {
                            controller.commonPlaceController.dropLatLng.value =
                                controller.target.value;
                            controller.commonPlaceController.dropLocation
                                .value = controller.getAddress.value;

                            Get.back(result: {
                              'latLng': controller
                                  .commonPlaceController.dropLatLng.value,
                              'address': controller
                                  .commonPlaceController.dropLocation.value,
                            });
                          } else {
                            controller.saveLocationController
                                .setSelectedLocation(
                              controller.getAddress.value,
                              controller.getAddress.value,
                              controller.target.value,
                            );
                            controller.commonPlaceController.getPosition
                                ?.value = GetPoistion.pin;
                            controller.commonPlaceController.getPosition
                                ?.refresh();
                            controller.citySelectionController
                                .callKnownLocationPickupApi(
                              cityInfo: CountryInfo(
                                name: controller
                                    .citySelectionController.selectedCity.value,
                                latitude: controller.citySelectionController
                                    .selectedLatitude.value,
                                longitude: controller.citySelectionController
                                    .selectedLongitude.value,
                              ),
                            );
                            controller.commonPlaceController.getPosition
                                ?.value = GetPoistion.pin;
                            controller.commonPlaceController.pickUpLocation
                                    .value =
                                controller
                                    .dashboardController.pickUpAddress.value;
                            controller
                                    .commonPlaceController.pickUpLatLng.value =
                                controller
                                    .dashboardController.pickUpLatLng.value;
                            Get.toNamed(AppRoutes.pickUpScreen);
                          }
                        },
                        favOnTab: () {
                          controller.saveLocationController.setSelectedLocation(
                            controller.commonPlaceController.dropLocation.value,
                            controller.commonPlaceController.dropSubtitle.value,
                            controller.commonPlaceController.dropLatLng.value,
                          );
                          Get.toNamed(AppRoutes.saveLocationPage);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
    });
  }

  Widget _suggestionList(ScrollController scrollController) {
    return Obx(() {
      bool isExpanded = controller.isSheetFullyExpanded.value;
      return Container(
        decoration: BoxDecoration(
          color: AppColor.kStatusBarPrimaryColor.value,
          borderRadius: BorderRadius.only(
            topLeft: isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
            topRight: isExpanded ? Radius.circular(0.r) : Radius.circular(20.r),
          ),
        ),
        child: ScrollConfiguration(
          behavior: NoGlowScrollBehavior(),
          child: ListView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            children: [
              if (!isExpanded) _line(),
              _whereTo(
                nowOnTab: () {
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
                      return null;
                    },
                  );
                },
                downOnTab: controller.onDropDownOnTab,
              ),
              _searchBar(),
              Obx(() => _tabsWidgetApiStatus(
                    status: controller.citySelectionController
                        .knownLocationsResponseStatus.value.status,
                    msg: controller.citySelectionController
                        .knownLocationsResponseStatus.value.message,
                  )),
              Obx(() => _tabBarViewApiStatus(
                    scrollController: scrollController,
                    status: controller.citySelectionController
                        .knownLocationsResponseStatus.value.status,
                    msg: controller.citySelectionController
                        .knownLocationsResponseStatus.value.message,
                  )),
              _destinationWidget(scrollController),
            ],
          ),
        ),
      );
    });
  }

  Widget _tabsWidgetApiStatus({int? status, String? msg}) {
    switch (status) {
      case 0:
        return const LocationListShimmer();
      case 1:
        return _tabsWidget();
      case -1:
        return ValueListenableBuilder<TextEditingValue>(
            valueListenable:
                controller.placeSearchController.destinationController,
            builder: (context, value, child) {
              return value.text != ""
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: 20.h),
                          CircleAvatar(
                              backgroundColor: AppColor.kLightTextPrimary.value
                                  .withOpacity(0.05),
                              child: Icon(
                                Icons.search,
                                color: AppColor.kPrimaryColor.value,
                              )),
                          SizedBox(height: 8.h),
                          textView(text: "Where Do You Want To Go".tr),
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: textView(
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                text:
                                    "Enter your destination in the search area above to find your location"
                                        .tr,
                                fontSize: AppFontSize.verySmall.value,
                                color: AppColor.kLightTextPrimary.value
                                    .withOpacity(0.5)),
                          ),
                          SizedBox(height: 8.h),
                          _useCurrentLocation(
                            icon: Icons.location_on,
                            value: "Select Location on Map".tr,
                            onTap: () {
                              controller.placeSearchController
                                  .destinationFocusNode.value
                                  .unfocus();
                              controller.placeSearchController
                                  .destinationController.text = "";
                              controller.isMapDragged.value = true;
                              controller.isSheetFullyExpanded.value = false;
                              controller.getAddressFromLatLng(controller
                                  .commonPlaceController.dropLatLng.value);
                              double targetHeight =
                                  controller.isMapDragged.value ? 0.3 : 0.5;
                              controller.draggableSheetHeight.value =
                                  targetHeight;
                              Future.delayed(const Duration(milliseconds: 100),
                                  () {
                                if (controller
                                    .draggableScrollableController.isAttached) {
                                  controller.draggableScrollableController
                                      .animateTo(
                                    targetHeight,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.fastOutSlowIn,
                                  );
                                } else {
                                  printLogs(
                                      "DraggableScrollableController is NOT attached!");
                                }
                              });
                            },
                          ),
                          SizedBox(height: 10.h),
                          _useCurrentLocation(
                              color: AppColor.kStatusBarPrimaryColor.value,
                              value: "Skip Destination".tr,
                              onTap: () {
                                controller.commonPlaceController.getPosition
                                    ?.value = GetPoistion.pin;
                                controller.commonPlaceController.dropLatLng
                                    .value = const LatLng(0.0, 0.0);
                                controller.commonPlaceController.dropLocation
                                    .value = "";
                                controller.commonPlaceController.dropSubtitle
                                    .value = "";
                                controller.done();
                              }),
                        ],
                      ),
                    );
            });
      case 400:
        return SizedBox(
            height: 200.h,
            width: ScreenUtil().screenWidth,
            child: Center(child: Text("$msg")));

      default:
        return SizedBox(
            height: 200.h,
            width: ScreenUtil().screenWidth,
            child: Center(child: Text("$msg")));
    }
  }

  Widget _tabBarViewApiStatus(
      {int? status, String? msg, required ScrollController scrollController}) {
    switch (status) {
      case 0:
        return const LocationListShimmer();
      case 1:
        return _tabBarViewContent(scrollController);

      case -1:
        return const SizedBox.shrink();

      case 400:
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  Widget _useCurrentLocation(
      {VoidCallback? onTap, IconData? icon, String? value, Color? color}) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
          border: Border.all(color: AppColor.kLightPrimary.value),
          borderRadius: BorderRadius.circular(20.r),
          color: color ?? AppColor.kPrimaryColor.value.withOpacity(0.7)),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: AppColor.kPrimaryTextColor.value,
                    size: 18.r,
                  )
                : const SizedBox.shrink(),
            SizedBox(
              width: 4.w,
            ),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: AppFontSize.small.value,
                  fontWeight: AppFontWeight.light.value,
                  color: AppColor.kPrimaryTextColor.value),
            )
          ],
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: _end(
                destinationController: controller.placeSearchController,
                hintText: "Enter your destination",
                onChanged: (value) {
                  if (value.isEmpty) {
                    controller.placeSearchController.clearDestinationText();
                    controller.placeSearchController.dropSuffixEnabled.value =
                        false;
                  } else {
                    controller.placeSearchController.dropSuffixEnabled.value =
                        true;
                  }
                  controller.placeSearchController.searchLocation(value: value);
                },
                onSubmitted: (value) {},
                destinationFocus:
                    controller.placeSearchController.destinationFocusNode.value,
                suffixOnTab: () {
                  Get.toNamed(AppRoutes.citySelectionPage, arguments: 2);
                },
                skipOnTab: () {
                  controller.commonPlaceController.getPosition?.value =
                      GetPoistion.pin;
                  controller.commonPlaceController.dropLatLng.value =
                      const LatLng(0.0, 0.0);
                  controller.commonPlaceController.dropLocation.value = "";
                  controller.commonPlaceController.dropSubtitle.value = "";
                  controller.done();
                },
                context: Get.context!),
          ),
        ],
      ),
    );
  }

  Widget _end(
      {String? hintText,
      void Function(String)? onChanged,
      void Function(String)? onSubmitted,
      PlaceSearchPageController? destinationController,
      FocusNode? destinationFocus,
      void Function()? suffixOnTab,
      void Function()? skipOnTab,
      required BuildContext context}) {
    return SizedBox(
      height: 32.h,
      child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: destinationController!.destinationController,
          builder: (context, value, child) {
            return CustomTextField(
              textController: destinationController.destinationController,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              enable: true,
              autofocus: controller.isDropEdit.value ||
                      !controller.isSheetFullyExpanded.value
                  ? false
                  : true,
              focusNode: destinationFocus,
              style: _textStyle(),
              onTap: () {
                controller.isSheetFullyExpanded.value = true;
                controller.draggableSheetHeight.value = 1.0;

                if (controller.draggableScrollableController.isAttached) {
                  controller.draggableScrollableController
                      .animateTo(
                    1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                  )
                      .then((_) {
                    print(
                        "Sheet expanded. Requesting focus... ${destinationFocus?.hasFocus}");
                    // Only request focus after sheet expansion is complete
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (destinationFocus != null &&
                          !destinationFocus.hasFocus) {
                        destinationFocus.requestFocus();
                      }
                    });
                  });
                }
              },
              decoration: _textFieldDecoration(
                hintText: hintText,
                skipTab: skipOnTab,
                onTab: suffixOnTab,
                clearButtonVisible: value.text.isNotEmpty,
                onClear: () {
                  destinationController.destinationController.clear();
                  if (onChanged != null) onChanged(''); // Clear callback
                },
              ),
            );
          }),
    );
  }

  _textFieldDecoration({
    String? hintText,
    Function()? onTab,
    Function()? skipTab,
    bool clearButtonVisible = false,
    void Function()? onClear,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h),
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
                double height = controller.draggableSheetHeight.value;
                // printLogs("Hii ravi taxi isSheetFullyExpanded: $height");
                if (height == 0.5) {
                  return controller.isSheetFullyExpanded.value
                      ? InkWell(
                          onTap: onTab,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              textView(
                                text: controller
                                    .citySelectionController.selectedCity.value,
                                fontSize: AppFontSize.smallMedium.value,
                                fontWeight: AppFontWeight.light.value,
                                color: AppColor.kLightTextPrimary.value
                                    .withOpacity(0.8),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: 1.h, left: 4.w),
                                child: Icon(
                                  Icons.keyboard_arrow_down_sharp,
                                  size: 22.r,
                                  color: AppColor.kLightTextPrimary.value
                                      .withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        )
                      : InkWell(
                          onTap: skipTab,
                          child: textView(
                            text: "Skip",
                            fontSize: AppFontSize.smallMedium.value,
                            fontWeight: AppFontWeight.light.value,
                            color: AppColor.kLightTextPrimary.value
                                .withOpacity(0.8),
                          ),
                        );
                } else {
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
                            color: AppColor.kLightTextPrimary.value
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ); /*InkWell(
                    onTap: onTab,
                    child: textView(
                      text:
                          controller.citySelectionController.selectedCity.value,
                      fontSize: AppFontSize.smallMedium.value,
                      fontWeight: AppFontWeight.light.value,
                      color: AppColor.kLightTextPrimary.value.withOpacity(0.8),
                    ),
                  );*/
                }
              }),
            ),
          ],
        ),
      ),
      hintStyle: TextStyle(
        fontSize: AppFontSize.smallMedium.value,
        fontWeight: AppFontWeight.medium.value,
        color: AppColor.kLightTextPrimary.value.withOpacity(0.8),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(16.r),
      ),
      filled: true,
      fillColor: Colors.grey[200],
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(16.r),
      ),
      isDense: true,
      // Reduces vertical padding
      contentPadding: EdgeInsets.only(right: 8.w), // Aligns content properly
    );
  }

  Widget _tabsWidget() {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.placeSearchController.destinationController,
        builder: (context, value, child) {
          return value.text != ""
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color:
                              AppColor.kLightTextPrimary.value.withOpacity(0.2),
                          height: 3.h,
                        )),
                    Obx(() {
                      if (controller
                          .citySelectionController.categories!.isEmpty) {
                        return const SizedBox(); // Don't build TabBar if data is not ready
                      }

                      return TabBar(
                        controller:
                            controller.citySelectionController.tabController,
                        labelColor: Colors.black,
                        indicatorWeight: 3.r,
                        unselectedLabelColor: Colors.grey,
                        // isScrollable: true,
                        indicatorColor: AppColor.kPrimaryColor.value,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: 0.w),
                        labelStyle: TextStyle(
                          fontWeight: AppFontWeight.semibold.value,
                          fontSize: AppFontSize.medium.value,
                        ),
                        tabs: List.generate(
                          controller
                                  .citySelectionController.categories?.length ??
                              1,
                          (index) {
                            final category = controller
                                .citySelectionController.categories?[index];
                            return Tab(
                              text: category?.name ?? "Category ${index + 1}",
                            );
                          },
                        ),
                      );
                    }),
                  ],
                );
        });
  }

  Widget _tabBarViewContent(ScrollController scrollController) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller.placeSearchController.destinationController,
      builder: (context, value, child) {
        return value.text != ""
            ? const SizedBox.shrink()
            : SizedBox(
                height: MediaQuery.of(context).size.height *
                    0.6, // Set a fixed height
                child: TabBarView(
                  controller: controller.citySelectionController.tabController,
                  children: List.generate(
                    controller.citySelectionController.categories?.length ?? 0,
                    (index) {
                      final category =
                          controller.citySelectionController.categories?[index];
                      return _airportTabContent(
                          scrollController, category ?? Categories());
                    },
                  ),
                ),
              );
      },
    );
  }

  Widget _destinationWidget(ScrollController scrollController) {
    return ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller.placeSearchController.destinationController,
        builder: (context, value, child) {
          return value.text != ""
              ? DestinationSuggestions(
                  scrollController: scrollController,
                )
              : const SizedBox.shrink();
        });
  }

  Widget _confirmDropOff(
      {Function()? favOnTab,
      required Function() confirmTab,
      required Function() listOnTab}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                              .commonPlaceController.dropLocation.value,
                          fontWeight: AppFontWeight.medium.value,
                        ),
                      ),
                      Obx(
                        () => textView(
                          text: controller
                              .commonPlaceController.dropSubtitle.value,
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
              SizedBox(width: 4.w)
            ],
          ),
          SizedBox(height: 30.h),
          Obx(
            () => controller.isOutsideUAE.value != true
                ? CustomButton(
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    height: 35.h,
                    width: double.maxFinite,
                    text: "Confirm dropoff",
                    onTap: confirmTab,
                  )
                : CustomButton(
                    height: 35.h,
                    padding: EdgeInsets.symmetric(horizontal: 0.w),
                    linearColor: whiteButtonLinearColorSecondary,
                    style: TextStyle(
                        color:
                            AppColor.kLightTextPrimary.value.withOpacity(0.5)),
                    width: double.maxFinite,
                    text: "Confirm dropoff",
                  ),
          ),
        ],
      ),
    );
  }

  Widget _whereTo(
      {required Function() nowOnTab, required Function() downOnTab}) {
    return Row(
      children: [
        Obx(() {
          bool isExpanded = controller.isSheetFullyExpanded.value;
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation, // Fading effect
                child: child,
              );
            },
            child: isExpanded
                ? Padding(
                    padding: EdgeInsets.only(left: 10.w, top: 5.h),
                    child: CustomCloseButton(
                      onTap: downOnTab,
                      icon: Icons.arrow_downward,
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 6.h, bottom: 6.h),
                    child: textView(
                      text: "Where to?",
                      fontSize: AppFontSize.dashboardDescription.value,
                      fontWeight: AppFontWeight.bold.value,
                    ),
                  ),
          );
        }),
        const Spacer(),
        Obx(() => Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: NowBookingWidget(
                isLaterBooking: controller.isLaterBooking,
                laterBookingDateTime: controller.laterBookingDateTime,
                onTab: nowOnTab,
              ),
            )),
      ],
    );
  }

  Widget useCurrentLocation(
      {VoidCallback? onTap, IconData? icon, String? value, Color? color}) {
    return Container(
      margin: EdgeInsets.only(top: 4.h, left: 12.w),
      decoration: BoxDecoration(
          border: Border.all(color: AppColor.kLightPrimary.value),
          borderRadius: BorderRadius.circular(20.r),
          color: color ?? AppColor.kPrimaryColor.value.withOpacity(0.5)),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon != null
                ? Icon(
                    icon,
                    color: AppColor.kPrimaryTextColor.value,
                    size: 18.r,
                  )
                : const SizedBox.shrink(),
            SizedBox(
              width: 4.w,
            ),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: AppFontSize.small.value,
                  fontWeight: AppFontWeight.light.value,
                  color: AppColor.kPrimaryTextColor.value),
            )
          ],
        ),
      ),
    );
  }

  String formatDateString(String dateString) {
    if (dateString.isEmpty) {
      return "Invalid Date";
    }

    try {
      // Define the format for parsing the input string
      DateFormat inputFormat = DateFormat("yyyy-MM-dd hh:mm:ss a");

      // Parse the string into a DateTime object
      DateTime dateTime = inputFormat.parse(dateString);

      // Format the DateTime into your desired format
      return DateFormat("dd MMM, hh:mm a").format(dateTime);
    } catch (e) {
      // Handle any parsing errors
      return "Invalid Date";
    }
  }

  Widget _nowBookingWidget({Function()? onTab}) {
    return InkWell(
      onTap: onTab,
      child: Padding(
        padding: EdgeInsets.only(right: 12.w),
        child: Obx(
          () {
            if (controller.laterBookingDateTime.isNotEmpty) {
              String formattedDate =
                  formatDateString(controller.laterBookingDateTime);

              return controller.isLaterBooking
                  ? Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 20.r,
                          color: AppColor.kPrimaryColor.value,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, right: 2.w),
                          child: textView(
                              text: formattedDate,
                              color: AppColor.kPrimaryIconColor.value,
                              fontSize: AppFontSize.medium.value,
                              fontWeight: AppFontWeight.semibold.value),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          size: 20.r,
                          color: AppColor.kPrimaryColor.value,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, right: 2.w),
                          child: textView(
                              text: "Now".tr,
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
                    );
            } else {
              // Handle the case where the date is empty
              return Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 20.r,
                    color: AppColor.kPrimaryColor.value,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 4.w, right: 2.w),
                    child: textView(
                        text: "Now".tr,
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
              );
            }
          },
        ),
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

  _textStyle() {
    return TextStyle(
        fontSize: AppFontSize.medium.value,
        fontWeight: AppFontWeight.medium.value,
        color: AppColor.kPrimaryTextColor.value);
  }

  Widget _airportTabContent(
      ScrollController scrollController, Categories categories) {
    final saveLocationController = Get.find<SaveLocationController>();

    return ListView.builder(
      itemCount: categories.locations?.length,
      physics: const ClampingScrollPhysics(),
      itemBuilder: (context, index) {
        final item = categories.locations?[index];
        return InkWell(
          onTap: () {
            if (controller.isDropEdit.value == true) {
              controller.commonPlaceController.dropLatLng.value = LatLng(
                  item?.latitude?.toDouble() ?? 0.0,
                  item?.longitude?.toDouble() ?? 0.0);
              controller.commonPlaceController.dropLocation.value =
                  item?.name ?? "";
              controller.commonPlaceController.dropSubtitle.value =
                  item?.address ?? "";
              Get.back(result: {
                'latLng': controller.commonPlaceController.dropLatLng.value,
                'address': controller.commonPlaceController.dropLocation.value,
              });
            } else {
              controller.commonPlaceController.dropLatLng.value = LatLng(
                  item?.latitude?.toDouble() ?? 0.0,
                  item?.longitude?.toDouble() ?? 0.0);
              controller.commonPlaceController.dropLocation.value =
                  item?.name ?? "";
              controller.commonPlaceController.dropSubtitle.value =
                  item?.address ?? "";
              // controller.placeSearchController.destinationController.text = item?.name ?? "";
              controller.commonPlaceController.getPosition?.value =
                  GetPoistion.pin;
              controller.citySelectionController.callKnownLocationPickupApi(
                  cityInfo: CountryInfo(
                      name:
                          controller.citySelectionController.selectedCity.value,
                      latitude: controller
                          .citySelectionController.selectedLatitude.value,
                      longitude: controller
                          .citySelectionController.selectedLongitude.value));
              controller.commonPlaceController.pickUpLocation.value =
                  controller.dashboardController.pickUpAddress.value;
              controller.commonPlaceController.pickUpLatLng.value =
                  controller.dashboardController.pickUpLatLng.value;
              Get.toNamed(AppRoutes.pickUpScreen);
            }
            printLogs("Hii taxi destination pickup page");
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                      color: AppColor.kLightPrimary.value.withOpacity(0.7),
                      shape: BoxShape.circle),
                  child: Icon(Icons.location_on_outlined,
                      size: 25.r, color: AppColor.kPrimaryColor.value),
                ),
                SizedBox(width: 16.w), // Space between avatar and text

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textView(
                          text: item?.name ?? "",
                          fontSize: AppFontSize.large.value,
                          fontWeight: AppFontWeight.semibold.value),
                      SizedBox(height: 5.h), // Space between title and subtitle
                      textView(
                        text: item?.address ?? "",
                        color:
                            AppColor.kLightTextPrimary.value.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w), // Space between text and trailing icon

                // Trailing icon
                InkWell(
                  onTap: () async {
                    if (item?.isFavorites == true) {
                      showDialogBox(
                          dismiss: true,
                          message:
                              "Are you sure you want to remove this saved location?",
                          middleTextStyle: TextStyle(
                              color: AppColor.kLightTextPrimary.value),
                          confirm: Obx(
                            () => CustomButton(
                              isLoader: controller.saveLocationLoader.value,
                              padding: EdgeInsets.zero,
                              width: 100.w,
                              text: "Yes",
                              height: 30.h,
                              onTap: () {
                                controller.callSaveLocationApi(
                                    sId: item?.sId, name: item?.name);
                              },
                            ),
                          ),
                          cancel: CustomButton(
                            padding: EdgeInsets.zero,
                            text: "No",
                            linearColor: redLinearColor,
                            height: 30.h,
                            width: 100.w,
                            onTap: () {
                              Get.back();
                            },
                          ));
                    } else {
                      saveLocationController.setSelectedLocation(
                          item?.name ?? "",
                          item?.address ?? "",
                          LatLng(item?.latitude?.toDouble() ?? 0.0,
                              item?.longitude?.toDouble() ?? 0.0));
                      Get.toNamed(AppRoutes.saveLocationPage);
                    }
                  },
                  child: Icon(
                    item?.isFavorites == true
                        ? Icons.favorite
                        : Icons.favorite_outline,
                    color: item?.isFavorites == true
                        ? AppColor.kPrimaryColor.value
                        : AppColor.kLightTextPrimary.value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showThumbsUpDialog() {
    Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            textView(
                text: "Are you sure you want to remove this saved location?"),
          ]),
          actions: <Widget>[
            CustomButton(
              text: "No",
              linearColor: redLinearColor,
              height: 35.h,
              width: double.maxFinite,
            ),
            SizedBox(height: 4.h),
            CustomButton(
              width: double.maxFinite,
              text: "Yes",
              height: 35.h,
            )
          ],
        ),
        barrierDismissible: true);
  }

  Future<bool> _onWillPop() async {
    if (controller.isDropEdit.value == false) {
      controller.isMapDragged.value = false;
      controller.placeSearchController.destinationController.text = '';
      controller.commonPlaceController.dropLocation.value = '';
      controller.commonPlaceController.dropLatLng.value =
          const LatLng(0.0, 0.0);
      controller.commonPlaceController.laterBookingDateTime.value = "";
      // Get.delete<DestinationController>();
      Get.offNamed(AppRoutes.dashboardPage);
    } else {
      Get.back();
      controller.isDropEdit.value = false;
    }
    return false;
  }

  Widget _mapPin() {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).size.height / 2.9),
        child: Obx(() {
          // This part will be reactive and will update based on camera dragging status
          if (controller.isCameraDragging.value) {
            // Default marker when camera is not dragging
            return Container(
              margin: EdgeInsets.only(top: 40.h),
              height: 7.h,
              width: 7.w,
              decoration: BoxDecoration(
                color: AppColor.kPrimaryColor.value,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColor.kPrimaryColor.value
                        .withOpacity(0.5), // Shadow color
                    spreadRadius: 5, // The spread radius
                    blurRadius: 10,
                  ),
                ],
              ),
            );
          } else {
            return Obx(() {
              // Marker for when the camera is dragging
              if (controller.isOutsideUAE.value) {
                // Render the default marker for outside UAE
                return locationNotAvailableMarker(
                  color: AppColor.kRedColour.value,
                  title: "RSL does not operate in this area",
                  backgroundColor: AppColor.kStatusBarPrimaryColor.value,
                  style: TextStyle(
                      fontSize: AppFontSize.medium.value,
                      color: AppColor.kPrimaryTextColor.value),
                );
              } else {
                // Render the custom pickDropMarkerNew for UAE
                return pickDropMarkerNew(
                  color: AppColor.kRedColour.value,
                  title: "Drop off",
                  image: Assets.destinationFlag,
                  backgroundColor: AppColor.kStatusBarPrimaryColor.value,
                  style: TextStyle(
                      fontSize: AppFontSize.medium.value,
                      fontWeight: AppFontWeight.semibold.value),
                );
              }
            });
          }
        }),
      ),
    );
  }

  Obx _googleMap() {
    return Obx(() => GoogleMap(
        zoomGesturesEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        padding: EdgeInsets.only(
            bottom: controller.isMapDragged.value == true ? 20.h : 150.h),
        initialCameraPosition: controller.initialCameraPosition(),
        onMapCreated: (GoogleMapController mapController) {
          mapController.setMapStyle(MapStyle.json);
          controller.isMapDragged.value = false;
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
        onCameraMove: (CameraPosition position) {
          controller.target.value = position.target;
          controller.isCameraDragging.value = true;
          // _onMapDrag(false);
        },
        onCameraMoveStarted: () {
          _onMapDrag(true);
        }));
  }

  void _onMapDrag(bool value) {
    controller.isMapDragged.value = value;
    controller.draggableSheetHeight.value = 0.3;
    controller.update();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (controller.draggableScrollableController.isAttached) {
        controller.draggableScrollableController.animateTo(
          0.3,
          duration: const Duration(milliseconds: 300),
          curve: Curves.fastOutSlowIn,
        );
        controller.draggableScrollableController.reset();
      } else {
        printLogs("_onMapDrag DraggableScrollableController is NOT attached!");
      }
    });
  }

  Widget _headerWidget({VoidCallback? backTap}) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 30.h, left: 8.w),
              child: CustomCloseButton(
                onTap: backTap,
                icon: controller.isDropEdit.value == false
                    ? Icons.close
                    : Icons.arrow_back,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget textView(
      {String? text,
      double? fontSize,
      FontWeight? fontWeight,
      Color? color,
      TextAlign? textAlign,
      int? maxLines}) {
    return Text(
      text ?? "",
      maxLines: maxLines ?? 1,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize ?? AppFontSize.medium.value,
        fontWeight: fontWeight ?? AppFontWeight.medium.value,
        color: color ?? AppColor.kPrimaryTextColor.value,
        // fontFamily: "Poppins"
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child; // This removes the glow effect
  }
}
