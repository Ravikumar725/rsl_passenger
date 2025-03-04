import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rsl_passenger/splash_screen.dart';

import 'network/services.dart';


class AppStart extends StatelessWidget {
  AppStart({super.key});
  @override
  Widget build(BuildContext context) {
    return  checkAppConnection();
  }

  Widget _appStartWidget() {
    return FutureBuilder<Status>(
      future: checkLoginStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data?.status == 1) {
            return const SplashScreen();
          } else if (snapshot.data?.status == 2) {
            return const SplashScreen();
            // return const LoginSelectionNewPage();
          }
        } else {
          return const SplashScreen();
        }
        return const SplashScreen();
      },
    );
  }

  Widget checkAppConnection() {
      return const SplashScreen();
  }
  Future<Status> checkLoginStatus() async {
    int? status = 2;
    const userInfo = "9";
    if (userInfo.isEmpty) {
      status = 2;
    } else {
      status = 1;
    }

    return Status(status: status);
  }
}

class Status {
  int? status;

  Status({this.status});
}
