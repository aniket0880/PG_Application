import 'dart:io';

import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/constants.dart';

// PDF
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FeeScreen extends StatefulWidget {
  const FeeScreen({Key? key}) : super(key: key);
  static String routeName = 'FeeScreen';

  @override
  State<FeeScreen> createState() => _FeeScreenState();
}

class _FeeScreenState extends State<FeeScreen> {
  late Razorpay _razorpay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _currentPaymentType = '';
  int _currentAmount = 0;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  // -------------------- PAYMENT HANDLERS --------------------

  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🔹 fetch user's registration number
    final userDoc = await _firestore
        .collection('users')
        .doc(user.uid)
        .get();

    final regNo = userDoc.data()?['registrationNo'];

    if (regNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration number not found')),
      );
      return;
    }

    await _firestore.collection('payments').add({
      'registrationNo': regNo, // ✅ IMPORTANT
      'type': _currentPaymentType,
      'amount': _currentAmount,
      'razorpayPaymentId': response.paymentId,
      'status': 'success',
      'createdAt': FieldValue.serverTimestamp(),
      'receiptNo': 'PG-${DateTime
          .now()
          .millisecondsSinceEpoch}',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Successful')),
    );
  }


  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Failed')),
    );
  }

  // -------------------- START PAYMENT --------------------

  void _startPayment({
    required int amount,
    required String type,
    required String description,
  }) {
    _currentPaymentType = type;
    _currentAmount = amount;

    var options = {
      'key': 'rzp_test_RryzsRvdqyuVWV',
      'amount': amount * 100, // paise
      'name': 'Sri Ram Girls PG',
      'description': description,
      'prefill': {
        'contact': '9000000000',
        'email': FirebaseAuth.instance.currentUser?.email ?? '',
      },
      'method': {
        'upi': true,
        'card': true,
        'netbanking': true,
        'wallet': true,
      }
    };

    _razorpay.open(options);
  }

  // -------------------- PDF RECEIPT --------------------

  Future<void> _downloadReceipt(Map<String, dynamic> data) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Sri Ram Girls PG',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Payment Receipt'),
              pw.Divider(),

              pw.Text('Receipt No: ${data['receiptNo']}'),
              pw.Text('Payment Type: ${data['type']}'),
              pw.Text('Amount Paid: ₹${data['amount']}'),
              pw.Text('Payment ID: ${data['razorpayPaymentId']}'),
              pw.Text('Status: ${data['status']}'),

              pw.SizedBox(height: 20),
              pw.Text(
                'Thank you for your payment.',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${data['receiptNo']}.pdf');
    await file.writeAsBytes(await pdf.save());

    await OpenFile.open(file.path);
  }

  // -------------------- UI --------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
      body: Container(
        padding: EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: kTopBorderRadius,
        ),
        child: Column(
          children: [
            _paymentCard(
              title: '6 Month Rent + Mess',
              amount: '₹60,000',
              onPay: () =>
                  _startPayment(
                    amount: 60000,
                    type: 'rent',
                    description: '6 Month Rent + Mess',
                  ),
            ),
            SizedBox(height: kDefaultPadding),
            _paymentCard(
              title: 'Electricity Bill (Monthly)',
              amount: '₹1,500',
              onPay: () =>
                  _startPayment(
                    amount: 1500,
                    type: 'electricity',
                    description: 'Monthly Electricity Bill',
                  ),
            ),
            SizedBox(height: kDefaultPadding),
            Expanded(child: _paymentHistory()),
          ],
        ),
      ),
    );
  }

  Widget _paymentCard({
    required String title,
    required String amount,
    required VoidCallback onPay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: kPrimaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Pay',
              style: TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          )
        ],
      ),
    );
  }


  // -------------------- PAYMENT HISTORY --------------------

  Widget _paymentHistory() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final regNo = userSnap.data!['registrationNo'];

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('payments')
              .where('registrationNo', isEqualTo: regNo)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No payment history'));
            }

            final docs = snapshot.data!.docs;

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final data = docs[index].data() as Map<String, dynamic>;

                return _paymentTile(data);
              },
            );
          },
        );
      },
    );
  }

  Widget _paymentTile(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['type'].toString().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,color: Colors.black
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Receipt: ${data['receiptNo']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${data['amount']}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _downloadReceipt(data), // ✅ NOW WORKS
                child: const Text(
                  'Download PDF',
                  style: TextStyle(
                    fontSize: 13,
                    color: kPrimaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}