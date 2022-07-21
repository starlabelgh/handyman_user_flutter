import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/component/price_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_data_model.dart';
import 'package:booking_system_flutter/screens/booking/component/edit_booking_service_dialog.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class BookingItemComponent extends StatelessWidget {
  final BookingData bookingData;

  BookingItemComponent({required this.bookingData});

  @override
  Widget build(BuildContext context) {
    Widget _buildEditBookingWidget() {
      if (bookingData.status == BookingStatusKeys.pending && DateTime.parse(bookingData.date.validate()).isAfter(DateTime.now())) {
        return IconButton(
          icon: ic_edit_square.iconImage(size: 20),
          visualDensity: VisualDensity.compact,
          onPressed: () {
            showInDialog(
              context,
              contentPadding: EdgeInsets.zero,
              hideSoftKeyboard: true,
              backgroundColor: context.cardColor,
              builder: (p0) {
                return AppCommonDialog(
                  title: language!.lblEditService,
                  child: EditBookingServiceDialog(data: bookingData),
                );
              },
            );
          },
        );
      }
      return Offstage();
    }

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(bottom: 16),
      width: context.width(),
      decoration: BoxDecoration(border: Border.all(color: context.dividerColor), borderRadius: radius()),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cachedImage(
                bookingData.serviceAttachments!.isNotEmpty ? bookingData.serviceAttachments!.first.validate() : '',
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ).cornerRadiusWithClipRRect(defaultRadius),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: bookingData.statusLabel.validate().getPaymentStatusBackgroundColor.withOpacity(0.1),
                              borderRadius: radius(8),
                            ),
                            child: Text(
                              bookingData.statusLabel.validate(),
                              style: boldTextStyle(color: bookingData.statusLabel.validate().getPaymentStatusBackgroundColor, size: 12),
                            ),
                          ),
                          _buildEditBookingWidget(),
                        ],
                      ),
                      Text('#${bookingData.id.validate()}', style: boldTextStyle(color: primaryColor, size: 16)),
                    ],
                  ),
                  4.height,
                  Marquee(
                    child: Text(
                      bookingData.serviceName.validate(),
                      style: boldTextStyle(size: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  4.height,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PriceWidget(
                        price: bookingData.isHourlyService
                            ? bookingData.totalAmount.validate()
                            : calculateTotalAmount(
                                servicePrice: bookingData.price.validate(),
                                qty: bookingData.quantity.validate(),
                                couponData: bookingData.couponData != null ? bookingData.couponData : null,
                                taxes: bookingData.taxes.validate(),
                                serviceDiscountPercent: bookingData.discount.validate(),
                              ),
                        color: primaryColor,
                        isHourlyService: bookingData.isHourlyService,
                        size: 18,
                      ),
                      if (bookingData.isHourlyService.toString().validate() == SERVICE_TYPE_HOURLY) 4.width else 8.width,
                      if (bookingData.discount != null && bookingData.discount != 0)
                        Row(
                          children: [
                            Text('(${bookingData.discount.validate()}%', style: boldTextStyle(size: 14, color: Colors.green)),
                            Text(' ${language!.lblOff})', style: boldTextStyle(size: 14, color: Colors.green)),
                          ],
                        ),
                    ],
                  ),
                ],
              ).expand(),
            ],
          ).paddingAll(8),
          Container(
            decoration: boxDecorationWithRoundedCorners(
              backgroundColor: context.cardColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('${language!.lblDate} & ${language!.lblTime}', style: secondaryTextStyle()),
                    8.width,
                    Text(
                      "${formatDate(bookingData.date.validate(), format: DATE_FORMAT_2)} At ${formatDate(bookingData.date.validate(), format: HOUR_12_FORMAT)}",
                      style: boldTextStyle(size: 14),
                      maxLines: 2,
                      textAlign: TextAlign.right,
                    ).expand(),
                  ],
                ).paddingAll(8),
                if (bookingData.providerName.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(language!.textProvider, style: secondaryTextStyle()),
                          8.width,
                          Text(bookingData.providerName.validate(), style: boldTextStyle(size: 14), textAlign: TextAlign.right).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (bookingData.handyman.validate().isNotEmpty)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(language!.textHandyman, style: secondaryTextStyle()),
                          Text(bookingData.handyman!.validate().first.handyman!.displayName.validate(), style: boldTextStyle(size: 14)).flexible(),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
                if (bookingData.paymentStatus != null && bookingData.status == BookingStatusKeys.complete)
                  Column(
                    children: [
                      Divider(height: 0),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(language!.paymentStatus, style: secondaryTextStyle()).expand(),
                          Text(
                            buildPaymentStatusWithMethod(bookingData.paymentStatus.validate(), bookingData.paymentMethod.validate()),
                            style: boldTextStyle(size: 14, color: bookingData.paymentStatus.validate() == SERVICE_PAYMENT_STATUS_PAID ? Colors.green : Colors.red),
                          ),
                        ],
                      ).paddingAll(8),
                    ],
                  ),
              ],
            ).paddingAll(8),
          ),
        ],
      ),
    );
  }
}
