import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rsl_passenger/dashboard/controller/dashboard_page_controller.dart';

import '../routes/routes.dart';
import '../widget/app_loader.dart';
import '../widget/styles/colors.dart';

class DashboardPage extends GetView<DashBoardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("Dashboard"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7AC6BF), // Change button color
                foregroundColor: Colors.white, // Change text color
              ),
              onPressed: () {
                controller.commonPlaceController.dropLatLng.value = controller.pickUpLatLng.value;
                // controller.placeSearchController.dropLatLng.value =
                //     controller.commonPlaceController.currentLatLng.value;
                Get.toNamed(AppRoutes.destinationPage);
                print("Button Pressed!");
              },
              child: const Text("Cab"),
            ),
            Align(
              alignment: Alignment.center,
              child: FloatingActionButton(
                heroTag: null,
                onPressed: () {
                  controller.checkAndGetCurrentLocation();
                },
                backgroundColor: Colors.white,
                mini: true,
                child: controller.isAddressFetching.value
                    ? const AppLoader()
                    : Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(80.r),
                    //set border radius more than 50% of height and width to make circle
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(4.r),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColor.kPrimaryColor.value,
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(2.r),
                        child: Center(
                          child: Icon(
                            Icons.location_searching_outlined,
                            size: 15.r,
                            color: AppColor.kWhiteIconColor.value,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
