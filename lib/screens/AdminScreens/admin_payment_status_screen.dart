import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class AdminPaymentStatusScreen extends StatelessWidget {
  static const routeName = 'AdminPaymentStatusScreen';

  const AdminPaymentStatusScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payment Status'),
          bottom: const TabBar(
            labelColor: Colors.white, // selected tab text color
            unselectedLabelColor: Colors.grey, // unselected tab text color
            tabs: [
              Tab(text: 'Mess Fees'),
              Tab(text: 'Electricity'),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            _UserPaymentList(type: 'rent'),
            _UserPaymentList(type: 'electricity'),
          ],
        ),
      ),
    );
  }
}
class _UserPaymentList extends StatelessWidget {
  final String type;

  const _UserPaymentList({required this.type});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = userSnapshot.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('payments')
              .where('type', isEqualTo: type)
              .where('status', isEqualTo: 'success')
              .snapshots(),
          builder: (context, paymentSnapshot) {
            if (!paymentSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final payments = paymentSnapshot.data!.docs;

            /// 🔑 registrationNo → payment
            final Map<String, Map<String, dynamic>> paidMap = {};
            for (var doc in payments) {
              final data = doc.data() as Map<String, dynamic>;
              if (data['registrationNo'] != null) {
                paidMap[data['registrationNo']] = data;
              }
            }

            return ListView.builder(
              padding: EdgeInsets.all(3.w),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user =
                users[index].data() as Map<String, dynamic>;

                final String name = user['name'] ?? '—';
                final String? regNo = user['registrationNo'];

                final bool isPaid =
                    regNo != null && paidMap.containsKey(regNo);

                final payment =
                regNo != null ? paidMap[regNo] : null;

                return _adminPaymentTile(
                  name: name,
                  regNo: regNo ?? '—',
                  isPaid: isPaid,
                  amount: payment?['amount'],
                );
              },
            );
          },
        );
      },
    );
  }
}

Widget _adminPaymentTile({
  required String name,
  required String regNo,
  required bool isPaid,
  int? amount,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: const [
        BoxShadow(color: Colors.black12, blurRadius: 4),
      ],
    ),
    child: Row(
      children: [
        // STATUS ICON
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: isPaid
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            isPaid ? Icons.check_circle : Icons.cancel,
            color: isPaid ? Colors.green : Colors.red,
          ),
        ),

        const SizedBox(width: 12),

        // USER DETAILS
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,color: Colors.black
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Reg No: $regNo',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),

        // AMOUNT & STATUS
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              isPaid ? '₹$amount' : '—',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isPaid ? 'PAID' : 'UNPAID',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isPaid ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
