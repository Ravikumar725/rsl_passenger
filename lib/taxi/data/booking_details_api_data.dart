import 'dart:convert';

class BookingDetailsRequestData {
  String? tripId;
  String? userId;
  String? phone;
  String? countryCode;
  String? name;
  String? email;
  int? type;
  String? requestType;

  BookingDetailsRequestData(
      {this.userId,
      this.requestType,
      this.tripId,
      this.countryCode,
      this.email,
      this.name,
      this.phone,
      this.type});

  BookingDetailsRequestData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    requestType = json['request_type'];
    tripId = json['trip_id'];
    phone = json['phone'];
    countryCode = json['countryCode'];
    name = json['name'];
    email = json['email'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['request_type'] = requestType;
    data['trip_id'] = tripId;
    data['phone'] = phone;

    data['countryCode'] = countryCode;
    data['name'] = name;
    data['email'] = email;
    data['type'] = type;
    return data;
  }
}

class BookingDetailsResponseData {
  String? message;
  Detail? detail;
  int? status;
  String? siteCurrency;
  String? authKey;

  BookingDetailsResponseData(
      {this.message,
      this.detail,
      this.status,
      this.siteCurrency,
      this.authKey});

  BookingDetailsResponseData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    detail = json['detail'] != null ? Detail.fromJson(json['detail']) : null;
    status = json['status'];
    siteCurrency = json['site_currency'];
    authKey = json['auth_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (detail != null) {
      data['detail'] = detail!.toJson();
    }
    data['status'] = status;
    data['site_currency'] = siteCurrency;
    data['auth_key'] = authKey;
    return data;
  }
}

class Detail {
  String? companyLogo;
  String? travelStatusLabel;
  String? showPopup;
  String? popupContents;
  String? companyName;
  String? taxiMinSpeed;
  String? tripSpeed;
  String? tripId;
  String? currentLocation;
  String? pickupLatitude;
  String? pickupLongitude;
  String? dropLocation;
  String? dropLatitude;
  String? dropLongitude;
  String? isMultiDrop;
  String? dropLocation2;
  String? dropLatitude2;
  String? dropLongitude2;
  String? dropLocation3;
  String? dropLatitude3;
  String? dropLongitude3;
  String? dropLocation4;
  String? dropLatitude4;
  String? dropLongitude4;
  String? dropTime;
  String? pickupDateTime;
  String? displayPickupDateTime;
  String? pickupTime;
  String? bookingTime;
  String? timeToReachPassen;
  String? noPassengers;
  String? rating;
  String? notes;
  String? pickupNotes;
  String? dropNotes;
  String? flightNumber;
  String? referenceNumber;
  String? driverName;
  String? driverId;
  String? driverReply;
  String? modelWaitingTime;
  String? modelName;
  String? freeCancellationTime;
  String? freeWaitingTime;
  String? remainingFreeCancellationTime;
  String? remainingFreeWaitingTime;
  String? pastTripsCancellationFare;
  String? finalPastTripsCancellationFare;
  String? taxiId;
  String? taxiNumber;
  String? driverPhone;
  String? passengerPhone;
  String? passengerName;
  String? travelStatus;
  String? bookedby;
  String? streetPickupTrip;
  String? waitingTime;
  String? modelWaitingFareMinute;
  String? waitingDistance;
  String? waitingFare;
  String? finalWaitingFare;
  String? distance;
  String? actualDistance;
  String? metric;
  String? promocodeFare;
  String? finalPromocodeFare;
  String? usedWalletAmount;
  String? finalUsedWalletAmount;
  String? amt;
  String? distanceFare;
  String? finalDistanceFare;
  String? actualPaidAmount;
  String? jobRef;
  String? paymentType;
  String? fareCalculationType;
  String? paymentTypeLabel;
  String? taxiSpeed;
  String? waitingFareHour;
  String? farePerMinute;
  String? subtotal;
  String? minutesFare;
  String? baseFare;
  String? distanceFareMetric;
  String? tripMinutes;
  String? eveningfare;
  String? nightfare;
  String? finalEveningfare;
  String? finalNightfare;
  String? taxPercentage;
  String? taxFare;
  String? isSplitFare;
  String? isGuestBooking;
  String? guestName;
  String? guestPhone;
  String? guideDriver;
  String? bookingtype;
  String? tollFare;
  String? finalTollFare;
  String? surcharge;
  String? finalSubtotal;
  String? finalTotal;
  String? finalCash;
  String? finalCard;
  String? packageType;
  String? packageId;
  String? inprogressWaitingTime;
  String? passengerChatId;
  String? driverChatId;
  String? passengerChatLogin;
  String? driverChatLogin;
  String? routePolyline;
  String? creditCardStatus;
  bool? isPrimary;
  String? tripDuration;
  String? mapImage;
  String? driverImage;
  String? passengerImage;
  String? driverLongtitute;
  String? driverLatitute;
  String? driverStatus;
  String? driverRating;
  String? approxFare;
  String? approxDistance;
  String? approxDuration;
  String? callUsNumber;
  String? receiptUrl;

