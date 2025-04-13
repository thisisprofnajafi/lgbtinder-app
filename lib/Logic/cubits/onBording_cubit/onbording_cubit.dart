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
      // First, notify backend that we're sending an OTP
      Map<String, dynamic> sendOtpData = {
        "phone_number": phoneNumber,
        "device_name": "Unknown Device"
      };
      
      // Call the backend send-otp endpoint
      await _api.sendRequest.post("${Config.baseUrlApi}${Config.sendOtp}", data: sendOtpData);
      
      // Now use Firebase to send the actual OTP
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
        String firebaseUid = userCredential.user!.uid;
        
        if (isForgot) {
          // For forgot password flow
          emit(otpComplete());
        } else {
          // For login or registration flow - Send verification details to backend
          Map<String, dynamic> verifyData = {
            'phone_number': phoneNumber,
            'firebase_uid': firebaseUid,
            'device_name': "Unknown Device"
          };
          
          // Now check if user exists in backend
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
      // Get Firebase UID if available
      String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      
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
      
      // Check if user exists using OTP verification endpoint
      Map data = {
        "phone_number": phoneNumber,
        "firebase_uid": firebaseUid,
        "device_name": "Unknown Device"
      };
      
      // Use the API endpoint for verify OTP as specified in the documentation
      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.verifyOtp}", data: data);
      
      if (response.statusCode == 200) {
        if (response.data["Result"] == "true" || response.data["user_exists"] == true) {
          // User exists - Login successful
          emit(CompletSteps());
          Preferences.saveUserDetails(response.data);
          
          // Store the auth token
          if (response.data["token"] != null) {
            await _api.updateAuthToken(response.data["token"]);
          }
          
          // If profile is incomplete, redirect to profile completion
          if (response.data["profile_complete"] == false) {
            // Redirect to profile completion flow
            updatestepsCount(3); // Assuming step 3 is for profile completion
          } else {
            Provider.of<FirebaseAuthService>(context, listen: false).singInAndStoreData(
                email: response.data["UserLogin"]["email"] ?? "",
                uid: response.data["UserLogin"]["id"].toString(),
                number: response.data["UserLogin"]["mobile"] ?? "",
                name: response.data["UserLogin"]["name"] ?? "",
                proPicPath: response.data["UserLogin"]["other_pic"]?.toString().split("\$;").first ?? "");
          }
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
      Response response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.getRelationGoals}");

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
      Response response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.getInterests}");

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
      Response response = await _api.sendRequest.get("${Config.baseUrlApi}${Config.getLanguages}");

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

  // Method to register basic user information
  Future<String> registerBasicInfo({
    required String name,
    required String email,
    required String mobile,
    required String ccode,
    required String bio,
    required String refCode,
    required BuildContext context,
  }) async {
    emit(LoadingState());
    try {
      // Get Firebase UID if available
      String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      
      // Create data for initial registration according to API requirements
      Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'mobile': mobile,
        'ccode': ccode,
        'profile_bio': bio,
        'refercode': refCode,
        'firebase_uid': firebaseUid,
        'device_name': "Unknown Device",
        'phone_number': "+$ccode$mobile" // International format as required
      };

      // Store these values in provider or shared preferences for later use
      Provider.of<OnBordingProvider>(context, listen: false).name.text = name;
      Provider.of<OnBordingProvider>(context, listen: false).email.text = email;
      Provider.of<OnBordingProvider>(context, listen: false).bio.text = bio;
      Provider.of<OnBordingProvider>(context, listen: false).referelCode.text = refCode;
      Provider.of<OnBordingProvider>(context, listen: false).mobileNumber.text = mobile;
      Provider.of<OnBordingProvider>(context, listen: false).ccode = ccode;

      emit(InitState()); // Reset state
      return "success";
    } catch (e) {
      emit(ErrorState(e.toString()));
      return "error: ${e.toString()}";
    }
  }

  // Method to update user profile with all required information
  Future<UserModel> updateUserProfile({
    required String bday,
    required String searchPreference,
    required String rediusSearch,
    required String relationGoal,
    required String intrest,
    required String language,
    required String gender,
    required String lat,
    required String long,
    required List images,
    required BuildContext context,
  }) async {
    emit(LoadingState());
    try {
      OnBordingProvider provider = Provider.of<OnBordingProvider>(context, listen: false);
      
      // Get Firebase UID
      String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      
      // Create the form data with all collected information
      FormData formData = FormData.fromMap({
        'name': provider.name.text,
        'email': provider.email.text,
        'phone_number': "+${provider.ccode}${provider.mobileNumber.text}",
        'firebase_uid': firebaseUid,
        'birth_date': bday,
        'looking_for': searchPreference, // API uses 'looking_for' instead of 'search_preference'
        'radius_search': rediusSearch,
        'relation_goal': relationGoal,
        'profile_bio': provider.bio.text,
        'interest': intrest,
        'languages': language, // API possibly uses plural form
        'referral_code': provider.referelCode.text, // Match API naming
        'gender': gender,
        'latitude': lat, // API uses latitude/longitude instead of lats/longs
        'longitude': long,
        'device_name': "Unknown Device",
        for (int a = 0; a < images.length; a++)
          'profile_pictures[]': await MultipartFile.fromFile(images[a].path, filename: images[a].path.split('/').last)
      });

      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.register}", data: formData);

      if (response.statusCode == 200) {
        if (response.data["Result"] == "true") {
          emit(CompletSteps());
          Preferences.saveUserDetails(response.data);
          
          // If firebase auth is needed
          String? uid = response.data["UserLogin"]?["id"]?.toString();
          String userEmail = response.data["UserLogin"]?["email"] ?? "";
          String userName = response.data["UserLogin"]?["name"] ?? "";
          String userPhone = response.data["UserLogin"]?["mobile"] ?? "";
          String profilePic = response.data["UserLogin"]?["other_pic"]?.toString().split("\$;").first ?? "";
          
          if (uid != null) {
            Provider.of<FirebaseAuthService>(context, listen: false).singInAndStoreData(
              email: userEmail,
              uid: uid,
              number: userPhone,
              name: userName,
              proPicPath: profilePic
            );
          }
          
          return UserModel.fromJson(response.data);
        } else {
          emit(ErrorState(response.data["ResponseMsg"] ?? "Registration failed"));
          return UserModel.fromJson({});
        }
      } else {
        emit(ErrorState(response.data["ResponseMsg"] ?? "Something went wrong"));
        return UserModel.fromJson({});
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      return UserModel.fromJson({});
    }
  }

  // Method to update steps count
  void updatestepsCount(int step) {
    if (navigatorKey.currentContext != null) {
      Provider.of<OnBordingProvider>(navigatorKey.currentContext!, listen: false).updateStepCount(step);
    }
  }

  // Registration method conforming to API requirements
  Future<UserModel> registerUserApi({
    required String name,
    required String profileBio,
    String? email,
    required String mobile,
    required String ccode,
    String? refCode,
    required context,
  }) async {
    emit(LoadingState());
    try {
      // Get Firebase UID
      String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;
      if (firebaseUid == null) {
        emit(ErrorState("Firebase authentication required"));
        return UserModel.fromJson({});
      }
      
      // Create the minimum required data for basic registration
      Map<String, dynamic> data = {
        // Required fields
        'name': name,
        'phone_number': "+$ccode$mobile", // International format as required
        'firebase_uid': firebaseUid,
        'profile_bio': profileBio,
        'device_name': "Unknown Device",
        
        // Optional fields
        if (email != null && email.isNotEmpty) 'email': email,
        if (refCode != null && refCode.isNotEmpty) 'referral_code': refCode,
      };

      // Make the API call
      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.register}", data: data);

      if (response.statusCode == 200) {
        if (response.data["Result"] == "true" || response.data["success"] == true) {
          emit(CompletSteps());
          
          // Save user details
          Preferences.saveUserDetails(response.data);
          
          // Save authentication token
          if (response.data["token"] != null) {
            await _api.updateAuthToken(response.data["token"]);
          }
          
          // Initialize OneSignal
          initPlatformState();
          
          // Set OneSignal tag if user ID is available
          if (response.data["user"] != null && response.data["user"]["id"] != null) {
            OneSignal.shared.sendTag("user_id", response.data["user"]["id"]);
          }
          
          // Set up Firebase if needed
          if (response.data["user"] != null) {
            setUpFirebase(context,
                email: response.data["user"]["email"] ?? "",
                uid: response.data["user"]["id"].toString(),
                proPic: response.data["user"]["profile_picture"] ?? "",
                number: response.data["user"]["phone_number"] ?? "",
                name: response.data["user"]["name"] ?? "");
          }
          
          // Check if profile completion is required
          if (response.data["profile_complete"] == false) {
            // Move to profile completion step
            updatestepsCount(3); // Assuming step 3 is for profile completion
          }
          
          return UserModel.fromJson(response.data);
        } else {
          emit(ErrorState(response.data["message"] ?? "Registration failed"));
          return UserModel.fromJson({});
        }
      } else {
        emit(ErrorState(response.data["message"] ?? "Something went wrong"));
        return UserModel.fromJson({});
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      return UserModel.fromJson({});
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
      Response response = await _api.sendRequest.post("${Config.baseUrlApi}${Config.forgotPassword}", data: data);
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

  // Method for profile completion
  Future<UserModel> profileCompletion({
    required String bday,
    required String gender,
    required String lookingFor,
    required String city,
    required String lat,
    required String long,
    required List images,
    required BuildContext context,
  }) async {
    emit(LoadingState());
    try {
      // Get auth token - this method requires authentication
      String token = await Preferences.getToken();
      
      if (token.isEmpty) {
        emit(ErrorState("Authentication required"));
        return UserModel.fromJson({});
      }
      
      // Create form data for profile completion
      FormData formData = FormData.fromMap({
        'birth_date': bday,
        'gender': gender,
        'looking_for': lookingFor,
        'city': city,
        'latitude': lat,
        'longitude': long,
        for (int a = 0; a < images.length; a++)
          'profile_pictures[]': await MultipartFile.fromFile(images[a].path, filename: images[a].path.split('/').last)
      });

      // Set up headers with authentication token
      Options options = Options(
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
        },
      );

      // Make the API call
      Response response = await _api.sendRequest.post(
        "${Config.baseUrlApi}${Config.profileComplete}", 
        data: formData,
        options: options
      );

      if (response.statusCode == 200) {
        if (response.data["Result"] == "true" || response.data["success"] == true) {
          emit(CompletSteps());
          
          // Save updated user details
          Preferences.saveUserDetails(response.data);
          
          // Update authentication token if provided
          if (response.data["token"] != null) {
            await _api.updateAuthToken(response.data["token"]);
          }
          
          return UserModel.fromJson(response.data);
        } else {
          emit(ErrorState(response.data["ResponseMsg"] ?? "Profile completion failed"));
          return UserModel.fromJson({});
        }
      } else {
        emit(ErrorState(response.data["ResponseMsg"] ?? "Something went wrong"));
        return UserModel.fromJson({});
      }
    } catch (e) {
      emit(ErrorState(e.toString()));
      return UserModel.fromJson({});
    }
  }
}
