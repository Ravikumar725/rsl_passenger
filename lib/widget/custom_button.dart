import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rsl_passenger/widget/styles/app_style.dart';
import 'package:rsl_passenger/widget/styles/colors.dart';

import 'app_loader.dart';


class CustomButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final String? secondaryText;
  final TextStyle? style;
  final TextStyle? secondaryTextStyle;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color borderColor;
  final double? height;
  final double? width;
  final bool? isLoader;
  final double? borderRadius;
  final LinearGradient? linearColor;
  final bool? isTaxiLoader;

  const CustomButton(
      {super.key,
      required this.text,
      this.secondaryText,
      this.onTap,
      this.style,
      this.secondaryTextStyle,
      this.padding,
      this.color,
      this.height,
      this.width,
      this.borderColor = Colors.transparent,
      this.borderRadius,
      this.isLoader = false,
      this.linearColor,
      this.isTaxiLoader = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 15.r),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius ?? 25.r),
        child: Material(
          color: color ?? AppColor.kPrimaryButtonBackGround.value,
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: height ?? 50.h,
              width: width ?? 50.h,
              decoration: BoxDecoration(
                  gradient: linearColor ?? primaryButtonLinearColor,
                  borderRadius: BorderRadius.circular(borderRadius ?? 25.r),
                  border: Border.all(color: borderColor)),
              child: isLoader == true
                  ? isTaxiLoader == true
                      ? CupertinoActivityIndicator(
                          animating: true,
                          radius: 10.r,
                          color: AppColor.kStatusBarPrimaryColor.value,
                        )
                      : AppLoader(
                          color: AppColor.kBackGroundColor.value,
                        )
                  : Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            text,
                            style: style ??
                                TextStyle(
                                  color: AppColor.kSecondaryTextColor.value,
                                  fontSize: AppFontSize.medium.value,
                                  fontWeight: AppFontWeight.semibold.value,
                                ),
                          ),
                          if (secondaryText?.isNotEmpty ?? false) ...[
                            Text(
                              "$secondaryText",
                              style: secondaryTextStyle ??
                                  TextStyle(
                                    color: AppColor.kSecondaryTextColor.value,
                                    fontSize: AppFontSize.verySmall.value,
                                    fontWeight: AppFontWeight.light.value,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
