import 'dart:convert';

class SaveBookingRequestData {
  String? phone;
  String? countryCode;
  String? name;
  String? email;
  int? type;
  String? approxDistance;
  double? approxDuration;
  String? approxTripFare;
  String? cityname;
  int? distanceAway;
  double? dropLatitude;
  double? dropLongitude;
  String? dropMakani;
  String? userId;
  String? dropNotes;
  String? dropplace;
  int? favDriverBookingType;

  // String? friendId1;
  int? friendId2;
  int? friendId3;
  int? friendId4;
  int? friendPercentage1;
  int? friendPercentage2;
  int? friendPercentage3;
  int? friendPercentage4;
  String? guestName;
  String? guestPhone;
  String? isGuestBooking;
  double? latitude;
  double? longitude;
  String? modelWaitingFare;
  String? motorModel;
  String? notes;
  String? nowAfter;
  String? passengerAppVersion;

  // String? passengerId;
  int? passengerPaymentOption;
  String? paymentMode;
  String? pickupplace;
  String? pickupMakani;
  String? pickupNotes;
  String? pickupTime;
  String? promoCode;
  String? requestType;
  String? subLogid;

  // String? mobile;
  String? routePolyline;
  String? priceHike;
  String? packageId;
  String? packageType;
  int? oneTimeDiscountApplied;
  int? oneTimeDiscountPercentage;

  SaveBookingRequestData(
      {this.approxDistance,
      this.approxDuration,
      this.approxTripFare,
      this.userId,
      this.cityname,
      this.distanceAway,
      this.dropLatitude,
      this.dropLongitude,
      this.dropMakani,
      this.dropNotes,
      this.dropplace,
      this.favDriverBookingType,
      // this.friendId1,
      this.friendId2,
      this.friendId3,
      this.friendId4,
      this.friendPercentage1,
      this.friendPercentage2,
      this.friendPercentage3,
      this.friendPercentage4,
      this.guestName,
      this.guestPhone,
      this.isGuestBooking,
      this.latitude,
      this.longitude,
      this.modelWaitingFare,
      this.motorModel,
      this.notes,
      this.nowAfter,
      this.passengerAppVersion,
      // this.passengerId,
      this.passengerPaymentOption,
      this.paymentMode,
      this.pickupplace,
      this.pickupMakani,
      this.pickupNotes,
      this.pickupTime,
      this.promoCode,
      this.requestType,
      this.countryCode,
      // this.mobile,
      this.subLogid,
      this.routePolyline,
      this.email,
      this.name,
      this.phone,
      this.type,
      this.priceHike,
      this.packageId,
      this.packageType,
      this.oneTimeDiscountApplied,
      this.oneTimeDiscountPercentage});

