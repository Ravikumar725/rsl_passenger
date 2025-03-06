
import 'dart:convert';

class GetDriverReplyRequestData {
  String? passengerTripId;

  GetDriverReplyRequestData({this.passengerTripId});

  GetDriverReplyRequestData.fromJson(Map<String, dynamic> json) {
    passengerTripId = json['passenger_tripid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['passenger_tripid'] = passengerTripId;
    return data;
  }
}

class GetDriverReplyResponseData {
  String? message;
  int? status;
  String? authKey;

  GetDriverReplyResponseData({this.message, this.status, this.authKey});

  GetDriverReplyResponseData.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    status = json['status'];
    authKey = json['auth_key'];
  }

  Map<String, dynamic> toJson() {
     final Map<String, dynamic> data = <String, dynamic>{};
    data['message'] = message;
    data['status'] = status;
    data['auth_key'] = authKey;
    return data;
  }
}

GetDriverReplyResponseData getGetDriverReplyResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return GetDriverReplyResponseData.fromJson(jsonData);
}

String getGetDriverReplyRequestToJson(GetDriverReplyRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}