  Detail(
      {this.companyLogo,
      this.travelStatusLabel,
      this.showPopup,
      this.popupContents,
      this.companyName,
      this.taxiMinSpeed,
      this.tripSpeed,
      this.tripId,
      this.currentLocation,
      this.pickupLatitude,
      this.pickupLongitude,
      this.dropLocation,
      this.dropLatitude,
      this.dropLongitude,
      this.isMultiDrop,
      this.dropLocation2,
      this.dropLatitude2,
      this.dropLongitude2,
      this.dropLocation3,
      this.dropLatitude3,
      this.dropLongitude3,
      this.dropLocation4,
      this.dropLatitude4,
      this.dropLongitude4,
      this.dropTime,
      this.pickupDateTime,
      this.displayPickupDateTime,
      this.pickupTime,
      this.bookingTime,
      this.timeToReachPassen,
      this.noPassengers,
      this.rating,
      this.notes,
      this.pickupNotes,
      this.dropNotes,
      this.flightNumber,
      this.referenceNumber,
      this.driverName,
      this.driverId,
      this.driverReply,
      this.modelWaitingTime,
      this.modelName,
      this.freeCancellationTime,
      this.freeWaitingTime,
      this.remainingFreeCancellationTime,
      this.remainingFreeWaitingTime,
      this.pastTripsCancellationFare,
      this.finalPastTripsCancellationFare,
      this.taxiId,
      this.taxiNumber,
      this.driverPhone,
      this.passengerPhone,
      this.passengerName,
      this.travelStatus,
      this.bookedby,
      this.streetPickupTrip,
      this.waitingTime,
      this.modelWaitingFareMinute,
      this.waitingDistance,
      this.waitingFare,
      this.finalWaitingFare,
      this.distance,
      this.actualDistance,
      this.metric,
      this.promocodeFare,
      this.finalPromocodeFare,
      this.usedWalletAmount,
      this.finalUsedWalletAmount,
      this.amt,
      this.distanceFare,
      this.finalDistanceFare,
      this.actualPaidAmount,
      this.jobRef,
      this.paymentType,
      this.fareCalculationType,
      this.paymentTypeLabel,
      this.taxiSpeed,
      this.waitingFareHour,
      this.farePerMinute,
      this.subtotal,
      this.minutesFare,
      this.baseFare,
      this.distanceFareMetric,
      this.tripMinutes,
      this.eveningfare,
      this.nightfare,
      this.finalEveningfare,
      this.finalNightfare,
      this.taxPercentage,
      this.taxFare,
      this.isSplitFare,
      this.isGuestBooking,
      this.guestName,
      this.guestPhone,
      this.guideDriver,
      this.bookingtype,
      this.tollFare,
      this.finalTollFare,
      this.surcharge,
      this.finalSubtotal,
      this.finalTotal,
      this.finalCash,
      this.finalCard,
      this.packageType,
      this.packageId,
      this.inprogressWaitingTime,
      this.passengerChatId,
      this.driverChatId,
      this.passengerChatLogin,
      this.driverChatLogin,
      this.routePolyline,
      this.creditCardStatus,
      this.isPrimary,
      this.tripDuration,
      this.mapImage,
      this.driverImage,
      this.passengerImage,
      this.driverLongtitute,
      this.driverLatitute,
      this.driverStatus,
      this.driverRating,
      this.approxFare,
      this.approxDistance,
      this.approxDuration,
      this.callUsNumber,
      this.receiptUrl});

