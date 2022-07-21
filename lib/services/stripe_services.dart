import 'dart:io';

import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/booking_detail_model.dart';
import 'package:booking_system_flutter/model/stripe_pay_model.dart';
import 'package:booking_system_flutter/network/network_utils.dart';
import 'package:booking_system_flutter/services/razor_pay_services.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';

class StripeServices {
  static late BookingDetailResponse bookDetailData;
  num totalAmount = 0;
  String stripeURL = "";
  String stripePaymentKey = "";

  init({
    required String stripePaymentPublishKey,
    required BookingDetailResponse data,
    required num totalAmount,
    required String stripeURL,
    required String stripePaymentKey,
  }) async {
    Stripe.publishableKey = stripePaymentPublishKey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    /*await Stripe.instance.createPaymentMethod(PaymentMethodParams.card(
      paymentMethodData: PaymentMethodData(
        billingDetails: BillingDetails(),
      ),
    ));*/

    await Stripe.instance.applySettings().catchError((e) {
      toast(e.toString(), print: true);

      throw e.toString();
    });

    bookDetailData = data;
    this.totalAmount = totalAmount;
    this.stripeURL = stripeURL;
    this.stripePaymentKey = stripePaymentKey;
    setValue("StripeKeyPayment", stripePaymentKey);
  }

  //StripPayment
  void stripePay() async {
    Map<String, String> headers = {
      HttpHeaders.authorizationHeader: 'Bearer $stripePaymentKey',
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
    };

    var request = http.Request('POST', Uri.parse(stripeURL));

    request.bodyFields = {
      'amount': '${(totalAmount.toInt() * 100)}',
      'currency': '${appStore.currencyCode}',
    };
    log('Booking Detail Response : ${bookDetailData.toJson()}');

    log(request.bodyFields);
    request.headers.addAll(headers);

    appStore.setLoading(true);

    await request.send().then((value) {
      appStore.setLoading(false);

      http.Response.fromStream(value).then((response) async {
        if (response.statusCode.isSuccessful()) {
          StripePayModel res = StripePayModel.fromJson(await handleResponse(response));

          await Stripe.instance
              .initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
              paymentIntentClientSecret: res.clientSecret.validate(),
              style: appStore.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              applePay: true,
              googlePay: true,
              testEnv: true,
              merchantCountryCode: 'IN',
              merchantDisplayName: APP_NAME,
              customerId: appStore.userId.toString(),
              customerEphemeralKeySecret: res.clientSecret.validate(),
              setupIntentClientSecret: res.clientSecret.validate(),
            ),
          )
              .then((value) async {
            await Stripe.instance.presentPaymentSheet().then((value) async {
              // return;
              savePay(paymentMethod: PAYMENT_METHOD_STRIPE, paymentStatus: SERVICE_PAYMENT_STATUS_PAID, data: bookDetailData);
            }).catchError((e) {
              log("presentPaymentSheet ${e.toString()}");
            });
          }).catchError((e) {
            toast(e.toString(), print: true);

            throw e.toString();
          });
        } else if (response.statusCode == 400) {
          toast("Testing Credential cannot pay more than 500");
        }
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString(), print: true);

        throw e.toString();
      });
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);

      throw e.toString();
    });
  }
}

StripeServices stripeServices = StripeServices();
