import 'dart:convert';
import 'package:get/get.dart';

import '../app_info.dart';
import '../dashboard/getx_storage.dart';

class ApiProvider extends GetConnect {
  // final GetStorageController controller = Get.find<GetStorageController>();

  @override
  void onInit() {
    super.onInit();
    bool _isAuthenticating = false;
    httpClient.addResponseModifier<Object?>((request, response) {
      final model = response.bodyString;
      printLogs("RES refreshToken -> ${model != null} ** ${model != null}");
      try {
        if (model != null) {
          final jsonData = json.decode(model);
          if (jsonData["accessToken"] != null) {
            printLogs("RES accessToken -> ${jsonData["accessToken"]}");
            // controller.saveAccessToken(value: jsonData["accessToken"]);
          }
          if (jsonData["refreshToken"] != null) {
            printLogs("RES refreshToken -> ${jsonData["refreshToken"]}");
            // controller.saveRefreshToken(value: jsonData["refreshToken"]);
          }
        }
      } catch (e) {
        printLogs("RES refreshToken -> ${e.toString()}");
      }

      return response;
    });
    // httpClient.addAuthenticator<Object?>((request) async {
    //   if (_isAuthenticating) {
    //     // Authentication is already in progress, avoid recursive call
    //     return request;
    //   }
    //   _isAuthenticating = true;
    //   try {
    //     printLogs("addAuthCalled");
    //     // Check if there's an existing access token
    //     String refreshToken = await GetStorageController().getRefreshToken();
    //     printLogs("addAuth RT -> $refreshToken");
    //     // ignore: unnecessary_null_comparison
    //     if (refreshToken == null || refreshToken == "") {
    //       refreshToken = AppInfo.secretKey;
    //     }
    //     final response = await httpClient.post(
    //       "${AppInfo.rslAppBaseUrl}getAccessToken",
    //       contentType: 'application/json',
    //       query: _query(),
    //       body: {},
    //       headers: defaultApiHeaders(await GetStorageController().getAccessToken())/*{'Authorization': refreshToken}*/,
    //     );
    //
    //     String newAccessToken = response.body["accessToken"]?.toString() ?? '';
    //     printLogs("getPassengerToken called new : $newAccessToken");
    //     controller.saveAccessToken(value: newAccessToken);
    //     request.headers['Authorization'] = newAccessToken;
    //   } finally {
    //     _isAuthenticating = false;
    //   }
    //
    //   return request;
    // });
    httpClient.maxAuthRetries = 2;
  }

  Future<String> httpRequest(
      {RequestType requestType = RequestType.kPost,
      required Resource resource,
      bool encryptParams = true,
      bool decryptResponse = false,
      Map<String, String>? queryParam,
      Duration? timeout,
      bool? disablePrintLog = false}) async {
    _commonPrintLogs(resource, timeout, disablePrintLog);
    switch (requestType) {
      case RequestType.kGet:
        Response response = await _getConnectGet(resource, queryParam);
        return response.bodyString ?? '';

      case RequestType.kPut:
        Response response =
            await put(resource.url, "", query: _query(customQuery: queryParam));
        return response.bodyString ?? '';

      default:
        Response response;
        response = await _getConnectPost(resource, queryParam, disablePrintLog);
        return response.bodyString ?? '';
    }
  }

  Future<Response<dynamic>> _getConnectPost(Resource<dynamic> resource,
      Map<String, String>? queryParam, bool? disablePrintLog) async {
    Response response;
    int status = 1;
    int maxcall = 1;
    response = await post(
      resource.url,
      resource.request,
      query: _query(customQuery: queryParam),
    );
    printLogs("**AFTER RESPONSE $maxcall**");
    _postPrintLogs(response, resource, disablePrintLog);
    response.bodyString == null ? status = 0 : status = 1;
    while (status == 0 && maxcall < 4) {
      response = await post(
        resource.url,
        resource.request,
        query: _query(customQuery: queryParam),
      );
      printLogs("**AFTER RESPONSE RECALL ${maxcall + 1}**");
      _postPrintLogs(response, resource, disablePrintLog);
      response.bodyString == null ? status = 0 : status = 1;
      maxcall++;
    }
    return response;
  }

