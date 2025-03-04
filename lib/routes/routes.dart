import 'package:get/get.dart';
import 'package:rsl_passenger/taxi/view/pickup/confirm_pickup_page.dart';
import 'package:rsl_passenger/taxi/view/taxi_page_new.dart';

import '../binding/bindings.dart';
import '../dashboard/dashboard_page.dart';
import '../taxi/view/city_selection_page.dart';
import '../taxi/view/destination/view/destination_page.dart';
import '../taxi/view/save_location_page.dart';

class AppRoutes {
  static const home = '/';
  static const dashboardPage = '/dashboardPage';
  static const destinationPage = '/destinationPage';
  static const pickUpScreen = '/pickUpScreen';
  static const saveLocationPage = '/saveLocationPage';
  static const taxiHomePageNew = '/taxiHomePageNew';
  static const citySelectionPage = '/citySelectionPage';

}

final List<GetPage> pages = [
  GetPage(
    name: AppRoutes.dashboardPage,
    page: () => const DashboardPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),

  GetPage(
    name: AppRoutes.destinationPage,
    page: () => const DestinationPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: AppRoutes.pickUpScreen,
    page: () => const PickupScreen(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: AppRoutes.taxiHomePageNew,
    page: () => const TaxiHomePageNew(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: AppRoutes.saveLocationPage,
    page: () => const SaveLocationPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: AppRoutes.citySelectionPage,
    page: () => const CitySelectionPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
];
