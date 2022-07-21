import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/screens/zoom_image_screen.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ImageBorder extends StatelessWidget {
  final String src;
  final double height;
  final double? width;

  ImageBorder({required this.src, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.dividerColor, width: 1),
        shape: BoxShape.circle,
      ),
      child: cachedImage(
        src,
        circle: true,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ).onTap(() {
        ZoomImageScreen(galleryImages: [src], index: 0).launch(context);
      }),
    );
  }
}
