import 'package:booking_system_flutter/generated/assets.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

Widget cachedImage(
  String? url, {
  required double height,
  double? width,
  BoxFit? fit,
  Color? color,
  String? placeHolderImage,
  AlignmentGeometry? alignment,
  bool usePlaceholderIfUrlEmpty = true,
  bool circle = false,
}) {
  if (url.validate().isEmpty) {
    return Container(
      height: height,
      width: width,
      color: grey.withOpacity(0.1),
      alignment: alignment,
      padding: EdgeInsets.all(10),
      child: Image.asset(Assets.iconsNoPhoto, color: appStore.isDarkMode ? Colors.white : Colors.black),
    ).cornerRadiusWithClipRRect(circle ? (height / 2) : 0);
  } else if (url.validate().startsWith('http')) {
    return CachedNetworkImage(
      placeholder: (_, __) {
        return placeHolderWidget(placeHolderImage: placeHolderImage, height: height, width: width, fit: fit, alignment: alignment).cornerRadiusWithClipRRect(circle ? (height / 2) : 0);
      },
      imageUrl: url!,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment as Alignment? ?? Alignment.center,
      errorWidget: (_, s, d) {
        return placeHolderWidget(placeHolderImage: placeHolderImage, height: height, width: width, fit: fit, alignment: alignment).cornerRadiusWithClipRRect(circle ? (height / 2) : 0);
      },
    ).cornerRadiusWithClipRRect(circle ? (height / 2) : 0);
  } else {
    return Image.asset(
      url!,
      height: height,
      width: width,
      fit: fit,
      color: color,
      alignment: alignment ?? Alignment.center,
      errorBuilder: (_, s, d) {
        return placeHolderWidget(height: height, width: width, fit: fit, alignment: alignment).cornerRadiusWithClipRRect(circle ? (height / 2) : 0);
      },
    ).cornerRadiusWithClipRRect(circle ? (height / 2) : 0);
  }
}

Widget placeHolderWidget({String? placeHolderImage, double? height, double? width, BoxFit? fit, AlignmentGeometry? alignment}) {
  return PlaceHolderWidget(
    height: height,
    width: width,
    alignment: alignment ?? Alignment.center,
  );
}
