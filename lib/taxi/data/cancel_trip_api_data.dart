import 'dart:convert';

class CancelTripRequestData {
  String? passengerLogId;
  String? paymentMode;
  String? remarks;
  String? creditCardCvv;
  String? payModId;
  String? travelStatus;
  String? paymentGatewayMode;

  CancelTripRequestData(
      {this.passengerLogId,
      this.paymentMode,
      this.remarks,
      this.creditCardCvv,
      this.payModId,
      this.travelStatus,
      this.paymentGatewayMode});

  CancelTripRequestData.fromJson(Map<String, dynamic> json) {
    passengerLogId = json['passenger_log_id'];
    paymentMode = json['payment_mode'];
    remarks = json['remarks'];
    creditCardCvv = json['creditcard_cvv'];
    payModId = json['pay_mod_id'];
    travelStatus = json['travel_status'];
    paymentGatewayMode = json['payment_gateway_mode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['passenger_log_id'] = this.passengerLogId;
    data['payment_mode'] = this.paymentMode;
    data['remarks'] = this.remarks;
    data['creditcard_cvv'] = this.creditCardCvv;
    data['pay_mod_id'] = this.payModId;
    data['travel_status'] = this.travelStatus;
    data['payment_gateway_mode'] = this.paymentGatewayMode;
    return data;
  }
}

String cancelTripRequestToJson(CancelTripRequestData data) {
  final dyn = data.toJson();
  return json.encode(dyn);
}

class CancelTripResponseData {
  String? message;
  String? status;

  CancelTripResponseData({this.message, this.status});

  CancelTripResponseData.fromJson(Map<String, dynamic> json) {
    message = json['message'].toString();
    status = json['status'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['status'] = this.status;
    return data;
  }
}

CancelTripResponseData cancelTripResponseFromJson(String str) {
  final jsonData = json.decode(str);
  return CancelTripResponseData.fromJson(jsonData);
}
