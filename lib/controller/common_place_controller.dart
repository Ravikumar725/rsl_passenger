import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../network/services.dart';
import '../taxi/data/booking_details_api_data.dart';
import '../taxi/data/nearest_drivers_list_api_data.dart';
import '../widget/utils/enums.dart';

class CommonPlaceController extends GetxController {
  var currentAddress = ''.obs;
  var currentLatLng = const LatLng(0, 0).obs;
  var pickUpLatLng = const LatLng(0, 0).obs;
  var dropLatLng = const LatLng(0, 0).obs;
  var dropLocation = ''.obs;
  var dropSubtitle = ''.obs;
  var pickUpLocation = ''.obs;
  var pickUpSubtitle = ''.obs;
  var laterBookingDateTime = ''.obs;
  var hourlyBookingDateTime = ''.obs;
  var tripId = ''.obs;
  Rx<GetPoistion>? getPosition = GetPoistion.pin.obs;
  RxBool ratingLoader = false.obs;
  RxDouble rating = 0.0.obs;
  var ratingText = ''.obs;
  RxList<String> impressText =
      ['On time pickup', 'Quick response', 'Smooth ride'].obs;
  var selectedIndex = 0.obs;

  TextEditingController comments = TextEditingController();
  RxBool isClockClicked = false.obs;
  RxBool isQuickChatClicked = false.obs;
  RxBool isCarClicked = false.obs;
  var pageType = 1.obs;

  Rx<BookingDetailsResponseData>? BookingDetailResponse =
      BookingDetailsResponseData().obs;
  RxList<CarModelData> carModelList = <CarModelData>[].obs;

  void updateTextForRating(double rating) {
    ratingText.value = getTextForRating(rating);
  }

  void selectIndex(int index) {
    selectedIndex.value = index;
  }

  String getTextForRating(double rating) {
    if (rating == 1) {
      return 'Very bad';
    } else if (rating == 2) {
      return 'Bad';
    } else if (rating == 3) {
      return 'Average';
    } else if (rating == 4) {
      return 'Good';
    } else if (rating == 5) {
      return 'Love it';
    } else {
      return '';
    }
  }

  void updateRating(double newRating) {
    rating.value = newRating;
  }

  void toggleRatingLoader() {
    ratingLoader.toggle();
  }

  @override
  void onClose() {
    laterBookingDateTime.value = '';
    dropLatLng = const LatLng(0, 0).obs;
    dropLocation = ''.obs;
    printLogs("Common Controller clered Later booking,drop & latlng");
    super.onClose();
  }

  clear() {
    pickUpLatLng.value = const LatLng(0.0, 0.0);
    dropLatLng.value = const LatLng(0.0, 0.0);
    pickUpLocation.value = "";
    dropLocation.value = "";
  }

  setBookLaterDateTime({DateTime? dateTime}) {
    if (dateTime == null) {
      laterBookingDateTime.value = '';
    } else {
      laterBookingDateTime.value = getFormattedDateTime(dateTime);
      //Get.back();
    }
  }

  String getFormattedDateTime(DateTime dateTime,
      {String format = 'yyyy-MM-dd hh:mm:ss aaa'}) {
    try {
      final formatter = DateFormat(format);
      return formatter.format(dateTime);
    } catch (e) {
      return '';
    }
  }
}