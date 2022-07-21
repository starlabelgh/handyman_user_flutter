import 'package:booking_system_flutter/component/back_widget.dart';
import 'package:booking_system_flutter/component/loader_widget.dart';
import 'package:booking_system_flutter/component/selected_item_widget.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/screens/auth/sign_in_screen.dart';
import 'package:booking_system_flutter/utils/colors.dart';
import 'package:booking_system_flutter/utils/common.dart';
import 'package:booking_system_flutter/utils/configs.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/images.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:booking_system_flutter/utils/string_extensions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  final String? phoneNumber;
  final bool? isOTPLogin;
  final String? verificationId;
  final String? otpCode;

  SignUpScreen({this.phoneNumber, this.isOTPLogin = false, this.otpCode, this.verificationId});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController fNameCont = TextEditingController();
  TextEditingController lNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController userNameCont = TextEditingController();
  TextEditingController mobileCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();

  FocusNode fNameFocus = FocusNode();
  FocusNode lNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode mobileFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  bool isAcceptedTc = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    mobileCont.text = widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
    passwordCont.text = widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
    userNameCont.text = widget.phoneNumber != null ? widget.phoneNumber.toString() : "";
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void registerUser() async {
    hideKeyboard(context);

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      if (isAcceptedTc) {
        appStore.setLoading(true);

        Map<String, dynamic> request = {
          UserKeys.firstName: fNameCont.text.trim(),
          UserKeys.lastName: lNameCont.text.trim(),
          UserKeys.userName: widget.phoneNumber ?? userNameCont.text.trim(),
          UserKeys.userType: LOGIN_TYPE_USER,
          UserKeys.contactNumber: widget.phoneNumber ?? mobileCont.text.trim(),
          UserKeys.email: emailCont.text.trim(),
          UserKeys.password: widget.phoneNumber ?? passwordCont.text.trim(),
          UserKeys.loginType: LOGIN_TYPE_USER
        };

        log("1st Request:- $request");

        await createUser(request).then((value) async {
          value.data!.password = passwordCont.text;
          // After successful entry in the mysql database it will login into firebase.
          await authService.signUpWithEmailPassword(context, registerResponse: value).then((value) {
            log("Firebase Login Register Done.");
          }).catchError((e) {
            if (e.toString() == USER_CANNOT_LOGIN) {
              toast("Please Login Again");
              SignInScreen().launch(context, isNewTask: true);
            } else if (e.toString() == USER_NOT_CREATED) {
              toast("Please Login Again");
              SignInScreen().launch(context, isNewTask: true);
            }
          });
        }).catchError((e) {
          log(e.toString());
          toast(e.toString());
        });
        appStore.setLoading(false);
      } else {
        toast('Please accept terms and condition');
      }
    }
  }

  Future<void> registerWithOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      hideKeyboard(context);
      appStore.setLoading(true);

      Map<String, dynamic> request = {
        UserKeys.firstName: fNameCont.text.trim(),
        UserKeys.lastName: lNameCont.text.trim(),
        UserKeys.userName: widget.phoneNumber ?? userNameCont.text.trim(),
        UserKeys.userType: LOGIN_TYPE_USER,
        UserKeys.contactNumber: widget.phoneNumber ?? mobileCont.text.trim(),
        UserKeys.email: emailCont.text.trim(),
        UserKeys.password: widget.phoneNumber ?? passwordCont.text.trim(),
        // UserKeys.uid: userModel.uid,
        UserKeys.loginType: LOGIN_TYPE_OTP
      };

      log("Request $request");
      await createUser(request).then((value) async {
        value.data!.password = widget.phoneNumber;
        value.data!.verificationId = widget.verificationId;
        value.data!.otpCode = widget.otpCode;

        await authService.signUpWithOTP(context, value.data!).then((value) {
          log("Login Success");
        }).catchError((e) {
          //
        });
      }).catchError((e) {
        log(e.toString());
      });

      appStore.setLoading(false);
      return;
    }
  }

  //region Widget
  Widget _buildTopWidget() {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          padding: EdgeInsets.all(16),
          child: ic_profile2.iconImage(color: Colors.white),
          decoration: boxDecorationDefault(shape: BoxShape.circle, color: primaryColor),
        ),
        16.height,
        Text(language!.lblHelloUser, style: boldTextStyle(size: 24)).center(),
        16.height,
        Text(language!.lblSignUpSubTitle, style: primaryTextStyle(size: 18), textAlign: TextAlign.center).center().paddingSymmetric(horizontal: 32),
      ],
    );
  }

  Widget _buildFormWidget() {
    return Column(
      children: [
        32.height,
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: fNameCont,
          focus: fNameFocus,
          nextFocus: lNameFocus,
          errorThisFieldRequired: language!.requiredText,
          decoration: inputDecoration(context, hint: language!.hintFirstNameTxt),
          suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.NAME,
          controller: lNameCont,
          focus: lNameFocus,
          nextFocus: userNameFocus,
          errorThisFieldRequired: language!.requiredText,
          decoration: inputDecoration(context, hint: language!.hintLastNameTxt),
          suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.USERNAME,
          controller: userNameCont,
          focus: userNameFocus,
          nextFocus: emailFocus,
          readOnly: widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
          errorThisFieldRequired: language!.requiredText,
          decoration: inputDecoration(context, hint: language!.hintUserNameTxt),
          suffix: ic_profile2.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.EMAIL,
          controller: emailCont,
          focus: emailFocus,
          errorThisFieldRequired: language!.requiredText,
          nextFocus: mobileFocus,
          decoration: inputDecoration(context, hint: language!.hintEmailTxt),
          suffix: ic_message.iconImage(size: 10).paddingAll(14),
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.PHONE,
          controller: mobileCont,
          focus: mobileFocus,
          readOnly: widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
          errorThisFieldRequired: language!.requiredText,
          nextFocus: passwordFocus,
          decoration: inputDecoration(context, hint: language!.hintContactNumberTxt),
          suffix: ic_calling.iconImage(size: 10).paddingAll(14),
          validator: (mobileCont) {
            String value = mobileCont.toString();
            String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
            RegExp regExp = new RegExp(pattern);
            if (value.length == 0) {
              return language!.phnrequiredtext;
            } else if (!regExp.hasMatch(value.toString())) {
              return language!.phnvalidation;
            }
            return null;
          },
        ),
        16.height,
        AppTextField(
          textFieldType: TextFieldType.PASSWORD,
          controller: passwordCont,
          focus: passwordFocus,
          readOnly: widget.isOTPLogin.validate() ? widget.isOTPLogin : false,
          suffixPasswordVisibleWidget: ic_show.iconImage(size: 10).paddingAll(14),
          suffixPasswordInvisibleWidget: ic_hide.iconImage(size: 10).paddingAll(14),
          errorThisFieldRequired: language!.requiredText,
          decoration: inputDecoration(context, hint: language!.hintPasswordTxt),
          onFieldSubmitted: (s) {
            if (widget.isOTPLogin == false)
              registerUser();
            else
              registerWithOTP();
          },
        ),
        20.height,
        _buildTcAcceptWidget(),
        8.height,
        AppButton(
          text: language!.signUp,
          color: primaryColor,
          textStyle: boldTextStyle(color: white),
          width: context.width() - context.navigationBarHeight,
          onTap: () {
            if (widget.isOTPLogin == false)
              registerUser();
            else
              registerWithOTP();
          },
        ),
      ],
    );
  }

  Widget _buildTcAcceptWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SelectedItemWidget(isSelected: isAcceptedTc).onTap(() async {
          isAcceptedTc = !isAcceptedTc;
          setState(() {});
        }),
        16.width,
        RichTextWidget(
          list: [
            TextSpan(text: '${language!.lblAgree} ', style: secondaryTextStyle()),
            TextSpan(
              text: language!.lblTermsOfService,
              style: boldTextStyle(color: primaryColor, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  commonLaunchUrl(TERMS_CONDITION_URL, launchMode: LaunchMode.externalApplication);
                },
            ),
            TextSpan(text: ' & ', style: secondaryTextStyle()),
            TextSpan(
              text: language!.lblPrivacyPolicy,
              style: boldTextStyle(color: primaryColor, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  commonLaunchUrl(PRIVACY_POLICY_URL, launchMode: LaunchMode.externalApplication);
                },
            ),
          ],
          textAlign: TextAlign.center,
        ).flexible(flex: 2),
      ],
    ).paddingAll(16);
  }

  Widget _buildFooterWidget() {
    return Column(
      children: [
        16.height,
        RichTextWidget(
          list: [
            TextSpan(text: "${language!.alreadyHaveAccountTxt} ? ", style: secondaryTextStyle()),
            TextSpan(
              text: language!.lblSignInHere,
              style: boldTextStyle(color: primaryColor, size: 14),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  finish(context);
                },
            ),
          ],
        ),
      ],
    );
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "",
        elevation: 0,
        color: context.scaffoldBackgroundColor,
        backWidget: BackWidget(iconColor: context.iconColor),
        systemUiOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: appStore.isDarkMode ? Brightness.light : Brightness.dark, statusBarColor: context.scaffoldBackgroundColor),
      ),
      body: SizedBox(
        width: context.width(),
        child: Stack(
          children: [
            Form(
              key: formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTopWidget(),
                    _buildFormWidget(),
                    8.height,
                    _buildFooterWidget(),
                  ],
                ),
              ),
            ),
            Observer(builder: (_) => LoaderWidget().center().visible(appStore.isLoading)),
          ],
        ),
      ),
    );
  }
}
