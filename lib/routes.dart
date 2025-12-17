import 'package:untitled/screens/AdminScreens/admin_home.dart';
import 'package:untitled/screens/AdminScreens/admin_payment_status_screen.dart';
import 'package:untitled/screens/Ask/help_screen.dart';
import 'package:untitled/screens/login_screen/login_screen.dart';
import 'package:untitled/screens/login_screen/signup_screen.dart';
import 'package:untitled/screens/splash_screen/splash_screen.dart';
import 'package:flutter/cupertino.dart';
import 'screens/Complain/assignment_screen.dart';
import 'screens/messmenu_screen/datesheet_screen.dart';
import 'screens/fee_screen/fee_screen.dart';
import 'screens/home_screen/home_screen.dart';
import 'screens/my_profile/my_profile.dart';
import 'package:untitled/screens/AdminScreens/admin_complaints_screen.dart';
import 'package:untitled/screens/AdminScreens/admin_mess_menu_screen.dart';
import 'package:untitled/screens/change_pass/change_password_screen.dart';

Map<String, WidgetBuilder> routes = {
  //all screens will be registered here like manifest in android
  SignupScreen.routeName: (context) => SignupScreen(),
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  MyProfileScreen.routeName: (context) => MyProfileScreen(),
  FeeScreen.routeName: (context) => FeeScreen(),
  ComplaintScreen.routeName: (context) => ComplaintScreen(),
  MessMenuScreen.routeName: (context) => MessMenuScreen(),

  AdminHome.routeName: (context) => AdminHome(),
  AdminComplaints.routeName: (context) => AdminComplaintsScreen(),

  AdminMessMenu.routeName: (ctx) => AdminMessMenuScreen(),
  HelpScreen.routeName: (context) => const HelpScreen(),

  ChangePasswordScreen.routeName: (context) =>
                                                const ChangePasswordScreen(),
  AdminPaymentStatusScreen.routeName: (context) =>
  const AdminPaymentStatusScreen(),
};




