import 'dart:convert';

import 'package:booking_system_flutter/component/app_common_dialog.dart';
import 'package:booking_system_flutter/component/otp_dialog.dart';
import 'package:booking_system_flutter/main.dart';
import 'package:booking_system_flutter/model/login_model.dart';
import 'package:booking_system_flutter/model/user_data_model.dart';
import 'package:booking_system_flutter/network/rest_apis.dart';
import 'package:booking_system_flutter/utils/constant.dart';
import 'package:booking_system_flutter/utils/model_keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nb_utils/nb_utils.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthServices {
  //region Google Login
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      //Authentication
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _auth.signInWithCredential(credential);
      final User user = authResult.user!;

      assert(!user.isAnonymous);

      final User currentUser = _auth.currentUser!;
      assert(user.uid == currentUser.uid);

      await googleSignIn.signOut();
      String firstName = '';
      String lastName = '';
      if (currentUser.displayName.validate().split(' ').length >= 1) firstName = currentUser.displayName.splitBefore(' ');
      if (currentUser.displayName.validate().split(' ').length >= 2) lastName = currentUser.displayName.splitAfter(' ');

      Map req = {
        "email": currentUser.email,
        "first_name": firstName,
        "last_name": lastName,
        "username": (firstName + lastName).toLowerCase(),
        "profile_image": currentUser.photoURL,
        "social_image": currentUser.photoURL,
        "accessToken": googleSignInAuthentication.accessToken,
        "login_type": LOGIN_TYPE_GOOGLE,
        "user_type": LOGIN_TYPE_USER,
      };

      log("Google Login Json" + jsonEncode(req));

      await loginUser(req, isSocialLogin: true).then((value) async {
        await loginFromFirebaseUser(currentUser, loginData: value);
      }).catchError((e) {
        log(e.toString());
      });
    } else {
      throw errorSomethingWentWrong;
    }
  }

  //endregion

  //region Email
  Future<void> signUpWithEmailPassword(context, {required LoginResponse registerResponse, bool? isOTP, bool isLogin = true}) async {
    UserData? registerData = registerResponse.data!;

    UserCredential? userCredential = await _auth.createUserWithEmailAndPassword(email: registerData.email.validate(), password: registerData.password.validate()).catchError((e) async {
      await _auth.signInWithEmailAndPassword(email: registerData.email.validate(), password: registerData.password.validate()).then((value) {
        //
        setRegisterData(
          currentUser: value.user!,
          registerData: registerData,
          userModel: UserData(
            id: registerData.id.validate(),
            uid: value.user!.uid,
            apiToken: registerData.apiToken,
            contactNumber: registerData.contactNumber,
            displayName: registerData.displayName,
            email: registerData.email,
            firstName: registerData.firstName,
            lastName: registerData.lastName,
            userType: registerData.userType,
            username: registerData.username,
            password: registerData.password,
          ),
          isRegister: true,
        );
      }).catchError((e) {
        toast(e.toString());
      });

      log("Err ${e.toString()}");
    });
    if (userCredential.user != null) {
      User currentUser = userCredential.user!;
      String displayName = registerData.firstName.validate() + registerData.lastName.validate();

      UserData userModel = UserData()
        ..id = registerData.id.validate()
        ..apiToken = registerData.apiToken.validate()
        ..uid = currentUser.uid
        ..email = currentUser.email
        ..contactNumber = registerData.contactNumber
        ..firstName = registerData.firstName.validate()
        ..lastName = registerData.lastName.validate()
        ..username = registerData.username.validate()
        ..displayName = displayName
        ..userType = LOGIN_TYPE_USER
        ..loginType = getStringAsync(LOGIN_TYPE)
        ..createdAt = Timestamp.now().toDate().toString()
        ..updatedAt = Timestamp.now().toDate().toString()
        ..playerId = getStringAsync(PLAYERID);

      setRegisterData(currentUser: currentUser, registerData: registerData, userModel: userModel, isRegister: isLogin);
    }
  }

  Future<UserData> signInWithEmailPassword(context, {required UserData userData}) async {
    return await _auth.signInWithEmailAndPassword(email: userData.email.validate(), password: userData.password.validate()).then((value) async {
      final User user = value.user!;

      UserData userModel = await userService.getUser(email: user.email);
      await updateUserData(userModel);

      return userModel;
    }).catchError((e) {
      log(e.toString());

      throw USER_NOT_FOUND;
    });
  }

  //endregion

  //region Change password
  Future<void> changePassword(String newPassword) async {
    await FirebaseAuth.instance.currentUser!.updatePassword(newPassword).then((value) async {
      await setValue("PASSWORD", newPassword);
    });
  }

  //endregion

  //region Common Methods
  Future<void> updateUserData(UserData user) async {
    userService.updateDocument(
      {
        'player_id': getStringAsync(PLAYERID),
        'updatedAt': Timestamp.now(),
      },
      user.uid,
    );
  }

  Future<void> loginFromFirebaseUser(User currentUser, {LoginResponse? loginData}) async {
    if (loginData!.data != null) {
      if (await userService.isUserExist(loginData.data!.email)) {
        log(" User  ${loginData.data!.apiToken.validate()}");

        ///Return user data
        await userService.userByEmail(loginData.data!.email).then((user) async {
          setRegisterData(currentUser: currentUser, userModel: loginData.data!, isRegister: false);
        }).catchError((e) {
          log(e);
          throw e;
        });
      } else {
        log("Create User");

        /// Create user
        loginData.data!.uid = currentUser.uid.validate();
        loginData.data!.userType = LOGIN_TYPE_USER;
        loginData.data!.loginType = LOGIN_TYPE_GOOGLE;
        loginData.data!.playerId = getStringAsync(PLAYERID);
        if (isIOS) {
          loginData.data!.displayName = currentUser.displayName;
        }

        log(loginData.data!);

        setRegisterData(currentUser: currentUser, userModel: loginData.data!, isRegister: true);
      }
    } else {
      appStore.setLoading(false);

      log("---------------Error---------------");
    }
  }

  Future<void> setRegisterData({required User currentUser, UserData? registerData, required UserData userModel, bool isRegister = true}) async {
    await appStore.setUserProfile(currentUser.photoURL.validate());

    log("============UserModel: ${userModel.toJson()}");
    if (isRegister) {
      await userService.addDocumentWithCustomId(currentUser.uid, userModel.toJson()).then((value) async {
        if (registerData != null) {
          // Login Request
          var request = {
            UserKeys.email: registerData.email.validate(),
            UserKeys.password: registerData.password.validate(),
            UserKeys.playerId: getStringAsync(PLAYERID),
          };

          // Calling Login API
          await loginUser(request).then((res) async {
            if (res.data!.userType == LOGIN_TYPE_USER) {
              // When Login is Successfully done and will redirect to HomeScreen.
              toast(language!.loginSuccessfully, print: true);
              appStore.setLoggedIn(true);
              if (res.data != null) await saveUserData(res.data!);
              appStore.setLoading(false);
            }
          }).catchError((e) {
            toast("Please Login Again");
            appStore.setLoading(false);

            throw USER_CANNOT_LOGIN;
          });
        }
      }).catchError((e) {
        log(e.toString());
        appStore.setLoading(false);

        throw USER_NOT_CREATED;
      });
    } else {
      appStore.setLoading(false);
      appStore.setLoggedIn(true);

      await saveUserData(userModel);
    }
  }

  //endregion

  //region OTP

  Future<void> loginWithOTP(BuildContext context, String phoneNumber) async {
    return await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        //
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          toast('The provided phone number is not valid.');
          throw 'The provided phone number is not valid.';
        } else {
          toast(e.toString());
          throw e.toString();
        }
      },
      codeSent: (String verificationId, int? resendToken) async {
        finish(context);

        appStore.setLoading(false);

        showInDialog(
          context,
          contentPadding: EdgeInsets.zero,
          builder: (p0) => AppCommonDialog(
            title: "ENTER OTP ",
            child: OTPDialog(verificationId: verificationId, isCodeSent: true, phoneNumber: phoneNumber),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
      },
    );
  }

  Future<void> signUpWithOTP(context, UserData data) async {
    AuthCredential credential = PhoneAuthProvider.credential(
      verificationId: data.verificationId.validate(),
      smsCode: data.otpCode.validate(),
    );

    await FirebaseAuth.instance.signInWithCredential(credential).then((result) {
      if (result.user != null) {
        User currentUser = result.user!;
        UserData userModel = UserData();
        var displayName = data.firstName.validate() + data.lastName.validate();

        userModel.uid = currentUser.uid.validate();
        userModel.email = data.email.validate();
        userModel.contactNumber = data.contactNumber.validate();
        userModel.firstName = data.firstName.validate();
        userModel.lastName = data.lastName.validate();
        userModel.username = data.username.validate();
        userModel.displayName = displayName;
        userModel.userType = LOGIN_TYPE_USER;
        userModel.loginType = LOGIN_TYPE_OTP;
        userModel.createdAt = Timestamp.now().toDate().toString();
        userModel.updatedAt = Timestamp.now().toDate().toString();
        userModel.playerId = getStringAsync(PLAYERID);

        log("User ${userModel.toJson()}");

        setRegisterData(currentUser: currentUser, registerData: data, userModel: userModel, isRegister: true);
      }
    });
  }

//endregion

}
