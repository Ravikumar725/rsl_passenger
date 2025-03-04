import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:rsl_passenger/routes/routes.dart';
import 'binding/bindings.dart';
import 'dashboard/controller/dashboard_page_controller.dart';
import 'dashboard/dashboard_page.dart';
import 'dashboard/getx_storage.dart';
import 'network/services.dart';

void main() {
  Get.put(ApiProvider());
  Get.put(DashBoardController());
  Get.put(GetStorageController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: "/",
      initialBinding: AppBindings(),
      getPages: pages,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7AC6BF)),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
      builder: (context, child) {
        return ScreenUtilInit(
          designSize: const Size(360, 640),
          minTextAdapt: true,
          splitScreenMode: true,
          child: child!,
        );
      },
    );
  }
}
