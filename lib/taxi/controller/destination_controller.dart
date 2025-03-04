import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsl_passenger/routes/routes.dart';
import 'package:rsl_passenger/taxi/controller/saved_location_controller.dart';
import '../../controller/common_place_controller.dart';
import '../../controller/place_search_page_controller.dart';
import '../../dashboard/controller/dashboard_page_controller.dart';
import '../../network/app_services.dart';
import '../../network/services.dart';
import '../data/save_location_api_data.dart';
import '../../widget/utils/api_response_handler.dart';
import 'city_selection_controller.dart';

class DestinationController extends GetxController {
  GoogleMapController? mapController;
  final commonPlaceController = Get.find<CommonPlaceController>();
  final placeSearchController = Get.find<PlaceSearchPageController>();
  final saveLocationController = Get.put(SaveLocationController());
  final citySelectionController = Get.put(CitySelectionController());
  final dashboardController = Get.find<DashBoardController>();

  var draggableSheetHeight = 0.5.obs;
  var isMapDragged = false.obs;
  var isSheetFullyExpanded = false.obs;
  var isDropEdit = false.obs;
  var saveLocationLoader = false.obs;
  var isAddressFetching = false.obs;
  late TabController tabController;

  late DraggableScrollableController draggableScrollableController;

  String get laterBookingDateTime =>
      commonPlaceController.laterBookingDateTime.value;

  bool get isLaterBooking => laterBookingDateTime.isNotEmpty;
  var isCameraDragging = false.obs;

  var getAddress = ''.obs;
  Rx<bool> mapLocationLoader = false.obs;
  Rx<LatLng> target = const LatLng(0.0, 0.0).obs;
  RxBool isOutsideUAE = false.obs;
  RxBool isInsideRadiusValue = true.obs;
  Rx<bool> showPolygon = false.obs;
  var dropEdit = 1.obs;

  // Rx<ResponseStatus> saveLocationResponseStatus = ResponseStatus().obs;

  RxSet<Marker> markers = RxSet<Marker>();
  RxSet<Marker> loadingMarkers = RxSet<Marker>();
  Rx<bool> isCameraIdle = true.obs;
  RxList<LatLng> polygon = RxList<LatLng>();
  Rx<double> animatedFooterHeight = 0.0.obs;
  Rx<double> animatedHeaderHeight = 0.0.obs;

