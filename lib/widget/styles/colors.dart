import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../dashboard/getx_storage.dart';
import '../../network/services.dart';
import '../../routes/routes.dart';

enum AppColor {
  kStatusBarPrimaryColor,
  kBackButtonColor,
  kAppbarPrimaryColor,
  kBackGroundColor,
  kSecondaryBackGroundColor,
  kPrimaryTextColor,
  kSecondaryTextColor,
  kLightTextPrimary,
  kLightTextSecondary,
  kLightTextDisabled,
  kPrimaryColor,
  kPrimaryButtonColor,
  kSecondaryButtonColor,
  khintTextColor,
  kTransparentGrey,
  kOutlineBorderTextField,
  kDarkLightColor,
  kPrimaryButtonBackGround,
  kContainerBorder,
  kSecondaryContainerBorder,
  kHeadbackgroundColor,
  kLightPrimary,
  kWarning,
  kIndicatorColor,
  kloader,
  kIconSecondaryColor,
  kPrimaryIconColor,
  kWhiteIconColor,
  kBlack,
  kImageBackgroundColor,
  kBackgroundColorNew,
  kGetSnackBarColor,
  kCreditCardColor,
  kPrimaryDarkColor,
  kPrimaryTextFldColor,
  kPrimaryListViewClr,
  kYellowColour,
  kRedColour,
  kOrangeColour,
  kGreenColour,
  kOtpGrey,
  kLabelGrey,
  kLightGrey100,
  kLightGrey,
  kSplashColor,
  kSplashStatusBar
}

extension AppColorHelper on AppColor {
  Color get value {
    switch (this) {
      case AppColor.kPrimaryColor:
        return const Color(0xFF7AC6BF);

      case AppColor.kStatusBarPrimaryColor:
        return const Color(0xffffffff);

      case AppColor.kPrimaryTextColor:
        return const Color(0xFF000000);

      case AppColor.kBackButtonColor:
        return const Color(0xFF637381);

      case AppColor.kAppbarPrimaryColor:
        return const Color(0xfffdfdff);


      case AppColor.kOtpGrey:
        return const Color(0xFFecf1f5);

      case AppColor.kLabelGrey:
        return Colors.grey.withOpacity(0.9);

      case AppColor.kBackGroundColor:
        return const Color(0xFFFFFFFF);

      case AppColor.kSecondaryBackGroundColor:
        return const Color.fromRGBO(217, 217, 217, 0.12);

      case AppColor.kSecondaryTextColor:
        return const Color(0xFFFFFFFF);

      case AppColor.kLightTextPrimary:
        return const Color.fromARGB(255, 100, 101, 102);

      case AppColor.kLightTextSecondary:
        return const Color(0xFF888D8F);

      case AppColor.kOutlineBorderTextField:
        return const Color(0xFFDBE0E4);

      case AppColor.kDarkLightColor:
        return const Color(0xFF637381);

      case AppColor.kPrimaryButtonBackGround:
        return const Color(0xff7AC6BF);
      case AppColor.kloader:
        return const Color(0xFF36B37E);
      case AppColor.kContainerBorder:
        return const Color(0xff7AC6BF);
      case AppColor.kSecondaryContainerBorder:
        return const Color(0xFFC5C5C5);
      case AppColor.kHeadbackgroundColor:
        return const Color(0xFF000000).withOpacity(0.08);
      case AppColor.kLightPrimary:
        return const Color(0xFFedf0ee);

      case AppColor.kPrimaryListViewClr:
        return const Color(0xFFddf2f0);

      case AppColor.kIndicatorColor:
        return const Color(0xFFCDE5A5);
      case AppColor.kYellowColour:
        return const Color(0xFFFFC007);
      case AppColor.kRedColour:
        return Colors.red;
      case AppColor.kIconSecondaryColor:
        return const Color(0xFF7AC6BF);
      case AppColor.kPrimaryIconColor:
        return Colors.black;
      case AppColor.kWhiteIconColor:
        return Colors.white;
      case AppColor.kBlack:
        return Colors.black;
      case AppColor.kImageBackgroundColor:
        return const Color(0xFFDADADA);
      case AppColor.kBackgroundColorNew:
        return const Color(0xFFF5F5F5);
      case AppColor.kGetSnackBarColor:
        return const Color(0xFFF5F5F5).withOpacity(0.90);
      case AppColor.kCreditCardColor:
        return const Color(0xFF192A55);
      case AppColor.kPrimaryDarkColor:
        return const Color.fromARGB(255, 6, 77, 125);
      case AppColor.kPrimaryTextFldColor:
        return const Color.fromARGB(243, 243, 243, 255);
      case AppColor.kOrangeColour:
        return const Color(0xFFFF9800);
      case AppColor.kGreenColour:
        return const Color(0xFF4CAF50);
      case AppColor.kSplashColor:
        return const Color(0xFF267E95);
      case AppColor.kSplashStatusBar:
        return const Color(0xFF84CBC5);
      default:
        return const Color(0xFF212B36);
    }
  }
}

