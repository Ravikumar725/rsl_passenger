import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rsl_passenger/taxi/controller/taxi_controller.dart';
import '../../../../network/app_services.dart';
import '../../../routes/routes.dart';
import '../../assets/assets.dart';
import '../../controller/common_place_controller.dart';
import '../../dashboard/data/data.dart';
import '../../dashboard/getx_storage.dart';
import '../../network/services.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/alert_helpers.dart';
import '../../widget/utils/api_response_handler.dart';
import '../../widget/utils/app_info.dart';
import '../../widget/utils/global_utils.dart';
import '../../widget/utils/map_marker.dart';
import '../../widget/utils/polyline_utils.dart';
import '../data/booking_details_api_data.dart';
import '../data/cancel_trip_api_data.dart';
import '../data/get_trip_update_api_data.dart';
import '../data/get_trip_update_dashboard_api_data.dart';
import '../widget/custom_map_marker.dart';

class TrackingController extends GetxController
    with GetTickerProviderStateMixin {
  RxList<Marker> vehicleMarker = <Marker>[].obs;
  RxList<Marker> pickUpDropMarkers = <Marker>[].obs;
  Rx<BookingDetailsResponseData>? bookingDetailResponse =
      BookingDetailsResponseData().obs;
  late Uint8List dropMarker;
  Rx<Detail?> bookingDetailInfo = Detail().obs;
  Rx<int> freeCancelTimeMinute = 0.obs;
  Rx<int> freeCancelTimeSeconds = 0.obs;
  Rx<int> waitingTimeMinute = 0.obs;
  Rx<int> waitingTimeSeconds = 0.obs;
  RxList<Polyline> polyline = <Polyline>[].obs;
  Timer? _freeCancellationTimer;
  Timer? _waitingTimer;
  Rx<bool> cancelButtonLoader = false.obs;
  Rx<GetTripUpdateDashResponseData> getTripUpdateResponseData =
      GetTripUpdateDashResponseData().obs;
  var isLoading = true.obs;
  var getTripUpdateApiSuccess = false.obs;
  Rx<double> totalDistance = 0.0.obs;
  Rx<int> timeInMinutes = 0.obs;
  Rx<int> etaMinutes = 0.obs;
  Rx<int> arriveMinutes = 0.obs;
  var cancelReason = ''.obs;
  Rx<UserInfo>? userInfo = UserInfo().obs;
  Rx<String> userId = ''.obs;
  final commonPlaceController = Get.find<CommonPlaceController>();
  final taxiPageController = Get.find<TaxiController>();
  var pickUpLatLng = const LatLng(0, 0).obs;
  var dropLatLng = const LatLng(0, 0).obs;
  var driverLatLng = const LatLng(25.2048, 55.2708).obs;
  var fromDiverLatLng = const LatLng(0, 0).obs;
  var showButtonLoader = false.obs;
  Timer? _tripUpdateTimer;
  GoogleMapController? mapController;
  Rx<bool> tripStarted = false.obs;

  Rx<String> passengerChatId = ''.obs;
  Rx<String> driverChatId = ''.obs;
  Rx<String> passengerChatLogIn = ''.obs;
  Rx<String> travelStatusMsg = ''.obs;
  Rx<String> driverChatLogIn = ''.obs;
  Rx<String> driverName = ''.obs;
  Rx<bool> launchChat = false.obs;
  RxString driverId = "".obs;

  String eventName = "RSL Lifestyle chat";
  RxString dialogId = ''.obs;

  //final List<Marker> _markers = <Marker>[];
  Animation<double>? _animation;
  final _mapMarkerSC = StreamController<List<Marker>>();

  // ignore: unused_element
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;

  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;

  Rx<bool> submitButtonLoader = false.obs;
  Rx<bool> freeWaitingTime = false.obs;

  final List<LatLng> polylinePath = [];
  final Set<Polyline> polylines = {};

  RxString estimatedTime = ''.obs;

  void showThumbsUpDialog() {
    Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          content: Container(
            height: 150,
            alignment: Alignment.center,
            child: Column(children: [
              SizedBox(height: 10.h),
              Icon(
                Icons.thumb_up_alt_outlined,
                size: 64,
                color: AppColor.kPrimaryColor.value,
              ),
              SizedBox(height: 10.h),
              Text(
                "Thank You",
                style: TextStyle(
                  color: AppColor.kBlack.value,
                  fontWeight: AppFontWeight.bold.value, // Making the text bold
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                "Your feedback was successfully submitted",
                style: TextStyle(color: AppColor.kBlack.value, fontSize: 12),
              )
            ]),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Get.toNamed(AppRoutes.dashboardPage);
              },
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                (Text(
                  'Back to home',
                  style: TextStyle(
                    color: AppColor.kPrimaryColor.value,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColor.kPrimaryColor.value,
                  ),
                ))
              ]),
            ),
          ],
        ),
        barrierDismissible: false);
  }

  @override
  void onInit() {
    getUserInfo();
    _cancelTripUpdateTimer();
    _waitingTimerCancel();
    _freeTimecancelTimer();
    _getCarImage();
    callBookingDetailsApi(tripUpdateTimer: true);
    super.onInit();
  }

  @override
  void onClose() {
    vehicleMarker.clear();
    pickUpDropMarkers.clear();
    fromDiverLatLng.value = const LatLng(0, 0);
    fromDiverLatLng.refresh();
    animatefinished.value = true;

    super.onClose();
  }

  callBookingDetailsApi({bool tripUpdateTimer = false}) async {
    bookingDetailsApi(BookingDetailsRequestData(
      tripId: commonPlaceController.tripId.value,
      userId: GlobalUtils.passUserId,
      requestType: '1',
      countryCode: GlobalUtils.countryCode,
      email: GlobalUtils.email,
      name: GlobalUtils.name,
      phone: GlobalUtils.phone,
      type: 0,
    )).then((value) async {
      if (value.status == 1) {
        bookingDetailResponse?.value = value;
        bookingDetailResponse?.refresh();
        bookingDetailInfo.value = value.detail;
        bookingDetailInfo.refresh();
        driverLatLng.value = LatLng(
            double.parse(bookingDetailInfo.value?.driverLatitute ?? "0,0"),
            double.parse(bookingDetailInfo.value?.driverLongtitute ?? "0,0"));
        pickUpLatLng.value = LatLng(
            double.parse("${bookingDetailInfo.value?.pickupLatitude}"),
            double.parse("${bookingDetailInfo.value?.pickupLongitude}"));
        dropLatLng.value = LatLng(
            double.parse("${bookingDetailInfo.value?.dropLatitude}"),
            double.parse("${bookingDetailInfo.value?.dropLongitude}"));
        travelStatusMsg.value =
            bookingDetailInfo.value?.travelStatusLabel ?? "";
        passengerChatLogIn.value =
            bookingDetailInfo.value?.passengerChatLogin ?? "";
        driverChatLogIn.value = bookingDetailInfo.value?.driverChatLogin ?? "";
        passengerChatId.value = bookingDetailInfo.value?.passengerChatId ?? "";
        driverChatId.value = bookingDetailInfo.value?.driverChatId ?? "";
        driverName.value = bookingDetailInfo.value?.driverName ?? "";

        GetStorageController().saveTripId(tripid: "${value.detail?.tripId}");

        freeCancellationTimer();
        if (getTripUpdateResponseData.value.status == 3) {
          _updateDriverAndVehicleLatLng(focus: true);
        } else {
          _updateDriverAndVehicleLatLng();
        }
        _setPickAndDropMarker();
        pickUpDropMarkers.refresh;
        if (tripUpdateTimer == true) {
          callGetTripUpdateTimerApi();
        }
        if (getTripUpdateResponseData.value.status == 5) {
          final commonPlaceController = Get.find<CommonPlaceController>();
          commonPlaceController.BookingDetailResponse?.value =
              bookingDetailResponse?.value ?? BookingDetailsResponseData();
          commonPlaceController.BookingDetailResponse?.refresh();
          Get.toNamed(AppRoutes.receiptPage);
        }
      } else {
        Get.snackbar("Error", "${value.message}");
      }
    }).onError(
      (error, stackTrace) {
        Get.snackbar("Message", "$error");
      },
    );
  }

  getUserInfo() async {
    final data = await GetStorageController().getUserInfo();
    if (data == null) return;
    userInfo?.value = data;
    userInfo?.refresh();
    return;
  }

  onBackPressed() {
    if (showButtonLoader.value) return;
    onBack();
  }

  callGetTripUpdateTimerApi() {
    _cancelTripUpdateTimer();
    _tripUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _callGetTripUpdateApi();
    });
  }

  int apiCallCount = 0;

  _callGetTripUpdateApi() async {
    isLoading.value = true;
    getTripUpdateApi(GetTripUpdateRequestData(
      userId: GlobalUtils.passUserId,
      requestType: "0",
      tripId: commonPlaceController.tripId.value,
      countryCode: GlobalUtils.countryCode,
      email: GlobalUtils.email,
      name: GlobalUtils.name,
      phone: GlobalUtils.phone,
      type: 0,
    )).then(
      (value) {
        isLoading.value = false;
        getTripUpdateApiSuccess.value = true;
        if (value.status == 1) {
          ///Booking Confirmed

          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value);
          driverLatLng.value = LatLng(
              getTripUpdateResponseData.value.driverLatitute?.toDouble() ?? 0.0,
              getTripUpdateResponseData.value.driverLongtitute?.toDouble() ??
                  0.0);

          _updateDriverAndVehicleLatLng();
          // _getTotalDistance();
        } else if (value.status == 12) {
          ///Driver on the Way

          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value);
          driverLatLng.value = LatLng(
              getTripUpdateResponseData.value.driverLatitute?.toDouble() ?? 0.0,
              getTripUpdateResponseData.value.driverLongtitute?.toDouble() ??
                  0.0);
          _updateDriverAndVehicleLatLng();
          _freeTimecancelTimer();
          _waitingTimerCancel();
        } else if (value.status == 2) {
          ///Arrived

          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value);
          driverLatLng.value = LatLng(
              getTripUpdateResponseData.value.driverLatitute?.toDouble() ?? 0.0,
              getTripUpdateResponseData.value.driverLongtitute?.toDouble() ??
                  0.0);
          _updateDriverAndVehicleLatLng();
          _waitingTimerStart();
          polyline.clear();
        } else if (value.status == 3) {
          ///Trip Started

          tripStarted.value = true;
          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value);
          driverLatLng.value = LatLng(
              getTripUpdateResponseData.value.driverLatitute?.toDouble() ?? 0.0,
              getTripUpdateResponseData.value.driverLongtitute?.toDouble() ??
                  0.0);
          _updateDriverAndVehicleLatLng();
          _freeTimecancelTimer();
          _waitingTimerCancel();
          _setPolyLine();
        } else if (value.status == 15) {
          ///Toll crossed Message
          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value);
          driverLatLng.value = LatLng(
              getTripUpdateResponseData.value.driverLatitute?.toDouble() ?? 0.0,
              getTripUpdateResponseData.value.driverLongtitute?.toDouble() ??
                  0.0);
          _updateDriverAndVehicleLatLng();
          _freeTimecancelTimer();
          _waitingTimerCancel();
          showAppDialog(
              message: '${value.message}',
              title: "Alert",
              confirm: defaultAlertConfirm(onPressed: () {
                Get.back();
              }));
        } else if (value.status == 4) {
          ///Waiting for Payment and Trip Completed
          printLogs("Trip Ended");
          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value);
          driverLatLng.value = LatLng(
              getTripUpdateResponseData.value.driverLatitute?.toDouble() ?? 0.0,
              getTripUpdateResponseData.value.driverLongtitute?.toDouble() ??
                  0.0);
          _updateDriverAndVehicleLatLng();
          _freeTimecancelTimer();
          _waitingTimerCancel();
          // _getTotalDistance();
        } else if (value.status == 5) {
          ///Receipt Page
          getTripUpdateResponseData.value = value;
          getTripUpdateResponseData.refresh();
          _updateBookingDetail(value: value, tripUpdateTimer: false);
          _freeTimecancelTimer();
          _waitingTimerCancel();
          printLogs("Booking Detail Updated in STATUS 5");
          _cancelTripUpdateTimer();
          // _qbLogOutRemoveTheQbSessions();
        } else if (value.status == 7 || value.status == 9) {
          ///passenger cancel

          _cancelTripUpdateTimer();
          Get.back();
          _freeTimecancelTimer();
          _waitingTimerCancel();
          showAppDialog(
              message: '${value.message}',
              title: "Alert",
              confirm: defaultAlertConfirm(onPressed: () {
                Get.back();
              }));
        } else if (value.status == 8 || value.status == 10) {
          ///Dispatcher cancel

          _cancelTripUpdateTimer();
          _freeTimecancelTimer();
          _waitingTimerCancel();
          Get.back();
          showAppDialog(
              message: '${value.message}',
              title: "Alert",
              confirm: defaultAlertConfirm(onPressed: () {
                Get.back();
              }));
        } else {
          _cancelTripUpdateTimer();
          _freeTimecancelTimer();
          _waitingTimerCancel();
        }
      },
    ).onError(
      (error, stackTrace) {
        isLoading.value = false;
      },
    );
  }

  void trackDriver(double destLat, double destLng, int initialTimeSeconds) {
    double avgSpeedKmh = 40; // Assume an average speed

    StreamSubscription<Position>? positionStream;
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best, distanceFilter: 10),
    ).listen((Position position) {
      double remainingDistance = calculateDistance(
          position.latitude, position.longitude, destLat, destLng);
      int remainingTimeSeconds =
          ((remainingDistance / avgSpeedKmh) * 3600).round();

      print("Remaining Distance: ${remainingDistance.toStringAsFixed(2)} km");
      print("Estimated Time Left: ${Duration(seconds: remainingTimeSeconds)}");

      // If close to destination, stop tracking
      if (remainingDistance < 0.5) {
        positionStream?.cancel();
        print("Arrived at destination.");
      }
    });
  }

  void callGetDirectionAPi({required LatLng pickup, required LatLng drop}) {
    printLogs("Hii ravi kumar get direction function called");
    googleMapApi(
      '${AppInfo.kAppBaseUrl}taxi/getDirections?origin=${pickup.latitude},${pickup.longitude}&destination=${drop.latitude},${drop.longitude}&mode=driving',
    ).then((response) {
      printLogs("Hii ravi kumar get direction api called");
      printLogs("Hii ravi kumar POLYLINE ${response.toString()}");
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
        }
      }
    } catch (e) {
      printLogs("Error in fetchOverviewPolyline: $e");
    }
  }

  void _setPolyLine({bool? setBounds = false, String? encode}) async {
    printLogs(
        "Tracking Page Polyline : ${bookingDetailResponse?.value.detail?.routePolyline}");
    List<LatLng> latLngPoints = decodePolylineStringToLatLng(
        encode ?? "${bookingDetailResponse?.value.detail?.routePolyline}");

    Polyline blackPolyline = Polyline(
      polylineId: const PolylineId('blackPolyLine'),
      width: 3,
      color: AppColor.kPrimaryColor.value,
      startCap: Cap.squareCap,
      endCap: Cap.squareCap,
      jointType: JointType.round,
      points: latLngPoints,
    );
    polyline.add(blackPolyline);
    polyline.refresh();
    if (setBounds == true) {
      _setLatLngBounds(latLngPoints);
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

  void _updateBookingDetail(
      {GetTripUpdateDashResponseData? value,
      bool tripUpdateTimer = false}) async {
    if (value?.display == 1) {
      final commonPlaceController = Get.find<CommonPlaceController>();
      commonPlaceController.tripId.value =
          "${bookingDetailResponse?.value.detail?.tripId}";
      callBookingDetailsApi(tripUpdateTimer: tripUpdateTimer);
    }
  }

  void _getCarImage() async {
    dropMarker = await getBytesFromAsset(
        path: Assets.carIcon, //paste the custom image path
        width: 60,
        height: 80);
  }

  void _updateDriverAndVehicleLatLng({bool? focus = false}) {
    _addvehicle();
    if (focus == true) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
            driverLatLng.value, 12.r), // Padding of 100 pixels
      );
    } else {
      mapController?.animateCamera(
        CameraUpdate.newLatLng(
          driverLatLng.value,
        ), // Padding of 100 pixels
      );
    }
  }

  LatLng previous = const LatLng(0.0, 0.0);
  RxBool animatefinished = false.obs;

  void _addvehicle() async {
    printLogs("FROM TO ${fromDiverLatLng.value}- ${driverLatLng.value}");
    if (animatefinished.value == false &&
        fromDiverLatLng.value != driverLatLng.value) {
      animatefinished.value = true;
      await Future.delayed(const Duration(seconds: 5)).then(
        (value) {
          animatefinished.value = false;
          animateCar(
              fromDiverLatLng.value.latitude != 0
                  ? fromDiverLatLng.value.latitude
                  : driverLatLng.value.latitude,
              fromDiverLatLng.value.longitude != 0
                  ? fromDiverLatLng.value.longitude
                  : driverLatLng.value.longitude,
              driverLatLng.value.latitude,
              driverLatLng.value.longitude,
              this);
          fromDiverLatLng.value =
              LatLng(driverLatLng.value.latitude, driverLatLng.value.longitude);
          fromDiverLatLng.refresh();
        },
      ).onError((error, stackTrace) {
        animatefinished.value = false;
      });
    }
  }

  animateCar(
    double fromLat,
    double fromLong,
    double toLat,
    double toLong,
    TickerProvider provider,
  ) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    vehicleMarker.clear();
    vehicleMarker.refresh();

    var carMarker = Marker(
      markerId: MarkerId("${driverLatLng.value}"),
      position: LatLng(fromLat, fromLong),
      // ignore: deprecated_member_use
      icon: BitmapDescriptor.fromBytes(dropMarker),
      anchor: const Offset(0.5, 0.5),
      flat: true,
      rotation: bearing,
      draggable: false,
    );

    vehicleMarker.add(carMarker);

    polylinePath.add(LatLng(fromLat, fromLong));

    final animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: provider,
    );

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;
        double lat = v * toLat + (1 - v) * fromLat;
        LatLng newPos = LatLng(lat, lng);

        if (vehicleMarker.contains(carMarker)) vehicleMarker.remove(carMarker);
        carMarker = Marker(
          markerId: MarkerId("${driverLatLng.value}"),
          position: newPos,
          // ignore: deprecated_member_use
          icon: BitmapDescriptor.fromBytes(dropMarker),
          anchor: const Offset(0.5, 0.5),
          flat: true,
          rotation: bearing,
          draggable: false,
        );
        vehicleMarker.add(carMarker);
        vehicleMarker.refresh();
        polylines.clear();
        // _drawPolylineCarMoving(newPos);
      });
    animationController.forward();
    printLogs("animate${_animation?.isDismissed}");
  }

  double getBearing(LatLng begin, LatLng end) {
    double startLat = radians(begin.latitude);
    double startLng = radians(begin.longitude);
    double endLat = radians(end.latitude);
    double endLng = radians(end.longitude);

    double dLng = endLng - startLng;

    double y = sin(dLng) * cos(endLat);
    double x =
        cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng);

    double bearing = atan2(y, x);

    // Convert from radians to degrees
    // bearing = radiansToDegrees(bearing);

    // Normalize to range [0, 360]
    bearing = (bearing + 360) % 360;

    return bearing;
  }

  double radians(double degrees) => degrees * pi / 180.0;

  double degrees(double radians) => radians * 180.0 / pi;

  void _addMarker(
      {required LatLng position, required BitmapDescriptor icon}) async {
    pickUpDropMarkers.add(
      Marker(
          zIndex: 1.2,
          markerId: MarkerId(position.toString()),
          position: position,
          icon: icon),
    );
  }

  void _setPickAndDropMarker() async {
    if (pickUpDropMarkers.length == 0) {
      printLogs("FROM 1 lenght ${pickUpDropMarkers.length}");
      _addMarker(
          position: pickUpLatLng.value,
          icon: await getWidgetMarker(
              widget: pickDropMarker(color: AppColor.kPrimaryColor.value)));
      if (LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude) !=
          const LatLng(0.0, 0.0)) {
        printLogs("FROM 1-2 ${pickUpDropMarkers.length}");
        _addMarker(
            position: dropLatLng.value,
            icon: await getWidgetMarker(
                widget: pickDropMarker(color: Colors.red)));
      }
      pickUpDropMarkers.refresh();
    } else if (pickUpDropMarkers.length == 2) {
      printLogs("FROM 2 ${pickUpDropMarkers.length}");
      if (LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude) !=
          const LatLng(0.0, 0.0)) {
        printLogs("FROM 2-1 ${pickUpDropMarkers.length}");
        pickUpDropMarkers.removeAt(
          1,
        );
        pickUpDropMarkers.add(
          Marker(
              zIndex: 1.2,
              markerId: MarkerId(
                  "${LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude)}"),
              position:
                  LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude),
              //flat: true,
              icon: await getWidgetMarker(
                  widget: pickDropMarker(color: Colors.red))),
        );
      }
      pickUpDropMarkers.refresh();
    } else if (pickUpDropMarkers.length == 1) {
      printLogs("FROM 3 ${pickUpDropMarkers.length}");
      if (LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude) !=
          const LatLng(0.0, 0.0)) {
        printLogs("FROM 3-1 ${pickUpDropMarkers.length}");
        pickUpDropMarkers.add(
          Marker(
              zIndex: 1.2,
              markerId: MarkerId(
                  "${LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude)}"),
              position:
                  LatLng(dropLatLng.value.latitude, dropLatLng.value.longitude),
              //flat: true,
              icon: await getWidgetMarker(
                  widget: pickDropMarker(color: Colors.red))),
        );
      }
      pickUpDropMarkers.refresh();
    }
  }

  void freeCancellationTimer() {
    const oneSec = Duration(seconds: 1);

    _freeTimecancelTimer();

    _freeCancellationTimer = Timer.periodic(oneSec, (timer) {
      if (freeCancelTimeSeconds.value == 0) {
        if (freeCancelTimeMinute.value == 0) {
          timer.cancel();
        } else {
          freeCancelTimeMinute.value--;
          freeCancelTimeSeconds.value = 59;
        }
      } else {
        freeCancelTimeSeconds.value--;
      }
    });
  }

  void _freeTimecancelTimer() {
    if (_freeCancellationTimer != null && _freeCancellationTimer!.isActive) {
      _freeCancellationTimer!.cancel();
    }
  }

  void _waitingTimerStart() {
    _waitingTimerCancel();

    int totalSeconds = waitingTimeMinute.value * 60 + waitingTimeSeconds.value;

    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (totalSeconds > 0) {
        totalSeconds--;
        waitingTimeMinute.value = totalSeconds ~/ 60;
        waitingTimeSeconds.value = totalSeconds % 60;
      } else {
        timer.cancel();
      }
    });
  }

  void _waitingTimerCancel() {
    if (_waitingTimer != null && _waitingTimer!.isActive) {
      _waitingTimer!.cancel();
    }
  }

  _cancelTripUpdateTimer() {
    try {
      printLogs("getTriperTimer Canceled");
      _tripUpdateTimer?.cancel();
    } catch (e) {
      e.printError();
    }
  }

  onBack() {
    Get.offAllNamed(AppRoutes.dashboardPage);
    _cancelTripUpdateTimer();
  }

  void cancelBookingApi() async {
    cancelButtonLoader.value = true;
    cancelTripApi(CancelTripRequestData(
      passengerLogId: commonPlaceController.tripId.value,
      payModId: "1",
      remarks: cancelReason.value,
      creditCardCvv: "",
      travelStatus: "4",
      paymentGatewayMode:
          AppInfo.kAppGetCore?.responseData?.paymentGatewayMode ?? "0",
      paymentMode: AppInfo.kAppGetCore?.responseData?.paymentMode ?? "0",
    )).then(
      (response) {
        if ((response.status == "1") || (response.status == "2")) {
          cancelButtonLoader.value = false;
          Get.snackbar("Message", '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
          Get.offAllNamed(AppRoutes.dashboardPage);
        } else {
          cancelButtonLoader.value = false;
          Get.snackbar("Message", '${response.message}',
              backgroundColor: AppColor.kGetSnackBarColor.value);
        }
      },
    ).onError((error, stackTrace) {
      cancelButtonLoader.value = false;
    });
  }

  void reviewPageBackPress() {
    Get.offAllNamed(AppRoutes.dashboardPage);
    TaxiController().onClose();
  }

  onCancelClicked() {
    Navigator.pop(Get.context!);
    Get.back();
    cancelBookingApi();
  }

  var showCancelBookingLoader = false.obs;

  var updateLocationLoader = false.obs;
  Rx<ResponseStatus> updateLocationResponseStatus = ResponseStatus().obs;
  var pickUp = ''.obs;
  var drop = ''.obs;
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const R = 6371; // Earth radius in km
  double dLat = (lat2 - lat1) * pi / 180.0;
  double dLon = (lon2 - lon1) * pi / 180.0;

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180.0) *
          cos(lat2 * pi / 180.0) *
          sin(dLon / 2) *
          sin(dLon / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  return R * c; // Distance in km
}
