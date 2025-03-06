import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rsl_passenger/widget/utils/global_utils.dart';
import '../../../../network/app_services.dart';
import '../../../routes/routes.dart';
import '../../widget/utils/alert_helpers.dart';
import '../../widget/utils/app_info.dart';
import '../../assets/assets.dart';
import '../../controller/common_place_controller.dart';
import '../../controller/place_search_page_controller.dart';
import '../../dashboard/controller/dashboard_page_controller.dart';
import '../../dashboard/getx_storage.dart';
import '../../dashboard/data/get_core_api_data.dart';
import '../../network/services.dart';
import '../../taxi/data/nearest_drivers_list_api_data.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/basic_utils.dart';
import '../../widget/utils/enums.dart';
import '../data/get_driver_reply_api_data.dart';
import '../data/get_trip_update_api_data.dart';
import '../data/savebooking_api_data.dart';
import '../widget/approximate_fare_calculation.dart';
import '../widget/custom_map_marker.dart';
import '../../widget/utils/map_marker.dart';
import '../../widget/utils/polyline_utils.dart';
import '../widget/taxi_timer_widget.dart';
import 'confirm_pickup_controller.dart';
import 'destination_controller.dart';

class ApiResponseStatus {
  int? status;
  String? message;

  ApiResponseStatus(
      {this.status = 15, this.message = "Connecting to server...."});
}

class TaxiController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final commonPlaceController = Get.find<CommonPlaceController>();
  final placeSearchPageController = Get.find<PlaceSearchPageController>();
  final dashboardController = Get.find<DashBoardController>();
  final confirmPickupController = Get.find<ConfirmPickupController>();
  final destinationController = Get.find<DestinationController>();
  late AnimationController? animationController;
  var guestFormKey = GlobalKey<FormState>();
  var guestCountryCode = "+971".obs;
  var PAYMENT_ID_CASH = 1.obs;
  var PAYMENT_ID_CARD = 2.obs;
  var paymentType = 1.obs;
  RxString appVersion = "".obs;
  RxString appBuildNumber = "".obs;

  TextEditingController promoCodeController = TextEditingController();

  RxBool isLoading = false.obs;

  RxBool showActivePromo = false.obs;

  // RxBool showPromoCodeView = false.obs;
  RxString appliedPromoCode = "".obs;
  RxString promoLabel = "".obs;
  RxString activePromoCode = "".obs;

  RxBool isPromoApplied = false.obs;

  RxDouble secondSheetSize = 0.13.obs;
  final ValueNotifier<double> draggableSheetHeight = ValueNotifier(0.45);
  late DraggableScrollableController draggableScrollableController;
  late DraggableScrollableController bottomDraggableScrollableController;
  final ValueNotifier<bool> isSheetFullyExpanded = ValueNotifier(false);
  var isControllerAttached = false.obs;

  //Taxi new
  RxString bookingStatus = "Create a booking".obs;
  var progressValue = 0.1.obs;
  Timer? _timer;
  var pickUpTime = 0.obs;
  RxString tripStatus = ''.obs;

  Timer? _taxiTimer;
  String timerMessage = "";

  Rx<ApproximateDistanceCalculated> distanceCalculated =
      Rx<ApproximateDistanceCalculated>(ApproximateDistanceCalculated.kWaiting);

  bool get isDistanceCalcWaiting =>
      distanceCalculated.value == ApproximateDistanceCalculated.kWaiting;

  bool get isDistanceCalcCompleted =>
      distanceCalculated.value == ApproximateDistanceCalculated.kCompleted;

  Rx<BookingState> bookingState =
      Rx<BookingState>(BookingState.kBookingStateOne);
  Rx<ApiResponseStatus> carModelApiStatus = ApiResponseStatus(status: 15).obs;
  Rx<ModelDetails> selectedCarModelList = ModelDetails().obs;

  @override
  void onInit() async {
    draggableScrollableController = DraggableScrollableController();
    bottomDraggableScrollableController = DraggableScrollableController();
    _callNearestDriversListApi();
    _fetchRoute();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    await getUserInfo();
    await getAppInfo();
    _scheduleNearestDriversListApiTimer();
    selectedCarModelList.value =
        dashboardController.getApiData.value.rslGetCore?[0].modelDetails?[1] ??
            ModelDetails();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _getCarImage();
    super.onInit();
  }

  // Cancel the timer if needed
  void cancelTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel(); // Cancel the timer if it's still active
    }
  }

  @override
  void onReady() {
    printLogs("ON READY");
    super.onReady();
  }

  @override
  void dispose() {
    _cancelNearestDriversListTimer();
    _cancelTripUpdateApiTimer();
    animationController!.dispose();
    _taxiTimer?.cancel();
    draggableScrollableController.dispose();
    bottomDraggableScrollableController.dispose();
    pickUpDropMarkers.clear();
    polyline.clear();
    overViewPolyLine.value = '';
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
    pickUpDropMarkers.clear();
    polyline.clear();
    overViewPolyLine.value = '';
    _cancelNearestDriversListTimer();
    cancelTimer();
  }

  final storageController = Get.find<GetStorageController>();

  GoogleMapController? mapController;

  Rx<CarModelData> selectedCarModel = CarModelData().obs;
  RxList<CarModelData> carModelList = <CarModelData>[].obs;

  RxList<Marker> markers = <Marker>[].obs;
  RxList<Marker> pickUpDropMarkers = <Marker>[].obs;
  Rx<DriverDetail?> availableDriverDetail = Rx<DriverDetail?>(null);

  RxList<LatLng> polylinePoints = <LatLng>[].obs;
  RxList<Polyline> polyline = <Polyline>[].obs;
  Timer? _nearestDriversListTimer, _tripUpdateTimer;

  var availableCarCount = 0.obs;
  var selectedModelIndex = 0.obs;
  var showButtonLoader = true.obs;
  var showCancelBookingLoader = false.obs;

