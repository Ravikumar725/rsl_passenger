import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/place_search_page_controller.dart';
import '../../network/services.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';

class DestinationSuggestions extends GetView<PlaceSearchPageController> {
  final int type;
  final ScrollController? scrollController;
  const DestinationSuggestions(
      {super.key, this.type = 0, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => controller.predictResponse.value.predictions.isNotEmpty
          ?  _listPredication()
          : const SizedBox.shrink(),
    );
  }

  Widget _listPredication() {
    if (controller.searching.value == true) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: 5, // Number of shimmer items to show
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Padding(
              padding: EdgeInsets.only(top: 15.h),
              child: Container(
                height: 30.h,
                margin: EdgeInsets.symmetric(vertical: 5.h),
              ),
            ),
          );
        },
       /* Container(
            color: AppColor.kPrimaryColor.value,
            constraints: BoxConstraints(maxHeight: 2.h),
            child: LinearProgressIndicator(
              color: AppColor.kPrimaryColor.value,
            )),*/
      );
    } else if (controller.predictResponse.value.status == "OK") {
      return controller.predictResponse.value.predictions.isNotEmpty
          ? ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              controller: scrollController,
              physics: const ScrollPhysics(),
              itemCount: controller.predictResponse.value.predictions.length,
              // Replace myList with your actual list of data
              itemBuilder: (context, index) {
                return _locationListWidget(
                    controller.predictResponse.value.predictions[index],
                    controller,
                    index);
              },
            )
          : const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }

  Widget _locationListWidget(Prediction predictionList,
      PlaceSearchPageController controller, int index) {
    // final saveLocationController = Get.find<SaveLocationController>();

    String locationType = predictionList.description?.toLowerCase() ?? "";
    return Padding(
      padding: EdgeInsets.only(top: 15.h),
      child: InkWell(
        onTap: () {
          controller.locationSelected(
              predictionList: predictionList, type: type);
        },
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 2.h),
                child: CircleAvatar(
                  backgroundColor: AppColor.kLightPrimary.value,
                  child: Icon(
                    getLocationIcon(locationType),
                    color: AppColor.kPrimaryColor.value,
                    size: 18.r,
                  ),
                ),
              ),
              SizedBox(
                width: 8.w,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${predictionList.description}",
                      overflow: TextOverflow.ellipsis,
                      style: _textStyle1(),
                    ),
                    SizedBox(
                      height: 8.h,
                    ),
                    Row(
                      children: [
                        Obx(
                          () => controller.distancesList.isNotEmpty &&
                                  index < controller.distancesList.length
                              ? Text(
                                  "${controller.distancesList[index]} - ",
                                  overflow: TextOverflow.ellipsis,
                                  style: _textStyle2(),
                                )
                              : const SizedBox.shrink(),
                        ),
                        Expanded(
                          child: predictionList
                                      .structuredFormatting?.secondaryText !=
                                  null
                              ? Text(
                                  "${predictionList.structuredFormatting?.secondaryText}",
                                  overflow: TextOverflow.ellipsis,
                                  style: _textStyle2(),
                                )
                              : Text(
                                  "${predictionList.structuredFormatting?.mainText}",
                                  overflow: TextOverflow.ellipsis,
                                  style: _textStyle2(),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  // saveLocationController.setSelectedPrediction(predictionList);
                  // Get.toNamed(NewAppRoutes.saveLocationPage);
                },
                child: Icon(Icons.favorite_outline,
                    color: AppColor.kLightTextPrimary.value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData getLocationIcon(String locationType) {
    if (locationType.contains('mall')) {
      return Icons.shopping_cart; // Icon for malls
    } else if (locationType.contains('airport')) {
      return Icons.local_airport; // Icon for airports
    } else if (locationType.contains('marina')) {
      return Icons.directions_boat; // Icon for marinas
    } else if (locationType.contains('hotel')) {
      return Icons.hotel; // Icon for hotels
    } else {
      return Icons.place; // Default icon for other types
    }
  }

  _textStyle1() {
    return TextStyle(
        fontSize: AppFontSize.medium.value,
        fontWeight: AppFontWeight.semibold.value,
        color: AppColor.kPrimaryTextColor.value);
  }

  _textStyle2() {
    return TextStyle(
        fontSize: AppFontSize.small.value,
        fontWeight: AppFontWeight.light.value,
        color: AppColor.kLightTextPrimary.value);
  }
}
