import 'dart:convert';

import 'known_location_list_api_data.dart';

class KnownLocationPickupRequestData {
  int? passengerId;
  int? type;
  CountryInfo? cityInfo;

  KnownLocationPickupRequestData({this.passengerId, this.type, this.cityInfo});

  KnownLocationPickupRequestData.fromJson(Map<String, dynamic> json) {
    passengerId = json['passengerId'];
    type = json['type'];
    cityInfo = json['cityInfo'] != null
        ? CountryInfo.fromJson(json['cityInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passengerId'] = passengerId;
    data['type'] = type;
    if (cityInfo != null) {
      data['cityInfo'] = cityInfo!.toJson();
    }
    return data;
  }
}

class KnownLocationPickupResponseData {
  int? status;
  String? message;
  ResponseData? responseData;

  KnownLocationPickupResponseData(
      {this.status, this.message, this.responseData});

  KnownLocationPickupResponseData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    responseData = json['responseData'] != null
        ? new ResponseData.fromJson(json['responseData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (responseData != null) {
      data['responseData'] = responseData!.toJson();
    }
    return data;
  }
}

class ResponseData {
  List<LocationsList>? locations;

  ResponseData({this.locations});

  ResponseData.fromJson(Map<String, dynamic> json) {
    if (json['locations'] != null) {
      locations = <LocationsList>[];
      json['locations'].forEach((v) {
        locations!.add(new LocationsList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (locations != null) {
      data['locations'] = locations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationsList {
  String? locationName;
  String? address;
  num? latitude;
  num? longitude;
  String? categoryName;

  LocationsList(
      {this.locationName,
      this.address,
      this.latitude,
      this.longitude,
      this.categoryName});

  LocationsList.fromJson(Map<String, dynamic> json) {
    locationName = json['locationName'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    categoryName = json['categoryName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['locationName'] = locationName;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['categoryName'] = categoryName;
    return data;
  }
}

KnownLocationPickupResponseData knownLocationPickupResponseFromJson(
    String str) {
  final jsonData = json.decode(str);
  return KnownLocationPickupResponseData.fromJson(jsonData);
}

knownLocationPickupRequestToJson(KnownLocationPickupRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
