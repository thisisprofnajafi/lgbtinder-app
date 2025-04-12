import 'package:dating/Logic/cubits/onBording_cubit/onbording_state.dart';
import 'package:dating/core/api.dart';
import 'package:dating/core/config.dart';
import 'package:dating/data/localdatabase.dart';
import 'package:dating/data/models/languagemodel.dart';
import 'package:dating/data/models/usermodel.dart';
import 'package:dating/presentation/firebase/auth_firebase.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

import '../../../core/push_notification_function.dart';
import '../../../data/models/getinterest_model.dart';
import '../../../data/models/relationGoalModel.dart';
import '../../../presentation/screens/Splash_Bording/auth_screen.dart';

// Import the navigator key
import '../../../main.dart';

class OnbordingCubit extends Cubit<OnbordingState> {
  OnbordingCubit() : super(InitState());

  final Api _api = Api();

  Future<void> sendOtpFunction({
    required String phoneNumber,
    required context,
    bool isForgot = false,
  }) async {
    emit(LoadingState());
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification on some Android devices (mainly happens in Android)
          verifyOtpCode(context, credential, isForgot);
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(ErrorState(e.message ?? "Verification failed"));
        },
        codeSent: (String verificationId, int? resendToken) {
          Provider.of<OnBordingProvider>(context, listen: false).vericitionId = verificationId;
          Provider.of<OnBordingProvider>(context, listen: false).otpBottomSheet(context, isForgot);
          emit(otpComplete());
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint("Exception in sendOtpFunction: $e");
      emit(ErrorState("An unexpected error occurred. Please try again."));
    }
  }

  // Method to verify OTP code
  Future<void> verifyOtpCode(context, PhoneAuthCredential credential, bool isForgot) async {
    try {
      emit(LoadingState());
      
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        String phoneNumber = userCredential.user!.phoneNumber ?? "";
        
        if (isForgot) {
          // For forgot password flow
          emit(otpComplete());
        } else {
          // For login or registration flow
          checkUserExistsInBackend(context, phoneNumber);
        }
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  // Check if user exists in backend
  Future<void> checkUserExistsInBackend(context, String phoneNumber) async {
    try {
      // Extract country code and phone number
      String formattedPhone = phoneNumber.substring(1); // Remove the + sign
      String countryCode = "";
      String number = "";
      
      RegExp regExp = RegExp(r'(\d{1,3})(\d+)');
      var matches = regExp.firstMatch(formattedPhone);
      
      if (matches != null && matches.groupCount >= 2) {
        countryCode = matches.group(1) ?? "";
        number = matches.group(2) ?? "";
      } else {
        emit(ErrorState("Invalid phone number format"));
        return;
      }
      
      // Check if user exists
      Map data = {"mobile": number, "ccode": countryCode};
      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.userLogin}", data: data);
      
      if (response.statusCode == 200) {
        if (response.data["Result"] == "true") {
          // User exists - Login successful
          emit(CompletSteps());
          Preferences.saveUserDetails(response.data);
          Provider.of<FirebaseAuthService>(context, listen: false).singInAndStoreData(
              email: response.data["UserLogin"]["email"] ?? "",
              uid: response.data["UserLogin"]["id"].toString(),
              number: response.data["UserLogin"]["mobile"],
              name: response.data["UserLogin"]["name"],
              proPicPath: response.data["UserLogin"]["other_pic"].toString().split("\$;").first);
        } else {
          // User does not exist - continue with registration
          updatestepsCount(2); // Move to step 2 of registration
        }
      } else {
        emit(ErrorState(response.data["ResponseMsg"] ?? "Something went wrong"));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  Future mobileCheckApi({required String number, required String ccode}) async {
    try {
      Map body = {"mobile": number, "ccode": "+$ccode"};

      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.mobileCheck}", data: body);

      if (response.data["Result"] == "false") {
        Fluttertoast.showToast(msg: response.data["ResponseMsg"]);
      }

      return response.data["Result"];
    } catch (e) {
      emit(ErrorState(e.toString()));
      rethrow;
    }
  }

  Future<RelationGoalModel> relationGoalListApi() async {
    try {
      Response response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.relationGoalList}");

      if (response.statusCode == 200) {
        return RelationGoalModel.fromJson(response.data);
      } else {
        emit(ErrorState(response.statusMessage.toString()));
        return RelationGoalModel.fromJson(response.data);
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      rethrow;
    }
  }

  Future<InterestModel> getInterestApi() async {
    try {
      Response response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.getInterestList}");

      if (response.statusCode == 200) {
        return InterestModel.fromJson(response.data);
      } else {
        emit(ErrorState(response.statusMessage.toString()));
        return InterestModel.fromJson(response.data);
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      rethrow;
    }
  }

  Future<LanguageModel> languagelistApi() async {
    try {
      Response response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.languagelist}");

      if (response.statusCode == 200) {
        return LanguageModel.fromJson(response.data);
      } else {
        emit(ErrorState(response.statusMessage.toString()));
        return LanguageModel.fromJson(response.data);
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      rethrow;
    }
  }

  // Method to update steps count
  void updatestepsCount(int step) {
    if (navigatorKey.currentContext != null) {
      Provider.of<OnBordingProvider>(navigatorKey.currentContext!, listen: false).updateStepCount(step);
    }
  }

  // Still using the registerUserApi but we don't need to collect password anymore
  Future<UserModel> registerUserApi({
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String bday,
    required String searchPreference,
    required String rediusSearch,
    required String relationGoal,
    required String profileBio,
    required String intrest,
    required String language,
    required String refCode,
    required String gender,
    required String lat,
    required String long,
    required List images,
    required context,
  }) async {
    emit(LoadingState());
    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'email': email,
        'mobile': mobile,
        'ccode': ccode,
        'birth_date': bday,
        'search_preference': searchPreference,
        'radius_search': rediusSearch,
        'relation_goal': relationGoal,
        'profile_bio': profileBio,
        'interest': intrest,
        'language': language,
        'password': "", // Password is not needed anymore
        'refercode': refCode,
        'gender': gender,
        'lats': lat,
        'longs': long,
        'size': images.length,
        for (int a = 0; a < images.length; a++)
          'otherpic$a': await MultipartFile.fromFile(images[a].path, filename: images[a].path.split('/').last)
      });

      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.regiseruser}", data: formData);

      if (response.statusCode == 200) {
        if (response.data["Result"] == "true") {
          emit(CompletSteps());
          Preferences.saveUserDetails(response.data);
          initPlatformState();
          OneSignal.shared.sendTag("user_id", response.data["UserLogin"]["id"]);
          setUpFirebase(context,
              email: response.data["UserLogin"]["email"],
              uid: response.data["UserLogin"]["id"],
              proPic: response.data["UserLogin"]["profile_pic"].toString().split("\$;").first,
              number: response.data["UserLogin"]["mobile"],
              name: response.data["UserLogin"]["name"]);
          return UserModel.fromJson(response.data);
        } else {
          emit(ErrorState(response.data["ResponseMsg"]));
          return UserModel.fromJson(response.data);
        }
      } else {
        emit(ErrorState(response.data["ResponseMsg"]));
        return UserModel.fromJson(response.data);
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      rethrow;
    }
  }

  setUpFirebase(context,
      {required String email,
      required String name,
      required String number,
      required String uid,
      required String proPic}) {
    try {
      Provider.of<FirebaseAuthService>(context, listen: false)
          .singUpAndStore(email: email, uid: uid, proPicPath: proPic, name: name, number: number);
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }

  // For password reset - keeping this functionality
  Future forgotPassApi(
      {required String mobile, required String password, required String ccode, required context}) async {
    try {
      Map data = {"mobile": mobile, "password": password, "ccode": "+$ccode"};
      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.forgetPassword}", data: data);
      if (response.statusCode == 200) {
        if (response.data["Result"] == "true") {
          Navigator.pushNamedAndRemoveUntil(context, AuthScreen.authScreenRoute, (route) => false);
          emit(ErrorState(response.data["ResponseMsg"]));
        } else {
          Navigator.pop(context);
          Navigator.pop(context);
          emit(ErrorState(response.data["ResponseMsg"]));
        }
      } else {
        emit(ErrorState(response.data["ResponseMsg"]));
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      rethrow;
    }
  }
}
