import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../assets/assets.dart';
import '../../widget/styles/colors.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;

  const CustomBackButton(
      {this.onTap, super.key, this.color, this.padding, this.iconSize});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(1.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(50.r),
        radius: 50.r,
        onTap: onTap ??
            () {
              Get.back();
            },
        child: Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          child: SvgPicture.asset(
            Assets.backArrow,
            // ignore: deprecated_member_use
            color: color ?? AppColor.kWhiteIconColor.value,
            height: iconSize ?? 12.h,
            width: iconSize ?? 12.w,
          ),
        ),
      ),
    );
  }
// SvgIconWidget(
//    onTap:onTap?? (){
//     Get.back();
//    },
//     svgIcon:SvgPicture.asset(Assets.backArrow,color:AppColor.kWhiteIconColor.value,height: 18.h,width: 18.w,) ,
//   );
// }
}

class CustomCloseButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final IconData? icon;

  const CustomCloseButton(
      {this.onTap, super.key, this.color, this.padding, this.iconSize, this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ??
          () {
            Get.back();
          },
      child: Container(
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
                strokeAlign: 1.r,
                color: AppColor.kLightTextPrimary.value.withOpacity(0.3))),
        child: Icon(
          icon ?? Icons.close,
          size: 20.r,
          color: color ?? AppColor.kLightTextPrimary.value,
        ),
      ),
    );
  }
}

class TaxiCustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final String? icon;

  const TaxiCustomBackButton(
      {this.onTap, super.key, this.color, this.padding, this.iconSize,this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: InkWell(
        onTap: onTap ??
            () {
              Get.back();
            },
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                  strokeAlign: 1.r,
                  color: AppColor.kLightTextPrimary.value.withOpacity(0.3))),
          child: SvgPicture.asset(
            icon ?? Assets.backArrow,
            // ignore: deprecated_member_use
            color: color ?? AppColor.kWhiteIconColor.value,
            height: iconSize ?? 10.h,
            width: iconSize ?? 10.w,
          ),
        ),
      ),
    );
  }
}
