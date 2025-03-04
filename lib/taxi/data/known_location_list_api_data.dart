import 'dart:convert';

class KnownLocationByCityRequestData {
  int? passengerId;
  int? type;
  CountryInfo? countryInfo;
  CountryInfo? cityInfo;

  KnownLocationByCityRequestData({this.passengerId,this.type, this.countryInfo, this.cityInfo});

  KnownLocationByCityRequestData.fromJson(Map<String, dynamic> json) {
    passengerId = json['passengerId'];
    type = json['type'];
    countryInfo = json['countryInfo'] != null
        ? CountryInfo.fromJson(json['countryInfo'])
        : null;
    cityInfo = json['cityInfo'] != null
        ? CountryInfo.fromJson(json['cityInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passengerId'] = passengerId;
    data['type'] = type;
    if (countryInfo != null) {
      data['countryInfo'] = countryInfo!.toJson();
    }
    if (cityInfo != null) {
      data['cityInfo'] = cityInfo!.toJson();
    }
    return data;
  }
}

class CountryInfo {
  String? name;
  num? latitude;
  num? longitude;

  CountryInfo({this.name, this.latitude, this.longitude});

  CountryInfo.fromJson(Map<String, dynamic> json) {
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


class KnownLocationListRequestData {
  int? passengerId;
  int? type;
  num? latitude;
  num? longitude;

  KnownLocationListRequestData({this.passengerId,this.type, this.latitude, this.longitude});

  KnownLocationListRequestData.fromJson(Map<String, dynamic> json) {
    passengerId = json['passengerId'];
    type = json['type'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passengerId'] = passengerId;
    data['type'] = type;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class KnownLocationListResponseData {
  int? status;
  String? message;
  ResponseData? responseData;

  KnownLocationListResponseData({this.status, this.message, this.responseData});

  KnownLocationListResponseData.fromJson(Map<String, dynamic> json) {
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
  KnownLocations? knownLocations;

  ResponseData({this.knownLocations});

  ResponseData.fromJson(Map<String, dynamic> json) {
    knownLocations = json['knownLocations'] != null
        ? KnownLocations.fromJson(json['knownLocations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (knownLocations != null) {
      data['knownLocations'] = knownLocations!.toJson();
    }
    return data;
  }
}

class KnownLocations {
  List<Categories>? categories;

  KnownLocations({this.categories});

  KnownLocations.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? name;
  List<Locations>? locations;

  Categories({this.name, this.locations});

  Categories.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['locations'] != null) {
      locations = <Locations>[];
      json['locations'].forEach((v) {
        locations!.add(Locations.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (locations != null) {
      data['locations'] = locations!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Locations {
  String? name;
  String? address;
  num? latitude;
  num? longitude;
  bool? isFavorites;
  String? sId;

  Locations({this.name, this.address, this.latitude, this.longitude,this.isFavorites,this.sId});

  Locations.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    isFavorites = json['isFavorites'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['address'] = address;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['isFavorites'] = isFavorites;
    data['_id'] = sId;
    return data;
  }
}

KnownLocationListResponseData knownLocationListResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return KnownLocationListResponseData.fromJson(jsonData);
}

knownLocationListRequestToJson(KnownLocationListRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

knownLocationByCityRequestToJson(KnownLocationByCityRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}