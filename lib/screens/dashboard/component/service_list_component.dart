import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:booking_system_flutter/screens/service/search_list_screen.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ServiceListComponent extends StatelessWidget {
  final List<ServiceData> serviceList;

  ServiceListComponent({required this.serviceList});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          ViewAllLabel(
            label: language!.service,
            list: serviceList,
            onTap: () {
              SearchListScreen().launch(context);
            },
          ).paddingSymmetric(horizontal: 16),
          8.height,
          serviceList.isNotEmpty
              ? Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: List.generate(serviceList.length, (index) {
                    return ServiceComponent(serviceData: serviceList[index], width: context.width() / 2 - 26);
                  }),
                ).paddingSymmetric(horizontal: 16, vertical: 8)
              : Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Column(
                    children: [
                      Image.asset(notDataFoundImg, height: 126),
                      32.height,
                      Text(language!.lblNoServicesFound, style: boldTextStyle()),
                    ],
                  ),
                ).center(),
        ],
      ),
    );
  }
}
