import 'dart:convert';

class GetCoreApiResponseData {
  int? status;
  String? message;
  ResponseData? responseData;

  GetCoreApiResponseData({this.status, this.message, this.responseData});

  GetCoreApiResponseData.fromJson(Map<String, dynamic> json) {
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
  String? store;
  String? paymentMode;
  String? paymentGatewayMode;
  num? walletAddMoneyMode;
  String? androidAppVersion;
  String? iosAppVersion;
  String? androidForceUpdateVersion;
  String? iosForceUpdateVersion;
  String? androidUpdateMessage;
  String? iOSUpdateMessage;
  String? androidForceUpdateMessage;
  String? iOSForceUpdateMessage;
  String? adminContactPhone;
  String? adminContactWhatsApp;
  String? adminContactEmail;
  String? lifeStyleBaseUrl;
  String? rslnodeBaseUrl;
  String? rslphpBaseUrl;
  String? promoBaseUrl;
  String? deactiveUrl;
  String? rslInvestorPartner;
  String? nearestDriversListBaseUrl;
  String? legacyAndPolicy;
  String? aboutRsllifestyle;
  String? privacyPolicy;
  String? helpCenter;
  List<ListTabItems>? listTabItems;
  List<RslGetCore>? rslGetCore;
  String? activityDetailUrl;
  String? holidayDetailUrl;
  String? staycationDetailUrl;
  String? rentalCarDetailUrl;
  String? rentalBusDetailUrl;
  int? holidayBookingFlow;
  int? staycationBookingFlow;
  int? busRentalBookingFlow;
  int? carRentalBookingFlow;
  String? supplier;
  String? imageBaseUrl;
  // int? futureBookingApiTime;
  // int? nearestDriverApiTime;
  // int? getTripUpdateApiTime;

  ResponseData({
    this.store,
    this.paymentMode,
    this.paymentGatewayMode,
    this.walletAddMoneyMode,
    this.androidAppVersion,
    this.iosAppVersion,
    this.androidForceUpdateVersion,
    this.iosForceUpdateVersion,
    this.androidUpdateMessage,
    this.iOSUpdateMessage,
    this.androidForceUpdateMessage,
    this.iOSForceUpdateMessage,
    this.adminContactPhone,
    this.adminContactWhatsApp,
    this.adminContactEmail,
    this.lifeStyleBaseUrl,
    this.rslnodeBaseUrl,
    this.rslphpBaseUrl,
    this.promoBaseUrl,
    this.nearestDriversListBaseUrl,
    this.rslInvestorPartner,
    this.deactiveUrl,
    this.legacyAndPolicy,
    this.aboutRsllifestyle,
    this.privacyPolicy,
    this.helpCenter,
    this.listTabItems,
    this.rslGetCore,
    this.activityDetailUrl,
    this.holidayDetailUrl,
    this.staycationDetailUrl,
    this.rentalCarDetailUrl,
    this.rentalBusDetailUrl,
    this.holidayBookingFlow,
    this.staycationBookingFlow,
    this.busRentalBookingFlow,
    this.carRentalBookingFlow,
    this.supplier,
    this.imageBaseUrl,
    // this.futureBookingApiTime,
    // this.nearestDriverApiTime,
    // this.getTripUpdateApiTime
  });

  ResponseData.fromJson(Map<String, dynamic> json) {
    store = json['store'];
    paymentMode = json['paymentMode'];
    paymentGatewayMode = json['paymentGatewayMode'];
    walletAddMoneyMode = json['walletAddMoneyMode'];
    androidAppVersion = json['androidAppVersion'];
    iosAppVersion = json['iosAppVersion'];
    androidForceUpdateVersion = json['androidForceUpdateVersion'];
    iosForceUpdateVersion = json['iosForceUpdateVersion'];
    androidUpdateMessage = json['androidUpdateMessage'];
    iOSUpdateMessage = json['iOSUpdateMessage'];
    androidForceUpdateMessage = json['androidForceUpdateMessage'];
    iOSForceUpdateMessage = json['iOSForceUpdateMessage'];
    adminContactPhone = json['adminContactPhone'];
    adminContactWhatsApp = json['adminContactWhatsApp'];
    adminContactEmail = json['adminContactEmail'];
    lifeStyleBaseUrl = json['lifeStyleBaseUrl'];
    rslnodeBaseUrl = json['rslnodeBaseUrl'];
    rslphpBaseUrl = json['rslphpBaseUrl'];
    promoBaseUrl = json['promoBaseUrl'];
    deactiveUrl = json['deactiveUrl'];
    rslInvestorPartner = json['rslInvestorPartner'];
    nearestDriversListBaseUrl = json['nearestDriversListBaseUrl'];
    legacyAndPolicy = json['legacyAndPolicy'];
    aboutRsllifestyle = json['aboutRsllifestyle'];
    privacyPolicy = json['privacyPolicy'];
    helpCenter = json['helpCenter'];
    activityDetailUrl = json['activityDetailUrl'];
    staycationDetailUrl = json['staycationDetailUrl'];
    holidayDetailUrl = json['holidayDetailUrl'];
    rentalCarDetailUrl = json['rentalCarDetailUrl'];
    rentalBusDetailUrl = json['rentalBusDetailUrl'];
    if (json['rslGetCore'] != null) {
      rslGetCore = <RslGetCore>[];
      json['rslGetCore'].forEach((v) {
        rslGetCore!.add(RslGetCore.fromJson(v));
      });
    }
    if (json['listTabItems'] != null) {
      listTabItems = <ListTabItems>[];
      json['listTabItems'].forEach((v) {
        listTabItems!.add(ListTabItems.fromJson(v));
      });
    }
    holidayBookingFlow = json['holidayBookingFlow'];
    staycationBookingFlow = json['staycationBookingFlow'];
    busRentalBookingFlow = json['busRentalBookingFlow'];
    carRentalBookingFlow = json['carRentalBookingFlow'];
    supplier = json['supplier'];
    imageBaseUrl = json['imageBaseUrl'];
    // futureBookingApiTime = json['futureBookingApiTime'];
    // nearestDriverApiTime = json['nearestDriverApiTime'];
    // getTripUpdateApiTime = json['getTripUpdateApiTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['store'] = store;
    data['paymentMode'] = paymentMode;
    data['paymentGatewayMode'] = paymentGatewayMode;
    data['walletAddMoneyMode'] = walletAddMoneyMode;
    data['androidAppVersion'] = androidAppVersion;
    data['iosAppVersion'] = iosAppVersion;
    data['androidForceUpdateVersion'] = androidForceUpdateVersion;
    data['iosForceUpdateVersion'] = iosForceUpdateVersion;
    data['androidUpdateMessage'] = androidUpdateMessage;
    data['iOSUpdateMessage'] = iOSUpdateMessage;
    data['androidForceUpdateMessage'] = androidForceUpdateMessage;
    data['iOSForceUpdateMessage'] = iOSForceUpdateMessage;
    data['adminContactPhone'] = adminContactPhone;
    data['adminContactWhatsApp'] = adminContactWhatsApp;
    data['adminContactEmail'] = adminContactEmail;
    data['lifeStyleBaseUrl'] = lifeStyleBaseUrl;
    data['rslnodeBaseUrl'] = rslnodeBaseUrl;
    data['rslphpBaseUrl'] = rslphpBaseUrl;
    data['promoBaseUrl'] = promoBaseUrl;
    data['deactiveUrl'] = deactiveUrl;
    data['rslInvestorPartner'] = rslInvestorPartner;
    data['nearestDriversListBaseUrl'] = nearestDriversListBaseUrl;
    data['legacyAndPolicy'] = legacyAndPolicy;
    data['aboutRsllifestyle'] = aboutRsllifestyle;
    data['privacyPolicy'] = privacyPolicy;
    data['helpCenter'] = helpCenter;
    data['activityDetailUrl'] = activityDetailUrl;
    data['staycationDetailUrl'] = staycationDetailUrl;
    data['holidayDetailUrl'] = holidayDetailUrl;
    data['rentalCarDetailUrl'] = rentalCarDetailUrl;
    data['rentalBusDetailUrl'] = rentalBusDetailUrl;
    if (rslGetCore != null) {
      data['rslGetCore'] = rslGetCore!.map((v) => v.toJson()).toList();
    }
    if (listTabItems != null) {
      data['listTabItems'] = listTabItems!.map((v) => v.toJson()).toList();
    }
    data['holidayBookingFlow'] = holidayBookingFlow;
    data['staycationBookingFlow'] = staycationBookingFlow;
    data['busRentalBookingFlow'] = busRentalBookingFlow;
    data['carRentalBookingFlow'] = carRentalBookingFlow;
    data['supplier'] = supplier;
    data['imageBaseUrl'] = imageBaseUrl;
    // data['futureBookingApiTime'] = futureBookingApiTime;
    // data['nearestDriverApiTime'] = nearestDriverApiTime;
    // data['getTripUpdateApiTime'] = getTripUpdateApiTime;
    return data;
  }
}

class RslGetCore {
  List<PickUpDropTerminals>? pickup_drop_terminals;
  List<ModelDetails>? modelDetails;
  String? nodePassengerUrl;
  int? isCarModelETAGoogleEnabled;
  num? oneTimeDiscountPercentage;
  String? androidGoogleApiKey;
  int? timeToSearchDriver;
  num? pickupDropChangeRadius;
  int? nearestDriverApiCallTime;
  int? getTripUpdateApiCallTime;
  List<String>? availablePickupLocations;
  List<String>? availableDropLocations;

