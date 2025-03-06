import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DriverShimmerWidget extends StatelessWidget {
  const DriverShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerPlaceholderWidget(
                  height: 60.0, width: 60.0, borderRadius: 30.0),
              SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerPlaceholderWidget(height: 12.0, width: 100.0),
                    SizedBox(height: 8.0),
                    ShimmerPlaceholderWidget(height: 12.0, width: 80.0),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Divider(),
          SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ShimmerPlaceholderWidget(
                  height: 35.0, width: 80.0, borderRadius: 8.0),
              ShimmerPlaceholderWidget(
                  height: 35.0, width: 80.0, borderRadius: 8.0),
            ],
          ),
          SizedBox(height: 10.0),
          Divider(),
          SizedBox(height: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ShimmerPlaceholderWidget(height: 12.0, width: 100.0),
              SizedBox(height: 8.0),
              ShimmerPlaceholderWidget(height: 12.0, width: 80.0),
            ],
          ),
          SizedBox(height: 10.0),
          Divider(),
          SizedBox(height: 10.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ShimmerPlaceholderWidget(height: 12.0, width: 100.0),
              SizedBox(height: 12.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerPlaceholderWidget(height: 12.0, width: 80.0),
                  ShimmerPlaceholderWidget(height: 12.0, width: 80.0),
                ],
              ),
              SizedBox(height: 8.0),
              ShimmerPlaceholderWidget(height: 12.0, width: 80.0),
            ],
          ),
        ],
      ),
    );
  }
}

class ShimmerPlaceholderWidget extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;

  const ShimmerPlaceholderWidget({
    super.key,
    this.height = 20.0,
    this.width = double.infinity,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