  Detail.fromJson(Map<String, dynamic> json) {
    travelStatusLabel = json['travel_status_label'].toString();
    companyLogo = json['company_logo'].toString();
    showPopup = json['show_popup'].toString();
    popupContents = json['popup_contents'].toString();
    companyName = json['company_name'].toString();
    taxiMinSpeed = json['taxi_min_speed'].toString();
    tripSpeed = json['trip_speed'].toString();
    tripId = json['trip_id'].toString();
    currentLocation = json['current_location'].toString();
    pickupLatitude = json['pickup_latitude'].toString();
    pickupLongitude = json['pickup_longitude'].toString();
    dropLocation = json['drop_location'].toString();
    dropLatitude = json['drop_latitude'].toString();
    dropLongitude = json['drop_longitude'].toString();
    isMultiDrop = json['is_multi_drop'].toString();
    dropLocation2 = json['drop_location_2'].toString();
    dropLatitude2 = json['drop_latitude_2'].toString();
    dropLongitude2 = json['drop_longitude_2'].toString();
    dropLocation3 = json['drop_location_3'].toString();
    dropLatitude3 = json['drop_latitude_3'].toString();
    dropLongitude3 = json['drop_longitude_3'].toString();
    dropLocation4 = json['drop_location_4'].toString();
    dropLatitude4 = json['drop_latitude_4'].toString();
    dropLongitude4 = json['drop_longitude_4'].toString();
    dropTime = json['drop_time'].toString();
    pickupDateTime = json['pickup_date_time'].toString();
    displayPickupDateTime = json['display_pickup_date_time'].toString();
    pickupTime = json['pickup_time'].toString();
    bookingTime = json['booking_time'].toString();
    timeToReachPassen = json['time_to_reach_passen'].toString();
    noPassengers = json['no_passengers'].toString();
    rating = json['rating'].toString();
    notes = json['notes'].toString();
    pickupNotes = json['pickup_notes'].toString();
    dropNotes = json['drop_notes'].toString();
    flightNumber = json['flight_number'].toString();
    referenceNumber = json['reference_number'].toString();
    driverName = json['driver_name'].toString();
    driverId = json['driver_id'].toString();
    driverReply = json['driver_reply'].toString();
    modelWaitingTime = json['model_waiting_time'].toString();
    modelName = json['model_name'].toString();
    freeCancellationTime = json['free_cancellation_time'].toString();
    freeWaitingTime = json['free_waiting_time'].toString();
    remainingFreeCancellationTime =
        json['remaining_free_cancellation_time'].toString();
    remainingFreeWaitingTime = json['remaining_free_waiting_time'].toString();
    pastTripsCancellationFare = json['past_trips_cancellation_fare'].toString();
    finalPastTripsCancellationFare =
        json['final_past_trips_cancellation_fare'].toString();
    taxiId = json['taxi_id'].toString();
    taxiNumber = json['taxi_number'].toString();
    driverPhone = json['driver_phone'].toString();
    passengerPhone = json['passenger_phone'].toString();
    passengerName = json['passenger_name'].toString();
    travelStatus = json['travel_status'].toString();
    bookedby = json['bookedby'].toString();
    streetPickupTrip = json['street_pickup_trip'].toString();
    waitingTime = json['waiting_time'].toString();
    modelWaitingFareMinute = json['model_waiting_fare_minute'].toString();
    waitingDistance = json['waiting_distance'].toString();
    waitingFare = json['waiting_fare'].toString();
    finalWaitingFare = json['final_waiting_fare'].toString();
    distance = json['distance'].toString();
    actualDistance = json['actual_distance'].toString();
    metric = json['metric'].toString();
    promocodeFare = json['promocode_fare'].toString();
    finalPromocodeFare = json['final_promocode_fare'].toString();
    usedWalletAmount = json['used_wallet_amount'].toString();
    finalUsedWalletAmount = json['final_used_wallet_amount'].toString();
    amt = json['amt'].toString();
    distanceFare = json['distance_fare'].toString();
    finalDistanceFare = json['final_distance_fare'].toString();
    actualPaidAmount = json['actual_paid_amount'].toString();
    jobRef = json['job_ref'].toString();
    paymentType = json['payment_type'].toString();
    fareCalculationType = json['fare_calculation_type'].toString();
    paymentTypeLabel = json['payment_type_label'].toString();
    taxiSpeed = json['taxi_speed'].toString();
    waitingFareHour = json['waiting_fare_hour'].toString();
    farePerMinute = json['fare_per_minute'].toString();
    subtotal = json['subtotal'].toString();
    minutesFare = json['minutes_fare'].toString();
    baseFare = json['base_fare'].toString();
    distanceFareMetric = json['distance_fare_metric'].toString();
    tripMinutes = json['trip_minutes'].toString();
    eveningfare = json['eveningfare'].toString();
    nightfare = json['nightfare'].toString();
    finalEveningfare = json['final_eveningfare'].toString();
    finalNightfare = json['final_nightfare'].toString();
    taxPercentage = json['tax_percentage'].toString();
    taxFare = json['tax_fare'].toString();
    isSplitFare = json['isSplit_fare'].toString();
    isGuestBooking = json['is_guest_booking'].toString();
    guestName = json['guest_name'].toString();
    guestPhone = json['guest_phone'].toString();
    guideDriver = json['guide_driver'].toString();
    bookingtype = json['bookingtype'].toString();
    tollFare = json['toll_fare'].toString();
    finalTollFare = json['final_toll_fare'].toString();
    surcharge = json['surcharge'].toString();
    finalSubtotal = json['final_subtotal'].toString();
    finalTotal = json['final_total'].toString();
    finalCash = json['final_cash'].toString();
    finalCard = json['final_card'].toString();
    packageType = json['package_type'].toString();
    packageId = json['package_id'].toString();
    inprogressWaitingTime = json['inprogress_waiting_time'].toString();
    passengerChatId = json['passenger_chat_id'].toString();
    driverChatId = json['driver_chat_id'].toString();
    passengerChatLogin = json['passenger_chat_login'].toString();
    driverChatLogin = json['driver_chat_login'].toString();
    routePolyline = json['route_polyline'].toString();
    creditCardStatus = json['credit_card_status'].toString();
    isPrimary = json['is_primary'];
    tripDuration = json['trip_duration'].toString();
    mapImage = json['map_image'].toString();
    driverImage = json['driver_image'].toString();
    passengerImage = json['passenger_image'].toString();
    driverLongtitute = json['driver_longtitute'].toString();
    driverLatitute = json['driver_latitute'].toString();
    driverStatus = json['driver_status'].toString();
    driverRating = json['driver_rating'].toString();
    approxFare = json['approx_fare'].toString();
    approxDistance = json['approx_distance'].toString();
    approxDuration = json['approx_duration'].toString();
    callUsNumber = json['call_us_number'].toString();
    receiptUrl = json['receiptUrl'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_logo'] = companyLogo;
    data['travel_status_label'] = travelStatusLabel;
    data['show_popup'] = showPopup;
    data['popup_contents'] = popupContents;
    data['company_name'] = companyName;
    data['taxi_min_speed'] = taxiMinSpeed;
    data['trip_speed'] = tripSpeed;
    data['trip_id'] = tripId;
    data['current_location'] = currentLocation;
    data['pickup_latitude'] = pickupLatitude;
    data['pickup_longitude'] = pickupLongitude;
    data['drop_location'] = dropLocation;
    data['drop_latitude'] = dropLatitude;
    data['drop_longitude'] = dropLongitude;
    data['is_multi_drop'] = isMultiDrop;
    data['drop_location_2'] = dropLocation2;
    data['drop_latitude_2'] = dropLatitude2;
    data['drop_longitude_2'] = dropLongitude2;
    data['drop_location_3'] = dropLocation3;
    data['drop_latitude_3'] = dropLatitude3;
    data['drop_longitude_3'] = dropLongitude3;
    data['drop_location_4'] = dropLocation4;
    data['drop_latitude_4'] = dropLatitude4;
    data['drop_longitude_4'] = dropLongitude4;
    data['drop_time'] = dropTime;
    data['pickup_date_time'] = pickupDateTime;
    data['display_pickup_date_time'] = displayPickupDateTime;
    data['pickup_time'] = pickupTime;
    data['booking_time'] = bookingTime;
    data['time_to_reach_passen'] = timeToReachPassen;
    data['no_passengers'] = noPassengers;
    data['rating'] = rating;
    data['notes'] = notes;
    data['pickup_notes'] = pickupNotes;
    data['drop_notes'] = dropNotes;
    data['flight_number'] = flightNumber;
    data['reference_number'] = referenceNumber;
    data['driver_name'] = driverName;
    data['driver_id'] = driverId;
    data['driver_reply'] = driverReply;
    data['model_waiting_time'] = modelWaitingTime;
    data['model_name'] = modelName;
    data['free_cancellation_time'] = freeCancellationTime;
    data['free_waiting_time'] = freeWaitingTime;
    data['remaining_free_cancellation_time'] = remainingFreeCancellationTime;
    data['remaining_free_waiting_time'] = remainingFreeWaitingTime;
    data['past_trips_cancellation_fare'] = pastTripsCancellationFare;
    data['final_past_trips_cancellation_fare'] = finalPastTripsCancellationFare;
    data['taxi_id'] = taxiId;
    data['taxi_number'] = taxiNumber;
    data['driver_phone'] = driverPhone;
    data['passenger_phone'] = passengerPhone;
    data['passenger_name'] = passengerName;
    data['travel_status'] = travelStatus;
    data['bookedby'] = bookedby;
    data['street_pickup_trip'] = streetPickupTrip;
    data['waiting_time'] = waitingTime;
    data['model_waiting_fare_minute'] = modelWaitingFareMinute;
    data['waiting_distance'] = waitingDistance;
    data['waiting_fare'] = waitingFare;
    data['final_waiting_fare'] = finalWaitingFare;
    data['distance'] = distance;
    data['actual_distance'] = actualDistance;
    data['metric'] = metric;
    data['promocode_fare'] = promocodeFare;
    data['final_promocode_fare'] = finalPromocodeFare;
    data['used_wallet_amount'] = usedWalletAmount;
    data['final_used_wallet_amount'] = finalUsedWalletAmount;
    data['amt'] = amt;
    data['distance_fare'] = distanceFare;
    data['final_distance_fare'] = finalDistanceFare;
    data['actual_paid_amount'] = actualPaidAmount;
    data['job_ref'] = jobRef;
    data['payment_type'] = paymentType;
    data['fare_calculation_type'] = fareCalculationType;
    data['payment_type_label'] = paymentTypeLabel;
    data['taxi_speed'] = taxiSpeed;
    data['waiting_fare_hour'] = waitingFareHour;
    data['fare_per_minute'] = farePerMinute;
    data['subtotal'] = subtotal;
    data['minutes_fare'] = minutesFare;
    data['base_fare'] = baseFare;
    data['distance_fare_metric'] = distanceFareMetric;
    data['trip_minutes'] = tripMinutes;
    data['eveningfare'] = eveningfare;
    data['nightfare'] = nightfare;
    data['final_eveningfare'] = finalEveningfare;
    data['final_nightfare'] = finalNightfare;
    data['tax_percentage'] = taxPercentage;
    data['tax_fare'] = taxFare;
    data['isSplit_fare'] = isSplitFare;
    data['is_guest_booking'] = isGuestBooking;
    data['guest_name'] = guestName;
    data['guest_phone'] = guestPhone;
    data['guide_driver'] = guideDriver;
    data['bookingtype'] = bookingtype;
    data['toll_fare'] = tollFare;
    data['final_toll_fare'] = finalTollFare;
    data['surcharge'] = surcharge;
    data['final_subtotal'] = finalSubtotal;
    data['final_total'] = finalTotal;
    data['final_cash'] = finalCash;
    data['final_card'] = finalCard;
    data['package_type'] = packageType;
    data['package_id'] = packageId;
    data['inprogress_waiting_time'] = inprogressWaitingTime;
    data['passenger_chat_id'] = passengerChatId;
    data['driver_chat_id'] = driverChatId;
    data['passenger_chat_login'] = passengerChatLogin;
    data['driver_chat_login'] = driverChatLogin;
    data['route_polyline'] = routePolyline;
    data['credit_card_status'] = creditCardStatus;
    data['is_primary'] = isPrimary;
    data['trip_duration'] = tripDuration;
    data['map_image'] = mapImage;
    data['driver_image'] = driverImage;
    data['passenger_image'] = passengerImage;
    data['driver_longtitute'] = driverLongtitute;
    data['driver_latitute'] = driverLatitute;
    data['driver_status'] = driverStatus;
    data['driver_rating'] = driverRating;
    data['approx_fare'] = approxFare;
    data['approx_distance'] = approxDistance;
    data['approx_duration'] = approxDuration;
    data['call_us_number'] = callUsNumber;
    data['receiptUrl'] = receiptUrl;
    return data;
  }
}

BookingDetailsResponseData bookingDetailsResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return BookingDetailsResponseData.fromJson(jsonData);
}

String bookingDetailsRequestToJson(BookingDetailsRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