// var laterBookingDateTime = ''.obs;
  var overViewPolyLine = ''.obs;
  var approximateTime = 0.0.obs;
  var approximateDistance = 0.0.obs;
  var approximateTrafficTime = 0.0.obs;
  var animationValue = 0.0.obs;
  var approximateFare = "".obs;
  var priceHike = "".obs;
  var tripFare = "".obs;

  String? tripId;
  BitmapDescriptor? carIcon;

  List<DriverDetail>? _driverDetails;

  String get laterBookingDateTime =>
      commonPlaceController.laterBookingDateTime.value;

  bool get isLaterBooking => laterBookingDateTime.isNotEmpty;

  RxBool canShowExcessFareInfo = false.obs;
  RxString alertShortDescription = "".obs;
  RxString alertLongDescription = "".obs;

  DriverDetail? previousNearestDriverData;
  LatLng? previousPickUpLatLng;
  var mapType = MapType.normal.obs;
  var trafficEnabled = false.obs;

  void changeMapType() {
    mapType.value =
        mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void changeTrafficView() {
    trafficEnabled.value = !trafficEnabled.value;
  }

  onCancelClicked() {
    Navigator.pop(Get.context!);
    Get.back();
    _callGetDriverReplyApi();
  }

  void _callGetDriverReplyApi() {
    showCancelBookingLoader.value = true;
    getDriverReplyApi(
      GetDriverReplyRequestData(passengerTripId: tripId),
    ).then((response) {
      showCancelBookingLoader.value = false;
      switch (response.status) {
        case 1:
          _refreshToBookingStateOne();
          showAppDialog(
              message: '${response.message}', confirm: defaultAlertConfirm());
          break;
        case 3:
          _refreshToBookingStateOne();
          Get.snackbar('Booking cancelled', '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
          break;
        default:
          Get.snackbar('Alert', '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
      }
    }).onError((error, stackTrace) {
      showCancelBookingLoader.value = false;
      Get.snackbar('Message', 'Something went wrong.',
          backgroundColor: AppColor.kGetSnackBarColor.value);
    });
  }

  onBackPressed() {
    if (bookingState.value == BookingState.kBookingStateTwo) {
      _refreshToBookingStateOne();
    } else {
      _cancelNearestDriversListTimer();
      Get.back();
    }
  }

  onCarModelSelected(int index, String? fare) {
    printLogs(
        "Hii ravi taxi approximate fare Selected Index: $index, Fare: $fare");
    final selectedIndex = carModelList
        .indexWhere((item) => item.modelId == carModelList[index].modelId);

    if (selectedIndex != -1) {
      // Set isSelected for all items
      for (var item in carModelList) {
        item.isSelected = false;
      }

      // Move the selected item to the first position
      final selectedItem = carModelList.removeAt(selectedIndex);
      selectedItem.isSelected = true;
      carModelList.insert(0, selectedItem);
      carModelList.refresh();
    }
    // var carModel = carModelList[index];
    showButtonLoader.value = true;
    selectedCarModel.value = carModelList.firstOrNull ?? CarModelData();
    for (ModelDetails coreModel in dashboardController
            .getApiData.value.rslGetCore?.firstOrNull?.modelDetails ??
        []) {
      if (coreModel.modelId == selectedCarModel.value.modelId) {
        selectedCarModelList.value = coreModel;
        selectedCarModelList.refresh();
        break;
      } else {
        selectedCarModelList.value = ModelDetails();
        selectedCarModelList.refresh();
      }
    }

    // Handle null fare properly
    approximateFare.value = fare?.isNotEmpty == true ? fare! : "0.0";
    approximateFare.refresh();
    tripFare.value =
        approximateFare.value.isEmpty ? "0.0" : approximateFare.value;
    tripFare.refresh();

    printLogs(
        "Hii sabari taxi approximate fare Updated Approximate Fare: ${approximateFare.value}");

    priceHike.value = selectedCarModel.value.priceHike.toString();
    _addNoDriverPickUpMarker();
    _callNearestDriversListApi();
  }

  onBackToConfirmPickUp() {
    Get.back();
    placeSearchPageController.pickController.text = '';
    commonPlaceController.pickUpLocation.value =
        commonPlaceController.currentAddress.value;
    commonPlaceController.pickUpSubtitle.value = '';
    placeSearchPageController.destinationController.text = '';
    confirmPickupController.draggableScrollableControllerPick.animateTo(
      0.28,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut, // Animation curve
    );
    confirmPickupController.isSheetFullyExpandedPick.value = false;
    confirmPickupController.update();
  }

  void _callNearestDriversListTimerApi() {
    isLoading.value = true;
    nearestDriverListApi(
      _getNearestDriversApiRequestData(),
    ).then((nearestDriversListResponse) async {
      showButtonLoader.value = false;
      checkExcessFareAndShowInfo(nearestDriversListResponse.fareDetails);
      switch (nearestDriversListResponse.status) {
        case 1:
          isLoading.value = false;
          carModelApiStatus.value.status = nearestDriversListResponse.status;
          carModelApiStatus.refresh();
          availableCarCount.value =
              nearestDriversListResponse.detail?.length ?? 0;
          availableDriverDetail.value =
              nearestDriversListResponse.detail?.first ?? null;
          _driverDetails = nearestDriversListResponse.detail;
          _checkDriverDistanceAndUpdatePickUpMarker();
          _updateVehicleMarkers();
          _checkAndUpdateModelList(nearestDriversListResponse.fareDetails);
          _checkAndCalculateApproxFare(nearestDriversListResponse.fareDetails);
          selectedCarModel.value =
              nearestDriversListResponse.fareDetails?[0] ?? CarModelData();
          selectedCarModel.refresh();
          printLogs("CAR MODEL LIST : ${carModelList.length}");
          break;
        case 0:
          isLoading.value = false;
          carModelApiStatus.value.status = nearestDriversListResponse.status;
          carModelApiStatus.refresh();
          printLogs(
              "Case0nearestDriversListResponse${nearestDriversListResponse.status}");
          availableCarCount.value = 0;
          availableDriverDetail.value = null;
          _driverDetails = null;
          _checkDriverDistanceAndUpdatePickUpMarker();
          _removeAllVehicleMarkers();
          _checkAndUpdateModelList(nearestDriversListResponse.fareDetails);
          _checkAndCalculateApproxFare(nearestDriversListResponse.fareDetails);
          break;
        default:
          isLoading.value = false;
          printLogs(
              'NearestDriversList else -> ${nearestDriversListResponse.message}');
      }
    }).catchError((onError) {
      printLogs('NearestDriversList Api error -> $onError');
    });
  }

  void _callNearestDriversListApi() {
    printLogs("NEAREST CALLED");
    isLoading.value = true;
    nearestDriverListApi(
      _getNearestDriversApiRequestData(),
    ).then((nearestDriversListResponse) {
      showButtonLoader.value = false;
      checkExcessFareAndShowInfo(nearestDriversListResponse.fareDetails);
      switch (nearestDriversListResponse.status) {
        case 1:
          printLogs(
              "Case1nearestDriversListResponse${nearestDriversListResponse.status}");
          carModelApiStatus.value.status = nearestDriversListResponse.status;
          carModelApiStatus.refresh();
          //Available driver
          availableCarCount.value =
              nearestDriversListResponse.detail?.length ?? 0;
          availableDriverDetail.value =
              nearestDriversListResponse.detail?.first ?? DriverDetail();
          _driverDetails = nearestDriversListResponse.detail;
          _checkAndUpdateModelList(nearestDriversListResponse.fareDetails);
          _updateVehicleMarkers();
          _checkDriverDistanceAndUpdatePickUpMarker();
          break;
        case 0:
          printLogs(
              "case 0 nearestDriversListResponse${nearestDriversListResponse.status}");
          isLoading.value = false;
          carModelApiStatus.value.status = nearestDriversListResponse.status;
          carModelApiStatus.refresh();
          _checkAndUpdateModelList(nearestDriversListResponse.fareDetails);
          //Not Available driver
          availableCarCount.value = 0;
          availableDriverDetail.value = DriverDetail();
          _driverDetails = null;
          _removeAllVehicleMarkers();
          _checkDriverDistanceAndUpdatePickUpMarker();
          break;
        default:
          isLoading.value = false;
          printLogs(
              'NearestDriversList else -> ${nearestDriversListResponse.message}');
      }
    }).catchError((onError) {
      showButtonLoader.value = false;
      isLoading.value = false;
      Get.snackbar('Message', 'Something went wrong.',
          backgroundColor: AppColor.kGetSnackBarColor.value);
    });
  }

  _checkAndUpdateModelList(List<CarModelData>? fareDetails) {
    if (fareDetails == null || fareDetails.isEmpty) {
      return;
    }

    if (carModelList.isEmpty) {
      for (var item in fareDetails) {
        String imageUrl = '';

        switch (item.modelId) {
          case 1:
            imageUrl =
                'https://web.limor.us/public/uploads/model_image/android/1_1661864880_focus.png';
            break;
          case 10:
            imageUrl =
                "https://web.limor.us/public/uploads/model_image/android/10_1661864933_focus.png";
            break;
          case 23:
            imageUrl =
                "https://web.limor.us/public/uploads/model_image/android/23_1661864963_focus.png";
            break;
          case 19:
            imageUrl =
                "https://web.limor.us/public/uploads/model_image/android/19_1661864983_focus.png";
            break;
          default:
            imageUrl =
                'https://web.limor.us/public/uploads/model_image/android/1_1661864880_focus.png';
        }

        // Add the "imageUrl" parameter to the item
        item.image = imageUrl;
      }

      if (fareDetails.isNotEmpty) {
        carModelList.value = fareDetails;
        carModelList.refresh();
        carModelList[0].isSelected = true;
        selectedCarModel.value = carModelList[0];
        selectedCarModel.refresh();
        selectedModelIndex.value = 0;
        carModelList.refresh();
        updateImage();
      }
    }
  }

  checkExcessFareAndShowInfo(List<CarModelData>? fareDetails) {
    if (fareDetails != null && fareDetails.isNotEmpty) {
      for (int i = 0; i < fareDetails.length; i++) {
        if (selectedCarModel.value.modelId == fareDetails[i].modelId) {
          canShowExcessFareInfo.value = fareDetails[i].nightFare != 0.0;
          canShowExcessFareInfo.value =
              fareDetails[i].eveningFare != 0.0 || canShowExcessFareInfo.value;
          alertShortDescription.value =
              fareDetails[i].alertShortDescription ?? "";
          alertLongDescription.value =
              fareDetails[i].alertLongDescription ?? "";
        }
      }
    }
  }

  _scheduleNearestDriversListApiTimer() {
    _cancelNearestDriversListTimer();
    _nearestDriversListTimer =
        Timer.periodic(const Duration(seconds: 5), (timer) {
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

  void _cancelTripUpdateApiTimer() {
    try {
      _tripUpdateTimer?.cancel();
    } catch (e) {
      e.printError();
    }
  }

  getAppInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
    appBuildNumber.value = packageInfo.buildNumber;
  }

  NearestDriversListRequestData _getNearestDriversApiRequestData() =>
      NearestDriversListRequestData(
        skipFav: '0',
        passengerAppVersion: appVersion.value,
        latitude: '${commonPlaceController.pickUpLatLng.value.latitude}',
        longitude: '${commonPlaceController.pickUpLatLng.value.longitude}',
        dropLat: '${commonPlaceController.dropLatLng.value.latitude}',
        dropLng: '${commonPlaceController.dropLatLng.value.longitude}',
        address: commonPlaceController.pickUpLocation.value,
        cityName: '',
        passengerId: GlobalUtils.rslID,
        placeId: '',
        routePolyline: overViewPolyLine.value,
        motorModel: '${selectedCarModel.value.modelId}',
      );

  showPromoLayout() {
    dashboardController.showPromoCodeView.value = true;
    showActivePromo.value = true;
    showActivePromo.refresh();
    dashboardController.showPromoCodeView.refresh();
  }

  hidePromoLayout() {
    dashboardController.showPromoCodeView.value = false;
    dashboardController.showPromoCodeView.refresh();
  }

  dynamic validatePromoCode() {
    var promoCode = promoCodeController.text.trim().toUpperCase();
    if (promoCode.isEmpty || promoCode.length < 3) {
      Get.snackbar('Alert', "Enter valid promo code",
          backgroundColor: AppColor.kGetSnackBarColor.value);
    } else {}
  }

  clearPromoCode() {
    promoCodeController.text = "";
    appliedPromoCode.value = "";
    appliedPromoCode.refresh();
    isPromoApplied.value = false;
    _checkAndCalculateApproxFare(carModelList);
    if (promoLabel.value.isNotEmpty) {
      dashboardController.showPromoCodeView.value = true;
      dashboardController.showPromoCodeView.refresh();
    } else {
      dashboardController.showPromoCodeView.value = false;
      dashboardController.showPromoCodeView.refresh();
    }
  }

  hidePromoCodeLoader() {
    Get.back();
  }

  void _updateVehicleMarkers() async {
    markers.clear();

    for (DriverDetail driverDetail in _driverDetails ?? []) {
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

  void _getCarImage() async {
    final Uint8List dropMarker = await getBytesFromAsset(
        path: Assets.carIcon, //paste the custom image path
        width: 60,
        height: 80);

    carIcon = BitmapDescriptor.fromBytes(dropMarker);
  }

  void _checkAndCalculateApproxFare(List<CarModelData>? fareDetails) {
    if (commonPlaceController.dropLatLng.value.latitude == 0 ||
        commonPlaceController.dropLatLng.value.latitude == 0.0) {
      for (var item in carModelList) {
        if (item.approximateFare != 0) {
          item.approximateFare = 0;
        }
      }
      return;
    }
    calculateApproximateFare(fareDetails ?? [], this);
    priceHike.value = selectedCarModel.value.priceHike.toString();
    printLogs(
        "Hii ravi taxi selectedCarModel approximateFare: ${selectedCarModel.value.approximateFare} ** ${approximateFare.value}");

    priceHike.refresh();
    carModelList.refresh();
  }

  void addPickUpDropMarkers({bool fetchRoute = false}) async {
    String dropCity = commonPlaceController.dropLocation.value.split(" - ")[0];
    String pickupCity =
        commonPlaceController.pickUpLocation.value.split(RegExp(r" - |,"))[0];
    calculateArrivalTime();
    pickUpDropMarkers.clear();
    _fetchRoute();
    _addMarker(
        onTap: () {
          _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
        },
        position: commonPlaceController.pickUpLatLng.value,
        icon: await getWidgetMarker(
            widget: pickDropMarker(
                color: AppColor.kPrimaryColor.value,
                isShow: 1,
                location: pickupCity,
                time: "Pick-up",
                textColor: AppColor.kPrimaryTextColor.value,
                backgroundColor: AppColor.kStatusBarPrimaryColor.value)));
    if (commonPlaceController.dropLatLng.value.latitude != 0.0) {
      await Future.delayed(const Duration(milliseconds: 1500));
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _addMarker(
            onTap: () {
              destinationController.isDropEdit.value = true;
              _moveToGoogleLocationPicker(type: GetPoistion.drop, pageType: 2);
            },
            position: commonPlaceController.dropLatLng.value,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
                    color: Colors.red,
                    backgroundColor: AppColor.kRedColour.value,
                    location: dropCity,
                    isShow: 1,
                    time: "Arrived by ${await calculateArrivalTime()}")));
      });

      if (fetchRoute) _fetchRoute();
    }
    pickUpDropMarkers.refresh();
  }

  void _addMarker(
      {required LatLng position,
      required BitmapDescriptor icon,
      required VoidCallback onTap}) async {
    pickUpDropMarkers.add(
      Marker(
          zIndex: 1.2,
          onTap: onTap,
          markerId: MarkerId(position.toString()),
          position: position,
          icon: icon),
    );
  }

  void clearDropOffValues({bool moveCamera = false}) {
    _resetApproximateTimeDistance();
    if (pickUpDropMarkers.length > 1) {
      pickUpDropMarkers
        ..removeAt(1)
        ..refresh();
    }

    if (moveCamera) {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
            commonPlaceController.pickUpLatLng.value), // Padding of 100 pixels
      );
    }
    polyline
      ..clear()
      ..refresh();
  }

  void _resetApproximateTimeDistance() {
    approximateTime.value = 0;
    approximateTrafficTime.value = 0;
    approximateDistance.value = 0;
  }

  void _fetchRoute() async {
    LatLng startMarker = commonPlaceController.pickUpLatLng.value;
    LatLng endMarker = commonPlaceController.dropLatLng.value;
    googleMapApi(
      '${AppInfo.kAppBaseUrl}taxi/getDirections?origin=${startMarker.latitude},${startMarker.longitude}&destination=${endMarker.latitude},${endMarker.longitude}&mode=driving',
    ).then((response) {
      printLogs("POLYLINE ${response.toString()}");
      fetchOverviewPolyline(response);
    });
  }

  void fetchOverviewPolyline(Map<String, dynamic> response) {
    double time = 0.0, distance = 0.0, trafficTime = 0.0;

    try {
      if (response['routes'] != null) {
        final routeArray = response['routes'] as List<dynamic>;
        if (routeArray.isNotEmpty) {
          final routes = routeArray[0] as Map<String, dynamic>;

          // Extract and set the overview polyline
          final overviewPolyLines =
              routes['overview_polyline'] as Map<String, dynamic>?;
          final overViewPoly = overviewPolyLines?['points'] as String? ?? '';
          overViewPolyLine.value = overViewPoly;
          drawRoutePolyline(decodePolylineStringToLatLng(overViewPoly));
          _callNearestDriversListApi();

          // Process legs array
          final legsArray = routes['legs'] as List<dynamic>;
          for (var i = 0; i < legsArray.length; i++) {
            // Standard duration
            final timeObject =
                legsArray[i]['duration'] as Map<String, dynamic>?;
            final legTime = timeObject?['value'] as int?;
            if (legTime != null) {
              time += legTime;
            }

            // Distance
            final distanceObject =
                legsArray[i]['distance'] as Map<String, dynamic>?;
            final legDistance = distanceObject?['value'] as int?;
            if (legDistance != null) {
              distance += legDistance;
            }

            // Traffic duration (if available)
            final trafficTimeObject =
                legsArray[i]['duration_in_traffic'] as Map<String, dynamic>?;
            if (trafficTimeObject != null) {
              final legTrafficTime = trafficTimeObject['value'] as int?;
              if (legTrafficTime != null) {
                trafficTime += legTrafficTime;
              }
            } else {
              printLogs(
                  "Traffic time data is missing for leg $i, using normal duration.");
              if (legTime != null) {
                trafficTime += legTime; // Fallback to normal duration
              }
            }
          }

          approximateTime.value = doubleWithTwoDigits(time / 60);
          approximateTrafficTime.value = doubleWithTwoDigits(trafficTime / 60);
          approximateDistance.value = doubleWithTwoDigits(distance / 1000);

          calculateArrivalTime();
        }
      }
    } catch (e) {
      printLogs("Error in fetchOverviewPolyline: $e");
      _resetApproximateTimeDistance();
    }
  }

  _setLatLngBounds(List<LatLng> polylinePoints) {
    if (polylinePoints.isNotEmpty) {
      double minLat = polylinePoints[0].latitude;
      double maxLat = polylinePoints[0].latitude;
      double minLng = polylinePoints[0].longitude;
      double maxLng = polylinePoints[0].longitude;
      printLogs("hisaabri PolylineLatlng is Not Empty");
      for (LatLng point in polylinePoints) {
        if (point.latitude < minLat) {
          minLat = point.latitude;
        }
        if (point.latitude > maxLat) {
          maxLat = point.latitude;
        }
        if (point.longitude < minLng) {
          minLng = point.longitude;
        }
        if (point.longitude > maxLng) {
          maxLng = point.longitude;
        }
      }
      printLogs("Loop ended");
      LatLngBounds bounds = LatLngBounds(
        southwest: LatLng(minLat, minLng),
        northeast: LatLng(maxLat, maxLng),
      );

      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } else {
      printLogs("hisaabri PolylineLatlng is Empty");
    }
  }

  void drawRoutePolyline(List<LatLng> result) {
    polyline.clear();
    Polyline blackPolyline = Polyline(
      polylineId: const PolylineId('blackPolyLine'),
      width: 3,
      color: AppColor.kPrimaryColor.value,
      startCap: Cap.squareCap,
      endCap: Cap.squareCap,
      jointType: JointType.round,
      points: result,
    );

    Polyline greyPolyline = Polyline(
        polylineId: const PolylineId('greyPolyLine'),
        width: 3,
        color: Colors.orange,
        startCap: Cap.squareCap,
        endCap: Cap.squareCap,
        jointType: JointType.round,
        points: animationController?.value != null
            ? result.sublist(
                0, (animationController!.value * result.length).round())
            : result);

    polyline
      ..add(blackPolyline)
      ..add(greyPolyline);
    polyline.refresh();

    _setLatLngBounds(result);
  }

  void startAnimation() {
    animationController?.reset();
    animationController?.forward();

    printLogs("hisabari AnimationStarted");
  }

  getUserInfo() async {
    final data = await GetStorageController().getUserInfo();
    if (data == null) return;
    return;
  }

  void showTaxiBookingTimer() async {
    showTaxiBookingTimerWidgetNew(
        setCurrentTime: () {
          commonPlaceController.laterBookingDateTime.value = "";
          Get.back();
        },
        laterEnable: isLaterBooking,
        onTap: (selectDateTime) {
          commonPlaceController.setBookLaterDateTime(dateTime: selectDateTime);
          return;
        });
  }

  void _checkDriverDistanceAndUpdatePickUpMarker() {
    if (availableCarCount.value > 0) {
      _addDistanceMarker();
    } else {
      _addNoDriverPickUpMarker();
    }
  }

  void callDistanceMatrixApi(double pLatitude, double pLongitude,
      double dLatitude, double dLongitude) async {
    googleMapApi(
            '${AppInfo.kGetRslNodePassengerUrl}getDistanceMatrix?origins=$pLatitude,$pLongitude&destinations=$dLatitude,$dLongitude&key=${AppInfo.kAndroidApiKey}&departure_time=now')
        .then((response) async {
      calculateDistance(response);
    });
  }

  void calculateDistance(Map<String, dynamic> response) async {
    var obj = response['rows'][0]['elements'][0];

    var ds = obj['distance'];
    String dis = ds['value'].toString();

    var timeObject = obj['duration'];
    String time = timeObject['value'].toString();

    var trafficTimeObject = obj['duration_in_traffic'];
    String traffic = trafficTimeObject['value'].toString();

    double times = double.parse(time) / 60;
    // ignore: unused_local_variable
    double dist = double.parse(dis) / 1000;
    double trafficTime = double.parse(traffic) / 60;
    print("hi times $times $trafficTime");
    var timeInMinutes = (times >= 1) ? times : 1;
    pickUpTime.value = timeInMinutes.toInt();
    showPickUpMarker(timeInMinutes);
  }

  void _addDistanceMarker() async {
    // Distance in kilometers
    num timeInMinutes = 1;
    var driverDetail = availableDriverDetail.value;

    if (driverDetail != null) {
      if ((previousNearestDriverData?.latitude != driverDetail.latitude) ||
          (previousPickUpLatLng?.latitude !=
              commonPlaceController.pickUpLatLng.value.latitude)) {
        int useDistanceMatrix = AppInfo
            .kIsCarModelETAGoogleEnabled; // Replace this with your condition
        if (useDistanceMatrix == 1) {
          callDistanceMatrixApi(
              commonPlaceController.pickUpLatLng.value.latitude,
              commonPlaceController.pickUpLatLng.value.longitude,
              availableDriverDetail.value?.latitude ?? 0.0,
              availableDriverDetail.value?.longitude ?? 0.0);
        } else {
          pickUpTime.value = timeInMinutes.toInt();
          showPickUpMarker(timeInMinutes);
        }
      }
    }
    previousNearestDriverData = driverDetail;
    previousPickUpLatLng = LatLng(
        commonPlaceController.pickUpLatLng.value.latitude,
        commonPlaceController.pickUpLatLng.value.longitude);
  }

  showPickUpMarker(timeInMinutes) async {
    String pickupCity =
        commonPlaceController.pickUpLocation.value.split(RegExp(r" - |,"))[0];
    printLogs(
        "Hii ravi taxi pick up location list ${commonPlaceController.pickUpLatLng.value}");
    if (pickUpDropMarkers.isNotEmpty) {
      pickUpDropMarkers[0] = Marker(
          zIndex: 1.2,
          onTap: () {
            _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
          },
          markerId:
              MarkerId(commonPlaceController.pickUpLatLng.value.toString()),
          position: commonPlaceController.pickUpLatLng.value,
          //flat: true,
          icon: await getWidgetMarker(
              widget: pickDropMarker(
                  color: AppColor.kPrimaryColor.value,
                  isShow: 1,
                  location: pickupCity,
                  time: "Pick-up in ${timeInMinutes.toStringAsFixed(1)} min",
                  textColor: AppColor.kPrimaryTextColor.value,
                  backgroundColor: AppColor.kStatusBarPrimaryColor.value)));
    } else {
      pickUpDropMarkers.add(
        Marker(
            zIndex: 1.2,
            onTap: () {
              _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
            },
            markerId:
                MarkerId(commonPlaceController.pickUpLatLng.value.toString()),
            position: commonPlaceController.pickUpLatLng.value,
            //flat: true,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
                    color: AppColor.kPrimaryColor.value,
                    isShow: 1,
                    location: pickupCity,
                    time: "Pick-up in ${timeInMinutes.toStringAsFixed(1)} min",
                    textColor: AppColor.kPrimaryTextColor.value,
                    backgroundColor: AppColor.kStatusBarPrimaryColor.value))),
      );
    }
    pickUpDropMarkers.refresh();
  }

  void resetDraggableSheets() {
    draggableScrollableController = DraggableScrollableController();
    bottomDraggableScrollableController = DraggableScrollableController();
  }

  void _moveToGoogleLocationPicker(
      {required GetPoistion type, int pageType = 1}) async {
    commonPlaceController.getPosition?.value = type;
    _cancelNearestDriversListTimer();
    resetDraggableSheets();
    try {
      if (pageType == 1) {
        confirmPickupController.isPickUpEdit.value = true;
        placeSearchPageController.isForceDropEdit.value = true;
        if (confirmPickupController
            .draggableScrollableControllerPick.isAttached) {
          confirmPickupController.draggableScrollableControllerPick.dispose();
          confirmPickupController.draggableScrollableControllerPick =
              DraggableScrollableController();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (confirmPickupController
              .draggableScrollableControllerPick.isAttached) {
            confirmPickupController.draggableScrollableControllerPick.animateTo(
              0.28,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            confirmPickupController.isSheetFullyExpandedPick.value = false;
          } else {
            print("DraggableScrollableController is NOT attached!");
          }
        });
        Get.offNamed(AppRoutes.pickUpScreen);
        placeSearchPageController.isForceDropEdit.value = false;
        confirmPickupController.isPickUpEdit.value = false;
        destinationController.isDropEdit.value = false;
      } else if (pageType == 2) {
        placeSearchPageController.destinationController.text = "";
        destinationController.isDropEdit.value = true;
        placeSearchPageController.isForceDropEdit.value = true;
        destinationController.isSheetFullyExpanded.value = false;
        destinationController.isMapDragged.value = false;
        if (destinationController.draggableScrollableController.isAttached) {
          destinationController.draggableScrollableController.dispose();
          destinationController.draggableScrollableController =
              DraggableScrollableController();
        }
        final result = await Get.toNamed(AppRoutes.destinationPage);

        // Check if the result is not null and update the state
        if (result != null) {
          final latLng = result['latLng'];
          final address = result['address'];
          String pickupCity = address.split(RegExp(r" - |,"))[0];
          commonPlaceController.dropLatLng.value = latLng;
          commonPlaceController.dropLocation.value = pickupCity;
          commonPlaceController.dropLatLng.refresh();
          commonPlaceController.dropLocation.refresh();
          // Update your controller or state with the returned data
          addPickUpDropMarkers();
          placeSearchPageController.isForceDropEdit.value = false;
        }
      } else {
        Get.back();
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _googleMapLocationDataUpdating(pageType);
      });
    } catch (e) {
      printLogs('Navigation error: $e');
    }
  }

  void _googleMapLocationDataUpdating(status) async {
    String pickupCity =
        commonPlaceController.pickUpLocation.value.split(",")[0];
    String secondIndex =
        commonPlaceController.pickUpLocation.value.split(",")[1];
    calculateArrivalTime();
    printLogs(
        "Hii ravi taxi pickup latLng is ${commonPlaceController.pickUpLatLng.value}");
    if (status == "1") {
      if (pickUpDropMarkers.isNotEmpty) {
        pickUpDropMarkers[0] = Marker(
          onTap: () {
            _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
          },
          zIndex: 1.2,
          markerId:
              MarkerId(commonPlaceController.pickUpLatLng.value.toString()),
          position: commonPlaceController.pickUpLatLng.value,
          icon: await getWidgetMarker(
              widget: pickDropMarker(
                  color: AppColor.kPrimaryColor.value,
                  isShow: 1,
                  location: "$pickupCity,$secondIndex",
                  time: "Pick-up",
                  textColor: AppColor.kPrimaryTextColor.value,
                  backgroundColor: AppColor.kStatusBarPrimaryColor.value)),
        );
      } else {
        pickUpDropMarkers.add(Marker(
          onTap: () {
            _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
          },
          zIndex: 1.2,
          markerId:
              MarkerId(commonPlaceController.pickUpLatLng.value.toString()),
          position: commonPlaceController.pickUpLatLng.value,
          icon: await getWidgetMarker(
              widget: pickDropMarker(
                  color: AppColor.kPrimaryColor.value,
                  isShow: 1,
                  location: "",
                  time: "Pick-up",
                  textColor: AppColor.kPrimaryTextColor.value,
                  backgroundColor: AppColor.kStatusBarPrimaryColor.value)),
        ));
      }

      pickUpDropMarkers.refresh();
      if (commonPlaceController.dropLatLng.value == const LatLng(0.0, 0.0)) {
        mapController?.animateCamera(
            CameraUpdate.newLatLng(commonPlaceController.pickUpLatLng.value));
      } else {
        _fetchRoute();
      }
      _scheduleNearestDriversListApiTimer();
    } else if (status == "2") {
      String dropCity = commonPlaceController.dropLocation.value.split(", ")[0];
      String secondIndex =
          commonPlaceController.dropLocation.value.split(", ")[1];

      // Check if the drop marker exists and update it or add it
      if (pickUpDropMarkers.length > 1) {
        await Future.delayed(const Duration(milliseconds: 1500));
        pickUpDropMarkers[1] = Marker(
          onTap: () {
            destinationController.isDropEdit.value = true;
            _moveToGoogleLocationPicker(type: GetPoistion.drop, pageType: 2);
          },
          zIndex: 1.2,
          markerId: MarkerId(commonPlaceController.dropLatLng.value.toString()),
          position: commonPlaceController.dropLatLng.value,
          icon: await getWidgetMarker(
              widget: pickDropMarker(
                  color: Colors.red,
                  backgroundColor: AppColor.kRedColour.value,
                  location: "$dropCity, $secondIndex",
                  isShow: 1,
                  time: "Arrived by ${await calculateArrivalTime()}")),
        );
      } else {
        // If no drop marker exists, add a new drop marker
        await Future.delayed(const Duration(milliseconds: 1500));
        pickUpDropMarkers.add(Marker(
          onTap: () {
            destinationController.isDropEdit.value = true;
            _moveToGoogleLocationPicker(type: GetPoistion.drop, pageType: 2);
          },
          zIndex: 1.2,
          markerId: MarkerId(commonPlaceController.dropLatLng.value.toString()),
          position: commonPlaceController.dropLatLng.value,
          icon: await getWidgetMarker(
              widget: pickDropMarker(
                  color: Colors.red,
                  backgroundColor: AppColor.kRedColour.value,
                  location: "$dropCity, $secondIndex",
                  isShow: 1,
                  time: "Arrived by ${await calculateArrivalTime()}")),
        ));
      }

      pickUpDropMarkers.refresh();
      if (commonPlaceController.dropLatLng.value == const LatLng(0.0, 0.0)) {
        mapController?.animateCamera(
            CameraUpdate.newLatLng(commonPlaceController.dropLatLng.value));
      } else {
        _fetchRoute();
      }
      _scheduleNearestDriversListApiTimer();
    }
  }

  Future<String> calculateArrivalTime() async {
    DateTime now = DateTime.now();
    double approximateMinutes = approximateTime.value;
    DateTime arrivalTime =
        now.add(Duration(minutes: approximateMinutes.round()));
    String formattedArrivalTime = DateFormat('hh:mm a').format(arrivalTime);
    printLogs("formattedArrivalTime----> $formattedArrivalTime");
    return formattedArrivalTime;
  }

  void _addNoDriverPickUpMarker() async {
    String dropCity = commonPlaceController.dropLocation.value.split(" - ")[0];
    String pickupCity =
        commonPlaceController.pickUpLocation.value.split(RegExp(r" - |,"))[0];
    if (pickUpDropMarkers.isNotEmpty) {
      pickUpDropMarkers[0] = Marker(
          onTap: () {
            _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
          },
          zIndex: 1.2,
          markerId:
              MarkerId(commonPlaceController.pickUpLatLng.value.toString()),
          position: commonPlaceController.pickUpLatLng.value,
          //flat: true,
          icon: await getWidgetMarker(
              widget: pickDropMarker(
                  color: AppColor.kPrimaryColor.value,
                  isShow: 1,
                  location: pickupCity,
                  time: "Pickup",
                  textColor: AppColor.kPrimaryTextColor.value,
                  backgroundColor: AppColor.kStatusBarPrimaryColor.value)));
    } else {
      pickUpDropMarkers.add(
        Marker(
            zIndex: 1.2,
            onTap: () {
              _moveToGoogleLocationPicker(type: GetPoistion.pin, pageType: 1);
            },
            markerId:
                MarkerId(commonPlaceController.pickUpLatLng.value.toString()),
            position: commonPlaceController.pickUpLatLng.value,
            //flat: true,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
                    color: AppColor.kPrimaryColor.value,
                    isShow: 1,
                    time: "Pickup",
                    location: dropCity,
                    textColor: AppColor.kPrimaryTextColor.value,
                    backgroundColor: AppColor.kStatusBarPrimaryColor.value))),
      );
    }
    pickUpDropMarkers.refresh();
  }

  onBookTaxiClicked({int type = 0, int? hourly = 0}) {
    getUserInfo();
    showButtonLoader.value = true;
    _cancelNearestDriversListTimer();
    _callSaveBookingApi();
  }

  void _callSaveBookingApi() async {
    await getUserInfo();
    showButtonLoader.value = true;
    printLogs("SaveBooking Polyline: ${overViewPolyLine.value}");
    CarModelData? matchedModel = carModelList.firstWhere(
        (coreModel) => coreModel.modelId == selectedCarModel.value.modelId);
    num approximateFare = matchedModel.approximateFare ?? 0.0;
    saveBookingApi(
      SaveBookingRequestData(
          name: GlobalUtils.name,
          email: GlobalUtils.email,
          type: 0,
          phone: GlobalUtils.phone,
          approxDistance: approximateDistance.value.toString(),
          approxDuration: approximateTime.value,
          approxTripFare: isPromoApplied.value
              ? tripFare.value.toString()
              : approximateFare.toString(),
          cityname: "",
          distanceAway: 0,
          routePolyline: overViewPolyLine.value,
          dropLatitude: commonPlaceController.dropLatLng.value.latitude,
          dropLongitude: commonPlaceController.dropLatLng.value.longitude,
          dropMakani: "",
          dropNotes: "",
          dropplace: commonPlaceController.dropLocation.value,
          favDriverBookingType: 0,
          userId: GlobalUtils.passUserId,
          friendId2: 0,
          friendId3: 0,
          friendId4: 0,
          friendPercentage1: 100,
          friendPercentage2: 0,
          friendPercentage3: 0,
          friendPercentage4: 0,
          guestName: "",
          guestPhone: "",
          isGuestBooking: "0",
          latitude: commonPlaceController.pickUpLatLng.value.latitude,
          longitude: commonPlaceController.pickUpLatLng.value.longitude,
          modelWaitingFare: "${selectedCarModel.value.waitingFare}",
          motorModel: '${selectedCarModel.value.modelId}',
          notes: "",
          nowAfter: isLaterBooking ? "1" : "0",
          passengerAppVersion: appVersion.value,
          passengerPaymentOption: paymentType.value,
          paymentMode: paymentType.value.toString(),
          pickupplace: commonPlaceController.pickUpLocation.value,
          pickupMakani: '',
          pickupNotes: '',
          pickupTime:
              isLaterBooking ? laterBookingDateTime : getFormattedTimeNow(),
          promoCode: appliedPromoCode.value,
          requestType: '1',
          subLogid: '',
          countryCode: GlobalUtils.countryCode,
          priceHike: priceHike.value.toString(),
          packageType: "",
          packageId: "",
          oneTimeDiscountApplied: 0,
          oneTimeDiscountPercentage: dashboardController
                  .getApiData.value.rslGetCore?[0].oneTimeDiscountPercentage
                  ?.toInt() ??
              0),
    ).then((response) {
      switch (response.status) {
        case 1:
          showButtonLoader.value = false;
          if (isLaterBooking) {
            _refreshToBookingStateOne();
            showAppDialog(
              message: '${response.message}',
              confirm: defaultAlertConfirm(
                onPressed: () {
                  tripId = '${response.detail?.passengerTripId}';
                  commonPlaceController.tripId.value = tripId ?? "";
                  GetStorageController().saveTripId(
                      tripid: "${response.detail?.passengerTripId}");
                  Get.toNamed(AppRoutes.dashboardPage);
                  _refreshToBookingStateOne();
                },
              ),
            );
          } else {
            tripStatus.value = response.message ?? "";
            tripStatus.refresh();
            bookingState.value = BookingState.kBookingStateTwo;
            tripId = '${response.detail?.passengerTripId}';
            commonPlaceController.tripId.value = tripId ?? "";
            GetStorageController().saveTripId(tripid: "$tripId");
            bookingState.value = BookingState.kBookingStateTwo;
            _scheduleTripUpdateApiTimer();
          }
          break;
        default:
          showButtonLoader.value = false;
          _scheduleNearestDriversListApiTimer();
          Get.snackbar('Error', '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
      }
      // showButtonLoader.value = false;
    }).onError((error, stackTrace) {
      showButtonLoader.value = false;
      _refreshToBookingStateOne();
      printLogs("TAXI ERROR : $error");
      Get.snackbar('Error', 'Something went wrong.',
          backgroundColor: AppColor.kGetSnackBarColor.value);
    });
  }

  _scheduleTripUpdateApiTimer() {
    _cancelTripUpdateApiTimer();
    _tripUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _callGetTripUpdateTimerApi();
    });
  }

  void _callGetTripUpdateTimerApi() async {
    getTripUpdateApi(
      GetTripUpdateRequestData(
        userId: GlobalUtils.passUserId,
        requestType: '1',
        tripId: tripId,
        countryCode: GlobalUtils.countryCode,
        email: GlobalUtils.email,
        name: GlobalUtils.name,
        phone: GlobalUtils.phone,
        type: 0,
      ),
    ).then((response) {
      switch (response.status) {
        case 1: //Booking confirmation - TripId should be saved
          tripStatus.value = response.message ?? '';
          tripStatus.refresh();
          _cancelNearestDriversListTimer();
          GetStorageController()
              .saveTripId(tripid: commonPlaceController.tripId.value);
          _refreshToBookingStateOne();
          Get.toNamed(AppRoutes.trackingPage);
          break;
        case 2: //Driver not assigned - all are busy
          tripStatus.value = response.message ?? '';
          tripStatus.refresh();
          break;
        case 7: //Trip already cancelled.

          Get.snackbar('Alert', '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
          break;
        case 6:
          commonPlaceController.tripId.value = "$tripId";
          commonPlaceController.tripId.refresh();
          timerMessage = response.message ?? "";
          break;
        default:
          Get.snackbar('Alert', '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
      }
    }).onError((error, stackTrace) {
      printLogs("Error in getUpdateDetailAPI : $error");
    });
  }

  // Method to update the second sheet height based on scroll offset
  void updateSheetHeight(double offset) {
    double newSize =
        0.13 - (offset / 1000); // Adjust divisor to control sensitivity
    secondSheetSize.value =
        newSize.clamp(0.01, 0.13); // Keep size in valid range
    printLogs("Hii updateSheetHeight is ${secondSheetSize.value}");
  }

  void updateImage() {
    final getCoreModelList = dashboardController
        .getApiData.value.rslGetCore?.firstOrNull?.modelDetails;
    for (int i = 0; i < (getCoreModelList?.length ?? 0); i++) {
      for (int j = 0; j < carModelList.length; j++) {
        if (carModelList[j].modelId == getCoreModelList?[i].modelId &&
            carModelList[j].modelId != null) {
          carModelList[j].focusImage = getCoreModelList?[i].focusImage;
          carModelList[j].unfocusImage = getCoreModelList?[i].unfocusImage;
          carModelList[j].modelName = getCoreModelList?[i].modelName;
          carModelList[j].modelSize = getCoreModelList?[i].modelSize;
          carModelList[j].description = getCoreModelList?[i].description;
        }
      }
    }
    carModelList.refresh();
  }

  void _refreshToBookingStateOne() {
    availableCarCount.value = 0;
    availableDriverDetail.value = null;
    showButtonLoader.value = false;
    showCancelBookingLoader.value = false;
    commonPlaceController.laterBookingDateTime.value = '';
    tripId = '';
    bookingState.value = BookingState.kBookingStateOne;
    _scheduleNearestDriversListApiTimer();
    _cancelTripUpdateApiTimer();
  }
}
