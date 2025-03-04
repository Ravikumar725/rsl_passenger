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
import '../../widget/utils/app_info.dart';
import '../../controller/common_place_controller.dart';
import '../../controller/place_search_page_controller.dart';
import '../data/data.dart';
import '../data/get_core_api_data.dart';
import '../../network/app_services.dart';
import '../../network/services.dart';
import '../../taxi/data/nearest_drivers_list_api_data.dart';
import '../../widget/custom_button.dart';
import '../getx_storage.dart';

class DashBoardController extends GetxController with WidgetsBindingObserver {
  Rx<ResponseData> getApiData = ResponseData().obs;
  var customDialRoot = false;
  var closeManually = false;
  var useRAnimation = true;
  var isDialOpen = false.obs;
  var dashBoardOnBack = 1.obs;
  var bottomSheetIsExpanded =
      false.obs; // Observable boolean to track expansion state
  RxBool showActivePromo = false.obs;
  RxBool showPromoCodeView = false.obs;
  RxString appliedPromoCode = "".obs;
  RxString promoLabel = "".obs;
  RxString activePromoCode = "".obs;
  var pickUpLatLng = const LatLng(0, 0).obs;
  var pickUpAddress = "".obs;

  @override
  void onInit() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    checkAndGetCurrentLocation();
    // getUserInfo();
    callGetCoreApi();
    WidgetsBinding.instance.addObserver(this);
    _scheduleNearestDriversListApiTimer();
    super.onInit();
  }

  // final placeSearchController = Get.put(PlaceSearchPageController());
  Rx<UserInfo?> userInfo = UserInfo().obs;
  RxString deviceToken = "".obs;
  late GoogleMapController mapController;
  RxBool viewEnable = false.obs;
  var isAddressFetching = false.obs;
  final commonPlaceController = Get.put(CommonPlaceController());
  Timer? _nearestDriversListTimer;
  RxList<Marker> markers = <Marker>[].obs;
  BitmapDescriptor? carIcon;
  BitmapDescriptor? currentLocationIcon;

  final _userId = '33164';
  final DEFAULT_MODEL_ID = '1';
  RxBool isExpanded = false.obs;
  var selectedIndex = 0.obs;
  Rx<Packages> selectedPackage = Packages().obs;
  String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  var submitButtonLoader = false.obs;
  var rating = 0.0.obs;
  var ratingStatus = 0.obs;
  var isFirstRide = 0.obs;
  var firstRideShow = 0.obs;
  Timer? _futureBookingNewTimer;
  var isBookingVisible = false.obs;

  void setSelectedIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void dispose() {
    _cancelNearestDriversListTimer();
    WidgetsBinding.instance.removeObserver(this);
    _cancelTripUpdateApiTimer();
    // cancelFutureBookingNewTimer();
    super.dispose();
  }

  scheduleFutureBookingNewApiTimer() {
    cancelFutureBookingNewTimer();
    if (userInfo.value?.rslId != null && userInfo.value?.rslId != "") {
      _futureBookingNewTimer =
          Timer.periodic(const Duration(seconds: 5), (timer) {
        // callFutureBookingNewApi();
      });
    }
  }

  void cancelFutureBookingNewTimer() {
    try {
      _futureBookingNewTimer?.cancel();
      _futureBookingNewTimer =
          null; // Ensure the timer is null after cancellation
    } catch (e) {
      e.printError();
    }
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

  void checkAndGetCurrentLocation() {
    _checkAndGetCurrentPosition().then((value) {
      isAddressFetching.value = false;
      final newLatLng = LatLng(value.latitude, value.longitude);
      pickUpLatLng.value = newLatLng;
      commonPlaceController.currentLatLng.value = newLatLng;
      // _moveToCurrentPosition(newLatLng);
      _getAddressFromLatLng(newLatLng, 0);
    }).onError((onError, stackTrace) {
      isAddressFetching.value = false;
      printLogs("checkAndGetCurrentLocation Error ${stackTrace.toString()}");
    });
  }

  void getAddress(LatLng newLatLng) {
    _getAddressFromLatLng(newLatLng, 1);
  }

  Future<void> checkCurrentLocationAndMoveToNextPage(
      {int type = 1, bool? searchEnable}) async {
    // _callNearestDriversListTimerApi();
    await getUserInfo();

    if (isAddressFetching.value || pickUpLatLng.value.latitude == 0) {
      Get.snackbar(
        "Warning",
        "Please wait. We\ 're trying to fetching your location",
      );
      return;
    } else {
      // placeSearchController.dropLatLng.value =
      //     commonPlaceController.currentLatLng.value;
      /* placeSearchController.pickController.text =
    commonPlaceController.currentAddress.value;
    placeSearchController.pickUpLatLng.value =
    commonPlaceController.currentLatLng.value;
      placeSearchController.nextPage.value = 1;*/
      // commonPlaceController.setBookLaterDateTime();
      // Get.toNamed(AppRoutes.placeSearchPage)?.then((value) {
      //   placeSearchController.onClose();
      // });
      Get.toNamed(AppRoutes.destinationPage);
    }

    /*GetStorageController().getUserId().then((value) {
      printLogs("USER ID : ${value}");
      if (value != '') {
      } else {
        Get.toNamed(AppRoutes.loginScreen);
      }
    });*/
  }

  Future<void> _moveToCurrentPosition(LatLng latLng) async {
    try {
      final GoogleMapController controller = mapController;
      await controller.animateCamera(
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
      // placeSearchController.pickController.text = address;
      // placeSearchController.pickUpLatLng.value = newLatLng;
    } catch (e) {
      printLogs('error --> $e');
    }
  }

  Future getUserInfo() async {
    userInfo.value = UserInfo();
    userInfo.refresh();
    try {
      userInfo.value = await GetStorageController().getUserInfo();
      userInfo.refresh();
      printLogs(
          "User id is ${userInfo.value?.userId} ** ${userInfo.value?.rslId}");
      if (userInfo.value?.userId != null && userInfo.value?.userId != "") {
      } else {
        printLogs("User id is empty");
      }
    } catch (error) {
      cancelFutureBookingNewTimer();
      printLogs("onError Dashboard UserInfo $error");
    }
  }

  void callGetCoreApi() {
    getCoreApi().then((value) {
      if (value.status == 1) {
        getApiData.value = value.responseData ?? ResponseData();
        getApiData.refresh();
        printLogs("get core api message ${value.message}");
      } else {
        printLogs("${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs("Get Cote api error $error");
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
          // _driverDetails = null;
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
          passengerId: _userId,
          placeId: '',
          motorModel: DEFAULT_MODEL_ID,
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

  void toggleExpansion() {
    isExpanded.value = !isExpanded.value;
  }

  StreamSubscription? _someSubscription;

  var terms = ''.obs;

  var secondsRemaining = 300.obs; // Make secondsRemaining observable
  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  void toggleBottomSheet() {
    bottomSheetIsExpanded.value = !bottomSheetIsExpanded.value;
  }

  showPromoLayout() {
    showPromoCodeView.value = true;
    showActivePromo.value = true;
    showActivePromo.refresh();
    showPromoCodeView.refresh();
  }

  hidePromoLayout() {
    showPromoCodeView.value = false;
    showPromoCodeView.refresh();
  }

  hidePromoCodeLoader() {
    Get.back();
  }

  TextEditingController promoCodeController = TextEditingController();
  RxBool isPromoApplied = false.obs;

  clearPromoCode() {
    promoCodeController.text = "";
    appliedPromoCode.value = "";
    appliedPromoCode.refresh();
    isPromoApplied.value = false;
    if (promoLabel.value.isNotEmpty) {
      showPromoCodeView.value = true;
      showPromoCodeView.refresh();
    } else {
      showPromoCodeView.value = false;
      showPromoCodeView.refresh();
    }
  }

  Timer? _tripUpdateTimer;
  RxString estimatedDuration = "".obs;
  var count = 0.obs;
  var tripStartCount = 0.obs;

  scheduleTripUpdateApiTimer() {
    _cancelTripUpdateApiTimer();
    _tripUpdateTimer =
        Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (userInfo.value?.rslId != null &&
          commonPlaceController.tripId.value != '') {}
    });
  }

  void _cancelTripUpdateApiTimer() {
    try {
      _tripUpdateTimer?.cancel();
    } catch (e) {
      e.printError();
    }
  }

  RxString remainingDuration = ''.obs; // Holds live countdown
  Timer? countdownTimer;
  int totalSeconds = 0;
  LatLng? lastKnownLocation; // Store the last known driver position

  void calculateTime({required LatLng pickUp, required LatLng drop}) {
    countdownTimer?.cancel();
    googleMapApi(
      '${AppInfo.kAppBaseUrl}taxi/getDirections?origin=${pickUp.latitude},${pickUp.longitude}&destination=${drop.latitude},${drop.longitude}&mode=driving',
    ).then((response) {
      printLogs("POLYLINE ${response.toString()}");
      try {
        // Parse the response to get duration (estimated time)
        if (response['routes'] != null && response['routes'].isNotEmpty) {
          var legs = response['routes'][0]['legs'];
          if (legs != null && legs.isNotEmpty) {
            String duration =
                legs[0]['duration']['text']; // Estimated time as text
            estimatedDuration.value = duration;
            remainingDuration.value = duration;

            int durationMinutes =
                _extractMinutesFromText(remainingDuration.value);

            // Call the new countdown timer method with halfway logic
            startCountdownWithHalfway(durationMinutes, pickUp, drop);
            // trackUserMovement(durationMinutes,pickUp,drop);
            printLogs("Hii ravi kumar Estimated Time: $duration");
          } else {
            printLogs("Hii ravi kumar No legs data available in the response");
          }
        } else {
          printLogs("Hii ravi kumar No routes data available in the response");
        }
      } catch (e) {
        printLogs("Hii ravi kumar Error parsing response: $e");
      }
    }).catchError((error) {
      printLogs("Hii ravi kumar Error in API call: $error");
    });
  }

  void trackUserMovement(int durationMinutes, LatLng pickUp, LatLng drop) {
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 500),
    ).listen((Position position) {
      printLogs("User moved 500m, re-fetching time...");
      startCountdownTimer(
          durationMinutes, pickUp, drop); // Call API only when needed
    });
  }

  void startCountdownTimer(int durationMinutes, LatLng pickUp, LatLng drop) {
    int totalSeconds = durationMinutes * 60; // Convert minutes to seconds
    int halfwayPoint = totalSeconds ~/ 2; // Find halfway point

    // Cancel existing countdown timer
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds > 0) {
        totalSeconds--; // Reduce seconds

        final minutes = totalSeconds ~/ 60;
        final seconds = totalSeconds % 60;

        // Update remaining duration
        remainingDuration.value = '$minutes mins';

        printLogs("Remaining Duration: ${remainingDuration.value}");

        // Call API again at halfway point for an updated estimate
        if (totalSeconds == halfwayPoint) {
          printLogs("Halfway reached, recalculating estimated time...");
          calculateTime(
              pickUp: pickUp, drop: drop); // Recalculate with actual values
        }
      } else {
        // Timer completed, stop and fetch the latest estimate
        printLogs("Countdown completed, fetching final estimate...");
        calculateTime(pickUp: pickUp, drop: drop);
        timer.cancel();
      }
    });
  }

  void startCountdownWithHalfway(
      int durationMinutes, LatLng pickUp, LatLng drop) {
    int totalSeconds = durationMinutes * 60; // Convert minutes to seconds
    int halfwayPoint = totalSeconds ~/ 3; // Calculate halfway point in seconds

    // Cancel any existing timer if running
    countdownTimer?.cancel();

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds > 0) {
        totalSeconds--;

        // Convert remaining seconds to minutes
        final minutes = totalSeconds ~/ 60;

        // Update the live countdown duration
        remainingDuration.value = '$minutes mins';
        printLogs(
            "Hii ravi kumar remainingDuration is ${remainingDuration.value}");
        // Check for halfway point and call `calculateTime`
        if (totalSeconds == halfwayPoint) {
          printLogs(
              "Hii ravi kumar Halfway point reached, calling calculateTime again...");
          calculateTime(pickUp: pickUp, drop: drop);
        }
      } else {
        // Timer is complete, call `calculateTime` for the final time
        printLogs(
            "Hii ravi kumar Countdown completed, calling calculateTime for final update...");
        calculateTime(pickUp: pickUp, drop: drop);

        timer.cancel();
        printLogs("Hii ravi kumar Countdown timer stopped.");
      }
    });
  }

  int _extractMinutesFromText(String durationText) {
    // Extract numeric minutes from text (e.g., "7 mins" -> 7)
    final durationParts = durationText.split(' ');
    if (durationParts.isNotEmpty) {
      return int.tryParse(durationParts[0]) ?? 0; // Return 0 if parsing fails
    }
    return 0;
  }

  // void startCountdownTimer(int durationMinutes) {
  //   int totalSeconds = durationMinutes * 60; // Convert minutes to seconds
  //
  //   // Cancel any existing timer if running
  //   countdownTimer?.cancel();
  //
  //   // Initialize a new timer
  //   countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     if (totalSeconds > 0) {
  //       totalSeconds--;
  //
  //       // Convert remaining seconds to minutes and seconds
  //       final minutes = totalSeconds ~/ 60;
  //
  //       // Update the live countdown duration
  //       remainingDuration.value = '$minutes mins';
  //     } else {
  //       // Timer is complete
  //       timer.cancel();
  //       printLogs("Countdown completed!");
  //     }
  //   });
  // }
}

BuildContext? context = Get.key.currentContext;
