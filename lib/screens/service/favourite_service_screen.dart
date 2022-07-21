import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/background_component.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/component/service_component.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class FavouriteServiceScreen extends StatefulWidget {
  const FavouriteServiceScreen({Key? key}) : super(key: key);

  @override
  _FavouriteServiceScreenState createState() => _FavouriteServiceScreenState();
}

class _FavouriteServiceScreenState extends State<FavouriteServiceScreen> {
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      init();
    });
  }

  Future<void> init() async {
    //
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        language!.lblFavorite,
        color: context.primaryColor,
        textColor: white,
        backWidget: BackWidget(),
      ),
      body: FutureBuilder<ServiceResponse>(
        future: getWishlist(),
        builder: (context, snap) {
          if (snap.hasData) {
            if (snap.data!.serviceList.validate().isEmpty) return BackgroundComponent();

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: AnimatedWrap(
                spacing: 16,
                runSpacing: 16,
                listAnimationType: ListAnimationType.Scale,
                itemCount: snap.data!.serviceList!.length,
                itemBuilder: (_, index) {
                  return ServiceComponent(
                    serviceData: snap.data!.serviceList![index],
                    width: context.width() / 2 - 24,
                    isFavouriteService: true,
                    onUpdate: () {
                      setState(() {});
                    },
                  );
                },
              ),
            );
          }

          return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
        },
      ),
    );
  }
}
