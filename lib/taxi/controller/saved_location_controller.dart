import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../../widget/utils/app_info.dart';
import '../../../../controller/common_place_controller.dart';
import '../../../../dashboard/getx_storage.dart';
import '../../dashboard/data/data.dart';
import '../../../../network/app_services.dart';
import '../../../../network/services.dart';
import '../../../../widget/styles/colors.dart';
import '../data/save_location_api_data.dart';
import '../data/saved_location_list_api_data.dart';
import '../../widget/utils/api_response_handler.dart';
import '../widget/custom_map_marker.dart';
import 'city_selection_controller.dart';

class SaveLocationController extends GetxController {
  Rx<Prediction?> selectedPrediction = Rx<Prediction?>(null);
  var locationName = ''.obs;
  var pickupDetails = ''.obs;
  GoogleMapController? mapController;
  RxSet<Marker> markers = RxSet<Marker>();
  Rx<LatLng> target = const LatLng(0.0, 0.0).obs;
  final commonPlaceController = Get.find<CommonPlaceController>();
  final citySelectionController = Get.put(CitySelectionController());
  TextEditingController locationNameController = TextEditingController();
  TextEditingController pickupDetailsController = TextEditingController();
  RxBool showOtherDetail = false.obs;
  late GoogleMapsPlaces _places;
  RxString addAddressLocation = "".obs;
  RxString addAddressSubtitle = "".obs;

  var mapType = MapType.normal.obs;
  var trafficEnabled = false.obs;
  RxBool isOutsideUAE = false.obs;
  var isAddressFetching = false.obs;
  Rx<UserInfo?> userInfo = UserInfo().obs;
  Rx<bool> mapLocationLoader = false.obs;
  RxBool isLoading = false.obs;

  Rx<ResponseStatus> saveLocationResponseStatus = ResponseStatus().obs;
  Rx<ResponseStatus> saveLocationListResponseStatus = ResponseStatus().obs;
  RxList<LocationList> locationList = <LocationList>[].obs;
  var selectedBuildingType = "Apt.".obs;
  TextEditingController nickNameController = TextEditingController();
  TextEditingController apartmentNoController = TextEditingController();
  TextEditingController floorNoController = TextEditingController();
  TextEditingController buildingNameController = TextEditingController();
  TextEditingController buildingNoController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController streetNameController = TextEditingController();
  TextEditingController additionalController = TextEditingController();

  final apartmentFormKey = GlobalKey<FormState>();
  final villaFormKey = GlobalKey<FormState>();
  final officeFormKey = GlobalKey<FormState>();
  final othersFormKey = GlobalKey<FormState>();

  var nickName = ''.obs;
  var apartmentNo = ''.obs;
  var floorNo = ''.obs;
  var buildingName = ''.obs;
  var buildingNo = ''.obs;
  var area = ''.obs;
  var streetName = ''.obs;
  var additional = ''.obs;

  final nickNameFocus = FocusNode();
  final apartmentNoFocus = FocusNode();
  final buildingNameFocus = FocusNode();
  final areaFocus = FocusNode();
  final streetNameFocus = FocusNode();
  final additionalFocus = FocusNode();
  final floorNoFocus = FocusNode();
  final buildingNoFocus = FocusNode();

  @override
  void onClose() {
    // Dispose of focus nodes
    nickNameFocus.dispose();
    apartmentNoFocus.dispose();
    buildingNameFocus.dispose();
    areaFocus.dispose();
    streetNameFocus.dispose();
    additionalFocus.dispose();
    floorNoFocus.dispose();
    buildingNoFocus.dispose();
    super.onClose();
  }

  void selectBuildingType(String type) {
    selectedBuildingType.value = type;
  }

  void changeMapType() {
    mapType.value =
        mapType.value == MapType.normal ? MapType.satellite : MapType.normal;
  }

  void changeTrafficView() {
    trafficEnabled.value = !trafficEnabled.value;
  }

  @override
  void onInit() {
    getUserInfo();
    initPlaces();
    super.onInit();
  }

  Future getUserInfo() async {
    userInfo.value = UserInfo();
    userInfo.refresh();
    try {
      userInfo.value = await GetStorageController().getUserInfo();
      userInfo.refresh();
      callSaveLocationListApi();
    } catch (error) {
      printLogs("onError Dashboard UserInfo $error");
    }
  }

