import 'dart:convert';

import 'get_trip_update_dashboard_api_data.dart';


class GetTripUpdateRequestData {
  String? userId;
  String? requestType;
  String? tripId;
  String? phone;
  String? countryCode;
  String? name;
  String? email;
  int? type;

  GetTripUpdateRequestData({
    this.userId,
    this.requestType,
    this.tripId,
    this.countryCode,
    this.email,
    this.name,
    this.phone,
    this.type,
  });

  GetTripUpdateRequestData.fromJson(Map<String, dynamic> json) {
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

class GetTripUpdateResponseData {
  String? message;
  num? fare;
  String? tripId;
  String? pickup;
  int? status;
  num? display;
  String? driverStatus;
  num? tripSpeed;
  num? driverLatitute;
  num? driverLongtitute;
  String? paymentType;
  num? baseFare;
  num? waitingFare;
  num? nightfare;
  num? eveningfare;
  num? paidAmount;
  num? promotion;
  num? tax;
  num? usedWalletAmount;
  String? minutesTraveled;
  num? minutesFare;
  num? distance;
  num? tripfare;
  num? tollFare;
  String? companyName;
  String? companyLogo;
  num? pastTripsCancellationFare;
  String? actual;
  String? isFirstTrip;
  String? eventRideCount;
  String? pickupDateTime;
  String? receiptUrl;
  num? distanceFare;
  num? subTotal;
  String? finalDistanceFare;
  String? finalWaitingFare;
  String? finalNightfare;
  String? finalEveningfare;
  String? finalTollFare;
  String? finalPastTripsCancellationFare;
  String? finalSubtotal;
  String? finalTotal;
  String? finalPromocodeFare;
  String? finalUsedWalletAmount;
  String? displayPickupDateTime;
  String? finalCash;
  String? finalCard;
  String? authKey;
  int? discountApplied;

  GetTripUpdateResponseData(
      {this.message,
      this.fare,
      this.tripId,
      this.pickup,
      this.status,
      this.display,
      this.driverStatus,
      this.tripSpeed,
      this.driverLatitute,
      this.driverLongtitute,
      this.paymentType,
      this.baseFare,
      this.waitingFare,
      this.nightfare,
      this.eveningfare,
      this.paidAmount,
      this.promotion,
      this.tax,
      this.usedWalletAmount,
      this.minutesTraveled,
      this.minutesFare,
      this.distance,
      this.tripfare,
      this.tollFare,
      this.companyName,
      this.companyLogo,
      this.pastTripsCancellationFare,
      this.actual,
      this.isFirstTrip,
      this.eventRideCount,
      this.pickupDateTime,
      this.receiptUrl,
      this.distanceFare,
      this.subTotal,
      this.finalDistanceFare,
      this.finalWaitingFare,
      this.finalNightfare,
      this.finalEveningfare,
      this.finalTollFare,
      this.finalPastTripsCancellationFare,
      this.finalSubtotal,
      this.finalTotal,
      this.finalPromocodeFare,
      this.finalUsedWalletAmount,
      this.displayPickupDateTime,
      this.finalCash,
      this.finalCard,
      this.authKey,
      this.discountApplied});

  GetTripUpdateResponseData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    fare = json['fare'];
    tripId = json['trip_id'];
    pickup = json['pickup'];
    status = json['status'];
    display = json['display'];
    driverStatus = json['driver_status'];
    tripSpeed = json['trip_speed'];
    driverLatitute = json['driver_latitute'];
    driverLongtitute = json['driver_longtitute'];
    paymentType = json['payment_type'];
    baseFare = json['base_fare'];
    waitingFare = json['waiting_fare'];
    nightfare = json['nightfare'];
    eveningfare = json['eveningfare'];
    paidAmount = json['paid_amount'];
    promotion = json['promotion'];
    tax = json['tax'];
    usedWalletAmount = json['used_wallet_amount'];
    minutesTraveled = json['minutes_traveled'];
    minutesFare = json['minutes_fare'];
    distance = json['distance'];
    tripfare = json['tripfare'];
    tollFare = json['toll_fare'];
    companyName = json['company_name'];
    companyLogo = json['company_logo'];
    pastTripsCancellationFare = json['past_trips_cancellation_fare'];
    actual = json['actual'];
    isFirstTrip = json['is_first_trip'];
    eventRideCount = json['event_ride_count'];
    pickupDateTime = json['pickup_date_time'];
    receiptUrl = json['receipt_url'];
    distanceFare = json['distance_fare'];
    subTotal = json['sub_total'];
    finalDistanceFare = json['final_distance_fare'];
    finalWaitingFare = json['final_waiting_fare'];
    finalNightfare = json['final_nightfare'];
    finalEveningfare = json['final_eveningfare'];
    finalTollFare = json['final_toll_fare'];
    finalPastTripsCancellationFare = json['final_past_trips_cancellation_fare'];
    finalSubtotal = json['final_subtotal'];
    finalTotal = json['final_total'];
    finalPromocodeFare = json['final_promocode_fare'];
    finalUsedWalletAmount = json['final_used_wallet_amount'];
    displayPickupDateTime = json['display_pickup_date_time'];
    finalCash = json['final_cash'];
    finalCard = json['final_card'];
    authKey = json['auth_key'];
    discountApplied = json['discount_applied'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['fare'] = fare;
    data['trip_id'] = tripId;
    data['pickup'] = pickup;
    data['status'] = status;
    data['display'] = display;
    data['driver_status'] = driverStatus;
    data['trip_speed'] = tripSpeed;
    data['driver_latitute'] = driverLatitute;
    data['driver_longtitute'] = driverLongtitute;
    data['payment_type'] = paymentType;
    data['base_fare'] = baseFare;
    data['waiting_fare'] = waitingFare;
    data['nightfare'] = nightfare;
    data['eveningfare'] = eveningfare;
    data['paid_amount'] = paidAmount;
    data['promotion'] = promotion;
    data['tax'] = tax;
    data['used_wallet_amount'] = usedWalletAmount;
    data['minutes_traveled'] = minutesTraveled;
    data['minutes_fare'] = minutesFare;
    data['distance'] = distance;
    data['tripfare'] = tripfare;
    data['toll_fare'] = tollFare;
    data['company_name'] = companyName;
    data['company_logo'] = companyLogo;
    data['past_trips_cancellation_fare'] = pastTripsCancellationFare;
    data['actual'] = actual;
    data['is_first_trip'] = isFirstTrip;
    data['event_ride_count'] = eventRideCount;
    data['pickup_date_time'] = pickupDateTime;
    data['receipt_url'] = receiptUrl;
    data['distance_fare'] = distanceFare;
    data['sub_total'] = subTotal;
    data['final_distance_fare'] = finalDistanceFare;
    data['final_waiting_fare'] = finalWaitingFare;
    data['final_nightfare'] = finalNightfare;
    data['final_eveningfare'] = finalEveningfare;
    data['final_toll_fare'] = finalTollFare;
    data['final_past_trips_cancellation_fare'] = finalPastTripsCancellationFare;
    data['final_subtotal'] = finalSubtotal;
    data['final_total'] = finalTotal;
    data['final_promocode_fare'] = finalPromocodeFare;
    data['final_used_wallet_amount'] = finalUsedWalletAmount;
    data['display_pickup_date_time'] = displayPickupDateTime;
    data['final_cash'] = finalCash;
    data['final_card'] = finalCard;
    data['auth_key'] = authKey;
    data['discount_applied'] = discountApplied;
    return data;
  }
}

GetTripUpdateDashResponseData getTripUpdateResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return GetTripUpdateDashResponseData.fromJson(jsonData);
}

String getTripUpdateRequestToJson(GetTripUpdateRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

GetTripUpdateResponseData getTripUpdateResponseFromJsonOld(String str) {
  final jsonData = json.decode(str);
  return GetTripUpdateResponseData.fromJson(jsonData);
}
