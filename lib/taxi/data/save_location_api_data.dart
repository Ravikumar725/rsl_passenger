import 'dart:convert';

class SaveLocationRequestData {
  String? sId;
  int? passengerId;
  String? name;
  String? address;
  String? houseNo;
  String? landmark;
  int? placeType;
  String? placeTypeName;
  double? latitude;
  double? longitude;
  LocationDetails? locationDetails;
  int? requestType;
  bool? isFavorites;

  SaveLocationRequestData(
      {this.sId,
      this.passengerId,
      this.name,
      this.address,
      this.houseNo,
      this.landmark,
      this.placeType,
      this.placeTypeName,
      this.latitude,
      this.longitude,
      this.locationDetails,
      this.requestType,
      this.isFavorites});

  SaveLocationRequestData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    passengerId = json['passengerId'];
    name = json['name'];
    address = json['address'];
    houseNo = json['houseNo'];
    landmark = json['landmark'];
    placeType = json['placeType'];
    placeTypeName = json['placeTypeName'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    locationDetails = json['details'] != null
        ? LocationDetails.fromJson(json['details'])
        : null;
    requestType = json['requestType'];
    isFavorites = json['isFavorites'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['passengerId'] = passengerId;
    data['name'] = name;
    data['address'] = address;
    data['houseNo'] = houseNo;
    data['landmark'] = landmark;
    data['placeType'] = placeType;
    data['placeTypeName'] = placeTypeName;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    if (locationDetails != null) {
      data['details'] = locationDetails!.toJson();
    }
    data['requestType'] = requestType;
    data['isFavorites'] = isFavorites;
    return data;
  }
}


class LocationDetails {
  String? buildingName;
  num? unitNo;
  String? street;
  String? area;
  String? additionalDetails;
  String? apartmentNo;
  num? floorNo;
  String? villaNo;
  String? officeName;

  LocationDetails(
      {this.buildingName,
      this.unitNo,
      this.street,
      this.area,
      this.additionalDetails,
      this.apartmentNo,
      this.floorNo,
      this.villaNo,this.officeName});

  LocationDetails.fromJson(Map<String, dynamic> json) {
    buildingName = json['buildingName'];
    unitNo = json['unitNo'];
    street = json['street'];
    area = json['area'];
    additionalDetails = json['additionalDetails'];
    apartmentNo = json['apartmentNo'];
    floorNo = json['floorNo'];
    villaNo = json['villaNo'];
    officeName = json['officeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (buildingName != null) data['buildingName'] = buildingName;
    if (unitNo != null) data['unitNo'] = unitNo;
    if (street != null) data['street'] = street;
    if (area != null) data['area'] = area;
    if (additionalDetails != null) data['additionalDetails'] = additionalDetails;
    if (apartmentNo != null) data['apartmentNo'] = apartmentNo;
    if (floorNo != null) data['floorNo'] = floorNo;
    if (villaNo != null) data['villaNo'] = villaNo;
    if (officeName != null) data['officeName'] = officeName;
    /*data['buildingName'] = buildingName;
    data['unitNo'] = unitNo;
    data['street'] = street;
    data['area'] = area;
    data['additionalDetails'] = additionalDetails;
    data['apartmentNo'] = apartmentNo;
    data['floorNo'] = floorNo;
    data['villaNo'] = villaNo;*/
    return data;
  }
}

class SaveLocationResponseData {
  int? status;
  String? message;
  String? accessToken;
  String? locationId;

  SaveLocationResponseData(
      {this.status, this.message, this.accessToken, this.locationId});

  SaveLocationResponseData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    accessToken = json['accessToken'];
    locationId = json['locationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    data['accessToken'] = accessToken;
    data['locationId'] = locationId;
    return data;
  }
}

SaveLocationResponseData saveLocationResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return SaveLocationResponseData.fromJson(jsonData);
}

saveLocationRequestToJson(SaveLocationRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
