// ignore_for_file: deprecated_member_use, use_super_parameters, prefer_typing_uninitialized_variables

import 'dart:convert';
import 'package:dating/core/config.dart';
import 'package:dating/presentation/screens/BottomNavBar/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../Logic/cubits/Home_cubit/home_cubit.dart';
import '../core/ui.dart';
import 'paymentcard.dart';

class StripePaymentWeb extends StatefulWidget {
  final PaymentCardCreated paymentCard;

  const StripePaymentWeb({Key? key, required this.paymentCard})
      : super(key: key);

  @override
  State<StripePaymentWeb> createState() => _StripePaymentWebState();
}

class _StripePaymentWebState extends State<StripePaymentWeb> {
  late WebViewController _controller;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // final dMode = Get.put(DarkMode());

  PaymentCardCreated? payCard;
  var progress;
  bool isPaymentSuccess = false;
  @override
  void initState() {
    super.initState();
    print(
        "prof is here ==========================================================================");
    setState(() {});

    payCard = widget.paymentCard;
  }

  String get initialUrl =>
      '${Config.baseUrl}stripe/index.php?name=${payCard!.name}&email=${payCard!.email}&cardno=${payCard!.number}&cvc=${payCard!.cvv}&amt=${payCard!.amount}&mm=${payCard!.month}&yyyy=${payCard!.year}&user_id=${payCard!.userId}&plan_id=${payCard!.planId}';

  @override
  Widget build(BuildContext context) {
    if (_scaffoldKey.currentState == null) {
      return PopScope(
        // onWillPop: (() async => true),
        canPop: true,
        onPopInvoked: (didPop) {},
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.only(top: 25),
                        color: Colors.grey.shade200,
                        height: MediaQuery.of(context).size.height,
                        child: WebView(
                          backgroundColor: Colors.grey.shade200,
                          initialUrl: initialUrl,
                          javascriptMode: JavascriptMode.unrestricted,
                          gestureNavigationEnabled: true,
                          onWebViewCreated: (controller) =>
                              _controller = controller,
                          onPageStarted: (String url) {
                            // Check if the user has reached the final page (success or cancel)
                            if (url.contains('success.php')) {
                              // Payment was successful
                              isPaymentSuccess = true;
                              _handlePaymentSuccess();
                              print("Page finished loading: $url success ========================================");
                            } else if (url.contains('cancel.php')) {
                              // Payment was canceled
                              isPaymentSuccess = false;
                              _handlePaymentCancel();
                              print("Page finished loading: $url faileddd =================================");
                            }
                          },
                          onPageFinished: (String url) {
                            // Here we can monitor the page loading state or use it to debug
                            print("Page finished loading: $url");
                          },
                          onProgress: (val) {
                            setState(() {});
                            progress = val;
                          },
                        ),
                      ),
                      Container(
                        height: 25,
                        color: Colors.white,
                        width: MediaQuery.of(context).size.width,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
            leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
            backgroundColor: Colors.black12,
            elevation: 0.0),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.appColor),
        ),
      );
    }
  }

  void _handlePaymentSuccess() {
    Fluttertoast.showToast(
      msg: "Payment Successful!",
      toastLength: Toast.LENGTH_SHORT,
    );
    // Navigate to the home page and clear the route stack
    BlocProvider.of<HomePageCubit>(context, listen: false).delUnlikeApi(context);
  }

  void _handlePaymentCancel() {
    Fluttertoast.showToast(
      msg: "Payment Canceled!",
      toastLength: Toast.LENGTH_SHORT,
    );
    // Navigate to the home page and clear the route stack
    BlocProvider.of<HomePageCubit>(context, listen: false).delUnlikeApi(context);
  }
}
