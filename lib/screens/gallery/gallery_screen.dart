import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/screens/gallery/gallery_component.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class GalleryScreen extends StatefulWidget {
  final String serviceName;
  final List<String> attachments;

  GalleryScreen({required this.serviceName, required this.attachments});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  @override
  void initState() {
    afterBuildCreated(() {
      setStatusBarColor(context.primaryColor);
    });
    super.initState();
  }

  @override
  void dispose() {
    setStatusBarColor(Colors.transparent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("${language!.lblGallery} ${'- ${widget.serviceName}'}", textColor: Colors.white, color: context.primaryColor, backWidget: BackWidget()),
      body: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: List.generate(widget.attachments.length, (i) => GalleryComponent(images: widget.attachments, index: i)),
      ).paddingSymmetric(horizontal: 16, vertical: 16),
    );
  }
}