  SaveBookingRequestData.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    name = json['name'];
    phone = json['phone'];
    type = json['type'];
    approxDistance = json['approx_distance'];
    approxDuration = json['approx_duration'];
    approxTripFare = json['approx_trip_fare'];
    cityname = json['cityname'];
    distanceAway = json['distance_away'];
    dropLatitude = json['drop_latitude'];
    dropLongitude = json['drop_longitude'];
    dropMakani = json['drop_makani'];
    dropNotes = json['drop_notes'];
    dropplace = json['dropplace'];
    favDriverBookingType = json['fav_driver_booking_type'];
    userId = json['userId'];
    //friendId1 = json['friend_id1'];
    friendId2 = json['friend_id2'];
    friendId3 = json['friend_id3'];
    friendId4 = json['friend_id4'];
    friendPercentage1 = json['friend_percentage1'];
    friendPercentage2 = json['friend_percentage2'];
    friendPercentage3 = json['friend_percentage3'];
    friendPercentage4 = json['friend_percentage4'];
    guestName = json['guest_name'];
    guestPhone = json['guest_phone'];
    isGuestBooking = json['is_guest_booking'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    modelWaitingFare = json['model_waiting_fare'];
    motorModel = json['motor_model'];
    notes = json['notes'];
    nowAfter = json['now_after'];
    passengerAppVersion = json['passenger_app_version'];
    // passengerId = json['passenger_id'];
    passengerPaymentOption = json['passenger_payment_option'];
    paymentMode = json['payment_mode'];
    pickupplace = json['pickupplace'];
    pickupMakani = json['pickup_makani'];
    pickupNotes = json['pickup_notes'];
    pickupTime = json['pickup_time'];
    promoCode = json['promo_code'];
    requestType = json['request_type'];
    // mobile = json['mobile'];
    countryCode = json['countryCode'];
    subLogid = json['sub_logid'];
    routePolyline = json['route_polyline'];
    priceHike = json['price_hike'];
    packageId = json['package_id'];
    packageType = json['package_type'];
    oneTimeDiscountApplied = json['one_time_discount_applied'];
    oneTimeDiscountPercentage = json['one_time_discount_percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['name'] = name;
    data['phone'] = phone;
    data['type'] = type;

    data['approx_distance'] = approxDistance;
    data['approx_duration'] = approxDuration;
    data['approx_trip_fare'] = approxTripFare;
    data['cityname'] = cityname;
    data['distance_away'] = distanceAway;
    data['userId'] = userId;
    data['drop_latitude'] = dropLatitude;
    data['drop_longitude'] = dropLongitude;
    data['drop_makani'] = dropMakani;
    data['drop_notes'] = dropNotes;
    data['dropplace'] = dropplace;
    data['fav_driver_booking_type'] = favDriverBookingType;
    // data['friend_id1'] = this.friendId1;
    data['friend_id2'] = friendId2;
    data['friend_id3'] = friendId3;
    data['friend_id4'] = friendId4;
    data['friend_percentage1'] = friendPercentage1;
    data['friend_percentage2'] = friendPercentage2;
    data['friend_percentage3'] = friendPercentage3;
    data['friend_percentage4'] = friendPercentage4;
    data['guest_name'] = guestName;
    data['guest_phone'] = guestPhone;
    data['is_guest_booking'] = isGuestBooking;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['model_waiting_fare'] = modelWaitingFare;
    data['motor_model'] = motorModel;
    data['notes'] = notes;
    data['now_after'] = nowAfter;
    data['passenger_app_version'] = passengerAppVersion;
    // data['passenger_id'] = this.passengerId;
    data['passenger_payment_option'] = passengerPaymentOption;
    data['payment_mode'] = paymentMode;
    data['pickupplace'] = pickupplace;
    data['pickup_makani'] = pickupMakani;
    data['pickup_notes'] = pickupNotes;
    data['pickup_time'] = pickupTime;
    data['promo_code'] = promoCode;
    data['request_type'] = requestType;
    // data['mobile'] = this.mobile;
    data['countryCode'] = countryCode;
    data['sub_logid'] = subLogid;
    data['route_polyline'] = routePolyline;
    data['price_hike'] = priceHike;
    data['package_id'] = packageId;
    data['package_type'] = packageType;
    data['one_time_discount_applied'] = oneTimeDiscountApplied;
    data['one_time_discount_percentage'] = oneTimeDiscountPercentage;
    return data;
  }
}

class SaveBookingResponseData {
  String? message;
  String? contactNumber;
  int? status;
  Detail? detail;
  String? authKey;

  SaveBookingResponseData(
      {this.message,
      this.contactNumber,
      this.status,
      this.detail,
      this.authKey});

  SaveBookingResponseData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    contactNumber = json['contactNumber'];
    status = json['status'];
    detail =
        json['detail'] != null ? new Detail.fromJson(json['detail']) : null;
    authKey = json['auth_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['contactNumber'] = contactNumber;
    data['status'] = status;
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    data['auth_key'] = authKey;
    return data;
  }
}

class Detail {
  int? passengerTripId;
  String? notificationTime;
  String? totalRequestTime;
  dynamic creditCardStatus;
  String? contactNumber;

  Detail(
      {this.passengerTripId,
      this.notificationTime,
      this.totalRequestTime,
      this.creditCardStatus,
      this.contactNumber});

  Detail.fromJson(Map<String, dynamic> json) {
    passengerTripId = json['passenger_tripid'];
    notificationTime = json['notification_time'];
    totalRequestTime = '${json['total_request_time']}';
    creditCardStatus = json['credit_card_status'];
    contactNumber = json['contactNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passenger_tripid'] = passengerTripId;
    data['notification_time'] = notificationTime;
    data['total_request_time'] = totalRequestTime;
    data['credit_card_status'] = creditCardStatus;
    data['contactNumber'] = contactNumber;
    return data;
  }
}

SaveBookingResponseData saveBookingResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return SaveBookingResponseData.fromJson(jsonData);
}

String saveBookingRequestToJson(SaveBookingRequestData data) {
  final dyn = data.toJson();
  print("SAVE BOOKING REQUEST : ${dyn.toString()}");
  return json.encode(dyn);
}