  @override
  void onInit() {
    ever(isSheetFullyExpanded, (callback) async {
      if (isSheetFullyExpanded.value) {
        await Future.delayed(const Duration(seconds: 1));
        placeSearchController.destinationFocusNode.value.requestFocus();
      } else {
        placeSearchController.destinationController.text = '';
        placeSearchController.destinationFocusNode.value.unfocus();
      }
    });
    // if (!Get.isRegistered<DraggableScrollableController>()) {
      draggableScrollableController = DraggableScrollableController();
    // } else {
    //   draggableScrollableController = Get.find<DraggableScrollableController>();
    // }
    // draggableScrollableController = DraggableScrollableController();
    draggableScrollableController.addListener(() {
      final position = draggableScrollableController.size;
      isSheetFullyExpanded.value = (position == 1.0);
    });
    draggableSheetHeight.value = 0.5;
    isMapDragged.value = false; // Ensure it starts as false
    isSheetFullyExpanded.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDefaultAddressAndLatLng();
      _enableHeaderAndFooterWidget();
    });
    super.onInit();
  }

  @override
  void dispose() {
    draggableScrollableController.dispose();
    tabController.dispose();
    super.dispose();
  }

  getDefaultAddressAndLatLng() {
    getAddress.value = commonPlaceController.dropLocation.value;
    target.value = commonPlaceController.dropLatLng.value;
    printLogs(
        "Hii ravi taxi camera position def ${getAddress.value} ** ${target.value}");
  }

  void moveToCurrentLocation() {
    _checkAndGetCurrentPosition().then((value) {
      isAddressFetching.value = false;
      final newLatLng = LatLng(value.latitude, value.longitude);
      // pickUpLatLng.value = newLatLng;
      commonPlaceController.currentLatLng.value = newLatLng;
      _moveToCurrentPosition(newLatLng);
    }).catchError((onError) {
      isAddressFetching.value = false;
      Get.snackbar('Error!', onError.toString());
    });
  }

  Future<void> _moveToCurrentPosition(LatLng latLng) async {
    try {
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: 15,
          ),
        ),
      );
    } catch (e) {
      printLogs('error --> $e');
    }
  }

  Future<Position> _checkAndGetCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    isAddressFetching.value = true;
    return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium));
  }

  void onDropDownOnTab() {
    placeSearchController.destinationFocusNode.value.unfocus();
    placeSearchController.destinationController.text = "";
    isMapDragged.value = true;
    isSheetFullyExpanded.value = false;
    getAddressFromLatLng(commonPlaceController.dropLatLng.value);
    // Set the target height
    double targetHeight = isMapDragged.value ? 0.3 : 0.5;
    draggableSheetHeight.value = targetHeight;
    update();
    if (draggableScrollableController.isAttached) {
      draggableScrollableController.animateTo(
        targetHeight,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Delay for height correction if necessary
      Future.delayed(const Duration(milliseconds: 100), () {
        double currentSize = draggableScrollableController.size;

        if (currentSize == 1.0) {
          if (draggableScrollableController.isAttached) {
            draggableScrollableController.animateTo(
              0.3,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          }
        }
      });
    }
  }

  done() {
    if (mapLocationLoader.value != true) {
      commonPlaceController.pickUpLocation.value =
          dashboardController.pickUpAddress.value;
      commonPlaceController.pickUpLatLng.value =
          dashboardController.pickUpLatLng.value;
      Get.toNamed(AppRoutes.pickUpScreen);
    }
  }

  getAddressFromLatLng(LatLng newLatLng) async {
    try {
      List<String> allowedCountries = dashboardController
              .getApiData.value.rslGetCore?.first.availableDropLocations ??
          [];

      // Fetch place information using coordinates
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          newLatLng.latitude, newLatLng.longitude);
      if (placeMarks.isEmpty) return;

      final placeMark = placeMarks.first;

      // If it's a drop page, allow any location inside the UAE
      if (allowedCountries.contains(placeMark.country)) {
        isOutsideUAE.value = false;
        final title = placeMark.name ?? "Unknown Location";
        final subtitle =
            "${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.country}";

        commonPlaceController.dropLocation.value = title;
        commonPlaceController.dropSubtitle.value = subtitle;
        commonPlaceController.dropLocation.refresh();
        commonPlaceController.dropSubtitle.refresh();
      } else {
        // Location is outside the UAE for drop
        final latLngAddress =
            "[${newLatLng.latitude.toStringAsFixed(4)}, ${newLatLng.longitude.toStringAsFixed(4)}]";
        isOutsideUAE.value = true;

        // Update the drop location address
        commonPlaceController.dropLocation.value = latLngAddress;
        commonPlaceController.dropSubtitle.value = ""; // No address subtitle
      }

      // Show address or latitude/longitude depending on whether it's inside or outside the UAE
      if (!showPolygon.value) {
        getAddress.value = isOutsideUAE.value
            ? "Lat: ${newLatLng.latitude}, Lng: ${newLatLng.longitude}"
            : "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
      }

      mapLocationLoader.value = false;
    } catch (e) {
      mapLocationLoader.value = false;
      printLogs('error --> $e');
    }
  }

  /*callSaveLocationApi(
      {String? sId = "", bool? isFavorites = false, String? name}) {
    saveLocationLoader.value = true;
    saveLocationResponseStatus.value.status = 0;
    saveLocationResponseStatus.refresh();
    saveLocationApi(SaveLocationRequestData(
      sId: sId,
      passengerId:
          int.tryParse(dashboardController.userInfo.value?.rslId ?? ""),
      placeType: 4,
      placeTypeName: "Others",
      requestType: 2,
      houseNo: "",
      landmark: "",
      latitude: 0.0,
      longitude: 0.0,
      name: name,
      address: "",
      isFavorites: isFavorites,
    )).then((value) {
      if (value.status == 1) {
        saveLocationLoader.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        citySelectionController.getUserInfo();
        Get.back();
      } else {
        saveLocationLoader.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        Get.back();
        printLogs("Hii countryCityList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii countryCityList api error catch : $error ** ${stackTrace.toString()}");
      saveLocationLoader.value = false;
      Get.back();
      saveLocationResponseStatus.value.status = 400;
      saveLocationResponseStatus.value.message = "something_went_wrong".tr;
      saveLocationResponseStatus.refresh();
    });
  }*/

  void setTarget({required LatLng getTarget}) {
    target.value = getTarget;
    target.refresh();
    getAddressFromLatLng(target.value);
    // onCameraIdle();
  }

  initialCameraPosition() {
    // getAddressFromLatLng(commonPlaceController.dropLatLng.value);
    return CameraPosition(
      target: commonPlaceController.dropLatLng.value,
      zoom: 15,
    );
  }

  _enableHeaderAndFooterWidget() {
    animatedHeaderHeight.value = 80;
    animatedFooterHeight.value = 80;
  }

  hideZoneView() {
    isCameraIdle.value = true;
    markers.clear();
    loadingMarkers.clear();
    showPolygon.value = false;
    onCameraPosition(target.value);
  }

  void onCameraPosition(LatLng target) {
    if (!showPolygon.value) {
      mapLocationLoader.value = true;
      getAddressFromLatLng(target);
    }
  }

  void moveCamera(terminalList) {
    if (mapController == null) return;
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target.value, 15.0),
    );
  }

  Rx<ResponseStatus> saveLocationResponseStatus = ResponseStatus().obs;

  callSaveLocationApi(
      {String? sId = "", bool? isFavorites = false, String? name}) {
    saveLocationLoader.value = true;
    saveLocationResponseStatus.value.status = 0;
    saveLocationResponseStatus.refresh();
    saveLocationApi(SaveLocationRequestData(
      sId: sId,
      passengerId:
          9 /*int.tryParse(dashboardController.userInfo.value?.rslId ?? "")*/,
      placeType: 4,
      placeTypeName: "Others",
      requestType: 2,
      houseNo: "",
      landmark: "",
      latitude: 0.0,
      longitude: 0.0,
      name: name,
      address: "",
      isFavorites: isFavorites,
    )).then((value) {
      if (value.status == 1) {
        saveLocationLoader.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        // citySelectionController.getUserInfo();
        Get.back();
      } else {
        saveLocationLoader.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        Get.back();
        printLogs("Hii countryCityList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii countryCityList api error catch : $error ** ${stackTrace.toString()}");
      saveLocationLoader.value = false;
      Get.back();
      saveLocationResponseStatus.value.status = 400;
      saveLocationResponseStatus.value.message = "something_went_wrong".tr;
      saveLocationResponseStatus.refresh();
    });
  }
}
