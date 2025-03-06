import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../network/services.dart';

void makePhoneCall({required String phone}) async {
  printLogs("makePhoneCall  : $phone");

  canLaunchUrl(Uri(scheme: 'tel', path: phone)).then((value) async {
    if (value == true) {
      await launchUrl(Uri(
        scheme: 'tel',
        path: phone,
      ));
    } else {
      Get.snackbar( "Message", "Please wait");
    }
  }).onError((error, stackTrace) {});
}
