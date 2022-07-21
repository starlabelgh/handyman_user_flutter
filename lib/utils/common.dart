import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/cached_network_image.dart';
import 'package:booking_system_flutter/component/html_widget.dart';
import 'package:booking_system_flutter/component/location_service_dialog.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/service_data_model.dart';
import 'package:booking_system_flutter/model/service_detail_response.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/permissions.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constant.dart';

Future<void> commonLaunchUrl(String address, {LaunchMode launchMode = LaunchMode.inAppWebView}) async {
  await launchUrl(Uri.parse(address), mode: launchMode).catchError((e) {
    toast('Invalid URL: $address');
  });
}

void launchCall(String? url) {
  if (url.validate().isNotEmpty) {
    if (isIOS)
      commonLaunchUrl('tel://' + url!, launchMode: LaunchMode.externalApplication);
    else
      commonLaunchUrl('tel:' + url!, launchMode: LaunchMode.externalApplication);
  }
}

void launchMap(String? url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl(GOOGLE_MAP_PREFIX + url!, launchMode: LaunchMode.externalApplication);
  }
}

void launchMail(String url) {
  if (url.validate().isNotEmpty) {
    commonLaunchUrl('$MAIL_TO$url', launchMode: LaunchMode.externalApplication);
  }
}

void checkIfLink(BuildContext context, String value, {String? title}) {
  if (value.validate().isEmpty) return;

  String temp = parseHtmlString(value.validate());
  if (temp.startsWith("https") || temp.startsWith("http")) {
    launchUrlCustomTab(temp.validate());
  } else if (temp.validateEmail()) {
    launchMail(temp);
  } else if (temp.validatePhone() || temp.startsWith('+')) {
    launchCall(temp);
  } else {
    HtmlWidget(postContent: value, title: title).launch(context);
  }
}

void launchUrlCustomTab(String? url) {
  if (url.validate().isNotEmpty) {
    custom_tabs.launch(
      url!,
      customTabsOption: custom_tabs.CustomTabsOption(
        enableDefaultShare: true,
        enableInstantApps: true,
        enableUrlBarHiding: true,
        showPageTitle: true,
        toolbarColor: primaryColor,
      ),
      safariVCOption: custom_tabs.SafariViewControllerOption(
        preferredBarTintColor: primaryColor,
        preferredControlTintColor: Colors.white,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: true,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      ),
    );
  }
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 3, name: 'Arabic', languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 4, name: 'Gujarati', languageCode: 'gu', fullLanguageCode: 'gu-GU', flag: 'assets/flag/ic_india.png'),
    LanguageDataModel(id: 5, name: 'African', languageCode: 'af', fullLanguageCode: 'ar-AF', flag: 'assets/flag/ic_af.png'),
    LanguageDataModel(id: 6, name: 'Dutch', languageCode: 'nl', fullLanguageCode: 'nl-NL', flag: 'assets/flag/ic_nl.png'),
    LanguageDataModel(id: 7, name: 'French', languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: 'assets/flag/ic_fr.png'),
    LanguageDataModel(id: 8, name: 'German', languageCode: 'de', fullLanguageCode: 'de-DE', flag: 'assets/flag/ic_de.png'),
    LanguageDataModel(id: 9, name: 'Indonesian', languageCode: 'id', fullLanguageCode: 'id-ID', flag: 'assets/flag/ic_id.png'),
    LanguageDataModel(id: 10, name: 'Spanish', languageCode: 'es', fullLanguageCode: 'es-ES', flag: 'assets/flag/ic_es.jpg'),
    LanguageDataModel(id: 11, name: 'Turkish', languageCode: 'tr', fullLanguageCode: 'tr-TR', flag: 'assets/flag/ic_tr.png'),
    LanguageDataModel(id: 12, name: 'Vietnam', languageCode: 'vi', fullLanguageCode: 'vi-VI', flag: 'assets/flag/ic_vi.png'),
    LanguageDataModel(id: 13, name: 'Albanian', languageCode: 'sq', fullLanguageCode: 'sq-SQ', flag: 'assets/flag/ic_arbanian.png'),
    LanguageDataModel(id: 14, name: 'Portugal', languageCode: 'pt', fullLanguageCode: 'pt-PT', flag: 'assets/flag/ic_pt.png'),
  ];
  /*//TODO Enable after adding more language on server
  if (false) {
    Iterable it = jsonDecode(getStringAsync(SERVER_LANGUAGES));
    var res = it.map((e) => LanguageOption.fromJson(e)).toList();

    localeLanguageList.clear();

    res.forEach((element) {
      localeLanguageList.add(LanguageDataModel(languageCode: element.id, flag: element.flagImage, name: element.title));
    });

    return localeLanguageList;
  } else {

  }*/
}

