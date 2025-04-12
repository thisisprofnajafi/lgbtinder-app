import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dating/Logic/cubits/auth_cubit/auth_state.dart';
import 'package:dating/core/api.dart';
import 'package:dating/core/config.dart';
import 'package:dating/presentation/firebase/auth_firebase.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../data/localdatabase.dart';

class AuthCubit extends Cubit<AuthStates> {
  AuthCubit() : super(AuthInitState());
  final Api _api = Api();

  // Send OTP for phone authentication
  Future<void> sendOtpForAuth({required String phoneNumber, required context}) async {
    try {
      emit(AuthLoading());
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification on some Android devices
          signInWithCredential(credential, context);
        },
        verificationFailed: (FirebaseException e) {
          emit(AuthErrorState(e.message ?? "Verification failed"));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(AuthOtpSentState(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  // Verify OTP and sign in
  Future<void> verifyOtpAndSignIn({
    required String verificationId,
    required String otp,
    required context,
    required bool isLogin,
  }) async {
    try {
      emit(AuthLoading());
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );
      
      await signInWithCredential(credential, context, isLogin: isLogin);
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  // Helper method to sign in with credentials
  Future<void> signInWithCredential(PhoneAuthCredential credential, context, {bool isLogin = true}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        if (isLogin) {
          // Check if user exists in backend for login
          checkUserIsValid(phone: userCredential.user!.phoneNumber ?? "", context: context);
        } else {
          // For registration flow
          emit(AuthLoggedInState(userCredential.user!));
        }
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  // Check if user exists in backend
  Future<void> checkUserIsValid({required String phone, required context}) async {
    try {
      // Extract country code and phone number
      String formattedPhone = phone.substring(1); // Remove the + sign
      String countryCode = "";
      String number = "";
      
      // Extract country code (assuming common formats)
      RegExp regExp = RegExp(r'(\d{1,3})(\d+)');
      var matches = regExp.firstMatch(formattedPhone);
      
      if (matches != null && matches.groupCount >= 2) {
        countryCode = matches.group(1) ?? "";
        number = matches.group(2) ?? "";
      } else {
        emit(AuthErrorState("Invalid phone number format"));
        return;
      }
      
      Map body = {
        "mobile": number,
        "ccode": countryCode,
      };

      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.userLogin}", data: body);

      if (response.statusCode == 200 && response.data["Result"] == "true") {
        emit(AuthUserHomeState(response.data.toString()));
        Preferences.saveUserDetails(response.data);
        Provider.of<FirebaseAuthService>(context, listen: false).singInAndStoreData(
            email: response.data["UserLogin"]["email"],
            uid: response.data["UserLogin"]["id"],
            number: response.data["UserLogin"]["mobile"],
            name: response.data["UserLogin"]["name"],
            proPicPath: response.data["UserLogin"]["other_pic"].toString().split("\$;").first);
      } else {
        // User not found
        emit(AuthErrorState(response.data["ResponseMsg"] ?? "User not found"));
      }
    } catch (e) {
      emit(AuthErrorState(e.toString()));
    }
  }

  void signOut() async {
    await FirebaseAuth.instance.signOut();
    await Preferences.clear();
    emit(AuthLogOut());
  }
}
