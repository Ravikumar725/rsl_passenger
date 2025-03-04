import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

final ThemeData themeData = ThemeData(
  useMaterial3: false,
  textTheme: GoogleFonts.outfitTextTheme().apply(),
  brightness: Brightness.light,
  primaryColor: AppColor.kPrimaryColor.value,
);

final ThemeData themeDataDark = ThemeData(
  useMaterial3: false,
  textTheme: GoogleFonts.outfitTextTheme().apply(),
  brightness: Brightness.dark,
  primaryColor: AppColor.kPrimaryColor.value,
);