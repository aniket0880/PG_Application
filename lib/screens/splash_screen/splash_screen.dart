import 'package:untitled/screens/login_screen/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/screens/login_screen/signup_screen.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushNamedAndRemoveUntil(
          context, SignupScreen
          .routeName, (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// --- LOGO FULL WIDTH ---
            Image.asset(
              'assets/images/img_1.png',
              width: 100.w,       // full screen width
              height: 30.h,       // adjust height as needed
              fit: BoxFit.cover,  // covers from end to end
            ),

            SizedBox(height: 4.h),

            /// --- TEXT BELOW LOGO ---
            Text(
              'Sri Ram',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              "Girl's PG",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ],
        ),
      ),
    );
  }
}
