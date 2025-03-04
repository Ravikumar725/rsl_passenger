import 'dart:convert';
import 'package:get/get_instance/src/get_instance.dart';
import 'package:rsl_passenger/network/services.dart';

import '../widget/utils/app_info.dart';
import '../dashboard/data/get_core_api_data.dart';
import '../taxi/data/Known_location_pickup_list_api_date.dart';
import '../taxi/data/city_selection_list_api_data.dart';
import '../taxi/data/known_location_list_api_data.dart';
import '../taxi/data/nearest_drivers_list_api_data.dart';
import '../taxi/data/save_location_api_data.dart';
import '../taxi/data/saved_location_list_api_data.dart';

final ApiProvider apiProvider = GetInstance().find<ApiProvider>();


/////TAXI
Future<NearestDriversListResponseData> nearestDriverListApi(
    NearestDriversListRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'http://ec2-34-197-53-22.compute-1.amazonaws.com:8810/api/v1/nearestdriverlistAll'/*'${AppInfo.kNearestDriveApi}'*/,
      request: nearestDriversListRequestToJson(requestData),
    ),
    disablePrintLog: false,
  );
  return nearestDriversListResponseFromJson(response);
}

/*Future<SaveBookingResponseData> saveBookingApi(
    SaveBookingRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: '${AppInfo.kAppBaseUrl}taxi/savebookingWeb',
      request: saveBookingRequestToJson(requestData),
    ),
  );
  return saveBookingResponseFromJson(response);
}*/

Future<GetCoreApiResponseData> getCoreApi() async {
  final response = await apiProvider.httpRequest(
    requestType: RequestType.kGet,
    resource: Resource(
      url: '${AppInfo.kAppCoreUrl}taxi/getCoreConfig',
      request: '',
    ),
  );
  return getCoreApiResponseFromJson(response);
}

Future<Map<String, dynamic>> googleMapApi(String url) async {
  final response = await apiProvider.httpRequestGetDirections(
      resource: Resource(url: url, request: ''), requestType: RequestType.kGet);
  return json.decode(response);
}

Future<SaveLocationResponseData> saveLocationApi(
    SaveLocationRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'https://passnodeauth.limor.us/passenger/saveLocation',
      request: saveLocationRequestToJson(requestData),
    ),
  );
  return saveLocationResponseFromJson(response);
}

Future<SaveLocationListResponseData> saveLocationListApi(
    SaveLocationListRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'https://passnodeauth.limor.us/passenger/locationList',
      request: saveLocationListRequestToJson(requestData),
    ),
  );
  return saveLocationListResponseFromJson(response);
}

Future<CountryCityListResponseData> countryCityListApi() async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'https://passnodeauth.limor.us/passenger/countryCityList',
      request: "",
    ),
  );
  return countryCityListResponseFromJson(response);
}

Future<KnownLocationListResponseData> knownLocationsApi(
    KnownLocationListRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'https://passnodeauth.limor.us/passenger/knownLocations',
      request: knownLocationListRequestToJson(requestData),
    ),
  );
  return knownLocationListResponseFromJson(response);
}

Future<KnownLocationListResponseData> knownLocationsByCityApi(
    KnownLocationByCityRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'https://passnodeauth.limor.us/passenger/knownLocations',
      request: knownLocationByCityRequestToJson(requestData),
    ),
  );
  return knownLocationListResponseFromJson(response);
}

Future<KnownLocationPickupResponseData> knownLocationsPickupApi(
    KnownLocationPickupRequestData requestData) async {
  final response = await apiProvider.httpRequest(
    resource: Resource(
      url: 'https://passnodeauth.limor.us/passenger/knownLocations',
      request: knownLocationPickupRequestToJson(requestData),
    ),
  );
  return knownLocationPickupResponseFromJson(response);
}
