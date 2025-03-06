import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../assets/assets.dart';
import '../../controller/common_place_controller.dart';
import '../../network/services.dart';
import '../../widget/styles/app_style.dart';
import '../../widget/styles/colors.dart';
import '../../widget/utils/global_utils.dart';
import '../../widget/utils/safe_area_container.dart';
import '../controller/tracking_controller.dart';
import '../widget/back_button.dart';

class ReceiptPage extends GetView<CommonPlaceController> {
  ReceiptPage({super.key});
  final trackingPageController = Get.find<TrackingController>();

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        trackingPageController.reviewPageBackPress();
        return true;
      },
      child: SafeAreaContainer(
        statusBarColor: Colors.transparent,
        themedark: false,
        child: Scaffold(
          body: SingleChildScrollView(
            child: Container(
              color: Colors.white, // Set your desired background color here
              child: CustomPaint(
                painter: CurvePainter(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 25.h,
                      ),
                      _headingWidget(),
                      SizedBox(
                        height: 20.h,
                      ),
                      _dateWidget(),
                      SizedBox(
                        height: 20.h,
                      ),
                      _textView("Thank you for choosing RSL Ride".tr,
                          AppColor.kBackGroundColor.value, 20.0),
                      SizedBox(
                        height: 70.h,
                      ),
                      _amountWidget(),
                      SizedBox(
                        height: 20.h,
                      ),
                      _dividerWidget(
                          AppColor.kPrimaryColor.value.withOpacity(0.5)),
                      SizedBox(
                        height: 20.h,
                      ),
                      Stack(
                        children: [
                          Positioned(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: 5.w,
                                  right: 5.w,
                                  top: MediaQuery.of(context).size.height *
                                      0.15),
                              child: Transform.scale(
                                scale: 1.5,
                                child: Center(
                                  child: Image.asset(
                                    width: 160,
                                    height: 160,
                                    Assets.rslBackground,
                                    color: AppColor.kPrimaryColor.value
                                        .withOpacity(0.3),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              _baseFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _distanceFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _waitingFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _dividerWidget(AppColor.kLightTextDisabled.value
                                  .withOpacity(0.1)),
                              SizedBox(
                                height: 15.h,
                              ),
                              _eveningFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _nightFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _subTotalFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _promotionFare(),
                              SizedBox(
                                height: 15.h,
                              ),
                              _dividerWidget(AppColor.kLightTextDisabled.value
                                  .withOpacity(0.1)),
                              SizedBox(
                                height: 20.h,
                              ),
                            ],
                          ),
                        ],
                      ),
                      _textView("Payments".tr, AppColor.kPrimaryTextColor.value,
                          AppFontSize.large.value),
                      Visibility(
                        visible: ((double.tryParse(controller
                                        .BookingDetailResponse
                                        ?.value
                                        .detail
                                        ?.actualPaidAmount ??
                                    "0") ??
                                0.0) >
                            0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            _cashWidget(),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: ((double.tryParse(controller
                                        .BookingDetailResponse
                                        ?.value
                                        .detail
                                        ?.finalUsedWalletAmount ??
                                    "0") ??
                                0.0) >
                            0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10.h,
                            ),
                            _walletWidget()
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.h,
                      ),
                      _downloadPdf(),
                      SizedBox(
                        height: 20.h,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: _textView(
                            "Rate Your Driver".tr,
                            AppColor.kPrimaryColor.value,
                            AppFontSize.large.value),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      _ratingBar(),
                      SizedBox(
                        height: 50.h,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dividerWidget(Color color) {
    return Divider(
      color: color,
      thickness: 1,
    );
  }

  Widget _headingWidget() {
    return Padding(
      padding: EdgeInsets.only(top: 8.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomBackButton(
            onTap: () {
              trackingPageController.reviewPageBackPress();
            },
            color: AppColor.kBackGroundColor.value,
            padding: const EdgeInsets.only(left: 4),
          ),
          Align(
            alignment: Alignment.center,
            child: _textView("Receipt".tr, AppColor.kBackGroundColor.value,
                AppFontSize.large.value),
          ),
          Align(
            alignment: Alignment.center,
            child: Text("Receipt".tr, style: const TextStyle(color: Colors.transparent)),
          )
        ],
      ),
    );
  }

  Widget _dateWidget() {
    return Row(
      children: [
        _textView(
            "${controller.BookingDetailResponse?.value.detail?.bookingTime}",
            AppColor.kBackGroundColor.value,
            AppFontSize.medium.value),
        const Spacer(),
        _textView(
            "${'Trip ID'.tr}: ${controller.BookingDetailResponse?.value.detail?.tripId}",
            AppColor.kBackGroundColor.value,
            AppFontSize.medium.value)
      ],
    );
  }

  Widget _textView(String text, Color color, double fontSize) {
    return Text(
      text,
      style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: AppFontWeight.medium.value),
    );
  }

  Widget _amountWidget() {
    return Row(
      children: [
        _textView("Amount".tr, AppColor.kPrimaryTextColor.value,
            AppFontSize.large.value),
        const Spacer(),
        _textView("${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.amt}",
            AppColor.kPrimaryTextColor.value, AppFontSize.large.value)
      ],
    );
  }

  Widget _fareText(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AppColor.kLightTextPrimary.value.withOpacity(0.5),
        fontWeight: AppFontWeight.medium.value,
        fontSize: AppFontSize.large.value,
      ),
    );
  }

  Widget _baseFare() {
    return Row(
      children: [
        _fareText("Base Fare".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.baseFare}"),
      ],
    );
  }

  Widget _distanceFare() {
    return Row(
      children: [
        _fareText("Distance Fare".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.distanceFare}"),
      ],
    );
  }

  Widget _waitingFare() {
    return Row(
      children: [
        _fareText("Waiting Fare".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.waitingFare}"),
      ],
    );
  }

  Widget _eveningFare() {
    return Row(
      children: [
        _fareText("Evening Fare".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.finalEveningfare}"),
      ],
    );
  }

  Widget _nightFare() {
    return Row(
      children: [
        _fareText("Night Fare".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.finalNightfare}"),
      ],
    );
  }

  Widget _subTotalFare() {
    return Row(
      children: [
        _fareText("SubTotal".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.subtotal}"),
      ],
    );
  }

  Widget _promotionFare() {
    return Row(
      children: [
        _fareText("Promotion".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.promocodeFare}"),
      ],
    );
  }

  Widget _cashWidget() {
    return Row(
      children: [
        Icon(
          controller.BookingDetailResponse?.value.detail?.paymentType == 1
              ? Icons.money
              : Icons.credit_card,
          color: Colors.grey.shade500,
        ),
        SizedBox(
          width: 10.w,
        ),
        _fareText(
            "${controller.BookingDetailResponse?.value.detail?.paymentTypeLabel}"),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.actualPaidAmount}"),
      ],
    );
  }

  Widget _walletWidget() {
    return Row(
      children: [
        Icon(
          Icons.wallet,
          color: Colors.grey.shade500,
        ),
        SizedBox(
          width: 10.w,
        ),
        _fareText("Wallet".tr),
        const Spacer(),
        _fareText(
            "${GlobalUtils.currency} ${controller.BookingDetailResponse?.value.detail?.finalUsedWalletAmount}"),
      ],
    );
  }

  Widget _downloadPdf() {
    return InkWell(
          onTap: () {
            printLogs(
                "URL : ${controller.BookingDetailResponse?.value.detail?.receiptUrl}");
            openFile(
                controller.BookingDetailResponse?.value.detail?.receiptUrl ??
                    '');
          },
          child: Row(
            children: [
              Icon(Icons.file_download_outlined,
                  color: AppColor.kPrimaryColor.value),
              SizedBox(
                width: 10.w,
              ),
              _textView("DownloadPDF".tr, AppColor.kPrimaryTextColor.value,
                  AppFontSize.large.value),
              const Spacer(),
              // controller.fileDownloade.value == true
              //     ? AppLoader(
              //         size: 20.r,
              //       )
              //     : const SizedBox.shrink()
            ],
          // ),
        ));
  }

  void openFile(String filePath) async {
    if (await canLaunchUrl(Uri.parse(filePath))) {
      printLogs("Url OPEN : true");
      await launchUrl(Uri.parse(filePath));
    } else {
      throw 'Could not launch $filePath';
    }
  }

  Widget _ratingBar() {
    return Align(
      alignment: Alignment.center,
      child: RatingBar.builder(
        initialRating: 0,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        unratedColor: AppColor.kLightTextDisabled.value.withOpacity(0.3),
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: CupertinoColors.systemYellow,
        ),
        onRatingUpdate: (rating) {
          controller.rating.value = rating;
          controller.updateTextForRating(rating);
          //Get.toNamed(AppRoutes.driverRatingPage);
          print(rating);
        },
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = AppColor.kPrimaryColor.value // Set the color of your curve here
      ..style = PaintingStyle.fill;

    var path = Path();
    path.moveTo(0, size.height * 0.26); // Set the starting point of your curve

    // Set the curve control points and end point as desired
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.2,
      size.width,
      size.height * 0.3,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.3,
      size.width,
      size.height * 0.3,
    );

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
