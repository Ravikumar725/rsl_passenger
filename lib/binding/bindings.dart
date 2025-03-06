import 'package:get/get.dart';
import 'package:rsl_passenger/taxi/controller/confirm_pickup_controller.dart';

import '../controller/common_place_controller.dart';
import '../controller/place_search_page_controller.dart';
import '../dashboard/controller/dashboard_page_controller.dart';
import '../dashboard/getx_storage.dart';
import '../network/services.dart';
import '../taxi/controller/city_selection_controller.dart';
import '../taxi/controller/destination_controller.dart';
import '../taxi/controller/saved_location_controller.dart';
import '../taxi/controller/taxi_controller.dart';
import '../taxi/controller/tracking_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<GetStorageController>(() => GetStorageController());
    Get.lazyPut<DashBoardController>(() => DashBoardController());
    Get.lazyPut<PlaceSearchPageController>(() => PlaceSearchPageController());
    Get.lazyPut<CommonPlaceController>(() => CommonPlaceController());
    Get.lazyPut<DestinationController>(() => DestinationController(), fenix: true);
    Get.lazyPut<CitySelectionController>(() => CitySelectionController());
    Get.lazyPut<SaveLocationController>(() => SaveLocationController());
    Get.lazyPut<ConfirmPickupController>(() => ConfirmPickupController());
    Get.lazyPut<TaxiController>(() => TaxiController());
    Get.lazyPut<TrackingController>(() => TrackingController());
  }
}
