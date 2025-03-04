import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../widget/styles/colors.dart';

class LocationListShimmer extends StatelessWidget {
  const LocationListShimmer({super.key,});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      margin: EdgeInsets.only(left: 2.w, right: 2.w, bottom: 4.h),
      child: listViewBuilder(),
    );
  }

  ListView listViewBuilder() {
    return ListView.builder(
        itemCount: 4,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[100]!,
                    highlightColor: Colors.grey[200]!,
                    child: Padding(
                        padding: EdgeInsets.only(left: 10.w),
                        child: Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColor.kStatusBarPrimaryColor.value,
                            ),
                            height: 40.h,
                          ),
                        ])),
                  ),
                ),
                Expanded(flex: 3, child: _columnView()),
              ],
            ),
          );
        });
  }

  Padding _columnView() {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[100]!,
            highlightColor: Colors.grey[200]!,
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                ),
                width: 100.w,
                height: 10.0.h,
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Shimmer.fromColors(
            baseColor: Colors.grey[100]!,
            highlightColor: Colors.grey[200]!,
            child: Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: Colors.white,
                ),
                height: 10.0.h,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
