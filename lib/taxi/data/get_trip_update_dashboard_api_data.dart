import 'dart:convert';

class GetTripUpdateDashRequestData {
  String? requestType;
  String? tripId;
  int? passengerId;

  GetTripUpdateDashRequestData(
      {this.requestType, this.tripId, this.passengerId});

  GetTripUpdateDashRequestData.fromJson(Map<String, dynamic> json) {
    requestType = json['request_type'];
    tripId = json['trip_id'];
    passengerId = json['passenger_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['request_type'] = requestType;
    data['trip_id'] = tripId;
    data['passenger_id'] = passengerId;
    return data;
  }
}

class GetTripUpdateDashResponseData {
  String? message;
  GetTripUpdate? detail;
  num? isSplitFare;
  int? discountApplied;
  String? isFirstTrip;
  String? tripId;
  num? tripSpeed;
  num? driverLatitute;
  num? driverLongtitute;
  int? status;
  int? display;
  String? authKey;

  GetTripUpdateDashResponseData(
      {this.message,
      this.detail,
      this.isSplitFare,
      this.discountApplied,
      this.tripId,
      this.tripSpeed,
      this.driverLatitute,
      this.driverLongtitute,
      this.status,
      this.isFirstTrip,
      this.display,
      this.authKey});

  GetTripUpdateDashResponseData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    if (json["detail"] is Map<String, dynamic>) {
      detail = GetTripUpdate.fromJson(
          json["detail"]); // Properly convert to Detail object
    } else {
      detail = null; // Assign null if 'detail' is not a map
    }
    isFirstTrip = json['is_first_trip'];
    discountApplied = json['discountApplied'];
    isSplitFare = json['isSplit_fare'];
    tripId = json['trip_id'];
    tripSpeed = json['trip_speed'];
    driverLatitute = json['driver_latitute'];
    driverLongtitute = json['driver_longtitute'];
    status = json['status'];
    display = json['display'];
    authKey = json['auth_key'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    if (detail != null && detail is Map<String, dynamic>) {
      data['detail'] = detail;
    } else {
      data['detail'] = {}; // Assign an empty map if detail is null or not a map
    }
    data['is_first_trip'] = isFirstTrip;
    data['discountApplied'] = discountApplied;
    data['isSplit_fare'] = isSplitFare;
    data['trip_id'] = tripId;
    data['trip_speed'] = tripSpeed;
    data['driver_latitute'] = driverLatitute;
    data['driver_longtitute'] = driverLongtitute;
    data['status'] = status;
    data['display'] = display;
    data['auth_key'] = authKey;
    return data;
  }
}

class GetTripUpdate {
  String? tripId;
  String? travelStatusMessage;
  String? pickupDateTime;
  int? bookingCreated;
  Driverdetails? driverdetails;

  GetTripUpdate(
      {this.tripId,
      this.driverdetails,
      this.travelStatusMessage,
      this.pickupDateTime,
      this.bookingCreated});

  GetTripUpdate.fromJson(Map<String, dynamic> json) {
    tripId = json['trip_id'];
    driverdetails = json['driverdetails'] != null
        ? Driverdetails.fromJson(json['driverdetails'])
        : null;
    travelStatusMessage = json['travel_status_message'];
    pickupDateTime = json['pickup_date_time'];
    bookingCreated = json['booking_created'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['trip_id'] = tripId;
    if (driverdetails != null) {
      data['driverdetails'] = driverdetails!.toJson();
    }
    data['travel_status_message'] = travelStatusMessage;
    data['pickup_date_time'] = pickupDateTime;
    data['booking_created'] = bookingCreated;
    return data;
  }
}

class Driverdetails {
  int? driverId;
  String? driverName;
  String? driverPhone;
  String? driverEmail;
  int? travelStatus;
  String? dropTime;
  String? pickupTime;
  String? driverCompanyName;
  MotorModelInfo? motorModelInfo;
  TaxiInfo? taxiInfo;
  String? pickupLocation;
  num? pickupLatitude;
  num? pickupLongitude;
  String? dropLocation;
  num? dropLatitude;
  num? dropLongitude;
  num? currentLatitude;
  num? currentLongitude;

