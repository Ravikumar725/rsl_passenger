import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../assets/assets.dart';
import '../../widget/styles/colors.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? appBarBackgroundColor;
  final Color? kStatusBarPrimaryColor;
  final Widget? title;
  final List<Widget>? actions;
  final bool? leadingWidth;
  final bool? viewSheet;
  final PreferredSizeWidget? bottom;
  final bool? automaticallyImplyLeading;
  final double? preferredSizeheight;
  final Widget? flexibleSpace;
  final bool? themedark;
  final double?elevation;
  const MyAppBar(
      {super.key,
      this.actions,
      this.appBarBackgroundColor,
      this.kStatusBarPrimaryColor,
      this.title,
      this.automaticallyImplyLeading,
      this.leadingWidth = false,
      this.bottom,
      this.preferredSizeheight,
      this.flexibleSpace,
      this.viewSheet = false,
      this.themedark,this.elevation});

  @override
  Size get preferredSize => Size(
        ScreenUtil().screenWidth,
        preferredSizeheight ?? 50.h,
      );
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          appBarBackgroundColor ?? AppColor.kAppbarPrimaryColor.value,
      automaticallyImplyLeading: automaticallyImplyLeading ?? false,
      toolbarHeight: 50.h,
      shadowColor: Colors.black.withOpacity(0.2),
      elevation:elevation?? 0,
      systemOverlayStyle:
          viewSheet == false ? _statusBar() : _transParentStatusBar(),
      centerTitle: false,
      leadingWidth: leadingWidth == true ? 62.w : 0,
      leading: _leadingWidget(),
      title: title,
      actions: actions,
      titleSpacing: 0.0,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
    );
  }

  SystemUiOverlayStyle _statusBar() {
    return SystemUiOverlayStyle(
      statusBarColor:
          kStatusBarPrimaryColor ?? AppColor.kStatusBarPrimaryColor.value,
      statusBarIconBrightness:
          themedark == false ? Brightness.dark : Brightness.light,
      statusBarBrightness:
          themedark == false ? Brightness.light : Brightness.dark,
    );
  }

  SystemUiOverlayStyle _transParentStatusBar() {
    return const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
  }

  Builder _leadingWidget() {
    return Builder(
      builder: (BuildContext context) {
        return SizedBox(
          height: 45.h,
          child: Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50.r),
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: SvgPicture.asset(
                      Assets.menu,
                      height: 12.h,
                      width: 12.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
