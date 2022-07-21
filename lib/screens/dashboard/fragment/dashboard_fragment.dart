import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/dashboard/component/category_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/customer_ratings_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/featured_service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/service_list_component.dart';
import 'package:booking_system_flutter/screens/dashboard/component/slider_and_location_component.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardFragment extends StatefulWidget {
  @override
  _DashboardFragmentState createState() => _DashboardFragmentState();
}

class _DashboardFragmentState extends State<DashboardFragment> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await setStatusBarColor(transparentColor, delayInMilliSeconds: 1000);

    LiveStream().on(LIVESTREAM_UPDATE_DASHBOARD, (p0) {
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
    LiveStream().dispose(LIVESTREAM_UPDATE_DASHBOARD);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          return await 2.seconds.delay;
        },
        child: Observer(
          builder: (_) {
            return FutureBuilder<DashboardResponse>(
              future: userDashboard(isCurrentLocation: appStore.isCurrentLocation, lat: getDoubleAsync(LATITUDE), long: getDoubleAsync(LONGITUDE)),
              builder: (context, snap) {
                if (snap.hasData) {
                  return Stack(
                    children: [
                      SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SliderLocationComponent(sliderList: snap.data!.slider.validate(), notificationReadCount: snap.data!.notificationUnreadCount.validate()),
                            32.height,
                            CategoryComponent(categoryList: snap.data!.category),
                            24.height,
                            FeaturedServiceListComponent(serviceList: snap.data!.featuredServices.validate()),
                            ServiceListComponent(serviceList: snap.data!.service.validate()),
                            16.height,
                            CustomerRatingsComponent(reviewData: snap.data!.dashboardCustomerReview.validate()),
                          ],
                        ),
                      ),
                      if (snap.connectionState == ConnectionState.waiting) LoaderWidget()
                    ],
                  );
                }
                return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
              },
            );
          },
        ),
      ),
    );
  }
}