  Driverdetails(
      {this.driverId,
      this.driverName,
      this.driverPhone,
      this.driverEmail,
      this.travelStatus,
      this.dropTime,
      this.pickupTime,
      this.driverCompanyName,
      this.motorModelInfo,
      this.taxiInfo,
      this.pickupLocation,
      this.pickupLatitude,
      this.pickupLongitude,
      this.dropLocation,
      this.dropLatitude,
      this.dropLongitude,
      this.currentLatitude,
      this.currentLongitude});

  Driverdetails.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'];
    driverName = json['driver_name'];
    driverPhone = json['driver_phone'];
    driverEmail = json['driver_email'];
    travelStatus = json['travel_status'];
    dropTime = json['drop_time'];
    pickupTime = json['pickup_time'];
    driverCompanyName = json['driver_company_name'];
    motorModelInfo = json['motor_model_info'] != null
        ? MotorModelInfo.fromJson(json['motor_model_info'])
        : null;
    taxiInfo =
        json['taxi_info'] != null ? TaxiInfo.fromJson(json['taxi_info']) : null;
    pickupLocation = json['pickup_location'];
    pickupLatitude = json['pickup_latitude'];
    pickupLongitude = json['pickup_longitude'];
    dropLocation = json['drop_location'];
    dropLatitude = json['drop_latitude'];
    dropLongitude = json['drop_longitude'];
    currentLatitude = json['current_latitude'];
    currentLongitude = json['current_longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driver_id'] = driverId;
    data['driver_name'] = driverName;
    data['driver_phone'] = driverPhone;
    data['driver_email'] = driverEmail;
    data['travel_status'] = travelStatus;
    data['drop_time'] = dropTime;
    data['pickup_time'] = pickupTime;
    data['driver_company_name'] = driverCompanyName;
    if (motorModelInfo != null) {
      data['motor_model_info'] = motorModelInfo!.toJson();
    }
    if (taxiInfo != null) {
      data['taxi_info'] = taxiInfo!.toJson();
    }
    data['pickup_location'] = pickupLocation;
    data['pickup_latitude'] = pickupLatitude;
    data['pickup_longitude'] = pickupLongitude;
    data['drop_location'] = dropLocation;
    data['drop_latitude'] = dropLatitude;
    data['drop_longitude'] = dropLongitude;
    data['current_latitude'] = currentLatitude;
    data['current_longitude'] = currentLongitude;
    return data;
  }
}

class MotorModelInfo {
  int? modelId;
  String? modelName;
  num? cancellationFare;
  num? minFare;
  num? taxiMinSpeed;
  num? taxiSpeed;

  MotorModelInfo(
      {this.modelId,
      this.modelName,
      this.cancellationFare,
      this.minFare,
      this.taxiMinSpeed,
      this.taxiSpeed});

  MotorModelInfo.fromJson(Map<String, dynamic> json) {
    modelId = json['model_id'];
    modelName = json['model_name'];
    cancellationFare = json['cancellation_fare'];
    minFare = json['min_fare'];
    taxiMinSpeed = json['taxi_min_speed'];
    taxiSpeed = json['taxi_speed'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['model_id'] = modelId;
    data['model_name'] = modelName;
    data['cancellation_fare'] = cancellationFare;
    data['min_fare'] = minFare;
    data['taxi_min_speed'] = taxiMinSpeed;
    data['taxi_speed'] = taxiSpeed;
    return data;
  }
}

class TaxiInfo {
  String? taxiId;
  String? taxiName;
  String? taxiNo;
  String? taxiUnique;
  String? taxiManufacturer;
  String? taxiImage;

  TaxiInfo(
      {this.taxiId,
      this.taxiName,
      this.taxiNo,
      this.taxiUnique,
      this.taxiManufacturer,
      this.taxiImage});

  TaxiInfo.fromJson(Map<String, dynamic> json) {
    taxiId = json['taxi_id'].toString();
    taxiName = json['taxi_name'];
    taxiNo = json['taxi_no'];
    taxiUnique = json['taxi_unique'];
    taxiManufacturer = json['taxi_manufacturer'];
    taxiImage = json['taxi_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['taxi_id'] = taxiId;
    data['taxi_name'] = taxiName;
    data['taxi_no'] = taxiNo;
    data['taxi_unique'] = taxiUnique;
    data['taxi_manufacturer'] = taxiManufacturer;
    data['taxi_image'] = taxiImage;
    return data;
  }
}

GetTripUpdateDashResponseData getTripUpdateDashResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return GetTripUpdateDashResponseData.fromJson(jsonData);
}

getTripUpdateDashRequestToJson(GetTripUpdateDashRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