LinearGradient? primaryLinearColor = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF6DC8BF),
    Color.fromRGBO(0, 0, 0, 0.89),
  ],
);

LinearGradient? secondaryLinearColor = const LinearGradient(
  transform: GradientRotation(4.71), // Convert 270.19 degrees to radians
  stops: [0.4656, 1.3414],
  colors: [
    Color.fromRGBO(102, 102, 102, 0.38),
    Color.fromRGBO(217, 217, 217, 0),
  ],
);

LinearGradient? lightLinearColor =  LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    AppColor.kLightTextPrimary.value.withOpacity(0.1),
    AppColor.kLightTextPrimary.value.withOpacity(0.1),
  ],
);

LinearGradient? redLinearColor = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.redAccent,
    Color.fromRGBO(255, 82, 82, 0.80),
  ],
);

LinearGradient? primaryBackGroundColorLinearColor = LinearGradient(
  transform: const GradientRotation(1.59), // Convert 90.82 degrees to radians
  stops: [-0.0966, 0.9719],
  colors: [
    const Color(0xFF50B2A9),
    const Color(0xFF8AD4CD).withOpacity(0.1),
  ],
);

LinearGradient? primaryButtonLinearColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    const Color(0xFF50B2A9),
    const Color(0xFF50B2A9).withOpacity(0.1),
  ],
);

LinearGradient? primaryButtonLinearColor1 = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    const Color(0xFF50B2A9).withOpacity(0.1),
    const Color(0xFF50B2A9).withOpacity(0.1),
  ],
);

LinearGradient? whiteButtonLinearColor = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white,
    Colors.white,
  ],
);

LinearGradient? trans = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.transparent,
    Colors.transparent,
  ],
);

LinearGradient? redButtonLinearColor = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromARGB(255, 235, 77, 77),
    Color.fromARGB(255, 240, 95, 95),
  ],
);

LinearGradient? blackButtonLinearColor = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.black,
    Colors.black,
  ],
);

LinearGradient? whiteButtonLinearColorSecondary = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromARGB(255, 214, 213, 213),
    Color.fromARGB(255, 214, 213, 213),
  ],
);

otpInputDecoration({String hintText = ''}) => InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 6,
        ),
      hintText: hintText,
      /*border: outlineInputBorder(),
      focusedBorder: outlineInputBorder(),
      enabledBorder: outlineInputBorder(),*/
      hintStyle: TextStyle(
        fontSize: 16,
        color: AppColor.kLightTextDisabled.value.withOpacity(0.5),
      ),
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
      filled: true,
      fillColor: Colors.transparent,
      focusColor: AppColor.kLightTextDisabled.value.withOpacity(0.5),
    );

LinearGradient bookingLinearColorButton = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF78CCC2),
    Color(0xFF50B2A9),
  ],
);

