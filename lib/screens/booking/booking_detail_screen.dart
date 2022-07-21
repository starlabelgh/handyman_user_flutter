import 'package:booking_system_flutter/component/add_review_dialog.dart';
import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/view_all_label_component.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/booking/booking_history_component.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_handyman_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/booking_detail_provider_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/countdown_component.dart';
import 'package:booking_system_flutter/screens/booking/component/price_common_widget.dart';
import 'package:booking_system_flutter/screens/booking/component/reason_dialog.dart';
import 'package:booking_system_flutter/screens/booking/component/service_proof_list_widget.dart';
import 'package:booking_system_flutter/screens/booking/handyman_info_screen.dart';
import 'package:booking_system_flutter/screens/booking/provider_info_screen.dart';
import 'package:booking_system_flutter/screens/payment/payment_screen.dart';
import 'package:booking_system_flutter/screens/review/rating_view_all_screen.dart';
import 'package:booking_system_flutter/screens/review/review_widget.dart';
import 'package:booking_system_flutter/screens/service/service_detail_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  BookingDetailScreen({required this.bookingId});

  @override
  _BookingDetailScreenState createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  //region Widgets
  Widget bookingIdWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          language!.lblBookingID,
          style: boldTextStyle(size: LABEL_TEXT_SIZE, color: appStore.isDarkMode ? white : gray.withOpacity(0.8)),
        ),
        Text('#' + widget.bookingId.validate().toString(), style: boldTextStyle(color: primaryColor, size: LABEL_TEXT_SIZE)),
      ],
    );
  }

  Widget _buildReasonWidget({required BookingDetailResponse snap}) {
    if (((snap.bookingDetail!.status == BookingStatusKeys.cancelled || snap.bookingDetail!.status == BookingStatusKeys.rejected || snap.bookingDetail!.status == BookingStatusKeys.failed) &&
        ((snap.bookingDetail!.reason != null && snap.bookingDetail!.reason!.isNotEmpty))))
      return Container(
        padding: EdgeInsets.all(16),
        color: redColor.withOpacity(0.08),
        width: context.width(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(getReasonText(snap.bookingDetail!.status.validate()), style: primaryTextStyle(color: redColor, size: 18)),
            6.height,
            Text('${snap.bookingDetail!.reason.validate()}', style: secondaryTextStyle()),
          ],
        ),
      );

    return SizedBox();
  }

  Widget serviceDetailWidget({required BookingData bookingDetail, required ServiceData serviceDetail}) {
    return GestureDetector(
      onTap: () {
        ServiceDetailScreen(serviceId: bookingDetail.serviceId.validate()).launch(context);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(bookingDetail.serviceName.validate(), style: boldTextStyle(size: 20)),
              16.height,
              Row(
                children: [
                  Text("${language!.lblDate}: ", style: secondaryTextStyle()),
                  bookingDetail.date.validate().isNotEmpty
                      ? Text(
                          formatDate(bookingDetail.date.validate(), format: DATE_FORMAT_2),
                          style: boldTextStyle(size: 14),
                        )
                      : SizedBox(),
                ],
              ).visible(bookingDetail.date.validate().isNotEmpty),
              8.height,
              Row(
                children: [
                  Text("${language!.lblTime}: ", style: secondaryTextStyle()),
                  bookingDetail.date.validate().isNotEmpty
                      ? Text(
                          formatDate(bookingDetail.date.validate(), format: HOUR_12_FORMAT),
                          style: boldTextStyle(size: 14),
                        )
                      : SizedBox(),
                ],
              ).visible(bookingDetail.date.validate().isNotEmpty),
            ],
          ).expand(),
          if (serviceDetail.attachments!.isNotEmpty)
            cachedImage(
              serviceDetail.attachments!.first,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ).cornerRadiusWithClipRRect(8)
        ],
      ),
    );
  }

  Widget handymanWidget({required List<UserData> handymanList, required ServiceData serviceDetail, required BookingData bookingDetail}) {
    if (handymanList.isEmpty) return Offstage();

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text(language!.lblAboutHandyman, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
          16.height,
          Column(
            children: handymanList.map((e) {
              return BookingDetailHandymanWidget(
                handymanData: e,
                serviceDetail: serviceDetail,
                bookingDetail: bookingDetail,
                onUpdate: () {
                  setState(() {});
                },
              ).onTap(() {
                HandymanInfoScreen(handymanId: e.id).launch(context).then((value) => null);
              });
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget providerWidget({required UserData? providerData, required ServiceData serviceDetail}) {
    if (providerData == null) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.height,
        Text(language!.lblAboutProvider, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        BookingDetailProviderWidget(providerData: providerData).onTap(() {
          ProviderInfoScreen(providerId: providerData.id).launch(context);
        }),
      ],
    );
  }

  Widget serviceProofListWidget({required List<ServiceProof> list}) {
    if (list.isEmpty) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Text(language!.lblServiceProof, style: boldTextStyle(size: LABEL_TEXT_SIZE)),
        16.height,
        Container(
          decoration: boxDecorationWithRoundedCorners(
            backgroundColor: context.cardColor,
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: ListView.separated(
            itemBuilder: (context, index) => ServiceProofListWidget(data: list[index]),
            itemCount: list.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return Divider(height: 0);
            },
          ),
        ),
        20.height,
      ],
    );
  }

  Widget customerReviewWidget({required List<RatingData> ratingList, required RatingData? customerReview, required BookingData bookingDetail}) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bookingDetail.status == BookingStatusKeys.complete && bookingDetail.paymentStatus == "paid")
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                24.height,
                if (customerReview == null)
                  Text(language!.lblNotRatedYet, style: boldTextStyle(size: LABEL_TEXT_SIZE))
                else
                  Row(
                    children: [
                      16.height,
                      Text(language!.yourReview, style: boldTextStyle(size: LABEL_TEXT_SIZE)).expand(),
                      ic_edit_square.iconImage(size: 16).paddingAll(8).onTap(() {
                        showInDialog(
                          context,
                          contentPadding: EdgeInsets.zero,
                          builder: (p0) {
                            return AddReviewDialog(customerReview: customerReview);
                          },
                        ).then((value) {
                          if (value ?? false) {
                            setState(() {});
                          }
                        }).catchError((e) {
                          toast(e.toString());
                        });
                      }),
                      ic_delete.iconImage(size: 16).paddingAll(8).onTap(() {
                        deleteDialog(context, onSuccess: () async {
                          appStore.setLoading(true);

                          await deleteReview(id: customerReview.id.validate()).then((value) {
                            toast(value.message);
                          }).catchError((e) {
                            toast(e.toString());
                          });

                          setState(() {});

                          appStore.setLoading(false);
                        }, title: language!.lblDeleteReview, subTitle: language!.lblConfirmReviewSubTitle);
                        return;
                      }),
                    ],
                  ),
                16.height,
                if (customerReview == null)
                  AppButton(
                    color: context.primaryColor,
                    onTap: () {
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        builder: (p0) {
                          return AddReviewDialog(serviceId: bookingDetail.serviceId.validate(), bookingId: bookingDetail.id.validate());
                        },
                      ).then((value) {
                        if (value) {
                          setState(() {});
                        }
                      }).catchError((e) {
                        log(e.toString());
                      });
                    },
                    text: language!.btnRate,
                    textColor: Colors.white,
                  ).withWidth(context.width())
                else
                  ReviewWidget(data: customerReview),
                8.height,
              ],
            ),
          24.height,
          if (ratingList.isNotEmpty)
            ViewAllLabel(
              label: language!.review,
              list: ratingList,
              onTap: () {
                RatingViewAllScreen(ratingData: ratingList, serviceId: bookingDetail.serviceId).launch(context);
              },
            ),
          8.height,
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: ratingList.length,
            itemBuilder: (context, index) => ReviewWidget(data: ratingList[index]),
          ),
        ],
      ),
    );
  }

  Widget counterWidget({required BookingDetailResponse value}) {
    if (value.bookingDetail!.isHourlyService &&
        (value.bookingDetail!.status == BookingStatusKeys.inProgress ||
            value.bookingDetail!.status == BookingStatusKeys.hold ||
            value.bookingDetail!.status == BookingStatusKeys.complete ||
            value.bookingDetail!.status == BookingStatusKeys.onGoing))
      return Column(
        children: [
          16.height,
          CountdownWidget(bookingDetailResponse: value),
        ],
      );
    else
      return Offstage();
  }

  Widget _action({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.pending || status.bookingDetail!.status == BookingStatusKeys.accept) {
      return AppButton(
        text: language!.lblCancelBooking,
        textColor: Colors.white,
        color: primaryColor,
        onTap: () {
          _handleCancelClick(status: status);
        },
      );
    } else if (status.bookingDetail!.status == BookingStatusKeys.onGoing) {
      return AppButton(
        text: language!.lblStart,
        textColor: Colors.white,
        color: Colors.green,
        onTap: () {
          _handleStartClick(status: status);
        },
      );
    } else if (status.bookingDetail!.status == BookingStatusKeys.inProgress) {
      return Row(
        children: [
          AppButton(
            text: language!.lblHold,
            textColor: Colors.white,
            color: holdColor,
            onTap: () {
              _handleHoldClick(status: status);
            },
          ).expand(),
          16.width,
          AppButton(
            text: language!.done,
            textColor: Colors.white,
            color: primaryColor,
            onTap: () {
              _handleDoneClick(status: status);
            },
          ).expand(),
        ],
      );
    } else if (status.bookingDetail!.status == BookingStatusKeys.hold) {
      return Row(
        children: [
          AppButton(
            text: language!.lblResume,
            textColor: Colors.white,
            color: primaryColor,
            onTap: () {
              _handleResumeClick(status: status);
            },
          ).expand(),
          16.width,
          AppButton(
            text: language!.lblCancel,
            textColor: Colors.white,
            color: cancelledColor,
            onTap: () {
              _handleCancelClick(status: status);
            },
          ).expand(),
        ],
      );
    } else if (status.bookingDetail!.status == BookingStatusKeys.complete && (status.bookingDetail!.paymentStatus == null)) {
      return AppButton(
        text: language!.lblPayNow,
        textColor: Colors.white,
        color: Colors.green,
        onTap: () {
          PaymentScreen(data: status).launch(context);
        },
      );
    }

    return SizedBox();
  }

  //endregion

  //region ActionMethods
  //region Cancel
  void _handleCancelClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.pending || status.bookingDetail!.status == BookingStatusKeys.accept || status.bookingDetail!.status == BookingStatusKeys.hold) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        builder: (context) {
          return AppCommonDialog(
            title: language!.lblCancelReason,
            child: ReasonDialog(status: status),
          );
        },
      ).then((value) {
        if (value != null) {
          setState(() {});
        }
      });
    }
  }

  //endregion

  //region Hold Click
  void _handleHoldClick({required BookingDetailResponse status}) {
    if (status.bookingDetail!.status == BookingStatusKeys.inProgress) {
      showInDialog(
        context,
        contentPadding: EdgeInsets.zero,
        backgroundColor: context.scaffoldBackgroundColor,
        builder: (context) {
          return AppCommonDialog(
            title: language!.lblConfirmService,
            child: ReasonDialog(status: status, currentStatus: BookingStatusKeys.hold),
          );
        },
      ).then((value) {
        if (value != null) {
          setState(() {});
        }
      });
    }
  }

  //endregion

  //region Resume Service
  void _handleResumeClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language!.lblNo,
      positiveText: language!.lblYes,
      title: language!.lblConFirmResumeService,
      onAccept: (c) {
        resumeClick(status: status);
      },
    );
  }

  void resumeClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatDate(DateTime.now().toString(), format: BOOKING_SAVE_FORMAT),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff: status.bookingDetail!.durationDiff.validate(),
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
    };

    log("req $request");
    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);

      commonStartTimer(isHourlyService: status.bookingDetail!.isHourlyService, status: BookingStatusKeys.inProgress, timeInSec: status.bookingDetail!.durationDiff.validate().toInt());
      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  //endregion

  //region Start Service
  void startClick({required BookingDetailResponse status}) async {
    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: formatDate(DateTime.now().toString(), format: BOOKING_SAVE_FORMAT),
      BookingUpdateKeys.endAt: status.bookingDetail!.endAt.validate(),
      BookingUpdateKeys.durationDiff: 0,
      BookingUpdateKeys.reason: "",
      CommonKeys.status: BookingStatusKeys.inProgress,
    };

    log("req $request");
    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);
      commonStartTimer(isHourlyService: status.bookingDetail!.isHourlyService, status: BookingStatusKeys.inProgress, timeInSec: status.bookingDetail!.durationDiff.validate().toInt());

      setState(() {});
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  void _handleStartClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      negativeText: language!.lblNo,
      positiveText: language!.lblYes,
      onAccept: (c) {
        startClick(status: status);
      },
    );
  }

  //endregion

  //region Done Service
  void doneClick({required BookingDetailResponse status}) async {
    String endDateTime = DateFormat(BOOKING_SAVE_FORMAT).format(DateTime.now());

    num durationDiff = DateTime.parse(endDateTime.validate()).difference(DateTime.parse(status.bookingDetail!.startAt.validate())).inSeconds;

    Map request = {
      CommonKeys.id: status.bookingDetail!.id.validate(),
      BookingUpdateKeys.startAt: status.bookingDetail!.startAt.validate(),
      BookingUpdateKeys.endAt: endDateTime,
      BookingUpdateKeys.durationDiff: durationDiff,
      BookingUpdateKeys.reason: "Done",
      CommonKeys.status: BookingStatusKeys.complete,
    };

    log("req $request");
    appStore.setLoading(true);

    await updateBooking(request).then((res) async {
      toast(res.message!);
      commonStartTimer(isHourlyService: status.bookingDetail!.isHourlyService, status: BookingStatusKeys.complete, timeInSec: status.bookingDetail!.durationDiff.validate().toInt());
    }).catchError((e) {
      toast(e.toString(), print: true);
    });

    appStore.setLoading(false);
  }

  void _handleDoneClick({required BookingDetailResponse status}) {
    showConfirmDialogCustom(
      context,
      negativeText: language!.lblNo,
      dialogType: DialogType.CONFIRMATION,
      primaryColor: context.primaryColor,
      title: language!.lblEndServicesMsg,
      positiveText: language!.lblYes,
      onAccept: (c) {
        doneClick(status: status);
      },
    );
  }

  //endregion
  //endregion

  //region Methods

  void commonStartTimer({required bool isHourlyService, required String status, required int timeInSec}) {
    if (isHourlyService) {
      Map<String, dynamic> liveStreamRequest = {
        "inSeconds": timeInSec,
        "status": status,
      };
      LiveStream().emit(LIVESTREAM_START_TIMER, liveStreamRequest);
    }
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyWidget(AsyncSnapshot<BookingDetailResponse> snap) {
      if (snap.hasError) {
        return Text(snap.error.toString()).center();
      } else if (snap.hasData) {
        return Stack(
          children: [
            Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(bottom: 60),
                  child: Column(
                    children: [
                      _buildReasonWidget(snap: snap.data!),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.height,
                            bookingIdWidget(),
                            16.height,
                            Divider(height: 0),
                            16.height,
                            serviceDetailWidget(bookingDetail: snap.data!.bookingDetail!, serviceDetail: snap.data!.service!),
                            16.height,
                            Divider(height: 0),
                            counterWidget(value: snap.data!),
                            serviceProofListWidget(list: snap.data!.serviceProof.validate()),
                            handymanWidget(handymanList: snap.data!.handymanData.validate(), serviceDetail: snap.data!.service!, bookingDetail: snap.data!.bookingDetail!),
                            providerWidget(providerData: snap.data!.providerData, serviceDetail: snap.data!.service!),
                            16.height,
                            PriceCommonWidget(
                              bookingDetail: snap.data!.bookingDetail!,
                              serviceDetail: snap.data!.service!,
                              taxes: snap.data!.bookingDetail!.taxes.validate(),
                              couponData: snap.data!.couponData,
                            ),
                            8.height,

                            /// Payment Detail Card
                            if (snap.data!.bookingDetail!.paymentId != null && snap.data!.bookingDetail!.paymentStatus != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  16.height,
                                  ViewAllLabel(
                                    label: language!.paymentDetail,
                                    list: [],
                                  ),
                                  8.height,
                                  Container(
                                    decoration: boxDecorationWithRoundedCorners(
                                      backgroundColor: context.cardColor,
                                      borderRadius: BorderRadius.all(Radius.circular(16)),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language!.lblId, style: secondaryTextStyle(size: 16)),
                                            Text("#" + snap.data!.bookingDetail!.paymentId.toString(), style: boldTextStyle()),
                                          ],
                                        ),
                                        4.height,
                                        Divider(),
                                        4.height,
                                        if (snap.data!.bookingDetail!.paymentMethod.validate().isNotEmpty)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(language!.lblMethod, style: secondaryTextStyle(size: 16)),
                                              Text(
                                                (snap.data!.bookingDetail!.paymentMethod != null ? snap.data!.bookingDetail!.paymentMethod.toString() : language!.notAvailable).capitalizeFirstLetter(),
                                                style: boldTextStyle(),
                                              ),
                                            ],
                                          ),
                                        4.height,
                                        Divider().visible(snap.data!.bookingDetail!.paymentMethod != null),
                                        8.height,
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(language!.lblStatus, style: secondaryTextStyle(size: 16)),
                                            Text(
                                              snap.data!.bookingDetail!.paymentStatus.validate(value: language!.lblPending).capitalizeFirstLetter(),
                                              style: boldTextStyle(),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            16.height,
                            customerReviewWidget(ratingList: snap.data!.ratingData.validate(), customerReview: snap.data!.customerReview, bookingDetail: snap.data!.bookingDetail!),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(bottom: 16, left: 16, right: 16, child: _action(status: snap.data!))
              ],
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading))
          ],
        );
      }
      return LoaderWidget().center();
    }

    return FutureBuilder<BookingDetailResponse>(
      future: getBookingDetail({
        CommonKeys.bookingId: widget.bookingId.toString(),
        CommonKeys.customerId: appStore.userId,
      }),
      builder: (context, snap) {
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            return await 2.seconds.delay;
          },
          child: Scaffold(
            appBar: appBarWidget(
              snap.hasData ? snap.data!.bookingDetail!.statusLabel.validate() : "",
              color: context.primaryColor,
              textColor: Colors.white,
              showBack: true,
              backWidget: BackWidget(),
              actions: [
                if (snap.hasData)
                  TextButton(
                    child: Text(language!.lblCheckStatus, style: primaryTextStyle(color: Colors.white)),
                    onPressed: () {
                      showModalBottomSheet(
                        backgroundColor: Colors.transparent,
                        context: context,
                        isScrollControlled: true,
                        isDismissible: true,
                        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
                        builder: (_) {
                          return DraggableScrollableSheet(
                            initialChildSize: 0.50,
                            minChildSize: 0.2,
                            maxChildSize: 1,
                            builder: (context, scrollController) => BookingHistoryComponent(data: snap.data!.bookingActivity!.reversed.toList(), scrollController: scrollController),
                          );
                        },
                      );
                    },
                  ).paddingRight(16)
              ],
            ),
            body: buildBodyWidget(snap),
          ),
        );
      },
    );
  }
}