InputDecoration inputDecoration(BuildContext context, {Widget? prefixIcon, String? hint, double? borderRadius}) {
  return InputDecoration(
    contentPadding: EdgeInsets.only(left: 12, bottom: 10, top: 10, right: 10),
    labelText: hint,
    labelStyle: secondaryTextStyle(),
    alignLabelWithHint: true,
    prefixIcon: prefixIcon,
    enabledBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 0.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
    errorMaxLines: 2,
    errorStyle: primaryTextStyle(color: Colors.red, size: 12),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius(borderRadius ?? defaultRadius),
      borderSide: BorderSide(color: primaryColor, width: 0.0),
    ),
    filled: true,
    fillColor: context.cardColor,
  );
}

String parseHtmlString(String? htmlString) {
  return parse(parse(htmlString).body!.text).documentElement!.text;
}

String formatDate(String? dateTime, {String format = DATE_FORMAT_1, bool isFromMicrosecondsSinceEpoch = false}) {
  if (isFromMicrosecondsSinceEpoch) {
    return DateFormat(format).format(DateTime.fromMicrosecondsSinceEpoch(dateTime.validate().toInt() * 1000));
  } else {
    return DateFormat(format).format(DateTime.parse(dateTime.validate()));
  }
}

Future<void> saveOneSignalPlayerId() async {
  await OneSignal.shared.getDeviceState().then((value) async {
    if (value!.userId.validate().isNotEmpty) await setValue(PLAYERID, value.userId.validate());
    log('notification player id ' + value.toString());
  }).catchError((e) {
    toast(e.toString());
  });
}

bool get isRTL => RTL_LanguageS.contains(appStore.selectedLanguageCode);

bool get getMobileLoginType => appStore.loginType == LOGIN_TYPE_OTP;

bool get getGoogleLoginType => appStore.loginType == LOGIN_TYPE_GOOGLE;

bool get getUserLoginType => appStore.loginType == LOGIN_TYPE_USER;

Widget noDataFound(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      cachedImage(notDataFoundImg, height: 200, width: 200),
      8.height,
      Text(language!.lblNoData, style: boldTextStyle()),
    ],
  );
}

num calculateTotalAmount({
  required num servicePrice,
  required int qty,
  required num? serviceDiscountPercent,
  CouponData? couponData,
  ServiceData? detail,
  required List<TaxData>? taxes,
}) {
  double totalAmount = 0.0;
  double discountPrice = 0.0;
  double taxAmount = 0.0;
  double couponDiscountAmount = 0.0;

  taxes.validate().forEach((element) {
    if (element.type == SERVICE_TYPE_PERCENT) {
      element.totalCalculatedValue = ((servicePrice * qty) * element.value.validate()) / 100;
    } else {
      element.totalCalculatedValue = element.value.validate();
    }
    taxAmount += element.totalCalculatedValue.validate().toDouble();
  });

  if (serviceDiscountPercent.validate() != 0) {
    totalAmount = (servicePrice * qty) - (((servicePrice * qty) * (serviceDiscountPercent!)) / 100);
    discountPrice = servicePrice * qty - totalAmount;

    totalAmount = (servicePrice * qty) - discountPrice - couponDiscountAmount + taxAmount;
  } else {
    totalAmount = (servicePrice * qty) - couponDiscountAmount + taxAmount;
  }

  if (couponData != null) {
    if (couponData.discountType.validate() == SERVICE_TYPE_FIXED) {
      totalAmount = totalAmount - couponData.discount.validate();
      couponDiscountAmount = couponData.discount.validate().toDouble();
    } else {
      totalAmount = totalAmount - ((totalAmount * couponData.discount.validate()) / 100);
      num calValue = (totalAmount * couponData.discount.validate());
      couponDiscountAmount = calValue / 100;
    }
    if (detail != null) {
      detail.couponCode = couponData.code.validate().toString();
      detail.appliedCouponData = couponData;
      detail.couponDiscountAmount = couponDiscountAmount.validate();
    }
  }

  if (detail != null) {
    detail.totalAmount = totalAmount.toStringAsFixed(DECIMAL_POINT).validate().toDouble();
    detail.qty = qty.validate();
    detail.discountPrice = discountPrice.toStringAsFixed(DECIMAL_POINT).validate().toDouble();
    detail.taxAmount = taxAmount.toStringAsFixed(DECIMAL_POINT).validate().toDouble();
  }
  return totalAmount;
}