  RslGetCore(
      {this.pickup_drop_terminals,
      this.nodePassengerUrl,
      this.modelDetails,
      this.isCarModelETAGoogleEnabled,
      this.oneTimeDiscountPercentage,
      this.androidGoogleApiKey,
      this.timeToSearchDriver,
      this.pickupDropChangeRadius,
      this.nearestDriverApiCallTime,
      this.getTripUpdateApiCallTime,
      this.availablePickupLocations,
      this.availableDropLocations});

  RslGetCore.fromJson(Map<String, dynamic> json) {
    if (json['pickup_drop_terminals'] != null) {
      pickup_drop_terminals = <PickUpDropTerminals>[];
      json['pickup_drop_terminals'].forEach((v) {
        pickup_drop_terminals!.add(PickUpDropTerminals.fromJson(v));
      });
    }
    if (json['model_details'] != null) {
      modelDetails = <ModelDetails>[];
      json['model_details'].forEach((v) {
        modelDetails!.add(ModelDetails.fromJson(v));
      });
    }
    nodePassengerUrl = json['node_passenger_url_auth'];
    isCarModelETAGoogleEnabled = json['isCarModelETAGoogleEnabled'];
    oneTimeDiscountPercentage = json['one_time_discount_percentage'];
    androidGoogleApiKey = json['android_google_api_key_new'];
    timeToSearchDriver = json['time_to_search_driver'];
    pickupDropChangeRadius = json['pickup_drop_change_radius'];
    nearestDriverApiCallTime = json['nearest_driver_api_call_time'];
    getTripUpdateApiCallTime = json['get_trip_update_api_call_time'];
    availablePickupLocations =
        (json['available_pickup_locations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
    availableDropLocations =
        (json['available_drop_locations'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (pickup_drop_terminals != null) {
      data['pickup_drop_terminals'] =
          pickup_drop_terminals!.map((v) => v.toJson()).toList();
    }
    if (modelDetails != null) {
      data['model_details'] = modelDetails!.map((v) => v.toJson()).toList();
    }
    data['one_time_discount_percentage'] = oneTimeDiscountPercentage;
    data['time_to_search_driver'] = timeToSearchDriver;
    data['pickup_drop_change_radius'] = pickupDropChangeRadius;
    data['nearest_driver_api_call_time'] = nearestDriverApiCallTime;
    data['get_trip_update_api_call_time'] = getTripUpdateApiCallTime;
    if (availablePickupLocations != null &&
        availablePickupLocations!.isNotEmpty) {
      data['available_pickup_locations'] = availablePickupLocations;
    }
    if (availableDropLocations != null && availableDropLocations!.isNotEmpty) {
      data['available_drop_locations'] = availableDropLocations;
    }
    return data;
  }
}

class ModelDetails {
  int? iId;
  int? modelId;
  int? isPackage;
  String? modelName;
  int? modelSize;
  num? baseFare;
  num? minFare;
  num? cancellationFare;
  num? minKm;
  num? minutesFare;
  num? belowAboveKm;
  num? belowKm;
  num? aboveKm;
  num? nightCharge;
  String? nightTimingFrom;
  String? nightTimingTo;
  num? nightFare;
  num? eveningCharge;
  String? eveningTimingFrom;
  String? eveningTimingTo;
  num? eveningFare;
  num? waitingFare;
  List<PackageDetails>? packageDetails;
  String? focusImage;
  String? unfocusImage;
  String? focusImageIos;
  String? unfocusImageIos;
  int? priority;
  String? androidFocusModelImage;
  String? androidUnfocusModelImage;
  String? androidFocusModelImageNew;
  String? iosFocusModelImage;
  String? iosUnfocusModelImage;
  String? focusModelImage;
  String? description;

  ModelDetails(
      {this.iId,
      this.modelId,
      this.isPackage,
      this.modelName,
      this.modelSize,
      this.baseFare,
      this.minFare,
      this.cancellationFare,
      this.minKm,
      this.minutesFare,
      this.belowAboveKm,
      this.belowKm,
      this.aboveKm,
      this.nightCharge,
      this.nightTimingFrom,
      this.nightTimingTo,
      this.nightFare,
      this.eveningCharge,
      this.eveningTimingFrom,
      this.eveningTimingTo,
      this.eveningFare,
      this.waitingFare,
      // this.packageDetails,
      this.focusImage,
      this.unfocusImage,
      this.focusImageIos,
      this.unfocusImageIos,
      this.priority,
      this.androidFocusModelImage,
      this.androidUnfocusModelImage,
      this.androidFocusModelImageNew,
      this.iosFocusModelImage,
      this.iosUnfocusModelImage,
      this.focusModelImage,
      this.description});

  ModelDetails.fromJson(Map<String, dynamic> json) {
    iId = json['_id'];
    modelId = json['model_id'];
    isPackage = json['is_package'];
    modelName = json['model_name'];
    modelSize = json['model_size'];
    baseFare = json['base_fare'];
    minFare = json['min_fare'];
    cancellationFare = json['cancellation_fare'];
    minKm = json['min_km'];
    minutesFare = json['minutes_fare'];
    belowAboveKm = json['below_above_km'];
    belowKm = json['below_km'];
    aboveKm = json['above_km'];
    nightCharge = json['night_charge'];
    nightTimingFrom = json['night_timing_from'];
    nightTimingTo = json['night_timing_to'];
    nightFare = json['night_fare'];
    eveningCharge = json['evening_charge'];
    eveningTimingFrom = json['evening_timing_from'];
    eveningTimingTo = json['evening_timing_to'];
    eveningFare = json['evening_fare'];
    waitingFare = json['waiting_fare'];
    if (json['package_details'] != null) {
      packageDetails = <PackageDetails>[];
      json['package_details'].forEach((v) {
        packageDetails!.add(PackageDetails.fromJson(v));
      });
    }
    focusImage = json['focus_image'];
    unfocusImage = json['unfocus_image'];
    focusImageIos = json['focus_image_ios'];
    unfocusImageIos = json['unfocus_image_ios'];
    priority = json['priority'];
    androidFocusModelImage = json['android_focus_model_image'];
    androidUnfocusModelImage = json['android_unfocus_model_image'];
    androidFocusModelImageNew = json['android_focus_model_image_new'];
    iosFocusModelImage = json['ios_focus_model_image'];
    iosUnfocusModelImage = json['ios_unfocus_model_image'];
    focusModelImage = json['focus_model_image'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = iId;
    data['model_id'] = modelId;
    data['is_package'] = isPackage;
    data['model_name'] = modelName;
    data['model_size'] = modelSize;
    data['base_fare'] = baseFare;
    data['min_fare'] = minFare;
    data['cancellation_fare'] = cancellationFare;
    data['min_km'] = minKm;
    data['minutes_fare'] = minutesFare;
    data['below_above_km'] = belowAboveKm;
    data['below_km'] = belowKm;
    data['above_km'] = aboveKm;
    data['night_charge'] = nightCharge;
    data['night_timing_from'] = nightTimingFrom;
    data['night_timing_to'] = nightTimingTo;
    data['night_fare'] = nightFare;
    data['evening_charge'] = eveningCharge;
    data['evening_timing_from'] = eveningTimingFrom;
    data['evening_timing_to'] = eveningTimingTo;
    data['evening_fare'] = eveningFare;
    data['waiting_fare'] = waitingFare;
    if (packageDetails != null) {
      data['package_details'] = packageDetails!.map((v) => v.toJson()).toList();
    }
    data['focus_image'] = focusImage;
    data['unfocus_image'] = unfocusImage;
    data['focus_image_ios'] = focusImageIos;
    data['unfocus_image_ios'] = unfocusImageIos;
    data['priority'] = priority;
    data['android_focus_model_image'] = androidFocusModelImage;
    data['android_unfocus_model_image'] = androidUnfocusModelImage;
    data['android_focus_model_image_new'] = androidFocusModelImageNew;
    data['ios_focus_model_image'] = iosFocusModelImage;
    data['ios_unfocus_model_image'] = iosUnfocusModelImage;
    data['focus_model_image'] = focusModelImage;
    data['description'] = description;
    return data;
  }
}

class PackageDetails {
  int? packageType;
  String? packageName;
  List<Packages>? packages;

  PackageDetails({this.packageType, this.packageName, this.packages});

  PackageDetails.fromJson(Map<String, dynamic> json) {
    packageType = json['package_type'];
    packageName = json['package_name'];
    if (json['packages'] != null) {
      packages = <Packages>[];
      json['packages'].forEach((v) {
        packages!.add(Packages.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['package_type'] = packageType;
    data['package_name'] = packageName;
    if (packages != null) {
      data['packages'] = packages!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Packages {
  int? packageId;
  int? packageType;
  dynamic packageHrsDays;
  dynamic packageMaxKm;
  num? packageAmount;
  num? packageAddKmAmt;
  num? packageAddHrAmt;
  String? packageStatus;
  int? packageCompanyId;
  String? packageLongDescription;
  String? packageShortDescription;

  Packages(
      {this.packageId,
      this.packageType,
      this.packageHrsDays,
      this.packageMaxKm,
      this.packageAmount,
      this.packageAddKmAmt,
      this.packageAddHrAmt,
      this.packageStatus,
      this.packageCompanyId,
      this.packageLongDescription,
      this.packageShortDescription});

  Packages.fromJson(Map<String, dynamic> json) {
    packageId = json['package_id'];
    packageType = json['package_type'];
    packageHrsDays = json['package_hrs_days'];
    packageMaxKm = json['package_max_km'];
    packageAmount = json['package_amount'];
    packageAddKmAmt = json['package_add_km_amt'];
    packageAddHrAmt = json['package_add_hr_amt'];
    packageStatus = json['package_status'];
    packageCompanyId = json['package_company_id'];
    packageLongDescription = json['package_long_description'];
    packageShortDescription = json['package_short_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['package_id'] = packageId;
    data['package_type'] = packageType;
    data['package_hrs_days'] = packageHrsDays;
    data['package_max_km'] = packageMaxKm;
    data['package_amount'] = packageAmount;
    data['package_add_km_amt'] = packageAddKmAmt;
    data['package_add_hr_amt'] = packageAddHrAmt;
    data['package_status'] = packageStatus;
    data['package_company_id'] = packageCompanyId;
    data['package_long_description'] = packageLongDescription;
    data['package_short_description'] = packageShortDescription;
    return data;
  }
}

class PickUpDropTerminals {
  String? address;
  List<PolygonList>? polygon;
  List<TerminalList>? terminalList;

  PickUpDropTerminals({this.address, this.polygon, this.terminalList});

  PickUpDropTerminals.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    if (json['polygon'] != null) {
      polygon = <PolygonList>[];
      json['polygon'].forEach((v) {
        polygon!.add(PolygonList.fromJson(v));
      });
    }
    if (json['terminalList'] != null) {
      terminalList = <TerminalList>[];
      json['terminalList'].forEach((v) {
        terminalList!.add(TerminalList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    if (polygon != null) {
      data['polygon'] = polygon!.map((v) => v.toJson()).toList();
    }

    if (terminalList != null) {
      data['terminalList'] = terminalList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PolygonList {
  double? latitude;
  double? longitude;

  PolygonList({
    this.latitude,
    this.longitude,
  });

  PolygonList.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class TerminalList {
  double? latitude;
  double? longitude;
  String? address;

  TerminalList({this.latitude, this.longitude, this.address});

  TerminalList.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['address'] = address;

    return data;
  }
}

class ListTabItems {
  String? image;
  String? title;
  int? type;

  ListTabItems({this.image, this.title, this.type});

  ListTabItems.fromJson(Map<String, dynamic> json) {
    image = json['image'];
    title = json['title'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['image'] = image;
    data['title'] = title;
    data['type'] = type;
    return data;
  }
}

GetCoreApiResponseData getCoreApiResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return GetCoreApiResponseData.fromJson(jsonData);
}
