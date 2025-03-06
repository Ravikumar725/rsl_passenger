import 'package:get/get.dart';
import 'package:rsl_passenger/taxi/view/pickup/confirm_pickup_page.dart';
import 'package:rsl_passenger/taxi/view/receipt_page.dart';
import 'package:rsl_passenger/taxi/view/taxi_page.dart';

import '../binding/bindings.dart';
import '../dashboard/dashboard_page.dart';
import '../taxi/view/booking_loading_page.dart';
import '../taxi/view/city_selection_page.dart';
import '../taxi/view/destination/view/destination_page.dart';
import '../taxi/view/save_location_page.dart';
import '../taxi/view/tracking_page.dart';

class AppRoutes {
  static const dashboardPage = '/dashboardPage';
  static const destinationPage = '/destinationPage';
  static const pickUpScreen = '/pickUpScreen';
  static const saveLocationPage = '/saveLocationPage';
  static const taxiHomePage = '/taxiHomePage';
  static const citySelectionPage = '/citySelectionPage';
  static const bookingLoadingPage = '/bookingLoadingPage';
  static const trackingPage = '/trackingPage';
  static const receiptPage = '/receiptPage';
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
    name: AppRoutes.taxiHomePage,
    page: () => const TaxiHomePage(),
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
  GetPage(
    name: AppRoutes.bookingLoadingPage,
    page: () => const BookingLoadingPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: AppRoutes.trackingPage,
    page: () => const TrackingPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
  GetPage(
    name: AppRoutes.receiptPage,
    page: () => ReceiptPage(),
    binding: AppBindings(),
    transition: Transition.fadeIn,
    transitionDuration: const Duration(milliseconds: 200),
  ),
];
