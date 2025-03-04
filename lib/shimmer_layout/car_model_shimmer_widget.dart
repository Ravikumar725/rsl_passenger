import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CarModelShimmer extends StatelessWidget {
  const CarModelShimmer({Key? key, this.type = 1}) : super(key: key);
  final int type;

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
        itemBuilder: (context, index) {
          return  Container(
            margin: EdgeInsets.symmetric(vertical: 10.h,horizontal: 8.w),
            child: Row(
              children: [
                Expanded(
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[100]!,
                    highlightColor: Colors.grey[200]!,
                    child: Padding(padding: EdgeInsets.only(left: 10.w,right: 5.w),child:Column(children: [Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.r),
                        color: Colors.white,
                      ),
                      height: 60.0.h,
                    ),
                      SizedBox(height: 10.h),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.r),
                          color: Colors.white,
                        ),
                        height: 60.0.h,
                      ),


          ]
                    )
                    ),

                  ),
                ),
                _columnView(),
              ],
            ),
          ) ;
        });
  }

  Padding _columnView() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


        ],
      ),
    );
  }


  Widget bottomView() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _listView(width: 110.w),
        SizedBox(
          width: 30.w,
        ),
        _listView(width: 60.w),
      ],
    );
  }

  Widget _listView({double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[100]!,
      highlightColor: Colors.grey[200]!,
      child: Container(
        width: width,
        height: 15.0,
        color: Colors.white,
      ),
    );
  }


}
