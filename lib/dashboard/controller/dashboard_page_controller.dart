import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rsl_passenger/routes/routes.dart';
import 'package:rsl_passenger/widget/utils/global_utils.dart';
import '../../controller/common_place_controller.dart';
import '../../widget/utils/enums.dart';
import '../data/get_core_api_data.dart';
import '../../network/app_services.dart';
import '../../network/services.dart';
import '../../taxi/data/nearest_drivers_list_api_data.dart';
import '../../widget/custom_button.dart';

class DashBoardController extends GetxController with WidgetsBindingObserver {
  Rx<ResponseData> getApiData = ResponseData().obs;
  RxBool showPromoCodeView = false.obs;
  var pickUpLatLng = const LatLng(0, 0).obs;
  var pickUpAddress = "".obs;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  Rx<Packages> selectedPackage = Packages().obs;

  @override
  void onInit() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    checkAndGetCurrentLocation();
    callGetCoreApi();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNearestDriversListApiTimer();
    super.onInit();
  }
  var isAddressFetching = false.obs;
  final commonPlaceController = Get.put(CommonPlaceController());
  Timer? _nearestDriversListTimer;
  RxList<Marker> markers = <Marker>[].obs;
  BitmapDescriptor? carIcon;

  @override
  void dispose() {
    _cancelNearestDriversListTimer();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<Position> _checkAndGetCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show a dialog explaining why location is needed
        _showPermissionBottomSheet();
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Show a dialog to guide the user to settings
      _showPermissionBottomSheet();
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium);
  }

  // Show Bottom Sheet for Permission Request
  void _showPermissionBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_off, size: 50, color: Colors.red),
            SizedBox(height: 10.h),
            const Text(
              "Location Permission Required",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            const Text(
              "RSL needs access to your location to provide the best experience. Please enable location permission in settings",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    height: 35.h,
                    text: 'Allow Location Access',
                    onTap: () {
                      Get.back(); // Close Bottom Sheet
                      openAppSettings(); // Open App Settings
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: false,
    );
  }

  void _showLocationServiceError() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.gps_off, size: 50, color: Colors.red),
            SizedBox(height: 10.h),
            const Text(
              "Location Services Disabled",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.h),
            const Text(
              "Please enable location services from your device settings to continue.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    height: 35.h,
                    text: 'Enable Location',
                    onTap: () {
                      Get.back(); // Close Bottom Sheet
                      Geolocator.openLocationSettings(); // Open Location Settings
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: false,
    );
  }

  void checkAndGetCurrentLocation() {
    _checkAndGetCurrentPosition().then((value) {
      isAddressFetching.value = false;
      final newLatLng = LatLng(value.latitude, value.longitude);
      pickUpLatLng.value = newLatLng;
      commonPlaceController.currentLatLng.value = newLatLng;
      _getAddressFromLatLng(newLatLng, 0);
    }).onError((onError, stackTrace) {
      isAddressFetching.value = false;
      _showPermissionBottomSheet();
      printLogs("checkAndGetCurrentLocation Error $onError ** ${stackTrace.toString()}");
    });
  }

  void getAddress(LatLng newLatLng) {
    _getAddressFromLatLng(newLatLng, 1);
  }

  Future<void> checkCurrentLocationAndMoveToNextPage(
      {int type = 1, bool? searchEnable}) async {

    if (isAddressFetching.value || pickUpLatLng.value.latitude == 0) {
      Get.snackbar(
        "Warning",
        "Please wait. We\ 're trying to fetching your location",
      );
      return;
    } else {
      Get.toNamed(AppRoutes.destinationPage);
    }
  }

  void _getAddressFromLatLng(LatLng newLatLng, int type) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          newLatLng.latitude, newLatLng.longitude);
      if (placeMarks.isEmpty) return;

      final placeMark = placeMarks.first;

      final address =
          "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
      pickUpAddress.value = address;
      commonPlaceController.currentAddress.value = address;
      if (type == 0) {
        _callNearestDriversListTimerApi();
      }
    } catch (e) {
      printLogs('error --> $e');
    }
  }

  void callGetCoreApi() {
    getCoreApi().then((value) {
      if (value.status == 1) {
        getApiData.value = value.responseData ?? ResponseData();
        getApiData.refresh();
      } else {
        printLogs("${value.message}");
      }
    }).onError((error, stackTrace) {
    });
  }

  _scheduleNearestDriversListApiTimer() {
    _cancelNearestDriversListTimer();
    _nearestDriversListTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) {
      _callNearestDriversListTimerApi();
    });
  }

  void _cancelNearestDriversListTimer() {
    try {
      _nearestDriversListTimer?.cancel();
    } catch (e) {
      e.printError();
    }
  }

  List<DriverDetail>? _driverDetails;

  void _callNearestDriversListTimerApi() {
    nearestDriverListApi(
      _getNearestDriversApiRequestData(),
    ).then((nearestDriversListResponse) async {
      switch (nearestDriversListResponse.status) {
        case 1:
          _driverDetails = nearestDriversListResponse.detail;
          _updateVehicleMarkers();
          break;
        case 0:
          _driverDetails = null;
          _removeAllVehicleMarkers();
          break;
        default:
      }
    });
  }

  NearestDriversListRequestData _getNearestDriversApiRequestData() =>
      NearestDriversListRequestData(
          skipFav: '0',
          passengerAppVersion: '',
          latitude: '${commonPlaceController.pickUpLatLng.value.latitude}',
          longitude: '${commonPlaceController.pickUpLatLng.value.longitude}',
          dropLat: '0.0',
          dropLng: '0.0',
          address: commonPlaceController.pickUpLocation.value,
          cityName: '',
          passengerId: GlobalUtils.rslID,
          placeId: '',
          motorModel: GlobalUtils.defaultModelID,
          routePolyline: '');

  void _updateVehicleMarkers() async {
    markers.clear();

    for (DriverDetail driverDetail in _driverDetails ?? []) {
      printLogs(
          "CAR MARKER UPDATED ${driverDetail.latitude}, ${driverDetail.longitude}");
      markers.add(
        Marker(
          markerId: MarkerId('${driverDetail.taxiId}'),
          position: LatLng(
            driverDetail.latitude ?? 0.0,
            driverDetail.longitude ?? 0.0,
          ),
          icon: carIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    }
    markers.refresh();
  }

  void _removeAllVehicleMarkers() {
    markers
      ..clear()
      ..refresh();
  }

  void moveToDropPage() {
    commonPlaceController.getPosition?.value = GetPoistion.drop;
    commonPlaceController.dropLocation.value = pickUpAddress.value;
    commonPlaceController.dropLatLng.value = pickUpLatLng.value;
    Get.toNamed(AppRoutes.destinationPage);
  }

  void moveToPickupPage() {
    commonPlaceController.getPosition?.value = GetPoistion.pin;
    commonPlaceController.pickUpLocation.value = pickUpAddress.value;
    commonPlaceController.pickUpLatLng.value = pickUpLatLng.value;
    commonPlaceController.dropLatLng.value = const LatLng(0, 0);
    commonPlaceController.dropLocation.value = "";
    Get.toNamed(AppRoutes.pickUpScreen);
  }
}