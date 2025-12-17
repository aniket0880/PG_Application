import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({Key? key}) : super(key: key);
  static String routeName = 'MyProfileScreen';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          TextButton.icon(
            onPressed: () {
              // later: report profile issue
            },
            icon: const Icon(Icons.report_gmailerrorred_outlined, color: Colors.white),
            label: const Text('Report', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      //  Fetch user data from Firestore
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {

          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final String name = data['name'] ?? '—';
          final String email = data['email'] ?? '—';
          final String phone = data['phone'] ?? '—';
          final String regNo = data['registrationNo'] ?? '—';

          final Timestamp? joinedTs = data['joinedOn'];

          final String joinedOn = joinedTs == null
              ? 'Not available'
              : "${joinedTs.toDate().day.toString().padLeft(2, '0')}/"
              "${joinedTs.toDate().month.toString().padLeft(2, '0')}/"
              "${joinedTs.toDate().year}";


          return Container(
            color: kOtherColor,
            child: Column(
              children: [

                // ================= HEADER =================
                Container(
                  width: 100.w,
                  height: 13.h, // reduced height
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: kBottomBorderRadius,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 9.w,
                        backgroundColor: Colors.white,
                        backgroundImage: const AssetImage('assets/images/'),
                      ),
                      SizedBox(width: 4.w),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 2.h),

                // ================= BASIC INFO CARD =================
                _infoCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _profileItem(
                        title: 'Registration No',
                        value: regNo,
                      ),
                      _profileItem(
                        title: 'Joined On',
                        value: joinedOn,
                      ),
                    ],
                  ),
                ),

                // ================= CONTACT INFO =================
                _infoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _profileColumn(title: 'Email', value: email),
                      SizedBox(height: 1.5.h),
                      _profileColumn(title: 'Phone Number', value: phone),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= REUSABLE CARD =================
  static Widget _infoCard({required Widget child}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  // ================= SMALL ROW ITEM =================
  static Widget _profileItem({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10.sp, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  // ================= COLUMN ITEM =================
  static Widget _profileColumn({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 10.sp, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        const Divider(),
      ],
    );
  }
}
