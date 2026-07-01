import 'package:flutter/material.dart';

class Gap extends StatelessWidget {
  const Gap({
    super.key,
    this.height,
    this.width,
    this.isSliver = false,
  });

  final double? height;
  final double? width;
  final bool isSliver;


  @override
  Widget build(BuildContext context) {
    if (isSliver) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: height ?? 0,
          width: width ?? 0,
        ),
      );
    } else {
      return SizedBox(
        height: height ?? 0,
        width: width ?? 0,
      );
    }
  }
}

