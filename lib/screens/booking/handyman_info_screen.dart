import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/user_info_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/provider_info_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/component/provider_handyman_info_widget.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/review/review_widget.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class HandymanInfoScreen extends StatefulWidget {
  final int? handymanId;

  HandymanInfoScreen({this.handymanId});

  @override
  HandymanInfoScreenState createState() => HandymanInfoScreenState();
}

class HandymanInfoScreenState extends State<HandymanInfoScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget aboutWidget({required String desc}) {
    return Text(desc.validate(), style: boldTextStyle());
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<ProviderInfoResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserInfoWidget(data: snap.data!.userData!, isOnTapEnabled: true, forProvider: false),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Text(language!.about, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                  16.height,
                  if (snap.data!.userData!.description.validate().isNotEmpty) aboutWidget(desc: snap.data!.userData!.description.validate()),
                  ProviderHandymanInfoWidget(data: snap.data!.userData!),
                  16.height,
                  ViewAllLabel(
                    label: language!.review,
                    list: snap.data!.handymanRatingReviewList,
                    onTap: () {
                      RatingViewAllScreen(handymanId: snap.data!.userData!.id).launch(context);
                    },
                  ),
                  snap.data!.handymanRatingReviewList.validate().isNotEmpty
                      ? AnimatedListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          slideConfiguration: SlideConfiguration(duration: 400.milliseconds, delay: 50.milliseconds),
                          padding: EdgeInsets.symmetric(vertical: 6),
                          itemCount: snap.data!.handymanRatingReviewList.validate().length,
                          itemBuilder: (context, index) => ReviewWidget(data: snap.data!.handymanRatingReviewList.validate()[index], isCustomer: true),
                        )
                      : Text(language!.lblNoReviews, style: secondaryTextStyle()).center().paddingOnly(top: 16),
                ],
              ).paddingAll(16),
            ],
          ),
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<ProviderInfoResponse>(
      future: getProviderDetail(widget.handymanId.validate()),
      builder: (context, snap) {
        return Scaffold(
          appBar: appBarWidget(
            language!.lblAboutHandyman,
            textColor: white,
            elevation: 1.5,
            color: context.primaryColor,
            backWidget: BackWidget(),
          ),
          body: buildBodyWidget(snap),
        );
      },
    );
  }
}
