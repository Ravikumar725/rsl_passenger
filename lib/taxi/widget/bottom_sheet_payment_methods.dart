import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../assets/assets.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../controller/taxi_controller.dart';

bottomSheetPaymentMethods() {
  final controller = Get.find<TaxiController>();

  return Get.bottomSheet(
    Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.r), topRight: Radius.circular(10.r))),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 14.w),
        child: /*Obx(
          () =>*/ Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _divider(),
              Padding(
                padding: const EdgeInsets.only(
                    top: 12, bottom: 0, left: 5, right: 5),
                child: Text(
                  "Payment methods",
                  style: TextStyle(
                      color: AppColor.kLightTextSecondary.value,
                      fontSize: AppFontSize.large.value,
                      fontWeight: AppFontWeight.normal.value),
                ),
              ),
              SizedBox(height: 10.h),
              // _walletWidget(controller),
              // _applePayWidget(controller),
              _cashWidget(controller),
              // controller.creditCardList.isNotEmpty
              //     ? ListView.builder(
              //         padding: EdgeInsets.only(top: 4.h),
              //         shrinkWrap: true,
              //         itemCount: controller.creditCardList.length,
              //         physics: const BouncingScrollPhysics(),
              //         itemBuilder: (BuildContext context, int index) {
              //           return _cardListWidget(controller, index);
              //         },
              //       )
              //     : const SizedBox(),
            ],
          ),
        ),
      ),
    // ),
  );
}
Widget _cashWidget(TaxiController controller) {
  return Obx(
    () => InkWell(
      onTap: () => ()/*controller.updateCashPayment()*/,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 5, right: 5),
        child: Row(
          children: [
            Image.asset(
              Assets.moneyImg,
              height: 20,
              width: 20,
              color: AppColor.kLightTextSecondary.value,
            ),
            SizedBox(
              width: 12.w,
            ),
            _text("Cash"),
            const Spacer(),
            Icon(
              controller.paymentType.value == controller.PAYMENT_ID_CASH.value
                  ? Icons.check_circle
                  : Icons.circle_outlined,
              color: controller.paymentType.value ==
                      controller.PAYMENT_ID_CASH.value
                  ? AppColor.kPrimaryColor.value
                  : AppColor.kLightTextPrimary.value,
              size: 22,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _text(String text) {
  return Text(
    text,
    style: TextStyle(
      color: AppColor.kPrimaryTextColor.value,
      fontSize: AppFontSize.medium.value,
      fontWeight: AppFontWeight.normal.value,
    ),
  );
}

Widget _divider() {
  return Padding(
    padding: const EdgeInsets.all(0.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 2.h,
          width: 40.w,
          decoration: BoxDecoration(
              color: AppColor.kBlack.value.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20.r)),
        )
      ],
    ),
  );
}
