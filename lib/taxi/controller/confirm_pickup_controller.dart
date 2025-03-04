import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsl_passenger/routes/routes.dart';
import 'package:rsl_passenger/taxi/controller/saved_location_controller.dart';
import '../../widget/utils/app_info.dart';
import '../../controller/common_place_controller.dart';
import '../../controller/place_search_page_controller.dart';
import '../../dashboard/controller/dashboard_page_controller.dart';
import '../../dashboard/data/get_core_api_data.dart';
import '../../network/services.dart';
import '../widget/custom_map_marker.dart';
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
    printLogs(
        "Hii confirm page pick up latLng is ${commonPlaceController.pickUpLatLng.value}");
    // getAddressFromLatLng(commonPlaceController.pickUpLatLng.value);
    isSheetFullyExpandedPick.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDefaultAddressAndLatLng();
      _enableHeaderAndFooterWidget();
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

  void onPickUpOnPress() {
    final placeSearchPageController = Get.find<PlaceSearchPageController>(); // ✅ Use existing instance

    destinationController.isDropEdit.value = false;
    // Get.back();
    printLogs('Hii ravi taxi Current Route: ${Get.currentRoute}');
    printLogs('Hii ravi taxi Previous Route: ${Get.previousRoute}');
    if (Get.previousRoute == AppRoutes.pickUpScreen) {
      Get.offNamed(AppRoutes.destinationPage);
    } else {
      Get.back();
    }
    // commonPlaceController.dropLocation.value = '';
    // commonPlaceController.dropLatLng.value = const LatLng(0.0, 0.0);
    commonPlaceController.pickUpLocation.value = commonPlaceController.currentAddress.value;
    commonPlaceController.pickUpLatLng.value = commonPlaceController.currentLatLng.value;
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

        // Delay for height correction if necessary
        Future.delayed(const Duration(milliseconds: 100), () {
          double currentSize = destinationController.draggableScrollableController.size;

          if (currentSize == 1.0 || currentSize == 0.9) {
            destinationController.isMapDragged.value = false;
            if (destinationController.draggableScrollableController.isAttached) {
              destinationController.draggableScrollableController.animateTo(
                0.5,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          }
        });
      } else {
        print("DraggableScrollableController is NOT attached!");
      }
    });
  }

  initialCameraPosition({GetPoistion? getPoistion}) {
    // getAddressFromLatLng(commonPlaceController.pickUpLatLng.value);
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
      List<String> allowed = dashboardController
              .getApiData.value.rslGetCore?.first.availablePickupLocations ??
          [];
      // Fetch place information using coordinates
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          newLatLng.latitude, newLatLng.longitude);
      if (placeMarks.isEmpty) return;

      final placeMark = placeMarks.first;
      printLogs("Location details: $placeMark ** ${placeMark.locality}");

      // Allowed locations
      List<String> allowedCities = dashboardController
              .getApiData.value.rslGetCore?.first.availablePickupLocations ??
          [];
      List<String> allowedAdministrativeAreas = dashboardController
              .getApiData.value.rslGetCore?.first.availablePickupLocations ??
          [];
      List<String> allowedSubAdministrativeAreas = dashboardController
              .getApiData.value.rslGetCore?.first.availablePickupLocations ??
          [];

      // Normalize values for case-insensitive matching
      String locality = placeMark.locality?.trim().toLowerCase() ?? "";
      String administrativeArea =
          placeMark.administrativeArea?.trim().toLowerCase() ?? "";
      String subAdministrativeArea =
          placeMark.subAdministrativeArea?.trim().toLowerCase() ?? "";

      bool isAllowedLocation = allowedCities
              .any((city) => city.toLowerCase() == locality) ||
          allowedAdministrativeAreas
              .any((area) => administrativeArea.contains(area.toLowerCase())) ||
          allowedSubAdministrativeAreas.any(
              (area) => subAdministrativeArea.contains(area.toLowerCase()));

      /*if (!isAllowedLocation) {
        // Location is outside allowed cities for pickup
        final latLngAddress =
            "[${newLatLng.latitude.toStringAsFixed(4)}, ${newLatLng.longitude.toStringAsFixed(4)}]";
        // isOutsideUAE.value = true;
        isOutsideUAE.refresh();
        printLogs(
            "Outside pickup location: ${commonPlaceController.getPosition?.value} ** ${isOutsideUAE.value}");

        // Update pickup location address
        commonPlaceController.pickUpLocation.value = latLngAddress;
        commonPlaceController.pickUpSubtitle.value = "";
      } else {*/
        // Location is inside allowed cities for pickup
        // isOutsideUAE.value = false;
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
    // checkInsidePolygonOrNot();
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

  void _addMarkers(List<TerminalList> terminalList, latLng) async {
    for (int i = 0; i < terminalList.length; i++) {
      /* printLogs(
          "hi marker ${latLng.latitude.toStringAsFixed(3)} , ${terminalList[i].latitude!.toStringAsFixed(3)}, ${latLng.longitude.toStringAsFixed(3)},${terminalList[i].longitude!.toStringAsFixed(3)} ");
      */
      if (latLng.latitude.toStringAsFixed(3) ==
              terminalList[i].latitude!.toStringAsFixed(3) &&
          latLng.longitude.toStringAsFixed(3) ==
              terminalList[i].longitude!.toStringAsFixed(3)) {
        markers.add(
          Marker(
            markerId: MarkerId('marker_$i'),
            position:
                LatLng(terminalList[i].latitude!, terminalList[i].longitude!),
            icon: await getWidgetMarker(
              widget: polygonMarker(text: terminalList[i].address, type: 0),
            ),
            // BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: "${terminalList[i].address}"),
          ),
        );
      } else {
        markers.add(
          Marker(
            markerId: MarkerId('marker_$i'),
            position:
                LatLng(terminalList[i].latitude!, terminalList[i].longitude!),
            icon: await getWidgetMarker(
              widget: polygonMarker(text: terminalList[i].address, type: 1),
            ),
            // BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow(title: "${terminalList[i].address}"),
          ),
        );
      }
    }
  }

  void moveCamera(terminalList) {
    if (mapController == null) return;
    mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(target.value, 15.0),
    );
  }
}
