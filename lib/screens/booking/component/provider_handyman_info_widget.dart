import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderHandymanInfoWidget extends StatelessWidget {
  final UserData data;

  const ProviderHandymanInfoWidget({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(color: context.cardColor),
      padding: EdgeInsets.all(16),
      width: context.width(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language!.hintEmailTxt, style: secondaryTextStyle()),
              4.height,
              Text(data.email.validate(), style: boldTextStyle()),
              24.height,
            ],
          ).onTap(() {
            launchMail("${data.email.validate()}");
          }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language!.hintContactNumberTxt, style: secondaryTextStyle()),
              4.height,
              Text(data.contactNumber.validate(), style: boldTextStyle()),
              24.height,
            ],
          ).onTap(() {
            launchCall(data.contactNumber.validate());
          }),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(language!.lblMemberSince, style: secondaryTextStyle()),
              4.height,
              Text("${DateTime.parse(data.createdAt.validate()).year}", style: boldTextStyle()),
            ],
          ),
        ],
      ),
    );
  }
}
