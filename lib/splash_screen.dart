import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rsl_passenger/widget/styles/colors.dart';
import 'assets/assets.dart';
import 'safe_area_container.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  SafeAreaContainer(statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppColor.kSplashColor.value,
       navigationBarthemedark: false,
      child: Container(
          padding: EdgeInsets.zero,
          child: Image.asset(
            fit: BoxFit.cover,
            Assets.splashGif, // Replace with your GIF file path
            width: MediaQuery.of(context).size.width, // Adjust width as needed
            height: MediaQuery.of(context).size.height,
          ),
      ),
    );
  }
}
