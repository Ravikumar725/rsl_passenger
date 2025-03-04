import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../assets/assets.dart';
import '../../network/services.dart';
import '../../safe_area_container.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../controller/city_selection_controller.dart';
import '../data/known_location_list_api_data.dart';
import '../widget/back_button.dart';
import '../widget/custom_app_bar.dart';
import '../widget/now_booking_widget.dart';
import '../widget/text_field.dart';

class CitySelectionPage extends GetView<CitySelectionController> {
  const CitySelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    printLogs("Hii taxi city selection is ${Get.arguments}");
    int type = Get.arguments;
    return SafeAreaContainer(
      child: Scaffold(
        appBar: _myAppbarWidget(),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: _end(context: Get.context!, hintText: "Search for a city"),
            ),
            _sizedBox(height: 8.h),

            // City List
            Expanded(
              child: Obx(() {
                // Check if the response status is valid
                if (controller.countryCityListResponseStatus.value.status !=
                    1) {
                  return const CitySelectionShimmer(); // Show shimmer if the status is not valid
                } else if (controller.filteredCountryCityList.isEmpty) {
                  // Check if the filtered list is empty
                  return Center(
                    child: textView(
                        text: "No countries found",
                        fontWeight: AppFontWeight.medium.value,
                        fontSize: AppFontSize.info.value,
                        color: AppColor.kPrimaryTextColor.value),
                  );
                } else {
                  return ListView.builder(
                    itemCount: controller.filteredCountryCityList.length,
                    itemBuilder: (context, index) {
                      final countryName =
                          controller.filteredCountryCityList[index];
                      final flag = controller
                          .getFlagForCountryCode(countryName.countryCode ?? "");

                      return Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 4.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Country with Flag
                            Row(
                              children: [
                                textView(
                                  text: flag,
                                  fontWeight: AppFontWeight.semibold.value,
                                  fontSize: AppFontSize.info.value,
                                ),
                                _sizedBox(),
                                textView(
                                  text: countryName.name,
                                  fontWeight: AppFontWeight.semibold.value,
                                  fontSize: AppFontSize.info.value,
                                ),
                              ],
                            ),
                            _sizedBox(),

                            // Cities under the country
                            ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  const NeverScrollableScrollPhysics(), // Disable inner scrolling
                              itemCount: countryName.city?.length ??
                                  0, // Check for null city list
                              itemBuilder: (context, cityIndex) {
                                final city = countryName.city?[cityIndex];
                                return InkWell(
                                  onTap: () {
                                    Get.back();
                                    controller.selectedCity.value =
                                        city?.name ?? "";
                                    controller.selectedLatitude.value =
                                        city?.latitude?.toDouble() ?? 0.0;
                                    controller.selectedLongitude.value =
                                        city?.longitude?.toDouble() ?? 0.0;
                                    printLogs("Hii taxi city selection is $type");
                                    if (type == 1) {
                                      controller.callKnownLocationPickupApi(
                                          cityInfo: CountryInfo(
                                              name: city?.name,
                                              latitude: city?.latitude,
                                              longitude: city?.longitude));
                                    } else {
                                      controller.callKnownLocationsByCity(
                                          countryInfo: CountryInfo(
                                              name: countryName.name,
                                              latitude: countryName.latitude,
                                              longitude: countryName.longitude),
                                          cityInfo: CountryInfo(
                                              name: city?.name,
                                              latitude: city?.latitude,
                                              longitude: city?.longitude));
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        left: 32.w, bottom: 10.h, top: 10.h),
                                    child: textView(
                                      text: city?.name ??
                                          "Unknown City", // Add fallback for null city name
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }
              }),
            )
          ],
        ),
      ),
    );
  }

  Widget _sizedBox({double? height, double? width}) {
    return SizedBox(
      height: height ?? 8.h,
      width: width ?? 8.w,
    );
  }

  Widget _end(
      {String? hintText,
      void Function(String)? onChanged,
      void Function(String)? onSubmitted,
      FocusNode? destinationFocus,
      required BuildContext context}) {
    return SizedBox(
      height: 32.h,
      child: CustomTextField(
        textController: controller.citySelectController,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        enable: true,
        autofocus: false,
        focusNode: destinationFocus,
        style: _textStyle(),
        decoration: _textFieldDecoration(
          hintText: hintText,
        ),
      ),
    );
  }

  _textFieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: "$hintText",
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h),
        child: SvgPicture.asset(
          Assets.search,
          height: 10.h,
          width: 10.w,
          // ignore: deprecated_member_use
          color: AppColor.kLightTextPrimary.value,
        ),
      ),
      hintStyle: TextStyle(
          fontSize: AppFontSize.smallMedium.value,
          fontWeight: AppFontWeight.medium.value,
          color: AppColor.kLightTextPrimary.value.withOpacity(0.8)),
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
      //labelText: 'Even Densed TextFiled',
      isDense: true,
      // Added this
      contentPadding: EdgeInsets.zero, // Added this
    );
  }

  _textStyle() {
    return TextStyle(
        fontSize: AppFontSize.medium.value,
        fontWeight: AppFontWeight.medium.value,
        color: AppColor.kPrimaryTextColor.value);
  }

  MyAppBar _myAppbarWidget() {
    return MyAppBar(
      elevation: 0.0,
      title: _backButton(onTap: () {
        Get.back();
      }),
      themedark: false,
      appBarBackgroundColor: AppColor.kBackGroundColor.value.withOpacity(0.8),
    );
  }

  Widget _backButton({VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColor.kLightPrimary.value),
        ),
        child: CustomBackButton(
          iconSize: 10.r,
          color: AppColor.kPrimaryTextColor.value.withOpacity(0.6),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          onTap: onTap,
        ),
      ),
    );
  }
}

class CitySelectionShimmer extends StatelessWidget {
  const CitySelectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5, // Number of shimmer items to display
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Shimmer effect for flag (replace with real flag later)
                  Container(
                    width: 40,
                    height: 40,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                  // Shimmer effect for country name
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        color: Colors.white,
                      ),
                      SizedBox(height: 8),
                      // Shimmer effect for city list
                      Container(
                        width: 80,
                        height: 12,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
