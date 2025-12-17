// lib/screens/admin/admin_home.dart
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/svg.dart';
import 'package:untitled/constants.dart';
import 'package:untitled/screens/AdminScreens/admin_payment_status_screen.dart';
import 'package:untitled/screens/home_screen/home_screen.dart'; // optional if you want a back to client home
import 'package:firebase_auth/firebase_auth.dart';

class AdminHome extends StatelessWidget {
  static String routeName = 'AdminHome';

  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // you can use a different AppBar style to visually distinguish admin area
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, 'LoginScreen', (r) => false);
            },
          )
        ],
      ),
      body: Column(
        children: [
          // top info panel (admin greeting + quick stats)
          Container(
            width: 100.w,
            height: 30.h,
            padding: EdgeInsets.all(kDefaultPadding),
            color: kPrimaryColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Welcome, Admin',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: kOtherColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  'Manage mess, complaints and payments',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: kOtherColor,
                  ),
                ),
                SizedBox(height: 2.h),
                // small stat row (placeholders, you can wire these to real data)

              ],
            ),
          ),

          // bottom section with admin cards
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: kOtherColor,
                borderRadius: kTopBorderRadius,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
                physics: BouncingScrollPhysics(),
                child: Wrap(
                  spacing: 1.h,
                  runSpacing: 1.5.h,
                  alignment: WrapAlignment.center,
                  children: [
                    AdminCard(
                      onPress: () {
                        Navigator.pushNamed(context, AdminMessMenu.routeName);
                      },
                      iconAsset: 'assets/icons/datesheet.svg',
                      title: 'Update\nMess Menu',
                    ),
                    AdminCard(
                      onPress: () {
                        Navigator.pushNamed(context, AdminComplaints.routeName);
                      },
                      iconAsset: 'assets/icons/result.svg',
                      title: 'View\nComplaints',
                    ),
                    AdminCard(
                      onPress: () {
                        Navigator.pushNamed(context, AdminPaymentStatusScreen.routeName);
                      },
                      iconAsset: 'assets/icons/resume.svg',
                      title: 'Payment\nStatus',
                    ),

                    AdminCard(
                      onPress: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(context, 'LoginScreen', (r) => false);
                      },
                      iconAsset: 'assets/icons/logout.svg',
                      title: 'Logout',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// small stat widget used on top panel
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      decoration: BoxDecoration(
        color: kOtherColor,
        borderRadius: BorderRadius.circular(kDefaultPadding / 2),
      ),
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

/// Reusable admin card (similar to your HomeCard)
class AdminCard extends StatelessWidget {
  final VoidCallback onPress;
  final String iconAsset;
  final String title;

  const AdminCard({
    Key? key,
    required this.onPress,
    required this.iconAsset,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isTablet = SizerUtil.deviceType == DeviceType.tablet;
    return InkWell(
      onTap: onPress,
      child: Container(
        width: 42.w,
        height: 18.h,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.circular(kDefaultPadding / 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // use an svg icon; if you don't have these assets, replace with Icon(...)
            SvgPicture.asset(
              iconAsset,
              height: isTablet ? 28.sp : 36.sp,
              width: isTablet ? 28.sp : 36.sp,
              color: kOtherColor,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder classes for routes — create real screens later
class AdminMessMenu {
  static const routeName = 'AdminMessMenu';
}

class AdminComplaints {
  static const routeName = 'AdminComplaints';
}

class AdminPayments {
  static const routeName = 'AdminPayments';
}
