import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rsl_passenger/dashboard/controller/dashboard_page_controller.dart';
import 'package:rsl_passenger/network/services.dart';
import 'package:rsl_passenger/widget/custom_button.dart';
import '../routes/routes.dart';
import '../widget/app_loader.dart';
import '../widget/styles/colors.dart';
import 'map_bottom_sheet.dart';

class DashboardPage extends GetView<DashBoardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Dashboard"),
      ),
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Center(
              child: CustomButton(
                text: "Cab",
                height: 35.h,
                width: 100.w,
                onTap: () {
                  controller.commonPlaceController.dropLatLng.value =
                      controller.pickUpLatLng.value;
                  Get.toNamed(AppRoutes.destinationPage);
                  printLogs("Button Pressed!");
                },
              ),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20.h,right: 8.w),
                    child: Obx(
                          () => InkWell(
                        onTap: () {
                          controller.checkAndGetCurrentLocation();
                        },
                        child: controller.isAddressFetching.value
                            ? const AppLoader()
                            : Container(
                          height: 30.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                              color: AppColor.kPrimaryColor.value,
                              borderRadius: BorderRadius.circular(8.r)),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 4.w),
                                child: Center(
                                  child: Icon(
                                    Icons.location_searching_outlined,
                                    size: 15.r,
                                    color: AppColor.kPrimaryTextColor.value,
                                  ),
                                ),
                              ),
                              const Text("Fetch Location"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                MapBottomSheet(
                  skipTap: () => controller.moveToPickupPage(),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
