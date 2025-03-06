import 'dart:convert';

class NearestDriversListRequestData {
  String? skipFav;
  String? passengerAppVersion;
  String? longitude;
  String? motorModel;
  String? dropLat;
  String? address;
  String? cityName;
  String? passengerId;
  String? placeId;
  String? latitude;
  String? dropLng;
  String? routePolyline;

  NearestDriversListRequestData(
      {this.skipFav,
      this.passengerAppVersion,
      this.longitude,
      this.motorModel,
      this.dropLat,
      this.address,
      this.cityName,
      this.passengerId,
      this.placeId,
      this.latitude,
      this.dropLng,
      this.routePolyline});

  NearestDriversListRequestData.fromJson(Map<String, dynamic> json) {
    skipFav = json['skip_fav'];
    passengerAppVersion = json['passenger_app_version'];
    longitude = json['longitude'];
    motorModel = json['motor_model'];
    dropLat = json['dropLat'];
    address = json['address'];
    cityName = json['city_name'];
    passengerId = json['passenger_id'];
    placeId = json['place_id'];
    latitude = json['latitude'];
    dropLng = json['dropLng'];
    routePolyline = json['route_polyline'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['skip_fav'] = skipFav;
    data['passenger_app_version'] = passengerAppVersion;
    data['longitude'] = longitude;
    data['motor_model'] = motorModel;
    data['dropLat'] = dropLat;
    data['address'] = address;
    data['city_name'] = cityName;
    data['passenger_id'] = passengerId;
    data['place_id'] = placeId;
    data['latitude'] = latitude;
    data['dropLng'] = dropLng;
    data['route_polyline'] = routePolyline;
    return data;
  }
}

class NearestDriversListResponseData {
  int? driverAroundMiles;
  List<CarModelData>? fareDetails;
  List<DriverDetail>? detail;
  String? message;
  String? metric;
  int? status;

  NearestDriversListResponseData(
      {this.driverAroundMiles,
      this.fareDetails,
      this.message,
      this.metric,
      this.status});

  NearestDriversListResponseData.fromJson(Map<String, dynamic> json) {
    driverAroundMiles = json['driver_around_miles'];
    if (json['fare_details'] != null) {
      fareDetails = <CarModelData>[];
      json['fare_details'].forEach((v) {
        fareDetails!.add(CarModelData.fromJson(v));
      });
    }
    if (json['detail'] != null) {
      detail = <DriverDetail>[];
      json['detail'].forEach((v) {
        detail!.add(DriverDetail.fromJson(v));
      });
    }
    message = json['message'];
    metric = json['metric'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driver_around_miles'] = driverAroundMiles;
    if (fareDetails != null) {
      data['fare_details'] = fareDetails!.map((v) => v.toJson()).toList();
    }
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    data['metric'] = metric;
    data['status'] = status;
    return data;
  }
}

class CarModelData {
  int? modelId;
  String? modelName;
  int? modelSize;
  int? modelMid;
  num? baseFare;
  num? waitingFare;
  int? waitingTimeSpeed;
  int? minKm;
  num? minFare;
  int? belowAboveKm;
  num? belowKm;
  num? aboveKm;
  num? nightFare;
  int? nightCharge;
  int? eveningCharge;
  String? eveningTimingFrom;
  String? eveningTimingTo;
  String? nightTimingFrom;
  String? nightTimingTo;
  num? eveningFare;
  int? waitingTime;
  num? minutesFare;
  String? description;
  String? metric;
  int? taxiSpeed;
  int? fareCalculationType;
  //List<dynamic>? nextModels;
  num? additionalFare;
  String? alertShortDescription;
  String? alertLongDescription;
  String? priceHike;
  num? tollFare;
  int? fullDay;
  int? halfDay;
  bool? isSelected;
  String? image;
  num? approximateFare;
  num? approximateFareWithWaitingFare;
  bool? isPromoApplied = false;
  String? originalFare;
  String? fareRange;
  String? focusImage;
  String? unfocusImage;