  Future<void> initPlaces() async {
    _places = GoogleMapsPlaces(
      apiKey: AppInfo.kGooglePlacesKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );
  }

  void onCameraPosition(LatLng target) {
    mapLocationLoader.value = true;
    getAddressFromLatLng(target);
  }

  void setTarget({required LatLng getTarget}) {
    target.value = getTarget;
    target.refresh();
    getAddressFromLatLng(getTarget);
  }

  void moveToCurrentLocation({double? zoom}) {
    _checkAndGetCurrentPosition().then((value) {
      isAddressFetching.value = false;
      final newLatLng = LatLng(value.latitude, value.longitude);
      // pickUpLatLng.value = newLatLng;
      commonPlaceController.currentLatLng.value = newLatLng;
      _moveToCurrentPosition(newLatLng, zoom ?? 15);
    }).catchError((onError) {
      isAddressFetching.value = false;
      Get.snackbar('Error!', onError.toString());
    });
  }

  Future<void> _moveToCurrentPosition(LatLng latLng, double zoom) async {
    try {
      await mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: latLng,
            zoom: zoom,
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

  CameraPosition initialCameraPosition() {
    return CameraPosition(
      target: target.value,
      zoom: 14,
    );
  }

  Future<void> setSelectedLocation(
      String locationValue, String pickupValue, LatLng latLng) async {
    if (commonPlaceController.getPosition?.value == GetPoistion.pin) {
      locationName.value = locationValue;
      pickupDetails.value = pickupValue;
      target.value = latLng;
      target.refresh();
      markers.add(
        Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
              color: AppColor.kPrimaryColor.value,
            ))),
      );
      markers.refresh();
      commonPlaceController.pickUpLatLng.value = latLng;
      commonPlaceController.pickUpLatLng.refresh();
      // getAddressFromLatLng(latLng);
      setTarget(getTarget: latLng);
    } else {
      locationName.value = locationValue;
      pickupDetails.value = pickupValue;
      target.value = latLng;
      target.refresh();
      markers.add(
        Marker(
            markerId: MarkerId(latLng.toString()),
            position: latLng,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
              color: AppColor.kRedColour.value,
            ))),
      );
      markers.refresh();
      commonPlaceController.dropLatLng.value = latLng;
      commonPlaceController.dropLatLng.refresh();
      // getAddressFromLatLng(latLng);
      setTarget(getTarget: latLng);
    }
    //mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  getAddressFromLatLng(LatLng newLatLng) async {
    try {
      // Fetch place information using coordinates
      List<Placemark> placeMarks = await placemarkFromCoordinates(
          newLatLng.latitude, newLatLng.longitude);

      if (placeMarks.isEmpty) return;

      final placeMark = placeMarks.first;

      // Check if the location is outside UAE
      /*if (placeMark.country != "United Arab Emirates") {
        // Update flag to indicate location is outside UAE
        isOutsideUAE.value = true;

        // Display latitude and longitude only
        final latLngAddress =
            "[${newLatLng.latitude.toStringAsFixed(4)}, ${newLatLng.longitude.toStringAsFixed(4)}]";
        if (commonPlaceController.getPosition?.value == GetPoistion.pin) {
          commonPlaceController.pickUpLocation.value = latLngAddress;
          commonPlaceController.pickUpSubtitle.value = "";
        } else {
          commonPlaceController.dropLocation.value = latLngAddress;
          commonPlaceController.dropSubtitle.value = ""; // No address subtitle
        }
      } else {*/
        // Update flag to indicate location is inside UAE
        isOutsideUAE.value = false;

        final address =
            "${placeMark.name}, ${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";

        final title = placeMark.name ?? "Unknown Location";
        final subtitle =
            "${placeMark.locality}, ${placeMark.administrativeArea}, ${placeMark.country}";

        addAddressLocation.value = title;
        addAddressSubtitle.value = subtitle;
        addAddressLocation.refresh();
        addAddressSubtitle.refresh();
      // }

      mapLocationLoader.value = false;
    } catch (e) {
      mapLocationLoader.value = false;
      printLogs('error --> $e');
    }
  }

  Future<void> setSelectedPrediction(Prediction prediction) async {
    // Set target location after fetching details
    if (commonPlaceController.getPosition?.value == GetPoistion.pin) {
      selectedPrediction.value = prediction;
      locationName.value = prediction.structuredFormatting?.mainText ?? "";
      pickupDetails.value = prediction.description ?? "";

      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId ?? '');
      final latLng = LatLng(
        detail.result.geometry?.location.lat ?? 0.0,
        detail.result.geometry?.location.lng ?? 0.0,
      );

      markers.add(
        Marker(
            markerId: MarkerId(prediction.placeId ?? ''),
            position: latLng,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
              color: AppColor.kPrimaryColor.value,
            ))),
      );
      markers.refresh();

      // setTarget(getTarget: latLng);
    } else {
      selectedPrediction.value = prediction;
      locationName.value = prediction.structuredFormatting?.mainText ?? "";
      pickupDetails.value = prediction.description ?? "";

      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(prediction.placeId ?? '');
      final latLng = LatLng(
        detail.result.geometry?.location.lat ?? 0.0,
        detail.result.geometry?.location.lng ?? 0.0,
      );

      markers.add(
        Marker(
            markerId: MarkerId(prediction.placeId ?? ''),
            position: latLng,
            icon: await getWidgetMarker(
                widget: pickDropMarker(
              color: AppColor.kPrimaryColor.value,
            ))),
      );
      markers.refresh();

      // setTarget(getTarget: latLng);
    }
  }

  callSaveLocationApi1(
      {String? sId = "",
      bool? isFavorites = false,
      int? requestType = 1,
      int? placeType = 4,
      String? placeTypeName = "Others",
      String? houseNo = "",
      String? landmark = "",
      double? latitude,
      double? longitude}) {
    isLoading.value = true;
    saveLocationResponseStatus.value.status = 0;
    saveLocationResponseStatus.refresh();
    saveLocationApi(SaveLocationRequestData(
            sId: sId,
            passengerId: 9/*int.tryParse(userInfo.value?.rslId ?? '')*/,
            placeType: placeType,
            placeTypeName: placeTypeName,
            houseNo: houseNo,
            landmark: landmark,
            requestType: requestType,
            latitude: target.value.latitude,
            longitude: target.value.longitude,
            name: locationNameController.text,
            address: pickupDetails.value,
            isFavorites: isFavorites,
            locationDetails: null))
        .then((value) {
      if (value.status == 1) {
        isLoading.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        locationNameController.text = '';
        citySelectionController.getUserInfo();
        if (requestType == 2) {
          getUserInfo();
        }
        if (placeType == 3) {
          getUserInfo();
          // Get.toNamed(NewAppRoutes.saveAddressListPage);
        } else {
          Get.back();
          Get.snackbar('', '${value.message}');
        }
      } else {
        isLoading.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        printLogs("Hii saveLocation api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii saveLocation api error catch : $error ** ${stackTrace.toString()}");
      isLoading.value = false;
      saveLocationResponseStatus.value.status = 400;
      saveLocationResponseStatus.value.message = "something_went_wrong".tr;
      saveLocationResponseStatus.refresh();
    });
  }
  var locationNameError = ''.obs; // Observable for validation error message

  void validateAndSaveLocation({bool? isFavorites = false}) {
    if (locationNameController.text.trim().isEmpty) {
      locationNameError.value = "Location name cannot be empty";
    } else {
      locationNameError.value = "";
      callSaveLocationApi1(isFavorites: true);
    }
  }

  callSaveLocationApi(
      {String? sId = "",
      bool? isFavorites = false,
      int? requestType = 1,
      int? placeType = 4,
      String? placeTypeName = "Others",
      String? houseNo = "",
      String? landmark = "",
      double? latitude,
      double? longitude,
      String? buildingName,
      String? villaNo}) {
    isLoading.value = true;
    saveLocationResponseStatus.value.status = 0;
    saveLocationResponseStatus.refresh();
    LocationDetails? locationDetails;
    if (placeTypeName == "Villa") {
      locationDetails = LocationDetails(
          villaNo: villaNo ?? "",
          area: area.value,
          street: streetName.value,
          additionalDetails: additional.value);
    } else if (placeTypeName == "Apartment") {
      locationDetails = LocationDetails(
          apartmentNo: apartmentNo.value,
          buildingName: buildingName,
          floorNo: int.tryParse(floorNo.value) ?? 0,
          additionalDetails: additional.value,
          area: area.value,
          street: streetName.value);
    } else if (placeTypeName == "Office") {
      locationDetails = LocationDetails(
          buildingName: buildingName,
          floorNo: int.tryParse(apartmentNo.value) ?? 0,
          area: area.value,
          street: streetName.value,
          additionalDetails: additional.value,
          officeName: buildingName);
    } else {
      locationDetails = LocationDetails(
        buildingName: buildingName,
        villaNo: villaNo ?? buildingName,
        unitNo: int.tryParse(apartmentNo.value) ?? 0,
        area: area.value,
        street: streetName.value,
        additionalDetails: additional.value,
      );
    }

    saveLocationApi(SaveLocationRequestData(
            sId: sId,
            passengerId: 9/*int.tryParse(userInfo.value?.rslId ?? '')*/,
            placeType: placeType,
            placeTypeName: placeTypeName,
            houseNo: houseNo,
            landmark: landmark,
            requestType: requestType,
            latitude: latitude ?? target.value.latitude,
            longitude: latitude ?? target.value.longitude,
            name: placeType == 3 ? nickNameController.text : "",
            address: placeType == 3
                ? commonPlaceController.currentAddress.value
                : "",
            isFavorites: isFavorites,
            locationDetails: locationDetails))
        .then((value) {
      if (value.status == 1) {
        isLoading.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        locationNameController.text = '';
        citySelectionController.getUserInfo();
        if (requestType == 2) {
          getUserInfo();
          Get.back();
        }
        if (placeType == 3) {
          clearAllValues();
          getUserInfo();
          // Get.toNamed(NewAppRoutes.saveAddressListPage);
        } else {
          Get.back();
          Get.snackbar('', '${value.message}');
        }
      } else {
        isLoading.value = false;
        saveLocationResponseStatus.value.status = value.status;
        saveLocationResponseStatus.value.message = value.message;
        saveLocationResponseStatus.refresh();
        printLogs("Hii saveLocation api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii saveLocation api error catch : $error ** ${stackTrace.toString()}");
      isLoading.value = false;
      saveLocationResponseStatus.value.status = 400;
      saveLocationResponseStatus.value.message = "something_went_wrong".tr;
      saveLocationResponseStatus.refresh();
    });
  }

  callSaveLocationListApi() {
    saveLocationListResponseStatus.value.status = 0;
    saveLocationListResponseStatus.refresh();
    saveLocationListApi(SaveLocationListRequestData(
            passengerId: int.tryParse(userInfo.value?.rslId ?? "")))
        .then((value) {
      if (value.status == 1) {
        saveLocationListResponseStatus.value.status = value.status;
        saveLocationListResponseStatus.value.message = value.message;
        saveLocationListResponseStatus.refresh();
        locationList.value = value.details?.locationList ?? [];
        locationList.refresh();
      } else {
        saveLocationListResponseStatus.value.status = value.status;
        saveLocationListResponseStatus.value.message = value.message;
        saveLocationListResponseStatus.refresh();
        printLogs("Hii saveLocationList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii saveLocationList api error catch : $error ** ${stackTrace.toString()}");
      saveLocationResponseStatus.value.status = 400;
      saveLocationResponseStatus.value.message = "something_went_wrong".tr;
      saveLocationResponseStatus.refresh();
    });
  }

  void clearAllValues() {
    // Clear all TextEditingController values
    nickNameController.clear();
    apartmentNoController.clear();
    floorNoController.clear();
    buildingNameController.clear();
    buildingNoController.clear();
    areaController.clear();
    streetNameController.clear();
    additionalController.clear();

    // Reset all observable values
    nickName.value = '';
    apartmentNo.value = '';
    floorNo.value = '';
    buildingName.value = '';
    buildingNo.value = '';
    area.value = '';
    streetName.value = '';
    additional.value = '';

    // Optionally, reset form keys if needed
    apartmentFormKey.currentState?.reset();
    villaFormKey.currentState?.reset();
    officeFormKey.currentState?.reset();
    othersFormKey.currentState?.reset();
  }
}