  Future<Response<dynamic>> _getConnectGet(
      Resource<dynamic> resource, Map<String, String>? queryParam) async {
    Response response;
    int status = 1;
    int maxcall = 1;
    response = await get(
      resource.url,
      query: _query(customQuery: queryParam),
    );
    printLogs("**AFTER RESPONSE $maxcall**");
    _getPrintLogs(response);
    response.bodyString == null ? status = 0 : status = 1;
    while (status == 0 && maxcall < 4) {
      response = await get(
        resource.url,
        query: _query(customQuery: queryParam),
      );
      printLogs("**AFTER RESPONSE RECALL ${maxcall + 1}**");
      _getPrintLogs(response);
      response.bodyString == null ? status = 0 : status = 1;
      maxcall++;
    }
    return response;
  }

  Map<String, String> _query({Map<String, String>? customQuery}) =>
      appQueryParam(customQuery: customQuery);

  void _commonPrintLogs(
      Resource<dynamic> resource, Duration? timeout, bool? disablePrintLog) {
    if (disablePrintLog == false) {
      printLogs("Request Url: ${resource.url}");
      printLogs("Request Data: ${resource.request}");
      httpClient.timeout = timeout ?? const Duration(seconds: 60);
      printLogs("**RESPONSE TIME OUT : ${httpClient.timeout.inSeconds} SEC**");
    }
  }

  void _postPrintLogs(
      Response<dynamic> response, Resource resource, bool? disablePrintLog) {
    if (disablePrintLog == false) {
      printLogs(
          "** API CALL => \n REQUEST URL : ${response.request?.url} \n REQEST DATA : ${resource.request} \n RESPONSE DATA : ${response.bodyString} \n STATUS CODE : ${response.status.code}");
    }
  }

  void _getPrintLogs(Response<dynamic> response) {
    printLogs(
        "** Request data => /n REQUEST URL : ${response.request?.url} /n RESPONSE : ${response.bodyString} /n STATUS CODE : ${response.status.code}");
  }

  Future<String> httpRequestGetDirections({
    RequestType requestType = RequestType.kGet,
    required Resource resource,
    bool encryptParams = true,
    bool decryptResponse = false,
    Duration? timeout,
  }) async {
    printLogs("Request Url: ${resource.url}");
    printLogs("Request Data: ${resource.request}");
    httpClient.timeout = timeout ?? const Duration(seconds: 60);
    printLogs("**RESPONSE TIME OUT : ${httpClient.timeout.inSeconds} SEC**");
    switch (requestType) {
      case RequestType.kGet:
        Response response = await get(resource.url);
        printLogs("**Request url: ${response.request?.url}");
        printLogs("**Response Status: ${response.status.code}");
        printLogs("Response: ${response.bodyString}");
        return response.bodyString ?? '';

      case RequestType.kPut:
        Response response = await put(resource.url, "");
        return response.bodyString ?? '';

      default:
        Response response = await post(
          resource.url,
          resource.request,
        );
        printLogs("**AFTER RESPONSE**");
        printLogs("**Request url: ${response.request?.url}");
        printLogs("**Response Status: ${response.status.code}");
        printLogs("**Response: ${response.bodyString}");
        return response.bodyString ?? '';
    }
  }
}

class Resource<T> {
  final String url;
  final String request;
  T Function(Response response)? parse;

  Resource({required this.url, required this.request, this.parse});
}

class Request<T> {
  final String request;

  Request({
    required this.request,
  });
}

enum RequestType { kGet, kPost, kPut, kPostMultiForm }

Map<String, String> defaultApiHeaders(token) {
  final _defaultApiHeaders = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${token}'
  };
  return _defaultApiHeaders;
}

void printLogs(Object object) {
  const bool isProduction = bool.fromEnvironment('dart.vm.product');
  if (!isProduction) {
    // ignore: avoid_print
    final request = '$object';
    int maxLogSize = 1000;
    for (int i = 0; i <= request.length / maxLogSize; i++) {
      int start = i * maxLogSize;
      int end = (i + 1) * maxLogSize;
      end = end > request.length ? request.length : end;
      print('${request.substring(start, end)}');
    }
  }
}