LinearGradient promotionLinearColorButton =  const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    /*Color(0xFF50B2A9),*/
    Colors.teal,
    Color(0xFF78CCC2),
  ],
);

LinearGradient? blackLinearColor = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFF000000),
    Color(0xFF000000),
  ],
);

class Themex extends GetxController {
  static Rx<CustomThemeData> theme = CustomThemeData().obs;
  static Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  static Rx<ThemeMode> themeModeType = ThemeMode.system.obs;

  @override
  void onInit() {
    _getThemeMode();
    super.onInit();
  }

  static void _getThemeMode() async {
    themeMode.value = await StorageX().getThemeMode();
    printLogs("Hii THEME : ${themeMode.value}");
    theme.value = _lightTheme;
  }

  static void changeThemeMode({required ThemeMode themeMode}) async {
    await StorageX().updateThemeMode(themeMode);
    _getThemeMode();
    Get.offAllNamed(AppRoutes.dashboardPage);
    // Get.offAll(() => const AppIntialization());
  }

  static final CustomThemeData _lightTheme = CustomThemeData(
    kPrimaryColor: const Color(0xFF7AC6BF),
    kPrimaryColorShadow: const Color.fromARGB(255, 243, 250, 253),
    kPrimaryTextColor: Colors.black,
    kSecondaryTextColor: const Color(0xFFF3F6F8),
    kHintTextColor: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
    kTextFieldBackgroundColor: Colors.white,
    kAppBackgroundColor: const Color(0xFFFFFFFF),
    kStatusBarPrimaryColor: const Color.fromARGB(255, 255, 255, 255),
    kIconPrimaryColor: const Color.fromARGB(255, 0, 0, 0),
    kInActiveColor: const Color.fromARGB(255, 112, 116, 117),
    kPrimaryLoader: const Color.fromARGB(255, 255, 255, 255),
    kAppbarPrimaryColor: const Color.fromARGB(255, 243, 92, 42),
    kTabBarPrimaryColor: const Color.fromARGB(255, 244, 240, 238),
    kIconSecondaryColor: const Color.fromARGB(255, 255, 255, 255),
    kLightColor: const Color.fromARGB(255, 200, 203, 203),
    kButtonPrimaryColor: const Color.fromARGB(255, 243, 92, 42),
    kLoaderPrimaryColor: const Color.fromARGB(255, 243, 92, 42),
    kBlack: Colors.black,
    kCursorColor: const Color.fromARGB(255, 170, 170, 170),
    kRed: Colors.red,
    kGreen: const Color(0xFF4F955D),
    kCheckColor: Colors.white,
    kprimaryBorderColor: const Color.fromARGB(255, 200, 203, 203),
    kLightBorderColor: const Color.fromARGB(255, 220, 220, 220),
  );

  // ignore: unused_field
  static final CustomThemeData _darkTheme = CustomThemeData(
    kPrimaryColor: const Color(0xFF7AC6BF),
    kPrimaryTextColor: Colors.white,
    kSecondaryTextColor: Colors.black,
    kHintTextColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
    kTextFieldBackgroundColor: Colors.black,
    kAppBackgroundColor: const Color(0xFF000000),
    kStatusBarPrimaryColor: const Color.fromARGB(255, 0, 0, 0),
    kIconPrimaryColor: const Color.fromARGB(255, 255, 255, 255),
    kInActiveColor: const Color.fromARGB(255, 233, 235, 235),
    kPrimaryLoader: const Color.fromARGB(255, 0, 0, 0),
    kAppbarPrimaryColor: const Color.fromARGB(255, 0, 0, 0),
    kTabBarPrimaryColor: const Color.fromARGB(255, 0, 0, 0),
    kIconSecondaryColor: const Color.fromARGB(255, 255, 255, 255),
    kLightColor: const Color.fromARGB(255, 234, 225, 225),
    kButtonPrimaryColor: const Color.fromARGB(255, 0, 0, 0),
    kLoaderPrimaryColor: const Color.fromARGB(255, 255, 255, 255),
    kBlack: Colors.black,
    kCursorColor: const Color.fromARGB(255, 236, 236, 236),
    kRed: Colors.red,
    kGreen: const Color(0xFF4F955D),
    kCheckColor: Colors.white,
    kprimaryBorderColor: const Color.fromARGB(255, 200, 203, 203),
    kLightBorderColor: const Color.fromARGB(255, 220, 220, 220),
  );
}

