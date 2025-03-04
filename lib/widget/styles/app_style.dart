import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppFontSize {
  small,
  medium,
  large,
  appBar,
  info,
  dashboardTitle,
  dashboardDescription,
  appTitle,
  appLargeTitle,
  veryLargeTitle,
  verySmall,
  smallMedium
}

enum AppFontWeight { light, normal, bold, semibold, medium, large }

extension FontSizeHelper on AppFontSize {
  double get value {
    switch (this) {
      case AppFontSize.verySmall:
        return 10.sp;
      case AppFontSize.small:
        return 12.sp;
      case AppFontSize.smallMedium:
        return 13.sp;
      case AppFontSize.medium:
        return 14.sp;
      case AppFontSize.large:
        return 16.sp;
      case AppFontSize.info:
        return 18.sp;
      case AppFontSize.dashboardTitle:
        return 24.sp;
      case AppFontSize.dashboardDescription:
        return 20.sp;
      case AppFontSize.appTitle:
        return 36.sp;
      case AppFontSize.appLargeTitle:
        return 40.sp;
      case AppFontSize.veryLargeTitle:
        return 44.sp;
      default:
        return 24.sp;
    }
  }
}

extension FontWeightHelper on AppFontWeight {
  FontWeight get value {
    switch (this) {
      case AppFontWeight.light:
        return FontWeight.w300;
      case AppFontWeight.normal:
        return FontWeight.w400;
      case AppFontWeight.bold:
        return FontWeight.w700;
      case AppFontWeight.large:
        return FontWeight.w800;
      case AppFontWeight.medium:
        return FontWeight.w500;
      case AppFontWeight.semibold:
        return FontWeight.w600;
      default:
        return FontWeight.w500;
    }
  }
}

TextStyle appFontFamily({TextStyle? textStyle}) {
  return GoogleFonts.outfit(textStyle: textStyle);
}
