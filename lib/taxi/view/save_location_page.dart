import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../safe_area_container.dart';
import '../../widget/custom_button.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../controller/saved_location_controller.dart';
import '../widget/back_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/map_style.dart';
import '../widget/text_field.dart';

class SaveLocationPage extends GetView<SaveLocationController> {
  const SaveLocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        controller.markers.clear();
        Get.back();
        return false;
      },
      child: SafeAreaContainer(
          child: Scaffold(
        appBar: _myAppBarWidget(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.kStatusBarPrimaryColor.value,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(12.r),
                        ),
                        child: SizedBox(height: 150.h, child: _googleMap()),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 4.h, horizontal: 4.w),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColor.kLightPrimary.value,
                              child: Icon(Icons.location_on,
                                  color: AppColor.kPrimaryColor.value),
                            ),
                            SizedBox(
                                width:
                                    10.w), // Spacing between the icon and text
                            // Title and subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  textView(
                                      text: controller.locationName.value,
                                      fontSize: AppFontSize.large.value,
                                      fontWeight: AppFontWeight.semibold.value),
                                  SizedBox(height: 5.h),
                                  textView(
                                      text: controller.pickupDetails.value,
                                      color: AppColor.kLightTextPrimary.value
                                          .withOpacity(0.6)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Location name input
                CustomTextField(
                  textController: controller.locationNameController,
                  hintText: "Name your location (Home/Work etc.)".tr,
                  autofocus: false,
                  enable: true,
                  keyboardType: TextInputType.streetAddress,
                  onChanged: (value) {},
                  cursorColor: AppColor.kPrimaryColor.value,
                  decoration: InputDecoration(
                      hintText: "Name your location (Home/Work etc.)".tr,
                      hintStyle: TextStyle(
                          color:
                              AppColor.kPrimaryTextColor.value.withOpacity(0.4),
                          fontSize: AppFontSize.medium.value,
                          fontWeight: AppFontWeight.medium.value),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: controller.locationNameError.value.isEmpty
                              ? AppColor.kPrimaryColor.value
                              : AppColor.kRedColour.value,
                          width: 2.r,
                        ),
                      )),
                ),
                // Pickup details input
                Obx(
                  () => controller.showOtherDetail.value
                      ? CustomTextField(
                          textController: controller.pickupDetailsController,
                          hintText: "Add pickup details".tr,
                          autofocus: false,
                          enable: true,
                          keyboardType: TextInputType.streetAddress,
                          onChanged: (value) {},
                          cursorColor: AppColor.kPrimaryColor.value,
                          decoration: InputDecoration(
                              hintText: "Add pickup details".tr,
                              hintStyle: TextStyle(
                                  color: AppColor.kPrimaryTextColor.value
                                      .withOpacity(0.4),
                                  fontSize: AppFontSize.medium.value,
                                  fontWeight: AppFontWeight.medium.value),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: AppColor.kPrimaryColor.value,
                                  width: 2.r,
                                ),
                              )))
                      : InkWell(
                          onTap: () {
                            controller.showOtherDetail.value =
                                !controller.showOtherDetail.value;
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 14.h),
                            child: textView(
                                text: "ADD OTHER DETAILS+",
                                fontSize: AppFontSize.smallMedium.value,
                                fontWeight: AppFontWeight.semibold.value,
                                color: AppColor.kPrimaryColor.value),
                          ),
                        ),
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CustomButton(
                    onTap: () {
                      if (controller.locationNameController.text
                          .trim()
                          .isEmpty) {
                        Get.snackbar(
                            'Warning!', "Please enter a location name.");
                      } else {
                        controller.callSaveLocationApi1(isFavorites: true);
                      }
                    },
                    padding: EdgeInsets.zero,
                    text: "Save",
                    isLoader: controller.isLoading.value,
                    height: 35.h,
                    width: double.maxFinite,
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Obx _googleMap() {
    return Obx(() => GoogleMap(
        zoomGesturesEnabled: false,
        scrollGesturesEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        myLocationEnabled: false,
        initialCameraPosition: controller.initialCameraPosition(),
        onMapCreated: (GoogleMapController mapController) {
          mapController.setMapStyle(MapStyle.json);
          controller.mapController = mapController;
        },
        markers: controller.markers,
        onCameraMove: (CameraPosition position) {
          controller.setTarget(getTarget: position.target);
        },
        onCameraMoveStarted: () {}));
  }

  MyAppBar _myAppBarWidget() {
    return MyAppBar(
      themedark: false,
      kStatusBarPrimaryColor: AppColor.kPrimaryColor.value,
      elevation: 0,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _backButton(
            onTap: () {
              controller.markers.clear();
              Get.back();
            },
          ),
          textView(
              text: "Save location",
              fontSize: AppFontSize.info.value,
              fontWeight: AppFontWeight.semibold.value),
        ],
      ),
    );
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

  Widget _backButton({VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: AppColor.kLightPrimary.value)),
          child: const CustomCloseButton()),
    );
  }
}
