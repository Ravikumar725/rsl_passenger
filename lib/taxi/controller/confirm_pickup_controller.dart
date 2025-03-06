import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsl_passenger/routes/routes.dart';
import 'package:rsl_passenger/taxi/controller/saved_location_controller.dart';
import '../../controller/common_place_controller.dart';
import '../../controller/place_search_page_controller.dart';
import '../../dashboard/controller/dashboard_page_controller.dart';
import '../../network/services.dart';
import '../../widget/utils/enums.dart';
import 'city_selection_controller.dart';
import 'destination_controller.dart';

class ConfirmPickupController extends GetxController {
  late DraggableScrollableController draggableScrollableControllerPick;
  var isSheetFullyExpandedPick = false.obs;
  var draggableSheetHeightPick = 0.28.obs;

  final commonPlaceController = Get.find<CommonPlaceController>();
  final saveLocationController = Get.put(SaveLocationController());
  final citySelectionController = Get.put(CitySelectionController());
  final dashboardController = Get.find<DashBoardController>();
  final destinationController = Get.find<DestinationController>();
  final placeSearchController = Get.find<PlaceSearchPageController>();

  var isAddressFetching = false.obs;
  GoogleMapController? mapController;
  var mapType = MapType.normal.obs;
  var trafficEnabled = false.obs;
  var getAddress = ''.obs;
  var pickupEdit = 1.obs;
  Rx<LatLng> target = const LatLng(0.0, 0.0).obs;

  String get laterBookingDateTime =>
      commonPlaceController.laterBookingDateTime.value;

  bool get isLaterBooking => laterBookingDateTime.isNotEmpty;

  RxBool isOutsideUAE = false.obs;
  RxBool isInsideRadiusValue = true.obs;
  Rx<bool> mapLocationLoader = false.obs;

  RxSet<Marker> markers = RxSet<Marker>();
  Rx<bool> isCameraIdle = true.obs;
  var isCameraDragging = false.obs;
  Rx<bool> showPolygon = false.obs;
  RxList<LatLng> polygon = RxList<LatLng>();
  RxSet<Marker> loadingMarkers = RxSet<Marker>();
  Rx<double> animatedFooterHeight = 0.0.obs;
  Rx<double> animatedHeaderHeight = 0.0.obs;
  var isPickUpEdit = false.obs;

  void changeMapType() {
    mapType.value =
        mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void changeTrafficView() {
    trafficEnabled.value = !trafficEnabled.value;
  }

  @override
  void onInit() {
    if (!Get.isRegistered<DraggableScrollableController>()) {
      draggableScrollableControllerPick = DraggableScrollableController();
    } else {
      draggableScrollableControllerPick =
          Get.find<DraggableScrollableController>();
    }
    draggableScrollableControllerPick.addListener(() {
      if (draggableScrollableControllerPick.isAttached) {
        final position = draggableScrollableControllerPick.size;
        isSheetFullyExpandedPick.value = (position == 1.0);
      } else {
        debugPrint("DraggableScrollableControllerPick is NOT attached yet!");
      }
    });
    isSheetFullyExpandedPick.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDefaultAddressAndLatLng();
      _enableHeaderAndFooterWidget();
    });
    ever(isSheetFullyExpandedPick, (callback) async {
      if (isSheetFullyExpandedPick.value) {
        await Future.delayed(const Duration(seconds: 1));
        placeSearchController.pickFocusNode.value.requestFocus();
      } else {
        placeSearchController.pickController.text = '';
        placeSearchController.pickFocusNode.value.unfocus();
      }
    });
    getAddressFromLatLng(commonPlaceController.pickUpLatLng.value);
    super.onInit();
  }

  @override
  void dispose() {
    draggableScrollableControllerPick.dispose();
    super.dispose();
  }

  getDefaultAddressAndLatLng() {
    getAddress.value = commonPlaceController.pickUpLocation.value;
    target.value = commonPlaceController.pickUpLatLng.value;
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

  void moveToCurrentLocation() {
    _checkAndGetCurrentPosition().then((value) {
      isAddressFetching.value = false;
      final newLatLng = LatLng(value.latitude, value.longitude);
      // pickUpLatLng.value = newLatLng;
      commonPlaceController.pickUpLatLng.value = newLatLng;
      _moveToCurrentPosition(newLatLng);
    }).catchError((onError) {
      isAddressFetching.value = false;
      Get.snackbar('Error!', onError.toString());
    });
  }

  Future<Position> _checkAndGetCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    isAddressFetching.value = true;
    return await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium));
  }

  void onPickUpOnPress() {
    final placeSearchPageController = Get.find<PlaceSearchPageController>();
    destinationController.isDropEdit.value = false;
    printLogs('Hii ravi taxi Current Route: ${Get.currentRoute}');
    printLogs('Hii ravi taxi Previous Route: ${Get.previousRoute}');
    if (Get.previousRoute == AppRoutes.pickUpScreen) {
      Get.offNamed(AppRoutes.destinationPage);
    } else {
      Get.back();
    }
    commonPlaceController.dropLocation.value =
        commonPlaceController.currentAddress.value;
    commonPlaceController.dropLatLng.value =
        commonPlaceController.currentLatLng.value;
    placeSearchPageController.destinationController.text = '';
    placeSearchPageController.pickController.text = '';
    commonPlaceController.laterBookingDateTime.value = "";
    placeSearchPageController.destinationFocusNode.value.unfocus();

    destinationController.isSheetFullyExpanded.value = false;
    destinationController.isMapDragged.value = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (destinationController.draggableScrollableController.isAttached) {
        destinationController.draggableScrollableController.animateTo(
          0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        Future.delayed(const Duration(milliseconds: 100), () {
          double currentSize =
              destinationController.draggableScrollableController.size;

          if (currentSize == 1.0) {
            destinationController.isMapDragged.value = false;
            if (destinationController
                .draggableScrollableController.isAttached) {
              destinationController.draggableScrollableController.animateTo(
                0.5,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      } else {}
    });
  }

  initialCameraPosition({GetPoistion? getPoistion}) {
    return CameraPosition(
      target: commonPlaceController.pickUpLatLng.value,
      zoom: 15,
    );
  }

  void setTarget({required LatLng getTarget}) {
    target.value = getTarget;
    target.refresh();
    getAddressFromLatLng(target.value);
    printLogs("");
  }

  getAddressFromLatLng(LatLng newLatLng) async {
    try {
      // Fetch place information using coordinates
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          newLatLng.latitude, newLatLng.longitude);
      if (placeMarks.isEmpty) return;

      final placeMark = placeMarks.first;
      printLogs("Location details: $placeMark ** ${placeMark.locality}");

      final title = placeMark.name ?? "Unknown Location";
      final subtitle =
          "${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.country}";

      commonPlaceController.pickUpLocation.value = title;
      commonPlaceController.pickUpSubtitle.value = subtitle;
      commonPlaceController.pickUpLocation.refresh();
      commonPlaceController.pickUpSubtitle.refresh();
      // }

      // Show address or coordinates based on validity
      if (!showPolygon.value) {
        getAddress.value = isOutsideUAE.value
            ? "Lat: ${newLatLng.latitude}, Lng: ${newLatLng.longitude}"
            : "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
      }

      mapLocationLoader.value = false;
    } catch (e) {
      mapLocationLoader.value = false;
      printLogs('Error --> $e');
    }
  }

  _enableHeaderAndFooterWidget() {
    animatedHeaderHeight.value = 80.h;
    animatedFooterHeight.value = 80.h;
  }

  void onCameraIdle() {
    _enableHeaderAndFooterWidget();
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
}
