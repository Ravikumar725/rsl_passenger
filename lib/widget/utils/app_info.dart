import 'app_info_args.dart';
import '../../dashboard/data/get_core_api_data.dart';


enum BaseUrls {
  local,
  demo,
  live,
}

extension BaseURLHelper on BaseUrls {
  String get rawValue {
    switch (this) {
      case BaseUrls.live:
        return 'https://node.royalsmartlifestyle.com/';
      case BaseUrls.demo:
        return 'http://157.241.59.247:4004/';
      case BaseUrls.local:
        return 'http://192.168.1.14:4008/';
    }
  }
}

class AppInfo {
  static final String kAppCoreUrl = BaseUrls.demo.rawValue;

  static get kAppBaseUrl => getAppBaseUrl();

  static get kAppImageBaseUrl => getAppImageBaseUrl();

  static get kAppVideoBaseUrl => getAppVideoBaseUrl();

  static get rslAppBaseUrl => getRslAppBaseUrl();

  static get rslAppDeActiveBaseUrl => getRslAppDeactiveBaseUrl();

  static get kAppPromoBaseUrl => getAppPromoBaseUrl();

  static get kNearestDriveApi => getAppPNearestUrl();

  static get kRslInvestorPartnerApi => getRslInvestorPartnerUrl();

  static get klegacyAndPolicy => getLegacyAndPolicyUrl();

  static get kAboutRslLifeStyle => getAboutRslLifeStyleUrl();

  static get kPrivacyPolicy => getPrivacyPolicyUrl();

  static get kHelpCenter => getHelpCenterUrl();

  static get kRslPhpBaseUrl => getRslPhpUrl();


  static get kGetRslNodePassengerUrl => getRslNodePassengerUrl();

  static get kAndroidApiKey => getAndroidApiKey();

  static get kIsCarModelETAGoogleEnabled => isCarModelETAGoogleEnabled();

  static GetCoreApiResponseData? kAppGetCore;
  static const String kPaymentTestMode = "1"; // "0" -> live, "1" -> test
  static const String kGooglePlacesKey =
      "AIzaSyDFvlhGWMJB7LNyzz52w6NZ5ZEjMU2pV9Q";
  static const String secretKey = "0003ec7c2a11e8ec20d622b83f95831a";
  static AppInfoPlusArgs? appInfo;
  static String appCurrency = "aed";

  static get applePayJsonString => getApplePayJson();

  static String getApplePayJson() {
    switch (appCurrency) {
      case "usd":
        return "{\"provider\":\"apple_pay\",\"data\":{\"merchantIdentifier\":\"merchant.com.rsl.passenger\",\"displayName\":\"RSLLifestyle\",\"merchantCapabilities\":[\"3DS\",\"debit\",\"credit\"],\"supportedNetworks\":[\"amex\",\"visa\",\"discover\",\"masterCard\"],\"countryCode\":\"US\",\"currencyCode\":\"USD\",\"requiredBillingContactFields\":null,\"requiredShippingContactFields\":null}}";
      case "aed":
        return "{\"provider\":\"apple_pay\",\"data\":{\"merchantIdentifier\":\"merchant.com.rsl.passenger\",\"displayName\":\"RSLLifestyle\",\"merchantCapabilities\":[\"3DS\",\"debit\",\"credit\"],\"supportedNetworks\":[\"amex\",\"visa\",\"discover\",\"masterCard\"],\"countryCode\":\"AE\",\"currencyCode\":\"AED\",\"requiredBillingContactFields\":null,\"requiredShippingContactFields\":null}}";
      default:
        return "{\"provider\":\"apple_pay\",\"data\":{\"merchantIdentifier\":\"merchant.com.rsl.passenger\",\"displayName\":\"RSLLifestyle\",\"merchantCapabilities\":[\"3DS\",\"debit\",\"credit\"],\"supportedNetworks\":[\"amex\",\"visa\",\"discover\",\"masterCard\"],\"countryCode\":\"AE\",\"currencyCode\":\"AED\",\"requiredBillingContactFields\":null,\"requiredShippingContactFields\":null}}";
    }
  }

  static String getAppBaseUrl() {
    return "http://157.241.59.247:4004/"/*"${kAppGetCore?.responseData?.lifeStyleBaseUrl}"*/;
  }

  static String getAppImageBaseUrl() {
    return "${kAppGetCore?.responseData?.imageBaseUrl}";
  }

  static String getAppVideoBaseUrl() {
    return "${kAppGetCore?.responseData?.lifeStyleBaseUrl}";
  }

  static String getRslAppBaseUrl() {
    return "https://passnodeauth.limor.us/passenger/"/*"${kAppGetCore?.responseData?.rslnodeBaseUrl}"*/;
  }

  static String getRslAppDeactiveBaseUrl() {
    return "${kAppGetCore?.responseData?.deactiveUrl}";
  }

  static String getAppPromoBaseUrl() {
    return "${kAppGetCore?.responseData?.promoBaseUrl}";
  }

  static String getAppPNearestUrl() {
    return "${kAppGetCore?.responseData?.nearestDriversListBaseUrl}";
  }

  static String getRslInvestorPartnerUrl() {
    return "${kAppGetCore?.responseData?.rslInvestorPartner}";
  }

  static String getLegacyAndPolicyUrl() {
    return "${kAppGetCore?.responseData?.legacyAndPolicy}";
  }

  static String getAboutRslLifeStyleUrl() {
    return "${kAppGetCore?.responseData?.aboutRsllifestyle}";
  }

  static String getPrivacyPolicyUrl() {
    return "${kAppGetCore?.responseData?.privacyPolicy}";
  }

  static String getHelpCenterUrl() {
    return "${kAppGetCore?.responseData?.helpCenter}";
  }

  static String getRslPhpUrl() {
    return "${kAppGetCore?.responseData?.rslphpBaseUrl}";
  }

  static String getRslNodePassengerUrl() {
    return "${kAppGetCore?.responseData?.rslGetCore![0].nodePassengerUrl}";
  }

  static String getAndroidApiKey() {
    return "${kAppGetCore?.responseData?.rslGetCore![0].androidGoogleApiKey}";
  }

  static int isCarModelETAGoogleEnabled() {
    return kAppGetCore
        ?.responseData?.rslGetCore![0].isCarModelETAGoogleEnabled ??
        0;
  }
}
  Map<String, String> appQueryParam({Map<String, String>? customQuery}) {
    Map<String, String> appQueryParam;
    final data = {
      'dID': AppInfo.appInfo?.deviceId ?? "",
      'dt': AppInfo.appInfo?.deviceType ?? "",
      'vn': AppInfo.appInfo?.buid ?? "",
      'bvn': AppInfo.appInfo?.deviceVersion ?? "",
      'currencyCode': AppInfo.appCurrency,
      /*'lng': "en",*/
      /*'cid':"223"*/
    };
    appQueryParam = {...data, ...?customQuery};
    return appQueryParam;
  }
