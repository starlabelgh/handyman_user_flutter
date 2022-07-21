import 'package:booking_system_flutter/component/disabled_rating_bar_widget.dart';
import 'package:booking_system_flutter/component/image_border_component.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class UserInfoWidget extends StatelessWidget {
  final UserData data;
  final bool? isOnTapEnabled;
  final bool forProvider;

  UserInfoWidget({required this.data, this.isOnTapEnabled, this.forProvider = true});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOnTapEnabled.validate(value: false)
          ? null
          : () {
              ProviderInfoScreen(providerId: data.id).launch(context);
            },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: boxDecorationDefault(
          color: context.cardColor,
          border: Border.all(color: context.dividerColor, width: 1),
          borderRadius: radiusOnly(bottomLeft: defaultRadius, bottomRight: defaultRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ImageBorder(
              src: data.profileImage.validate(),
              height: 90,
              width: 90,
            ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.displayName.validate(), style: boldTextStyle(size: 18)),
                        if (data.designation.validate().isNotEmpty)
                          Column(
                            children: [
                              4.height,
                              Marquee(child: Text(data.designation.validate(), style: secondaryTextStyle())),
                            ],
                          ),
                      ],
                    ).flexible(),
                    Image.asset(ic_verified, height: 24, width: 24, color: verifyAcColor).visible(data.isVerifyProvider == 1),
                  ],
                ),
                10.height,
                DisabledRatingBarWidget(rating: forProvider ? data.providersServiceRating.validate() : data.handymanRating.validate()),
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
