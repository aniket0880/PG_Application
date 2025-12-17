import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  static String routeName = 'HelpScreen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
      ),
      body: Container(
        width: 100.w,
        padding: EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: kTopBorderRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2.h),

            // -------- HEADER --------
            Text(
              'Need Help?',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              'Contact us using the details below for any issues related to PG, payments or facilities.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall!
                  .copyWith(color: Colors.black54),
            ),

            SizedBox(height: 3.h),

            // -------- PHONE CARD --------
            _contactCard(
              icon: Icons.call,
              title: 'Call Us',
              value: '+91 98765 43210',
              subtitle: 'Available 9 AM – 9 PM',
            ),

            SizedBox(height: 2.h),

            // -------- EMAIL CARD --------
            _contactCard(
              icon: Icons.email_outlined,
              title: 'Email Support',
              value: 'support@srigrampg.com',
              subtitle: 'We usually reply within 24 hours',
            ),

            SizedBox(height: 4.h),

            // -------- FOOTER NOTE --------
            Center(
              child: Text(
                'Thank you for staying with us 🙏',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= CONTACT CARD WIDGET =================
  Widget _contactCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimaryColor),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
