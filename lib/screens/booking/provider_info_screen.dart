import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/user_info_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/provider_info_response.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/component/provider_handyman_info_widget.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/search_list_screen.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ProviderInfoScreen extends StatefulWidget {
  final int? providerId;

  ProviderInfoScreen({this.providerId});

  @override
  ProviderInfoScreenState createState() => ProviderInfoScreenState();
}

class ProviderInfoScreenState extends State<ProviderInfoScreen> {
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

  Widget servicesWidget({required List<ServiceData> list, int? providerId}) {
    return Column(
      children: [
        8.height,
        ViewAllLabel(
          label: language!.service,
          list: list,
          onTap: () {
            SearchListScreen(providerId: providerId).launch(context, pageRouteAnimation: PageRouteAnimation.Fade);
          },
        ),
        8.height,
        AnimatedWrap(
          spacing: 16,
          runSpacing: 16,
          itemCount: list.length,
          itemBuilder: (_, index) => ServiceComponent(serviceData: list[index], width: context.width()),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProviderInfoResponse>(
      future: getProviderDetail(widget.providerId.validate()),
      builder: (context, snap) {
        return Scaffold(
          appBar: appBarWidget(
            language!.lblAboutProvider,
            textColor: white,
            elevation: 1.5,
            color: context.primaryColor,
            backWidget: BackWidget(),
          ),
          body: snap.hasData
              ? Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UserInfoWidget(data: snap.data!.userData!, isOnTapEnabled: true),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              16.height,
                              Text(language!.lblAbout, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
                              16.height,
                              if (snap.data!.userData!.description.validate().isNotEmpty) Text(snap.data!.userData!.description.validate(), style: boldTextStyle()),
                              ProviderHandymanInfoWidget(data: snap.data!.userData!),
                              16.height,
                              servicesWidget(list: snap.data!.serviceList!, providerId: widget.providerId.validate()),
                            ],
                          ).paddingAll(16),
                        ],
                      ),
                    ),
                  ],
                )
              : LoaderWidget(),
        );
      },
    );
  }
}