Future<bool> addToWishList({required int serviceId}) async {
  Map req = {"id": "", "service_id": serviceId, "user_id": appStore.userId};
  return await addWishList(req).then((res) {
    toast(res.message!);
    return true;
  }).catchError((error) {
    toast(error.toString());
    return false;
  });
}

Future<bool> removeToWishList({required int serviceId}) async {
  Map req = {"user_id": appStore.userId, 'service_id': serviceId};

  return await removeWishList(req).then((res) {
    toast(res.message!);
    return true;
  }).catchError((error) {
    toast(error.toString());
    return false;
  });
}

Widget commonLocationWidget({required BuildContext context, required Function() onTap, Color? color}) {
  return Observer(
    builder: (_) => IconButton(
      icon: ic_active_location.iconImage(size: 24, color: appStore.isCurrentLocation ? color ?? Colors.white : color ?? Colors.white),
      visualDensity: VisualDensity.compact,
      onPressed: () {
        Permissions.cameraFilesAndLocationPermissionsGranted().then((value) async {
          await setValue(PERMISSION_STATUS, value);

          if (value) {
            showInDialog(
              context,
              contentPadding: EdgeInsets.zero,
              builder: (p0) {
                return AppCommonDialog(
                  title: language!.lblAlert,
                  child: LocationServiceDialog(),
                );
              },
            ).then(
              (value) async {
                if (value != null) {
                  await setValue(PERMISSION_STATUS, value);
                  onTap.call();
                }
              },
            );
          }
        }).catchError((e) {
          toast(e.toString(), print: true);
        });
      },
    ),
  );
}

Future deleteDialog(
  BuildContext context, {
  final String? title,
  final String? subTitle,
  required final Function() onSuccess,
  final Function()? onCancel,
}) async {
  return showInDialog(
    context,
    contentPadding: EdgeInsets.zero,
    builder: (c) {
      return Container(
        width: context.width(),
        padding: EdgeInsets.symmetric(vertical: 40, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 100,
              width: 100,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
              ),
              child: Image.asset(ic_delete_dialog, height: 60, width: 60),
            ),
            32.height,
            Text(title ?? language!.lblDeleteAddress, style: boldTextStyle(size: 22)),
            16.height,
            Text(subTitle ?? language!.lblDeleteSunTitle, style: secondaryTextStyle(), textAlign: TextAlign.center),
            24.height,
            Row(
              children: [
                AppButton(
                  text: language!.lblCancel,
                  textColor: textPrimaryColorGlobal,
                  color: context.cardColor,
                  onTap: onCancel ??
                      () {
                        finish(context);
                      },
                ).expand(),
                16.width,
                AppButton(
                  text: language!.lblDelete,
                  color: primaryColor,
                  textColor: Colors.white,
                  onTap: () {
                    onSuccess.call();
                    finish(context);
                  },
                ).expand(),
              ],
            )
          ],
        ),
      );
    },
  );
}

Widget circleImage({required String image, double size = 24}) {
  return cachedImage(image, width: size, height: size, fit: BoxFit.cover).cornerRadiusWithClipRRect(90);
}

// Logic For Calculate Time
String calculateTimer(int secTime) {
  int hour = 0, minute = 0, seconds = 0;

  hour = secTime ~/ 3600;

  minute = ((secTime - hour * 3600)) ~/ 60;

  seconds = secTime - (hour * 3600) - (minute * 60);

  String hourLeft = hour.toString().length < 2 ? "0" + hour.toString() : hour.toString();

  String minuteLeft = minute.toString().length < 2 ? "0" + minute.toString() : minute.toString();

  String minutes = minuteLeft == '00' ? '01' : minuteLeft;

  String result = "$hourLeft:$minutes";

  return result;
}

