import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/constants.dart';
import 'package:untitled/screens/Complain/assignment_screen.dart';
import 'package:untitled/screens/messmenu_screen/datesheet_screen.dart';
import 'package:untitled/screens/fee_screen/fee_screen.dart';
import 'package:untitled/screens/my_profile/my_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';
import 'widgets/student_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static String routeName = 'HomeScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //fixed height for first half
          Container(
            width: 100.w,
            height: 40.h,
            padding: EdgeInsets.all(kDefaultPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StudentName(
                          studentName: 'Aryan',
                        ),
                        kHalfSizedBox,
                        StudentClass(studentClass: 'EX:Student ID'),
                        kHalfSizedBox,
                        StudentYear(studentYear: 'May-June'),
                      ],
                    ),
                    kHalfSizedBox,
                    StudentPicture(
                        picAddress: 'assets/images/img.png',
                        onPress: () {
                          Navigator.pushNamed(
                              context, MyProfileScreen.routeName);
                        }),
                  ],
                ),
                sizedBox,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    
                    StudentDataCard(
                      onPress: () {
                        Navigator.pushNamed(context, FeeScreen.routeName);
                      },
                      title: 'Fees Due',
                      value: '600 rupees',
                    ),
                  ],
                )
              ],
            ),
          ),

          // Remaining bottom section
          Expanded(
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: kOtherColor,
                borderRadius: kTopBorderRadius,
              ),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Wrap(
                    spacing: 1.h, // space between columns
                    runSpacing: 1.5.h, // space between rows
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
                        onPress: () {},
                        icon: 'assets/icons/ask.svg',
                        title: 'Ask',
                      ),

                      HomeCard(
                        onPress: () {},
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
                          Navigator.pushNamedAndRemoveUntil(context, 'LoginScreen', (r) => false);
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

class HomeCard extends StatelessWidget {
  const HomeCard(
      {Key? key,
        required this.onPress,
        required this.icon,
        required this.title})
      : super(key: key);

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
              height: SizerUtil.deviceType == DeviceType.tablet ? 28.sp : 36.sp,
              width: SizerUtil.deviceType == DeviceType.tablet ? 28.sp : 36.sp,
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
