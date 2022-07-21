import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/services/location_service.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class LocationServiceDialog extends StatefulWidget {
  final Function()? onAccept;

  LocationServiceDialog({this.onAccept});

  @override
  State<LocationServiceDialog> createState() => _LocationServiceDialogState();
}

class _LocationServiceDialogState extends State<LocationServiceDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(appStore.isCurrentLocation ? language!.msgForLocationOn : language!.lblLocationOffMsg, style: primaryTextStyle()).paddingAll(16),
          16.height,
          AppButton(
            text: language!.lblOk,
            width: context.width(),
            color: primaryColor,
            textColor: Colors.white,
            onTap: () async {
              getUserLocation().then((value) async {
                await appStore.setCurrentLocation(!appStore.isCurrentLocation);
                setState(() {});

                appStore.setLoading(true);

                finish(context, true);
              }).catchError((e) {
                log(e.toString());
              });
            },
          ).paddingAll(16)
        ],
      ),
    );
  }
}
