import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/common_place_controller.dart';
import '../../dashboard/getx_storage.dart';
import '../../dashboard/data/data.dart';
import '../../network/app_services.dart';
import '../../network/services.dart';
import '../data/Known_location_pickup_list_api_date.dart';
import '../data/city_selection_list_api_data.dart';
import '../data/known_location_list_api_data.dart';
import '../../widget/utils/api_response_handler.dart';

class CitySelectionController extends GetxController
    with GetTickerProviderStateMixin {
  final commonPlaceController = Get.find<CommonPlaceController>();

  final TextEditingController citySelectController = TextEditingController();
  Rx<ResponseStatus> countryCityListResponseStatus = ResponseStatus().obs;
  Rx<ResponseStatus> knownLocationsResponseStatus = ResponseStatus().obs;
  RxList<CountryCityList>? countryCityList = <CountryCityList>[].obs;
  RxList<CountryCityList> filteredCountryCityList = <CountryCityList>[].obs;
  RxList<Categories>? categories = <Categories>[].obs;
  RxList<LocationsList>? locations = <LocationsList>[].obs;
  RxString selectedCity = "Dubai".obs;
  RxDouble selectedLatitude = 0.0.obs;
  RxDouble selectedLongitude = 0.0.obs;
  late TabController tabController;
  Rx<UserInfo?> userInfo = UserInfo().obs;

  @override
  void onInit() {
    // getUserInfo();
    tabController = TabController(length: 1, vsync: this);
    tabController.index = 0;
    citySelectController.addListener(_filterCities);
    callCountryCityList();
    callKnownLocationsList();
    super.onInit();
  }

  Future getUserInfo() async {
    userInfo.value = UserInfo();
    userInfo.refresh();
    try {
      userInfo.value = await GetStorageController().getUserInfo();
      userInfo.refresh();
      callCountryCityList();
      callKnownLocationsList();
    } catch (error) {
      printLogs("onError Dashboard UserInfo $error");
    }
  }

  String getFlagForCountryCode(String countryCode) {
    // Convert the country code to flag emoji
    return String.fromCharCodes(
      countryCode.codeUnits.map((char) => 0x1F1A5 + char),
    );
  }

  void _filterCities() {
    String query = citySelectController.text.toLowerCase();

    if (query.isEmpty) {
      // If query is empty, show all countries and cities
      filteredCountryCityList.assignAll(countryCityList ?? []);
    } else {
      // Filter countries based on cities' names matching the query
      filteredCountryCityList.assignAll(
        countryCityList!
            .map((country) {
              // Filter cities within the country based on the query
              var filteredCities = country.city?.where((city) {
                return city.name?.toLowerCase().contains(query) ?? false;
              }).toList();

              // If the country has any matching cities, return the country with filtered cities
              if (filteredCities != null && filteredCities.isNotEmpty) {
                return CountryCityList(
                  name: country.name,
                  latitude: country.latitude,
                  longitude: country.longitude,
                  countryCode: country.countryCode,
                  city: filteredCities,
                );
              }
              return null; // If no cities match, return null (exclude country)
            })
            .whereType<
                CountryCityList>() // Removes null values from the map result
            .toList(),
      );
    }
    // Print the filtered results for debugging
    print("Filtered List: ${filteredCountryCityList.length} results found.");
  }

  callCountryCityList() {
    countryCityListResponseStatus.value.status = 0;
    countryCityListResponseStatus.refresh();

    countryCityListApi().then((value) {
      if (value.status == 1) {
        countryCityListResponseStatus.value.status = value.status;
        countryCityListResponseStatus.value.message = value.message;
        countryCityListResponseStatus.refresh();
        countryCityList?.assignAll(value.responseData?.countryCityList ?? []);
        filteredCountryCityList.assignAll(countryCityList ?? []);
        selectedLatitude.value = countryCityList?.first.city?.first.latitude?.toDouble() ?? 0.0;
        selectedLongitude.value = countryCityList?.first.city?.first.longitude?.toDouble() ?? 0.0;
      } else {
        countryCityListResponseStatus.value.status = value.status;
        countryCityListResponseStatus.value.message = value.message;
        countryCityListResponseStatus.refresh();
        printLogs("Hii countryCityList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii countryCityList api error catch : $error ** ${stackTrace.toString()}");
      countryCityListResponseStatus.value.status = 400;
      countryCityListResponseStatus.value.message = "something_went_wrong".tr;
      countryCityListResponseStatus.refresh();
    });
  }

  callKnownLocationsList() {
    knownLocationsResponseStatus.value.status = 0;
    knownLocationsResponseStatus.refresh();
    knownLocationsApi(KnownLocationListRequestData(
            passengerId: 9/*int.tryParse(userInfo.value?.rslId ?? "9")*/,
            type: 1,
            latitude: commonPlaceController.currentLatLng.value.latitude,
            longitude: commonPlaceController.currentLatLng.value.longitude))
        .then((value) {
      if (value.status == 1) {
        knownLocationsResponseStatus.value.status = value.status;
        knownLocationsResponseStatus.value.message = value.message;
        knownLocationsResponseStatus.refresh();

        List<Categories>? fetchedCategories =
            value.responseData?.knownLocations?.categories ?? [];

        int suggestionsIndex = fetchedCategories.indexWhere(
            (category) => category.name?.toLowerCase() == "suggestions");

        Categories? suggestionsCategory;

        if (suggestionsIndex != -1) {
          suggestionsCategory = fetchedCategories.removeAt(suggestionsIndex);
          if (suggestionsCategory.locations?.isNotEmpty ?? false) {
            fetchedCategories.insert(0, suggestionsCategory);
          }
        }

        categories?.value = fetchedCategories
            .where((category) =>
                category.name?.toLowerCase() != "suggestions" ||
                (category.locations?.isNotEmpty ?? false))
            .toList();
        categories?.refresh();

        updateTabController(categories?.length ?? 0);

        /*List<Categories>? fetchedCategories =
            value.responseData?.knownLocations?.categories ?? [];

        // Move the "suggestions" category to the front
        int suggestionsIndex = fetchedCategories.indexWhere((category) =>
        category.name?.toLowerCase() == "suggestions");
        if (suggestionsIndex != -1) {
          var suggestionsCategory = fetchedCategories.removeAt(suggestionsIndex);
          fetchedCategories.insert(0, suggestionsCategory);
        }

        categories?.value = fetchedCategories;
        categories?.refresh();

        // categories?.value =
        //     value.responseData?.knownLocations?.categories ?? [];
        // categories?.refresh();
        updateTabController(categories?.length ?? 0);*/

        printLogs(
            "Hii countryCityList api value is ${value.responseData?.knownLocations?.categories?.length}");
      } else {
        knownLocationsResponseStatus.value.status = value.status;
        knownLocationsResponseStatus.value.message = value.message;
        knownLocationsResponseStatus.refresh();
        printLogs("Hii countryCityList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii countryCityList api error catch : $error ** ${stackTrace.toString()}");
      knownLocationsResponseStatus.value.status = 400;
      knownLocationsResponseStatus.value.message = "something_went_wrong".tr;
      knownLocationsResponseStatus.refresh();
    });
  }

  void updateTabController(int newLength) {
    tabController = TabController(length: newLength, vsync: this);
    update();
  }

  callKnownLocationsByCity({CountryInfo? countryInfo, CountryInfo? cityInfo}) {
    knownLocationsResponseStatus.value.status = 0;
    knownLocationsResponseStatus.refresh();

    knownLocationsByCityApi(KnownLocationByCityRequestData(
      passengerId: 9/*int.tryParse(userInfo.value?.rslId ?? "9")*/,
      type: 2,
      countryInfo: countryInfo,
      cityInfo: cityInfo,
    )).then((value) {
      if (value.status == 1) {
        knownLocationsResponseStatus.value.status = value.status;
        knownLocationsResponseStatus.value.message = value.message;
        knownLocationsResponseStatus.refresh();
        List<Categories>? fetchedCategories =
            value.responseData?.knownLocations?.categories ?? [];

        int suggestionsIndex = fetchedCategories.indexWhere(
                (category) => category.name?.toLowerCase() == "suggestions");

        Categories? suggestionsCategory;

        if (suggestionsIndex != -1) {
          suggestionsCategory = fetchedCategories.removeAt(suggestionsIndex);
          if (suggestionsCategory.locations?.isNotEmpty ?? false) {
            fetchedCategories.insert(0, suggestionsCategory);
          }
        }

        categories?.value = fetchedCategories
            .where((category) =>
        category.name?.toLowerCase() != "suggestions" ||
            (category.locations?.isNotEmpty ?? false))
            .toList();
        categories?.refresh();

        updateTabController(categories?.length ?? 0);
        /*categories?.value =
            value.responseData?.knownLocations?.categories ?? [];
        categories?.refresh();
        updateTabController(categories?.length ?? 0);*/
        printLogs(
            "Hii countryCityList api value is ${value.responseData?.knownLocations?.categories?.length}");
      } else {
        knownLocationsResponseStatus.value.status = value.status;
        knownLocationsResponseStatus.value.message = value.message;
        knownLocationsResponseStatus.refresh();
        printLogs("Hii countryCityList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii countryCityList api error catch : $error ** ${stackTrace.toString()}");
      knownLocationsResponseStatus.value.status = 400;
      knownLocationsResponseStatus.value.message = "something_went_wrong".tr;
      knownLocationsResponseStatus.refresh();
    });
  }

  callKnownLocationPickupApi({CountryInfo? cityInfo}) {
    knownLocationsResponseStatus.value.status = 0;
    knownLocationsResponseStatus.refresh();

    knownLocationsPickupApi(KnownLocationPickupRequestData(
      passengerId: 9/*int.tryParse(userInfo.value?.rslId ?? "9")*/,
      type: 3,
      cityInfo: cityInfo,
    )).then((value) {
      if (value.status == 1) {
        knownLocationsResponseStatus.value.status = value.status;
        knownLocationsResponseStatus.value.message = value.message;
        knownLocationsResponseStatus.refresh();
        locations?.value = value.responseData?.locations ?? [];
        locations?.refresh();
      } else {
        knownLocationsResponseStatus.value.status = value.status;
        knownLocationsResponseStatus.value.message = value.message;
        knownLocationsResponseStatus.refresh();
        printLogs("Hii countryCityList api error ${value.message}");
      }
    }).onError((error, stackTrace) {
      printLogs(
          "Hii countryCityList api error catch : $error ** ${stackTrace.toString()}");
      knownLocationsResponseStatus.value.status = 400;
      knownLocationsResponseStatus.value.message = "something_went_wrong".tr;
      knownLocationsResponseStatus.refresh();
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    citySelectController.dispose();
    citySelectController.removeListener(_filterCities);
    super.onClose();
  }
}
