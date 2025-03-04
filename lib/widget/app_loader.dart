import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:rsl_passenger/widget/styles/colors.dart';


class AppLoader extends StatelessWidget {
  const AppLoader({this.color, this.size, super.key});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.fourRotatingDots(
      color: color ?? AppColor.kloader.value,
      size: size ?? 30.r,
    );
  }
}

class imageLoader extends StatelessWidget {
  const imageLoader({this.color, this.size, super.key});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeRotatingDots(
      color: color ?? AppColor.kPrimaryColor.value,

      size: size ?? 30.r,
    );
  }
}
class DotLoader extends StatelessWidget {
  const DotLoader({this.color, this.size, super.key});

  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.staggeredDotsWave (
      color: color ?? AppColor.kPrimaryColor.value,

      size: size ?? 30.r,
    );
  }
}