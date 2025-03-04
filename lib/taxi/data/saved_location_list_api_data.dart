import 'dart:convert';

class SaveLocationListRequestData {
  int? passengerId;

  SaveLocationListRequestData({this.passengerId});

  SaveLocationListRequestData.fromJson(Map<String, dynamic> json) {
    passengerId = json['passengerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passengerId'] = passengerId;
    return data;
  }
}

class SaveLocationListResponseData {
  int? status;
  String? message;
  Details? details;

  SaveLocationListResponseData({this.status, this.message, this.details});

  SaveLocationListResponseData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    details = json['details'] != null ? Details.fromJson(json['details']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (details != null) {
      data['details'] = details!.toJson();
    }
    return data;
  }
}

class Details {
  List<LocationList>? locationList;

  Details({this.locationList});

  Details.fromJson(Map<String, dynamic> json) {
    if (json['locationList'] != null) {
      locationList = <LocationList>[];
      json['locationList'].forEach((v) { locationList!.add(LocationList.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (locationList != null) {
      data['locationList'] = locationList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationList {
  String? sId;
  String? name;
  String? address;
  String? houseNo;
  String? landmark;
  String? placeTypeName;
  num? latitude;
  num? longitude;
  num? placeType;
  num? passengerId;
  Details? details;
  String? createdDate;
  String? lastUpdatedDate;

  LocationList({this.sId, this.name, this.address, this.houseNo, this.landmark, this.placeTypeName, this.latitude, this.longitude, this.placeType, this.passengerId, this.details, this.createdDate, this.lastUpdatedDate});

  LocationList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    address = json['address'];
    houseNo = json['houseNo'];
    landmark = json['landmark'];
    placeTypeName = json['placeTypeName'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    placeType = json['placeType'];
    passengerId = json['passengerId'];
    details = json['details'] != null ? Details.fromJson(json['details']) : null;
    createdDate = json['createdDate'];
    lastUpdatedDate = json['lastUpdatedDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    data['address'] = address;
    data['houseNo'] = houseNo;
    data['landmark'] = landmark;
    data['placeTypeName'] = placeTypeName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['placeType'] = placeType;
    data['passengerId'] = passengerId;
    if (details != null) {
      data['details'] = details!.toJson();
    }
    data['createdDate'] = createdDate;
    data['lastUpdatedDate'] = lastUpdatedDate;
    return data;
  }
}


SaveLocationListResponseData saveLocationListResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return SaveLocationListResponseData.fromJson(jsonData);
}

saveLocationListRequestToJson(SaveLocationListRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}