class CustomThemeData {
  final Color kPrimaryColor;
  final Color kPrimaryColorShadow;
  final Color kPrimaryTextColor;
  final Color kSecondaryTextColor;
  final Color kHintTextColor;
  final Color kTextFieldBackgroundColor;
  final Color kAppBackgroundColor;
  final Color kStatusBarPrimaryColor;
  final Color kIconPrimaryColor;
  final Color kInActiveColor;
  final Color kPrimaryLoader;
  final Color kAppbarPrimaryColor;
  final Color kTabBarPrimaryColor;
  final Color kIconSecondaryColor;
  final Color kLightColor;
  final Color kButtonPrimaryColor;
  final Color kLoaderPrimaryColor;
  final Color kOnline;
  final Color kBlack;
  final Color kCursorColor;
  final Color kRed;
  final Color kGreen;
  final Color kCheckColor;
  final Color kprimaryBorderColor;
  final Color kLightBorderColor;
  final Color kOnInfoColor;
  final Color kOnWarningColor;
  final Color kOnSuccessColor;
  final Color kOnErrorColor;

  // Constructor
  CustomThemeData({
    //this.primaryColor = const Color(0xFF253640),
    this.kPrimaryColor = const Color(0xFFEA8A23),
    this.kPrimaryColorShadow = const Color.fromARGB(255, 200, 235, 255),
    this.kPrimaryTextColor = Colors.black,
    this.kSecondaryTextColor = const Color(0xFFF3F6F8),
    this.kTextFieldBackgroundColor = const Color.fromARGB(255, 250, 250, 250),
    this.kAppBackgroundColor = const Color(0xFFFFFFFF),
    this.kStatusBarPrimaryColor = const Color(0xFFF3F6F8),
    this.kIconPrimaryColor = const Color.fromARGB(255, 0, 0, 0),
    this.kInActiveColor = const Color.fromARGB(255, 112, 116, 117),
    this.kPrimaryLoader = const Color.fromARGB(255, 255, 255, 255),
    this.kAppbarPrimaryColor = const Color.fromARGB(255, 243, 92, 42),
    this.kTabBarPrimaryColor = const Color.fromARGB(255, 244, 240, 238),
    this.kIconSecondaryColor = const Color.fromARGB(255, 255, 255, 255),
    this.kLightColor = const Color.fromARGB(255, 200, 203, 203),
    this.kCursorColor = const Color.fromARGB(255, 236, 236, 236),
    this.kButtonPrimaryColor = const Color.fromARGB(255, 243, 92, 42),
    this.kLoaderPrimaryColor = const Color.fromARGB(255, 243, 92, 42),
    this.kOnline = const Color(0xFF18761B),
    this.kBlack = Colors.black,
    this.kRed = Colors.red,
    this.kHintTextColor = const Color.fromARGB(255, 0, 0, 0),
    this.kGreen = const Color(0xFF4F955D),
    this.kCheckColor = Colors.white,
    this.kprimaryBorderColor = const Color.fromARGB(255, 200, 203, 203),
    this.kLightBorderColor = const Color.fromARGB(255, 220, 220, 220),
    this.kOnInfoColor = Colors.blue,
    this.kOnWarningColor = Colors.red,
    this.kOnSuccessColor = Colors.black,
    this.kOnErrorColor = Colors.red,
  });
}