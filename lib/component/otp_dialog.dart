import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_up_screen.dart';
import 'package:booking_system_flutter/screens/dashboard/dashboard_screen.dart';
import 'package:booking_system_flutter/services/auth_services.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';

class OTPDialog extends StatefulWidget {
  static String tag = '/OTPDialog';
  final String? verificationId;
  final String? phoneNumber;
  final bool? isCodeSent;
  final PhoneAuthCredential? credential;

  OTPDialog({this.verificationId, this.isCodeSent, this.phoneNumber, this.credential});

  @override
  OTPDialogState createState() => OTPDialogState();
}

class OTPDialogState extends State<OTPDialog> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AuthServices authService = AuthServices();
  TextEditingController numberController = TextEditingController();

  String? countryCode = '';

  String otpCode = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(false);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //region Methods
  Future<void> otpLogin() async {
    var request = {
      UserKeys.userName: widget.phoneNumber!.replaceAll('+', ''),
      UserKeys.password: widget.phoneNumber!.replaceAll('+', ''),
      UserKeys.playerId: getStringAsync(PLAYERID),
      UserKeys.loginType: 'mobile',
    };

    appStore.setLoading(true);
    await loginUser(request, isSocialLogin: true).then((res) async {
      res.data!.password = widget.phoneNumber.validate();
      // log("token ${res}");

      // return;
      await userService.getUser(email: res.data!.email).then((value) {
        appStore.setLoading(false);

        res.data!.uid = value.uid;

        if (res.data!.userType == LOGIN_TYPE_USER) {
          if (res.data != null) saveUserData(res.data!);
          toast(language!.loginSuccessfully);
          DashboardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
        } else {
          toast(language!.lblOnlyUserCanLoggedInHere);
        }
      });
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString());
    });
  }

  Future<void> submit() async {
    appStore.setLoading(true);

    PhoneAuthProvider.credential(
      verificationId: widget.verificationId!,
      smsCode: otpCode.validate(),
    );

    Map req = {
      "email": "",
      "username": widget.phoneNumber!.replaceAll('+', ''),
      "first_name": '',
      "last_name": '',
      "login_type": LOGIN_TYPE_OTP,
      "user_type": "user",
      "accessToken": widget.phoneNumber!.replaceAll('+', ''),
    };

    await loginUser(req, isSocialLogin: true).then((value) async {
      appStore.setLoginType(LOGIN_TYPE_OTP);

      if (value.isUserExist == null) {
        /// Register
        otpLogin();
      } else {
        /// not Register
        appStore.setLoading(false);
        finish(context);
        SignUpScreen(
          phoneNumber: widget.phoneNumber!.replaceAll('+', ''),
          otpCode: otpCode.validate(),
          verificationId: widget.verificationId!,
          isOTPLogin: true,
        ).launch(context);
      }
    }).catchError((e) {
      appStore.setLoading(false);

      if (e.toString().contains('invalid_username')) {
        finish(context);
        SignUpScreen(
          phoneNumber: widget.phoneNumber!.replaceAll('+', ''),
          otpCode: otpCode.validate(),
          verificationId: widget.verificationId!,
          isOTPLogin: true,
        ).launch(context);
      } else {
        toast(e.toString(), print: true);
      }
    });
  }

  Future<void> sendOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      hideKeyboard(context);

      String number = '+$countryCode${numberController.text.trim()}';

      if (!number.startsWith('+')) {
        number = '+$countryCode${numberController.text.trim()}';
      }
      appStore.setLoading(true);
      await authService.loginWithOTP(context, number).then((value) {
        //
      }).catchError((e) {
        appStore.setLoading(true);

        toast(e.toString(), print: true);
      });
    }
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    Widget _buildMainWidget({required bool isOtpSent}) {
      if (isOtpSent) {
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(language!.lblenterPhnNumber, style: boldTextStyle()),
                16.height,
                Container(
                  child: Row(
                    children: [
                      CountryCodePicker(
                        initialSelection: '+91',
                        showCountryOnly: false,
                        showFlag: true,
                        showFlagDialog: true,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                        dialogBackgroundColor: context.cardColor,
                        textStyle: primaryTextStyle(size: 18),
                        onInit: (c) {
                          countryCode = c!.dialCode;
                        },
                        onChanged: (c) {
                          countryCode = c.dialCode;
                        },
                      ),
                      2.width,
                      Form(
                        key: formKey,
                        child: AppTextField(
                          controller: numberController,
                          textFieldType: TextFieldType.PHONE,
                          decoration: inputDecoration(context),
                          autoFocus: true,
                          onFieldSubmitted: (s) {
                            sendOTP();
                          },
                        ).expand(),
                      ),
                    ],
                  ),
                ),
                30.height,
                AppButton(
                  onTap: () {
                    sendOTP();
                  },
                  text: language!.btnSendOtp,
                  color: primaryColor,
                  textStyle: boldTextStyle(color: white),
                  width: context.width(),
                )
              ],
            ),
            Observer(
              builder: (context) {
                return LoaderWidget().visible(appStore.isLoading);
              },
            )
          ],
        );
      } else {
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(language!.enterOtp, style: boldTextStyle()),
                30.height,
                OTPTextField(
                  length: 6,
                  width: MediaQuery.of(context).size.width,
                  fieldWidth: 35,
                  style: primaryTextStyle(),
                  textFieldAlignment: MainAxisAlignment.spaceAround,
                  fieldStyle: FieldStyle.box,
                  onChanged: (s) {
                    otpCode = s;
                  },
                  onCompleted: (pin) {
                    otpCode = pin;
                    submit();
                  },
                ).fit(),
                30.height,
                AppButton(
                  onTap: () {
                    submit();
                  },
                  text: language!.confirm,
                  color: primaryColor,
                  textStyle: boldTextStyle(color: white),
                  width: context.width(),
                ),
                Observer(builder: (context) {
                  return LoaderWidget().visible(appStore.isLoading);
                }),
              ],
            ),
          ],
        );
      }
    }

    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      child: _buildMainWidget(isOtpSent: !widget.isCodeSent.validate()),
    );
  }
}
