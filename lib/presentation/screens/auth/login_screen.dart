import 'package:dating/Logic/cubits/onBording_cubit/onbording_cubit.dart';
import 'package:dating/Logic/cubits/onBording_cubit/onbording_state.dart';
import 'package:dating/presentation/screens/BottomNavBar/bottombar.dart';
import 'package:dating/presentation/screens/splash_bording/creat_steps.dart';
import 'package:dating/presentation/screens/splash_bording/onBordingProvider/onbording_provider.dart';
import 'package:dating/presentation/screens/splash_bording/onbording_screens.dart';
import 'package:dating/presentation/widgets/main_button.dart';
import 'package:dating/presentation/widgets/other_widget.dart';
import 'package:dating/presentation/widgets/sizeboxx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';

import '../../../Logic/cubits/auth_cubit/auth_cubit.dart';
import '../../../Logic/cubits/auth_cubit/auth_state.dart';
import '../../../core/ui.dart';
import '../../../language/localization/app_localization.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String loginRoute = "/loginScreen";

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late OnBordingProvider onBordingProvider;
  @override
  void initState() {
    super.initState();
    onBordingProvider = Provider.of<OnBordingProvider>(context, listen: false);
    onBordingProvider.mobileNumber.text = '';
  }

  @override
  Widget build(BuildContext context) {
    onBordingProvider = Provider.of<OnBordingProvider>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        BackButtons(),
                      ],
                    ),
                    const SizBoxH(size: 0.04),
                    Text(
                      AppLocalizations.of(context)?.translate("Sign in") ?? "Sign in",
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizBoxH(size: 0.01),
                    Text(
                      AppLocalizations.of(context)?.translate("Welcome back! Please enter your mobile number.") ??
                          "Welcome back! Please enter your mobile number.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizBoxH(size: 0.04),

                    IntlPhoneField(
                      initialCountryCode: "US",
                      keyboardType: TextInputType.number,
                      cursorColor: Colors.black,
                      showCountryFlag: false,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      disableLengthCheck: true,
                      controller: onBordingProvider.mobileNumber,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      dropdownIcon: const Icon(
                        Icons.arrow_drop_down,
                      ),
                      dropdownTextStyle: Theme.of(context).textTheme.bodyMedium,
                      style: Theme.of(context).textTheme.bodyMedium!,
                      onCountryChanged: (value) {
                        onBordingProvider.ccode =
                            onBordingProvider.updateVeriable(value.dialCode);
                      },
                      onChanged: (value) {
                        onBordingProvider.updateNameFiled(
                            controller: onBordingProvider.mobileNumber, value: value.number);
                      },
                      decoration: InputDecoration(
                        helperText: null,
                        hintText: AppLocalizations.of(context)?.translate("Mobile Number") ??
                            "Mobile Number",
                        hintStyle: Theme.of(context).textTheme.bodyMedium,
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: AppColors.appColor,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).dividerTheme.color!,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      invalidNumberMessage: AppLocalizations.of(context)
                          ?.translate("Please enter your mobile number") ??
                          "Please enter your mobile number",
                    ),

                    const SizBoxH(size: 0.04),
                    MainButton(
                      title: AppLocalizations.of(context)?.translate("Get Verification Code") ?? "Get Verification Code",
                      titleColor: Colors.white,
                      bgColor: AppColors.appColor,
                      onTap: () {
                        if (onBordingProvider.mobileNumber.text.isEmpty) {
                          Fluttertoast.showToast(msg: "Please Enter Mobile Number");
                        } else {
                          // Send OTP for authentication
                          BlocProvider.of<OnbordingCubit>(context).sendOtpFunction(
                            phoneNumber: "+${onBordingProvider.ccode}${onBordingProvider.mobileNumber.text.trim()}",
                            context: context,
                          );
                        }
                      }
                    ),
                  ],
                ),
              ),
            ),
            BlocConsumer<OnbordingCubit, OnbordingState>(listener: (context, state) {
              if (state is ErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error)));
              }
              if (state is CompletSteps) {
                Navigator.of(context)
                    .pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const BottomBar()), (route) => false);
              }
            }, builder: (context, state) {
              if (state is LoadingState) {
                return Center(child: CircularProgressIndicator(color: AppColors.appColor));
              } else {
                return const SizedBox();
              }
            }),
            BlocConsumer<AuthCubit, AuthStates>(listener: (context, state) {
              if (state is AuthErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage)));
              }

              if (state is AuthLoggedInState) {
                Navigator.pushNamed(context, CreatSteps.creatStepsRoute);
                onBordingProvider.setDataInFildes(state.firebaseuser);
              }

              if (state is AuthUserHomeState) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  BottomBar.bottomBarRoute,
                  (route) => false,
                );
              }
            }, builder: (context, state) {
              if (state is AuthLoading) {
                return Center(child: CircularProgressIndicator(color: AppColors.appColor));
              } else {
                return const SizedBox();
              }
            })
          ],
        ),
      ),
    );
  }
}
