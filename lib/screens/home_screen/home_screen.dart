import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sizer/sizer.dart';

import 'package:untitled/constants.dart';
import 'package:untitled/screens/Ask/help_screen.dart';
import 'package:untitled/screens/Change_Pass/change_password_screen.dart';
import 'package:untitled/screens/Complain/assignment_screen.dart';
import 'package:untitled/screens/messmenu_screen/datesheet_screen.dart';
import 'package:untitled/screens/fee_screen/fee_screen.dart';
import 'package:untitled/screens/my_profile/my_profile.dart';

import 'widgets/student_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  static String routeName = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      body: Column(
        children: [
          // ================= TOP PROFILE SECTION =================
          Container(
            width: 100.w,
            height: 40.h,
            padding: EdgeInsets.all(kDefaultPadding),
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('User data not found'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;

                // ---------- SAFE DATA EXTRACTION ----------
                final String name = data['name'] ?? '—';
                final String regNo = data['registrationNo'] ?? '—';

                final Timestamp? joinedTs = data['joinedOn'];
                final String joinedText = joinedTs == null
                    ? '—'
                    : "${joinedTs.toDate().month}/${joinedTs.toDate().year}";

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ---------- LEFT SIDE TEXT ----------
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StudentName(studentName: name),
                            kHalfSizedBox,
                            StudentClass(studentClass: regNo),
                            kHalfSizedBox,
                            StudentYear(studentYear: joinedText),
                          ],
                        ),

                        // ---------- PROFILE PICTURE ----------
                        StudentPicture(
                          picAddress: 'assets/images/img_2.png',
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              MyProfileScreen.routeName,
                            );
                          },
                        ),
                      ],
                    ),

                    sizedBox,

                    // ---------- QUICK ACTION CARD ----------
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StudentDataCard(
                          onPress: () {
                            Navigator.pushNamed(
                                context, FeeScreen.routeName);
                          },
                          title: 'Fees Payment',
                          value: '',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // ================= BOTTOM GRID SECTION =================
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: kOtherColor,
                borderRadius: kTopBorderRadius,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Wrap(
                    spacing: 1.h,
                    runSpacing: 1.5.h,
                    alignment: WrapAlignment.center,
                    children: [
                      HomeCard(
                        onPress: () {
                          Navigator.pushNamed(
                              context, ComplaintScreen.routeName);
                        },
                        icon: 'assets/icons/assignment.svg',
                        title: 'Complain',
                      ),
                      HomeCard(
                        onPress: () {
                          Navigator.pushNamed(
                              context, MessMenuScreen.routeName);
                        },
                        icon: 'assets/icons/datesheet.svg',
                        title: 'Mess Menu',
                      ),
                      HomeCard(
                        onPress: () {
                          Navigator.pushNamed(context, HelpScreen.routeName);
                        },
                        icon: 'assets/icons/ask.svg',
                        title: 'Help',
                      ),

                      HomeCard(
                        onPress: () {
                          Navigator.pushNamed(
                            context,
                            ChangePasswordScreen.routeName,
                          );
                        },
                        icon: 'assets/icons/lock.svg',
                        title: 'Change\nPassword',
                      ),

                      HomeCard(
                        onPress: () {},
                        icon: 'assets/icons/event.svg',
                        title: 'Events',
                      ),
                      HomeCard(
                        onPress: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            'LoginScreen',
                                (route) => false,
                          );
                        },
                        icon: 'assets/icons/logout.svg',
                        title: 'Logout',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= HOME GRID CARD =================

class HomeCard extends StatelessWidget {
  const HomeCard({
    Key? key,
    required this.onPress,
    required this.icon,
    required this.title,
  }) : super(key: key);

  final VoidCallback onPress;
  final String icon;
  final String title;

  @override
  Widget build(BuildContext context) {
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
            SvgPicture.asset(
              icon,
              height: SizerUtil.deviceType == DeviceType.tablet
                  ? 28.sp
                  : 36.sp,
              width: SizerUtil.deviceType == DeviceType.tablet
                  ? 28.sp
                  : 36.sp,
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
