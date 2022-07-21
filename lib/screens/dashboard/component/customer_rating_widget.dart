import 'package:booking_system_flutter/component/add_review_dialog.dart';
import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/component/disabled_rating_bar_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/dashboard_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CustomerRatingWidget extends StatefulWidget {
  final DashboardCustomerReview data;
  final Function(DashboardCustomerReview)? onDelete;

  CustomerRatingWidget({required this.data, this.onDelete});

  @override
  _CustomerRatingWidgetState createState() => _CustomerRatingWidgetState();
}

class _CustomerRatingWidgetState extends State<CustomerRatingWidget> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  Widget serviceWidget({required DashboardCustomerReview data}) {
    return Container(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cachedImage(
                data.attchments.validate().isNotEmpty ? data.attchments!.first.validate() : '',
                height: 80,
                width: 80,
                fit: BoxFit.cover,
              ).cornerRadiusWithClipRRect(defaultRadius),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${data.serviceName.validate()}', style: boldTextStyle(size: 20), maxLines: 3, overflow: TextOverflow.ellipsis),
                  TextButton(
                    style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.all(0))),
                    onPressed: () {
                      ServiceDetailScreen(serviceId: data.serviceId.validate()).launch(context);
                    },
                    child: Text(language!.viewDetail, style: secondaryTextStyle()),
                  ),
                ],
              ).flexible()
            ],
          ),
        ],
      ),
    );
  }

  Widget reviewWidget({required DashboardCustomerReview data}) {
    return Container(
      decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(language!.lblYourComment, style: boldTextStyle(size: 18)).expand(),
              ic_edit_square.iconImage(size: 16).paddingAll(8).onTap(() async {
                Map<String, dynamic>? dialogData = await showInDialog(
                  context,
                  contentPadding: EdgeInsets.zero,
                  builder: (p0) {
                    return AddReviewDialog(
                      customerReview: RatingData(
                        bookingId: data.bookingId,
                        createdAt: data.createdAt,
                        customerId: data.customerId,
                        id: data.id,
                        profileImage: data.profileImage,
                        rating: data.rating,
                        review: data.review,
                        serviceId: data.serviceId,
                        customerName: data.customerName,
                      ),
                      isCustomerRating: true,
                    );
                  },
                );

                if (dialogData != null) {
                  widget.data.rating = dialogData['rating'];
                  widget.data.review = dialogData['review'];

                  setState(() {});

                  LiveStream().emit(LIVESTREAM_UPDATE_DASHBOARD);
                }
              }),
              ic_delete.iconImage(size: 16).paddingAll(8).onTap(() {
                deleteDialog(
                  context,
                  title: language!.lblDeleteReview,
                  subTitle: language!.lblConfirmReviewSubTitle,
                  onSuccess: () async {
                    appStore.setLoading(true);

                    if (getStringAsync(USER_EMAIL) != DEFAULT_EMAIL) {
                      await deleteReview(id: data.id.validate()).then((value) {
                        appStore.setLoading(false);
                        toast(value.message);

                        widget.onDelete?.call(data);
                        LiveStream().emit(LIVESTREAM_UPDATE_DASHBOARD);
                      }).catchError((e) {
                        appStore.setLoading(false);
                        toast(e.toString(), print: true);
                      });
                    } else {
                      toast(language!.lblUnAuthorized);
                    }

                    setState(() {});
                  },
                );
                return;
              }),
            ],
          ),
          Divider(),
          DisabledRatingBarWidget(rating: data.rating.validate().toDouble()),
          8.height,
          Text(data.review.validate(), style: secondaryTextStyle(size: 14)),
        ],
      ),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(8),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          serviceWidget(data: widget.data),
          16.height,
          reviewWidget(data: widget.data),
        ],
      ),
    );
  }
}
