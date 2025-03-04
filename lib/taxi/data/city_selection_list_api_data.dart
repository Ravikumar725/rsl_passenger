import 'dart:convert';

class CountryCityListResponseData {
  int? status;
  String? message;
  ResponseData? responseData;

  CountryCityListResponseData({this.status, this.message, this.responseData});

  CountryCityListResponseData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    responseData = json['responseData'] != null
        ? ResponseData.fromJson(json['responseData'])
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
  List<CountryCityList>? countryCityList;

  ResponseData({this.countryCityList});

  ResponseData.fromJson(Map<String, dynamic> json) {
    if (json['countryCityList'] != null) {
      countryCityList = <CountryCityList>[];
      json['countryCityList'].forEach((v) {
        countryCityList!.add(CountryCityList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (countryCityList != null) {
      data['countryCityList'] =
          countryCityList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CountryCityList {
  String? name;
  num? latitude;
  num? longitude;
  String? countryCode;
  List<City>? city;

  CountryCityList({this.name, this.latitude, this.longitude,this.countryCode, this.city});

  CountryCityList.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    countryCode = json['countryCode'];
    if (json['city'] != null) {
      city = <City>[];
      json['city'].forEach((v) {
        city!.add(City.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['countryCode'] = countryCode;
    if (city != null) {
      data['city'] = city!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class City {
  String? name;
  num? latitude;
  num? longitude;

  City({this.name, this.latitude, this.longitude});

  City.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}



CountryCityListResponseData countryCityListResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return CountryCityListResponseData.fromJson(jsonData);
}
