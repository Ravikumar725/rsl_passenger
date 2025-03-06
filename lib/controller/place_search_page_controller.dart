import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:rsl_passenger/dashboard/controller/dashboard_page_controller.dart';
import 'package:rsl_passenger/routes/routes.dart';

import '../widget/utils/app_info.dart';
import '../network/services.dart';
import '../widget/utils/enums.dart';
import 'common_place_controller.dart';

class PlaceSearchPageController extends GetxController {
  Rx<bool> pageLoader = false.obs;
  Rx<int> nextPage = 1.obs;
  final commomPlaceController = Get.put(CommonPlaceController());
  final dashboardController = Get.put(DashBoardController());
  var searchType = 0;

  @override
  void onInit() {
    pickFocusNode.value.addListener(_onPickFocusChange);
    destinationFocusNode.value.addListener(_onDestinationFocusChange);
    initPlaces();
    super.onInit();
  }

  Future<void> initPlaces() async {
    _places = GoogleMapsPlaces(
      apiKey: AppInfo.kGooglePlacesKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
  }

  @override
  void onClose() {
    // pickController.text = '';
    // destinationController.text = '';
    super.onClose();
  }

  final commonPlaceController = Get.find<CommonPlaceController>();

  // final dashboardController = Get.find<DashBoardController>();

  TextEditingController pickController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  Rx<FocusNode> pickFocusNode = FocusNode().obs;
  Rx<FocusNode> destinationFocusNode = FocusNode().obs;
  var visibleCurrentLocation = false.obs;
  var pickUpSuffixEnabled = true.obs;
  var dropSuffixEnabled = false.obs;
  late GoogleMapsPlaces _places;
  RxList<Prediction> predictionList = <Prediction>[].obs;
  Rx<PlacesAutocompleteResponse> predictResponse =
      PlacesAutocompleteResponse(status: "SEARCHING", predictions: []).obs;
  RxBool searching = false.obs;
  var pickUpLatLng = const LatLng(0, 0).obs;
  var pickUpAddress = ''.obs;
  var dropLatLng = const LatLng(0, 0).obs;
  var distancesList = [].obs;

  clearPickText() {
    pickController.text = '';
    pickUpLatLng.value = const LatLng(0.0, 0.0);
    predictResponse.value = _clearResponse();
    // taxiController.pickUpLocation.value = '';
    // taxiController.pickUpLatLng.value == LatLng(0.0, 0.0);
    update();
  }

  unFocus() {
    pickFocusNode.value.unfocus();
    destinationFocusNode.value.unfocus();
  }

  PlacesAutocompleteResponse _clearResponse() =>
      PlacesAutocompleteResponse(status: "", predictions: []);

  void clearDestinationText() {
    destinationController.clear();
    dropLatLng.value = const LatLng(0.0, 0.0);
    // taxiController.dropLocation.value = '';
    // taxiController.dropLatLng.value == LatLng(0.0, 0.0);
    predictResponse.value = _clearResponse();
    update();
  }

  void _onDestinationFocusChange() {
    if (destinationFocusNode.value.hasFocus) {
      visibleCurrentLocation.value = true;

      // predictResponse.value = _clearResponse();
    } else {
      visibleCurrentLocation.value = false;
    }
    if (destinationController.value.text == "") {
      predictResponse.value = _clearResponse();
    }
  }

  void _onPickFocusChange() {
    if (pickFocusNode.value.hasFocus) {
      visibleCurrentLocation.value = true;
      //predictResponse.value = _clearResponse();
    } else {
      visibleCurrentLocation.value = false;
    }
    if (pickController.value.text == "") {
      predictResponse.value = _clearResponse();
    }
  }

//IMPORTANT

  void locationSelected(
      {required Prediction predictionList, required int type}) async {
    final address = predictionList.description ?? "";
    PlacesDetailsResponse detail =
        await _places.getDetailsByPlaceId(predictionList.placeId ?? '');
    final latLng = LatLng(detail.result.geometry?.location.lat ?? 0.0,
        detail.result.geometry?.location.lng ?? 0.0);
    if (pickFocusNode.value.hasFocus) {
      searchType = 1;
      pickController.text = address;
      pickUpLatLng.value = latLng;
      commomPlaceController.pickUpLocation.value = address;
      commomPlaceController.pickUpLatLng.value = latLng;
      predictResponse.value = _clearResponse();
      pickFocusNode.value.unfocus();
      printLogs(
          "Hii Ravi Taxi pick location select is $address **$latLng **${pickUpLatLng.value}");
    } else if (destinationFocusNode.value.hasFocus) {
      searchType = 2;
      destinationController.text = address;
      dropLatLng.value = latLng;
      predictResponse.value = _clearResponse();
      destinationFocusNode.value.unfocus();
      printLogs(
          "Hii Ravi Taxi drop location select is $address **$latLng **${commonPlaceController.getPosition?.value}");
    }
    _moveToTaxiPage(type);
  }

  var isForceDropEdit = false.obs;
  void _moveToTaxiPage(int type) {
    if (type == 0) {
      commomPlaceController.pageType.value = 1;
      moveToGoogleLocationPickerDropOff();
    } else {
      predictResponse.value.predictions.clear();
      if (nextPage.value == 2) {
        printLogs("Hii Ravi kumar Taxi type5 ${nextPage.value}");
      } else {
        printLogs("Hii Ravi kumar Taxi type6 ${nextPage.value}");
        if (searchType == 1) {
          printLogs("Hii Ravi kumar Taxi search type is $searchType");
          commonPlaceController.pickUpLatLng.value = pickUpLatLng.value;
          Get.toNamed(AppRoutes.taxiHomePage);
        } else {
          commonPlaceController.pickUpLatLng.value =
              dashboardController.pickUpLatLng.value;
          if (isForceDropEdit.value) {
            printLogs("Hii Ravi kumar Taxi search type 2 home Page");
            Get.toNamed(AppRoutes.taxiHomePage);
          } else {
            printLogs("Hii Ravi kumar Taxi search type 2 pickup page");
            Get.toNamed(AppRoutes.pickUpScreen);
          }
          // Get.toNamed(AppRoutes.pickUpScreen);
        }
      }
    }
  }

  void swapLocation(
    TextEditingValue pickValue,
    TextEditingValue destinationValue,
    LatLng pickLatLng,
    LatLng dropingLatLng,
  ) {
    pickController.value = destinationValue;
    destinationController.value = pickValue;
    pickUpLatLng.value = dropingLatLng;
    dropLatLng.value = pickLatLng;
    if (pickController.text.isEmpty) {
      pickFocusNode.value.requestFocus();
    } else if (destinationController.text.isEmpty) {
      destinationFocusNode.value.requestFocus();
    }
  }

  void searchLocation({required String value}) async {
    if (value.trim().isEmpty) {
      printLogs("EMPTY STRING PASSED");
      predictResponse.value = _clearResponse();

      if (pickFocusNode.value.hasFocus) {
        pickController.text = '';
        pickUpLatLng.value = const LatLng(0.0, 0.0);
      } else if (destinationFocusNode.value.hasFocus) {
        destinationController.text = '';
        dropLatLng.value = const LatLng(0.0, 0.0);
      }
      return;
    }

    searching.value = true;
    List<String> countryCodes = AppInfo.kAppCoreUrl.toLowerCase() ==
        BaseUrls.demo.rawValue.toLowerCase()
        ? ["IN", "AE"] // Allow both India and UAE
        : ["AE"]; // Default to UAE

    List<Prediction> mergedPredictions = [];

    for (String country in countryCodes) {
      final res = await _places.autocomplete(value,
          components: [Component(Component.country, country)]);

      printLogs("PREDICTION STATUS for $country: ${res.status}");

      if (res.status == 'OK' && res.predictions.isNotEmpty) {
        mergedPredictions.addAll(res.predictions); // Merge results
      }
    }

    // Stop searching indicator
    searching.value = false;

    // Filter merged results
    List<Prediction> filteredPredictions;
    if (pickFocusNode.value.hasFocus) {
      // Pickup: Only allow Dubai and Abu Dhabi
      filteredPredictions = mergedPredictions.where((prediction) {
        final desc = prediction.description?.toLowerCase() ?? "";

        return AppInfo.kAppCoreUrl.toLowerCase() ==
            BaseUrls.demo.rawValue.toLowerCase()
            ? desc.contains("dubai") ||
            desc.contains("abu dhabi") ||
            desc.contains("tamil nadu")
            : desc.contains("dubai") || desc.contains("abu dhabi");
      }).toList();
    } else if (destinationFocusNode.value.hasFocus) {
      // Drop-off: Allow any location in UAE and India (no filtering needed)
      filteredPredictions = mergedPredictions;
    } else {
      filteredPredictions = [];
    }

// Update response
    if (filteredPredictions.isNotEmpty) {
      predictResponse.value = PlacesAutocompleteResponse(
        status: "OK",
        predictions: filteredPredictions,
      );
      predictResponse.refresh();
      calculateDistancesForPredictions(filteredPredictions);
    } else {
      printLogs("No valid predictions found");
      predictResponse.value = _clearResponse();
    }
    /*final res = await _places
        .autocomplete(value, components: [Component(Component.country, "AE")]);
    searching.value = false;

    printLogs("PREDICTION STATUS: ${res.status}");

    if (res.status == 'OK' && res.predictions.isNotEmpty) {
      List<Prediction> filteredPredictions;

      if (pickFocusNode.value.hasFocus) {
        // Pickup: Only allow Dubai and Abu Dhabi
        filteredPredictions = res.predictions.where((prediction) {
          final desc = prediction.description?.toLowerCase() ?? "";
          return desc.contains("dubai") || desc.contains("abu dhabi");
        }).toList();
      } else if (destinationFocusNode.value.hasFocus) {
        // Drop-off: Allow any location in UAE (no filtering needed)
        filteredPredictions = res.predictions;
      } else {
        filteredPredictions = [];
      }

      if (filteredPredictions.isNotEmpty) {
        predictResponse.value = PlacesAutocompleteResponse(
          status: res.status,
          predictions: filteredPredictions,
        );
        predictResponse.refresh();
        calculateDistancesForPredictions(filteredPredictions);
      } else {
        printLogs("No valid predictions found");
        predictResponse.value = _clearResponse();
      }
    } else {
      printLogs("No predictions found");
      predictResponse.value = _clearResponse();
    }*/
  }

  void skip() {
    if (pickController.text == "" || pickUpLatLng.value == const LatLng(0, 0)) {
    } else {
      Get.toNamed(AppRoutes.pickUpScreen);
    }
  }

  void checkAndGetCurrentLocation() {
    pageLoader.value = true;
    _checkAndGetCurrentPosition().then((value) {
      final newLatLng = LatLng(value.latitude, value.longitude);
      // taxiController.pickUpLatLng.value = newLatLng;
      _getAddressFromLatLng(newLatLng);
    }).catchError((onError) {
      pageLoader.value = false;
      unFocus();
      Get.snackbar("Message", "Something went wrong");
      // Get.snackbar('Error!', '${onError.toString()}',
      //     backgroundColor: AppColor.kGetSnackBarColor.value);
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
    return await Geolocator.getCurrentPosition();
  }

  void _getAddressFromLatLng(LatLng newLatLng) async {
    try {
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          newLatLng.latitude, newLatLng.longitude);
      pageLoader.value = false;
      unFocus();
      if (placeMarks.isEmpty) return;

      final placeMark = placeMarks.first;

      final address =
          "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";

      if (pickFocusNode.value.hasFocus) {
        pickController.text = address;
        pickUpLatLng.value = newLatLng;
        // taxiController
        //   ..pickUpLocation.value = address
        //   ..pickUpLatLng.value =
        //       LatLng(newLatLng.latitude, newLatLng.longitude);
      } else if (destinationFocusNode.value.hasFocus) {
        destinationController.text = address;
        dropLatLng.value = newLatLng;
        // taxiController
        //   ..dropLocation.value = address
        //   ..dropLatLng.value = LatLng(newLatLng.latitude, newLatLng.longitude);
      }
    } catch (e) {
      pageLoader.value = false;
      unFocus();
      Get.snackbar("Error", "Something went wrong");
      printLogs('printRSL error --> $e');
    }
  }

  void moveToGoogleLocationPickerDropOff() async {
    commomPlaceController.getPosition?.value = GetPoistion.drop;
    commomPlaceController.dropLocation.value = destinationController.text;
    commomPlaceController.dropLatLng.value = dropLatLng.value;

    // final status = await Get.toNamed(AppRoutes.googleMapLocation);
    final status = await Get.toNamed(AppRoutes.destinationPage);
    printLogs("hi status $status");

    switch (status) {
      case "2":
        destinationController.text = commomPlaceController.dropLocation.value;
        dropLatLng.value = commomPlaceController.dropLatLng.value;
        break;
    }
    checkPickUpLocationInPolygon();
    // _moveToTaxiPage(1);
  }

  void moveToGoogleLocationPickerPickUp() async {
    commomPlaceController.getPosition?.value = GetPoistion.pin;
    commomPlaceController.pickUpLocation.value = pickController.text;
    commomPlaceController.pickUpLatLng.value = pickUpLatLng.value;

    print(
        "hi pickup ${commomPlaceController.pickUpLocation.value} ${commomPlaceController.pickUpLatLng.value}");

    // Get.put(GoogleMapLocationController());
    final status = await Get.toNamed(AppRoutes.destinationPage);
    // final status = await Get.toNamed(AppRoutes.googleMapLocation);
    switch (status) {
      case "1":
        pickController.text = commomPlaceController.pickUpLocation.value;
        pickUpLatLng.value = commomPlaceController.pickUpLatLng.value;
        break;
    }

    _moveToTaxiPage(1);
  }

  void checkPickUpLocationInPolygon() {
    printLogs("Hii ravi new taxi list page check PickUp Location In Polygon");
    moveToGoogleLocationPickerPickUp();
  }

  Future<void> calculateDistancesForPredictions(
      List<Prediction> predictions) async {
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.low),
      );

      // Clear existing distances
      distancesList.clear();

      // Process each prediction
      for (var prediction in predictions) {
        String placeId = prediction.placeId ?? '';

        // Skip if placeId is empty
        if (placeId.isEmpty) {
          distancesList.add('No Place ID Found');
          continue;
        }

        // Fetch coordinates for this placeId
        LatLng? locationCoordinates = await _getPlaceCoordinates(placeId);

        if (locationCoordinates == null) {
          distancesList.add('Unable to Retrieve Location');
          continue;
        }

        // Calculate distance in meters
        double distanceInMeters = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          locationCoordinates.latitude,
          locationCoordinates.longitude,
        );

        // Convert to KM and add to the list
        double distanceInKilometers = distanceInMeters / 1000;
        distancesList.add("${distanceInKilometers.toStringAsFixed(2)} KM");
      }

      // Trigger UI update
      distancesList.refresh();
    } catch (e) {
      print("Error calculating distances: $e");
    }
  }

  Future<LatLng?> _getPlaceCoordinates(String placeId) async {
    final details =
        await _places.getDetailsByPlaceId(placeId); // Google Places API call
    if (details.result.geometry != null) {
      return LatLng(
        details.result.geometry!.location.lat,
        details.result.geometry!.location.lng,
      );
    }
    return null;
  }
}
