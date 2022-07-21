import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BackgroundComponent extends StatelessWidget {
  final String? image;
  final String? text;
  final String? subTitle;
  final double? size;

  final bool isError;

  BackgroundComponent({this.image, this.text, this.subTitle, this.size, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height(),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image ?? notDataFoundImg, width: size ?? 200),
          30.height,
          Text(text ?? language!.lblNoData, style: boldTextStyle(size: 20), textAlign: TextAlign.center).paddingSymmetric(horizontal: 16),
          if (subTitle.validate().isNotEmpty) Text(subTitle!, style: secondaryTextStyle(size: 20), textAlign: TextAlign.center).paddingSymmetric(horizontal: 16, vertical: 8),
        ],
      ),
    );
  }
}