  CarModelData({
    this.modelId,
    this.modelName,
    this.modelSize,
    this.modelMid,
    this.baseFare,
    this.waitingFare,
    this.waitingTimeSpeed,
    this.minKm,
    this.minFare,
    this.belowAboveKm,
    this.belowKm,
    this.aboveKm,
    this.nightFare,
    this.nightCharge,
    this.eveningCharge,
    this.eveningTimingFrom,
    this.eveningTimingTo,
    this.nightTimingFrom,
    this.nightTimingTo,
    this.eveningFare,
    this.waitingTime,
    this.minutesFare,
    this.description,
    this.metric,
    this.taxiSpeed,
    this.fareCalculationType,
   // this.nextModels,
    this.additionalFare,
    this.alertShortDescription,
    this.alertLongDescription,
    this.priceHike,
    this.tollFare,
    this.fullDay,
    this.halfDay,
    this.isSelected,
    this.image,
    this.approximateFare,
    this.approximateFareWithWaitingFare,
    this.isPromoApplied,
    this.originalFare,
    this.fareRange,
    this.focusImage,
    this.unfocusImage
  });

  CarModelData.fromJson(Map<String, dynamic> json) {
    modelId = json['model_id'];
    modelName = json['model_name'];
    modelSize = json['model_size'];
    modelMid = json['model_mid'];
    baseFare = json['base_fare'];
    waitingFare = json['waiting_time'];
    waitingTimeSpeed = json['waitingTimeSpeed'];
    minKm = json['min_km'];
    minFare = json['min_fare'];
    belowAboveKm = json['below_above_km'];
    belowKm = json['below_km'];
    aboveKm = json['above_km'];
    nightFare = json['night_fare'];
    nightCharge = json['night_charge'];
    eveningCharge = json['evening_charge'];
    eveningTimingFrom = json['evening_timing_from'];
    eveningTimingTo = json['evening_timing_to'];
    nightTimingFrom = json['night_timing_from'];
    nightTimingTo = json['night_timing_to'];
    eveningFare = json['evening_fare'];
    waitingTime = json['waiting_time'];
    minutesFare = json['minutes_fare'];
    description = json['description'];
    metric = json['metric'];
    taxiSpeed = json['taxi_speed'];
    fareCalculationType = json['fare_calculation_type'];
    //nextModels = json['next_models'].cast<dynamic>();
    additionalFare = json['additional_fare'];
    alertShortDescription = json['alert_short_description'];
    alertLongDescription = json['alert_long_description'];
    priceHike = json['price_hike'];
    tollFare = json['tollFare'];
    fullDay = json['full_day'];
    halfDay = json['half_day'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['model_id'] = modelId;
    data['model_name'] = modelName;
    data['model_size'] = modelSize;
    data['model_mid'] = modelMid;
    data['base_fare'] = baseFare;
    data['waiting_time'] = waitingFare;
    data['waitingTimeSpeed'] = waitingTimeSpeed;
    data['min_km'] = minKm;
    data['min_fare'] = minFare;
    data['below_above_km'] = belowAboveKm;
    data['below_km'] = belowKm;
    data['above_km'] = aboveKm;
    data['night_fare'] = nightFare;
    data['night_charge'] = nightCharge;
    data['evening_charge'] = eveningCharge;
    data['evening_timing_from'] = eveningTimingFrom;
    data['evening_timing_to'] = eveningTimingTo;
    data['night_timing_from'] = nightTimingFrom;
    data['night_timing_to'] = nightTimingTo;
    data['evening_fare'] = eveningFare;
    data['waiting_time'] = waitingTime;
    data['minutes_fare'] = minutesFare;
    data['description'] = description;
    data['metric'] = metric;
    data['taxi_speed'] = taxiSpeed;
    data['fare_calculation_type'] = fareCalculationType;
   // data['next_models'] = this.nextModels;
    data['additional_fare'] = additionalFare;
    data['alert_short_description'] = alertShortDescription;
    data['alert_long_description'] = alertLongDescription;
    data['price_hike'] = priceHike;
    data['tollFare'] = tollFare;
    data['full_day'] = fullDay;
    data['half_day'] = halfDay;
    return data;
  }
}

class DriverDetail {
  int? driverId;
  int? distanceKm;
  double? latitude;
  double? longitude;
  int? taxiModel;
  int? taxiId;

  DriverDetail({
    this.driverId,
    this.distanceKm,
    this.latitude,
    this.longitude,
    this.taxiModel,
    this.taxiId,
  });

  DriverDetail.fromJson(Map<String, dynamic> json) {
    driverId = json['driver_id'];
    distanceKm = json['distance_km'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    taxiModel = json['taxi_model'];
    taxiId = json['taxi_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['driver_id'] = driverId;
    data['distance_km'] = distanceKm;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['taxi_model'] = taxiModel;
    data['taxi_id'] = taxiId;
    return data;
  }
}

NearestDriversListResponseData nearestDriversListResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return NearestDriversListResponseData.fromJson(jsonData);
}

String nearestDriversListRequestToJson(NearestDriversListRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
