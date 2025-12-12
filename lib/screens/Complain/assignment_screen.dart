// lib/screens/complaint_screen/complaint_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:untitled/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({Key? key}) : super(key: key);
  static String routeName = 'Complain Screen';

  @override
  State<ComplaintScreen> createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _isSubmitting = false;

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to submit a ticket')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final nowMillis = DateTime.now().millisecondsSinceEpoch;

      await _firestore.collection('complaints').add({
        'subject': _subjectController.text.trim(),
        'category': _categoryController.text.trim(),
        'description': _descriptionController.text.trim(),
        'status': 'Open',
        'createdAt': FieldValue.serverTimestamp(), // server timestamp
        'createdAtMillis': nowMillis, // client fallback for immediate ordering/display
        'userId': user.uid,
        'userEmail': user.email ?? '',
      });

      _subjectController.clear();
      _categoryController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaint ticket raised successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit ticket: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(Timestamp? ts, int? millis) {
    if (ts != null) {
      final date = ts.toDate();
      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}  "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    }
    if (millis != null) {
      final d = DateTime.fromMillisecondsSinceEpoch(millis);
      return "${d.day.toString().padLeft(2, '0')}/"
          "${d.month.toString().padLeft(2, '0')}/"
          "${d.year}  "
          "${d.hour.toString().padLeft(2, '0')}:"
          "${d.minute.toString().padLeft(2, '0')}";
    }
    return '--';
  }

  void _showComplaintDetails(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kDefaultPadding)),
      ),
      builder: (ctx) {
        final status = data['status'] ?? 'Open';
        final createdAt = data['createdAt'] as Timestamp?;
        final createdAtMillis = data['createdAtMillis'] is int
            ? data['createdAtMillis'] as int
            : (data['createdAtMillis'] is num ? (data['createdAtMillis'] as num).toInt() : null);
        final closedAt = data['closedAt'] as Timestamp?;
        final closedAtMillis = data['closedAtMillis'] is int
            ? data['closedAtMillis'] as int
            : (data['closedAtMillis'] is num ? (data['closedAtMillis'] as num).toInt() : null);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: Text(data['subject'] ?? '', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600))),
                _StatusPill(status: status),
              ]),
              SizedBox(height: 1.h),
              if ((data['category'] ?? '').toString().isNotEmpty)
                Text('Category: ${data['category']}', style: TextStyle(fontSize: 10.sp)),
              SizedBox(height: 1.h),
              Text(data['description'] ?? '', style: TextStyle(fontSize: 9.5.sp, color: Colors.black87)),
              SizedBox(height: 1.5.h),
              Text('Submitted: ${_formatDate(createdAt, createdAtMillis)}', style: TextStyle(fontSize: 8.5.sp, color: Colors.black54)),
              if (status == 'Closed')
                Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Closed: ${_formatDate(closedAt, closedAtMillis)}',
                    style: TextStyle(fontSize: 8.5.sp, color: Colors.black54),
                  ),
                ),
              SizedBox(height: 2.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Close', style: TextStyle(color: kPrimaryColor)),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        );
      },
    );
  }

  // helper to force a rebuild (used by retry button)
  void _forceRebuild() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Complaint', style: TextStyle(fontSize: 11.sp))),
        body: Center(child: Text('Please sign in to raise complaints')),
      );
    }

    // Order by createdAtMillis which is always present (client-supplied fallback)
    final ticketsStream = _firestore
        .collection('complaints')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAtMillis', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint', style: TextStyle(fontSize: 11.sp)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: kOtherColor, borderRadius: kTopBorderRadius),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raise a Ticket',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10.sp, color: Colors.black)),
                    SizedBox(height: 1.h),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _subjectController,
                            style: TextStyle(color: Colors.black, fontSize: 10.sp),
                            decoration: _formDecoration('Subject'),
                            validator: (value) => value!.trim().isEmpty ? 'Enter subject' : null,
                          ),
                          SizedBox(height: 1.2.h),
                          TextFormField(
                            controller: _categoryController,
                            style: TextStyle(color: Colors.black, fontSize: 10.sp),
                            decoration: _formDecoration('Category (Fees, Attendance, Hostel...)'),
                          ),
                          SizedBox(height: 1.2.h),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 4,
                            style: TextStyle(color: Colors.black, fontSize: 10.sp),
                            decoration: _formDecoration('Describe your issue'),
                            validator: (value) => value!.trim().isEmpty ? 'Enter description' : null,
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitComplaint,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: EdgeInsets.symmetric(vertical: 1.3.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kDefaultPadding),
                                ),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                  : Text('Submit Ticket', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500,color: Colors.black)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.5.h),

                    // DIAGNOSTIC STREAMBUILDER: shows full error + retry button
                    StreamBuilder<QuerySnapshot>(
                      stream: ticketsStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          final err = snapshot.error;
                          debugPrint('ticketsStream error (detailed): $err');

                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Error loading tickets', style: TextStyle(color: Colors.red)),
                                SizedBox(height: 6),
                                SelectableText(err.toString(), style: TextStyle(fontSize: 10.sp, color: Colors.black87)),
                                SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _forceRebuild,
                                  child: Text('Retry'),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Tip: if this says PERMISSION_DENIED, check Firestore rules or use dev rules while testing.',
                                  style: TextStyle(fontSize: 8.5.sp, color: Colors.black54),
                                ),
                              ],
                            ),
                          );
                        }

                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final docs = snapshot.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Text('No tickets yet.'),
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Your Tickets', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10.sp, color: Colors.black)),
                            SizedBox(height: 1.h),
                            SizedBox(
                              height: 20.h, // height of each card
                              child: PageView.builder(
                                controller: PageController(viewportFraction: 0.85),
                                itemCount: docs.length,
                                itemBuilder: (context, index) {
                                  final d = docs[index];
                                  final data = d.data() as Map<String, dynamic>;

                                  // defensive parsing for numeric createdAtMillis
                                  final createdAtMillisRaw = data['createdAtMillis'];
                                  final int? createdAtMillis = createdAtMillisRaw is int
                                      ? createdAtMillisRaw
                                      : (createdAtMillisRaw is num ? createdAtMillisRaw.toInt() : null);

                                  final subject = data['subject'] ?? '';
                                  final category = data['category'] ?? '';
                                  final description = data['description'] ?? '';
                                  final status = data['status'] ?? 'Open';
                                  final createdAt = data['createdAt'] as Timestamp?;

                                  return GestureDetector(
                                    onTap: () => _showComplaintDetails(context, data),
                                    child: Container(
                                      margin: EdgeInsets.only(right: 2.w),
                                      padding: EdgeInsets.all(kDefaultPadding),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(kDefaultPadding),
                                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(subject,
                                                          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                                    ),
                                                    _StatusPill(status: status),
                                                  ],
                                                ),
                                                SizedBox(height: 0.6.h),
                                                if ((category ?? '').toString().isNotEmpty)
                                                  Text(category, style: TextStyle(fontSize: 9.sp, color: Colors.black87)),
                                                SizedBox(height: 0.6.h),
                                                Text(
                                                  description,
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(fontSize: 8.5.sp, color: Colors.black54),
                                                ),
                                                SizedBox(height: 0.8.h),
                                                Text(_formatDate(createdAt, createdAtMillis), style: TextStyle(fontSize: 8.2.sp, color: Colors.black45)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
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

  InputDecoration _formDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(fontSize: 9.5.sp, color: Colors.black, fontWeight: FontWeight.w500),
      contentPadding: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 2.w),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kDefaultPadding)),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool closed = status.toLowerCase() == 'closed';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: closed ? Colors.green.shade600 : Colors.orange.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        closed ? 'Closed' : 'Open',
        style: TextStyle(color: Colors.white, fontSize: 8.5.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
