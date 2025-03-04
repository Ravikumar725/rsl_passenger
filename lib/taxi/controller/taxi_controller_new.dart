import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../network/app_services.dart';
import '../../../routes/routes.dart';
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
import '../../widget/utils/approximate_fare_calculation_new.dart';
import '../widget/custom_map_marker.dart';
import '../../widget/utils/map_marker.dart';
import '../../widget/utils/polyline_utils.dart';
import '../widget/taxi_timer_widget.dart';
import 'confirm_pickup_controller.dart';
import 'destination_controller.dart';

enum ApproximateDistanceCalculated { kWaiting, kCompleted }

enum BookingState {
  kBookingStateOne,
  kBookingStateTwo,
}

class ApiResponseStatus {
  int? status;
  String? message;

  ApiResponseStatus(
      {this.status = 15, this.message = "Connecting to server...."});
}

class TaxiControllerNew extends GetxController
    with GetSingleTickerProviderStateMixin, WidgetsBindingObserver {
  final commonPlaceController = Get.find<CommonPlaceController>();
  final placeSearchPageController = Get.find<PlaceSearchPageController>();
  final dashboardController = Get.find<DashBoardController>();
  final confirmPickupController = Get.find<ConfirmPickupController>();
  final destinationController = Get.find<DestinationController>();
  late AnimationController? animationController;
  var guestFormKey = GlobalKey<FormState>();
  var guestContryCode = "+971".obs;
  var PAYMENT_ID_CASH = 1.obs;
  var PAYMENT_ID_CARD = 2.obs;
  var PAYMENT_ID_WALLET = 3.obs;
  var PAYMENT_ID_APPLEPAY = 4.obs;
  var paymentType = 1.obs;
  RxString appVersion = "".obs;
  RxString appBuildNumber = "".obs;

  TextEditingController guestPhoneNumber = TextEditingController();
  TextEditingController guestEmailId = TextEditingController();
  TextEditingController promoCodeController = TextEditingController();
  RxBool viewGuestFieldForm = false.obs;

  Rx<Polyline>? polylineAnimate;
  RxBool isLoading = false.obs;

  RxBool showActivePromo = false.obs;

  // RxBool showPromoCodeView = false.obs;
  RxString appliedPromoCode = "".obs;
  RxString promoLabel = "".obs;
  RxString activePromoCode = "".obs;

  RxBool isPromoApplied = false.obs;

  RxBool guestLoader = false.obs;
  RxString selectedGuest = "Me".obs;
  RxString selectedGuestPhone = "".obs;
  RxString isGuestBooking = "0".obs;

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
    WidgetsBinding.instance.addObserver(this);
    _callNearestDriversListApi();
    _fetchRoute();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
      //Use TickerProviderStateMixin
    );
    await getUserInfo();
    await getAppInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    _scheduleNearestDriversListApiTimer();
    _getCarImage();
    super.onInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Handle app lifecycle changes
    switch (state) {
      case AppLifecycleState.resumed:
        addPickUpDropMarkers();
        print('Hii App resumed');
        break;
      case AppLifecycleState.inactive:
        print('Hii App inactive');
        break;
      case AppLifecycleState.paused:
        print('Hii App paused');
        break;
      case AppLifecycleState.detached:
        print('Hii App detached');
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  onCarModelSelected(int index, String? fare) {
    var carModel = carModelList[index];
    showButtonLoader.value = true;
    selectedCarModel.value = carModel;

    selectedCarModelList.value = dashboardController
            .getApiData.value.rslGetCore?[0].modelDetails?[index + 1] ??
        ModelDetails();

    selectedModelIndex.value = index;
    selectedModelIndex.refresh();
    carModelList.refresh();

    approximateFare.value = fare?.isNotEmpty == true ? fare! : "0.0";
    approximateFare.refresh();
    tripFare.value = approximateFare.value ?? "";
    tripFare.refresh();

    priceHike.value = carModel.priceHike.toString();
    _addNoDriverPickUpMarker();
    _callNearestDriversListApi();
  }

  void moveToTrackingPage() {
    startBookingStatusTimer();
    startProgress();
    startTimer();
  }

  Timer? bookingStatusTimer;

  void startBookingStatusTimer() {
    int statusIndex = 0;
    List<String> statuses = [
      "Create a booking",
      "Finding your Captain",
      "Checking optimal routes",
      "Locating nearest Captain"
    ];

    bookingStatusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (statusIndex < statuses.length) {
        bookingStatus.value = statuses[statusIndex];
        statusIndex++;
      } else {
        timer.cancel(); // Stop the timer after all statuses are shown
      }
    });
  }

  Timer? progressTimer;

  void startProgress() {
    progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (progressValue.value < 1.0) {
        if (progressValue.value == 0.1) {
          progressValue.value = 0.2;
          bookingStatus.value = 'Create a booking';
        } else if (progressValue.value == 0.2) {
          progressValue.value = 0.4;
          bookingStatus.value = 'Finding your Captain';
        } else if (progressValue.value == 0.4) {
          progressValue.value = 0.6;
          bookingStatus.value = 'Checking optimal routes';
        } else if (progressValue.value == 0.6) {
          progressValue.value = 0.8;
          bookingStatus.value = 'Locating nearest Captain';
          timer.cancel();
        }
      }
    });
  }

  int elapsedSeconds = 0;

  void startTimer() {
    const int targetDuration = 30; // Target duration in seconds

    // Start the timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds++;

      if (elapsedSeconds >= targetDuration) {
        // Cancel the timer when it reaches 30 seconds
        timer.cancel();
        // Get.toNamed(NewAppRoutes.trackingPageNew);
        printLogs("Timer canceled after $targetDuration seconds.");
        // Perform any additional actions after canceling the timer
      } else {
        // Update your UI or perform any periodic action
        printLogs("Elapsed time: $elapsedSeconds seconds");
      }
    });
  }

  // Cancel the timer if needed
  void cancelTimer() {
    if (_timer?.isActive ?? false) {
      _timer?.cancel(); // Cancel the timer if it's still active
    }
  }

  void cancelAllTimers() {
    // Cancel booking status timer
    bookingStatusTimer?.cancel();

    // Cancel progress timer
    progressTimer?.cancel();

    // Cancel the main navigation timer
    cancelTimer();
  }

  void updateProgress(double value) {
    progressValue.value = value;
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

  GoogleMapController? mapController = null;

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
  var isDistanceCalculated = false.obs;

// var laterBookingDateTime = ''.obs;
  var overViewPolyLine = ''.obs;
  var approximateTime = 0.0.obs;
  var approximateDistance = 0.0.obs;
  var approximateTrafficTime = 0.0.obs;
  var animationValue = 0.0.obs;
  var approximateFare = "".obs;
  var priceHike = "".obs;
  var tripFare = "".obs;

  final userId = '33164';
  String? tripId;
  BitmapDescriptor? carIcon;

  List<DriverDetail>? _driverDetails;

  String get laterBookingDateTime =>
      commonPlaceController.laterBookingDateTime.value;

  String get hourlyBookingDateTime =>
      commonPlaceController.hourlyBookingDateTime.value;

  bool get isHourlyBooking => hourlyBookingDateTime.isNotEmpty;

  bool get isLaterBooking => laterBookingDateTime.isNotEmpty;

  RxBool canShowExcessFareInfo = false.obs;
  RxString alertShortDescription = "".obs;
  RxString alertLongDescription = "".obs;

  DriverDetail? previousNearestDriverData;
  LatLng? previousPickUpLatLng;
  int? oneTimeDiscount = 0;
  var oneTimeDiscountType = 1.obs;
  var defaultCard = 0.obs;
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
    Navigator.pop(Get.context!); // Close CancelReasonsBottomSheet
    Get.back(); // Close cancelBottomAlert
    // _showCancelBookingConfirmation();
  }

  onBackPressed() {
    _cancelNearestDriversListTimer();
    Get.back();
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
          _checkAndCalculateApproxFare(nearestDriversListResponse.fareDetails);
          selectedCarModel.value =
              nearestDriversListResponse.fareDetails?[0] ?? CarModelData();
          selectedCarModel.refresh();
          // approximateFare.value =
          //     "${nearestDriversListResponse.fareDetails?[0].approximateFare}";
          // approximateFare.refresh();
          printLogs("CAR MODEL LIST : ${carModelList.length}");
          break;
        case 0:
          // carModelApiStatus.value.status = 1;
          isLoading.value = false;
          carModelApiStatus.value.status = nearestDriversListResponse.status;
          carModelApiStatus.refresh();
          print(
              "Case0nearestDriversListResponse${nearestDriversListResponse.status}");
          availableCarCount.value = 0;
          availableDriverDetail.value = null;
          _driverDetails = null;
          _checkDriverDistanceAndUpdatePickUpMarker();
          _removeAllVehicleMarkers();
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
          print(
              "Case1nearestDriversListResponse${nearestDriversListResponse.status}");
          carModelApiStatus.value.status = nearestDriversListResponse.status;
          carModelApiStatus.refresh();
          //Available driver
          availableCarCount.value =
              nearestDriversListResponse.detail?.length ?? 0;
          availableDriverDetail.value =
              nearestDriversListResponse.detail?.first ?? DriverDetail();
          _driverDetails = nearestDriversListResponse.detail;
          _updateVehicleMarkers();
          _checkDriverDistanceAndUpdatePickUpMarker();
          // _checkAndCalculateApproxFare(nearestDriversListResponse.fareDetails);
          break;
        case 0:
          print(
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
          // _checkAndCalculateApproxFare(nearestDriversListResponse.fareDetails);
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

      carModelList.value = fareDetails;
      carModelList.refresh();
      selectedCarModel.value = carModelList[0];
      selectedCarModel.refresh();
      selectedModelIndex.value = 0;
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
        passengerId: userId,
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

  void _getCarImage() async {
    final Uint8List dropMarker = await getBytesFromAsset(
        path: Assets.carIcon, //paste the custom image path
        width: 60,
        height: 80);

    carIcon = BitmapDescriptor.fromBytes(dropMarker);

    // carIcon = await BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration(size: Size(24, 24)), Assets.carIcon);
  }

  void _checkAndCalculateApproxFare(List<CarModelData>? fareDetails) {
    if (commonPlaceController.dropLatLng.value.latitude == 0) {
      for (var item in carModelList) {
        if (item.approximateFare != 0) {
          item.approximateFare = 0;
        }
      }
      return;
    }
    // approximateFare.value = selectedCarModel.value.approximateFare.toString();
    priceHike.value = selectedCarModel.value.priceHike.toString();
    // approximateFare.refresh();
    printLogs(
        "Hii ravi taxi selectedCarModel approximateFare: ${selectedCarModel.value.approximateFare} ** ${approximateFare.value}");

    priceHike.refresh();
    carModelList.refresh();
  }

  void calculateFareForAll(
      String? discountPercentage, String? maximumDiscount) {
    if (discountPercentage != null && maximumDiscount != null) {
      for (var carModelData in carModelList) {
        // printLogs(
        //     "hii calculateFareForAll $discountPercentage $maximumDiscount");
        isPromoApplied.value = true;
        // carModelData.originalFare = carModelData.approximateFare.toString();
        var discountPercentageValue =
            double.tryParse(discountPercentage) ?? 0.0;
        var maximumDiscountValue = double.tryParse(maximumDiscount) ?? 0.0;

        var discount = double.parse(carModelData.approximateFare.toString()) *
            (discountPercentageValue * 0.01);

        var fareToDeduct = discount;
        if (maximumDiscountValue > 0) {
          fareToDeduct = min(discount, maximumDiscountValue);
        }
        // printLogs("hii calculateFareForAll $fareToDeduct");
        if (carModelData.approximateFareWithWaitingFare != null) {
          if (carModelData.approximateFare?.round() !=
                  carModelData.approximateFareWithWaitingFare?.round() &&
              carModelData.approximateFareWithWaitingFare!.round() >
                  carModelData.approximateFare!.round()) {
            carModelData.fareRange =
                "${(carModelData.approximateFare! - fareToDeduct).round()} - ${(carModelData.approximateFareWithWaitingFare! - fareToDeduct).round()}";
            carModelData.originalFare =
                "${carModelData.approximateFare?.round()} - ${carModelData.approximateFareWithWaitingFare?.round()}";
            tripFare.value = carModelData.fareRange ?? "";
          } else {
            carModelData.fareRange =
                "${(carModelData.approximateFare! - fareToDeduct).round()}";
            carModelData.originalFare =
                "${carModelData.approximateFare?.round()}";
            tripFare.value = carModelData.fareRange ?? "";
          }
        } else {
          carModelData.fareRange =
              "${(carModelData.approximateFare! - fareToDeduct).round()}";
          carModelData.originalFare =
              "${carModelData.approximateFare?.round()}";
          tripFare.value = carModelData.fareRange ?? "";
        }
        carModelData.approximateFare =
            carModelData.approximateFare!.round() - fareToDeduct.round();
      }
      carModelList.refresh();
    } else {
      for (var carModelData in carModelList) {
        isPromoApplied.value = true;
        carModelData.originalFare = carModelData.approximateFare.toString();
        if (carModelData.approximateFare?.round() !=
                carModelData.approximateFareWithWaitingFare?.round() &&
            carModelData.approximateFareWithWaitingFare!.round() >
                carModelData.approximateFare!.round()) {
          carModelData.fareRange =
              "${carModelData.approximateFare?.round()} - ${carModelData.approximateFareWithWaitingFare?.round()}";
          tripFare.value = carModelData.fareRange ?? "";
        } else {
          carModelData.fareRange = "${carModelData.approximateFare?.round()}";
          tripFare.value = carModelData.fareRange ?? "";
        }
      }
      carModelList.refresh();
    }
  }

  void addPickUpDropMarkers({bool fetchRoute = false}) async {
    String dropCity = commonPlaceController.dropLocation.value.split(" - ")[0];
    printLogs(
        "Hii Taxi pickUp drop marker is ${commonPlaceController.dropLocation.value} ** $dropCity ** ${commonPlaceController.pickUpLatLng.value}");
    String pickupCity =
        commonPlaceController.pickUpLocation.value.split(RegExp(r" - |,"))[0];
    // String pickupCityName =
    //     commonPlaceController.pickUpLocation.value.split(" - ")[1];
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
//pickDistanceMarker(color:AppColor.kPrimaryColor.value )
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
    // commonPlaceController.dropLatLng.value = const LatLng(0, 0);
    // commonPlaceController.dropLocation.value = '';
    // commonPlaceController.laterBookingDateTime.value = '';
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
    // String apiKey =
    //     AppInfo.kGoogleMapKey; // Replace with your Google Maps API key
    printLogs("Hii Taxi fetchRoute latLng $startMarker ** $endMarker");
    googleMapApi(
      'http://157.241.59.247:4004/taxi/getDirections?origin=${startMarker.latitude},${startMarker.longitude}&destination=${endMarker.latitude},${endMarker.longitude}&mode=driving',
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

          // Update approximate values
          approximateTime.value = doubleWithTwoDigits(time / 60);
          approximateTrafficTime.value = doubleWithTwoDigits(trafficTime / 60);
          approximateDistance.value = doubleWithTwoDigits(distance / 1000);

          printLogs(
              "Hii ravi Approximate traffic time: ${approximateTrafficTime.value}");
          printLogs(
              "Hii ravi Approximate normal time: ${approximateTime.value}");
          printLogs(
              "Hii ravi Approximate distance: ${approximateDistance.value}");

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

// void animatePolyline(List<LatLng> points) async {
//   polylinePoints.value = []; // Clear existing points

//   for (int i = 0; i < points.length; i++) {
//     await Future.delayed(
//       Duration(
//         seconds: 3,
//       ),
//     ); // Delay between each point
//     polylinePoints.add(
//       points[i],
//     );
//   }
// }

// void createPolyline() {
//   polyline.add(
//     Polyline(
//       polylineId: PolylineId('route'),
//       color: Colors.red,
//       width: 5,
//       points: polylinePoints,
//     ),
//   );
// }

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
    // List<LatLng> getAnimatedPoints() {
    //   final animationValue = animationController!.value;
    //   final endIndex = (animationValue * result.length).toInt();
    //   return result.sublist(0, endIndex);
    // }

    // Polyline getAnimatedPolyline() {
    //   polyline.refresh();
    //   final animatedPoints = getAnimatedPoints();
    //   return Polyline(
    //     polylineId: PolylineId('greyPolyLine'),
    //     color: Colors.orange,
    //     width: 5,
    //     points: animatedPoints,
    //   );
    // }

    polyline
      ..add(blackPolyline)
      ..add(greyPolyline);
    polyline.refresh();

    _setLatLngBounds(result);

    // animatePolyline(blackPolyline.points);
    //_animationController?.repeat(reverse: true);
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
    // if (back == true) {
    //   laterBookingDateTime.value =
    //       commonPlaceController.laterBookingDateTime.value;
    //   print("hisabari showBookingTimer$back");
    // } else {
    //   print("hisabari showBookingTimer$back");
    // }
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
    /* double distance = await calculateHaverShineDistance(
        startLat: commonPlaceController.pickUpLatLng.value.latitude,
        startLng: commonPlaceController.pickUpLatLng.value.longitude,
        endLat: availableDriverDetail.value?.latitude ?? 0.0,
        endLng: availableDriverDetail.value?.longitude ?? 0.0);
    int timeInMinutes = minutesUsingDistance(distance: distance);
    timeInMinutes = (timeInMinutes >= 1) ? timeInMinutes : 1;*/
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
          // double distance = calculateHaverShineDistance(
          //     startLat: commonPlaceController.pickUpLatLng.value.latitude,
          //     startLng: commonPlaceController.pickUpLatLng.value.longitude,
          //     endLat: availableDriverDetail.value?.latitude ?? 0.0,
          //     endLng: availableDriverDetail.value?.longitude ?? 0.0);
          // int time = minutesUsingDistance(distance: distance);
          // timeInMinutes = (time >= 1) ? time : 1;
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
    // String secondIndex =
    //     commonPlaceController.pickUpLocation.value.split(RegExp(r" - |,"))[1];
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
                  backgroundColor: AppColor.kStatusBarPrimaryColor
                      .value)) /*getWidgetMarker(
              widget: pickDistanceMarker(
                  text: "${timeInMinutes.toStringAsFixed(1)}",
                  color: AppColor.kPrimaryColor.value))*/
          );
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
                    backgroundColor: AppColor.kStatusBarPrimaryColor
                        .value) /*pickDistanceMarker(
                    text: "$timeInMinutes",
                    color: AppColor.kPrimaryColor.value)*/
                )),
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
        // Get.toNamed(AppRoutes.destinationPage);
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
      // Safely handle status
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _googleMapLocationDataUpdating(pageType);
      });
    } catch (e) {
      // Handle navigation error if needed
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
    // Update only the pickup marker instead of clearing all markers
    if (status == "1") {
      // Check if the pickup marker exists and update it or add it
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
        // If no markers are present, just add the pickup marker
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
    // String pickupCityName =
    //     commonPlaceController.pickUpLocation.value.split(RegExp(r" - |,"))[1];
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

  String? validatePhoneNumber(String? value) {
    if (value == '') {
      return 'Please enter mobile number';
    }
    if (!GetUtils.isPhoneNumber(value.toString())) {
      return 'Please enter valid mobile number';
    }
    if (double.tryParse(value.toString()) == null) {
      return 'Invalid number format';
    }
    return null;
  }

  bool? submit() {
    final isValid = guestFormKey.currentState?.validate();
    // if (!isValid!) {
    //   return;
    // }
    return isValid;
  }

  RxDouble firstSheetHeight = 0.45.obs;
  RxBool isFirstSheetExpanded = false.obs;
  RxBool isSecondSheetExpanded = false.obs;
  RxDouble secondSheetSize = 0.13.obs;
  double maxOffset = 1000.0;
  final ValueNotifier<double> draggableSheetHeight = ValueNotifier(0.45);
  late DraggableScrollableController draggableScrollableController;
  late DraggableScrollableController bottomDraggableScrollableController;
  final ValueNotifier<bool> isSheetFullyExpanded = ValueNotifier(false);
  bool isSecondSheetListenerAdded = false;
  bool isListenerAdded = false;
  var isControllerAttached = false.obs;

  // Method to update the second sheet height based on scroll offset
  void updateSheetHeight(double offset) {
    double newSize =
        0.13 - (offset / 1000); // Adjust divisor to control sensitivity
    secondSheetSize.value =
        newSize.clamp(0.01, 0.13); // Keep size in valid range
    printLogs("Hii updateSheetHeight is ${secondSheetSize.value}");
  }
}