num hourlyCalculation({required int secTime, required num price}) {
  num result = 0;

  String time = calculateTimer(secTime);
  String perMinuteCharge = (price / 60).toStringAsFixed(2);

  if (time == "01:00") {
    String value = (price * 1).toStringAsFixed(2);
    result = value.toDouble();
  } else {
    List<String> data = time.split(":");
    if (data.first == "00") {
      String value;
      if (secTime < 60) {
        value = (perMinuteCharge.toDouble() * 1).toStringAsFixed(2);
      } else {
        value = (perMinuteCharge.toDouble() * data.last.toDouble()).toStringAsFixed(2);
      }

      result = value.toDouble();
    } else {
      if (data.first.toInt() > 01 && data.last.toInt() == 00) {
        String value = (price * data.first.toInt()).toStringAsFixed(2);
        result = value.toDouble();
      } else {
        String value = (price * data.first.toInt()).toStringAsFixed(2);
        String extraMinuteCharge = (data.last.toDouble() * perMinuteCharge.toDouble()).toStringAsFixed(2);
        String finalPrice = (value.toDouble() + extraMinuteCharge.toDouble()).toStringAsFixed(2);
        result = finalPrice.toDouble();
      }
    }
  }

  return result.toDouble();
}

Brightness getStatusBrightness({required bool val}) {
  return val ? Brightness.light : Brightness.dark;
}

String getPaymentStatusText(String? status, String? method) {
  if (status!.isEmpty) {
    return 'Pending';
  } else if (status == SERVICE_PAYMENT_STATUS_PAID) {
    return 'Paid';
  } else if (status == SERVICE_PAYMENT_STATUS_PENDING && method == PAYMENT_METHOD_COD) {
    return 'Pending Approval';
  }
  if (status == SERVICE_PAYMENT_STATUS_PENDING) {
    return 'Pending';
  } else {
    return "";
  }
}

String getReasonText(String val) {
  if (val == BookingStatusKeys.cancelled) {
    return language!.lblReasonCancelling;
  } else if (val == BookingStatusKeys.rejected) {
    return language!.lblReasonRejecting;
  } else if (val == BookingStatusKeys.failed) {
    return language!.lblFailed;
  }
  return '';
}

bool get isIqonicProduct => currentPackageName == appPackageName;

bool get isUserTypeHandyman => appStore.userType == USER_TYPE_HANDYMAN;

bool get isUserTypeProvider => appStore.userType == USER_TYPE_PROVIDER;

bool get isUserTypeUser => appStore.userType == USER_TYPE_USER;

bool get isLoginTypeUser => appStore.loginType == LOGIN_TYPE_USER;

bool get isLoginTypeGoogle => appStore.loginType == LOGIN_TYPE_GOOGLE;

bool get isLoginTypeOTP => appStore.loginType == LOGIN_TYPE_OTP;

String buildPaymentStatusWithMethod(String status, String method) {
  return '${getPaymentStatusText(status, method)}${status == SERVICE_PAYMENT_STATUS_PAID ? ' by $method' : ''}';
}

Color getRatingBarColor(int rating) {
  if (rating == 1 || rating == 2) {
    return Color(0xFFE80000);
  } else if (rating == 3) {
    return Color(0xFFff6200);
  } else if (rating == 4 || rating == 5) {
    return Color(0xFF73CB92);
  } else {
    return Color(0xFFE80000);
  }
}

Future<FirebaseRemoteConfig> setupFirebaseRemoteConfig() async {
  final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  remoteConfig.setConfigSettings(RemoteConfigSettings(fetchTimeout: Duration.zero, minimumFetchInterval: Duration.zero));
  await remoteConfig.fetch();
  await remoteConfig.fetchAndActivate();

  setValue(IN_MAINTENANCE_MODE, remoteConfig.getBool(IN_MAINTENANCE_MODE));
  if (isIOS) {
    await setValue(HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_APP_STORE_REVIEW));
  } else if (isAndroid) {
    await setValue(HAS_IN_REVIEW, remoteConfig.getBool(HAS_IN_PLAY_STORE_REVIEW));
  }
  return remoteConfig;
}

void ifNotTester(VoidCallback callback) {
  if (appStore.userEmail != DEFAULT_EMAIL) {
    callback.call();
  } else {
    toast(language!.lblUnAuthorized);
  }
}
