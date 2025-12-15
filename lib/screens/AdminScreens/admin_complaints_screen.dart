// lib/screens/admin/admin_complaints_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class AdminComplaintsScreen extends StatelessWidget {
  static const routeName = 'AdminComplaints';

  final _firestore = FirebaseFirestore.instance;

  AdminComplaintsScreen({Key? key}) : super(key: key);

  Future<void> _closeComplaint(BuildContext context, String docId) async {
    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Admin not signed in')));
      return;
    }

    try {
      await _firestore.collection('complaints').doc(docId).update({
        'status': 'Closed',
        'closedAt': FieldValue.serverTimestamp(),
        'closedBy': admin.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Complaint closed')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to close: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaintsStream = _firestore.collection('complaints').orderBy('createdAt', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(title: Text('Complaints', style: TextStyle(fontSize: 11.sp))),
      body: Container(
        color: kOtherColor,
        padding: EdgeInsets.all(kDefaultPadding),
        child: StreamBuilder<QuerySnapshot>(
          stream: complaintsStream,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
            final docs = snap.data?.docs ?? [];
            if (docs.isEmpty) return Center(child: Text('No complaints yet'));

            return ListView.separated(
              itemCount: docs.length,
              separatorBuilder: (_, __) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final d = docs[index];
                final data = d.data() as Map<String, dynamic>;
                final subject = data['subject'] ?? '';
                final category = data['category'] ?? '';
                final description = data['description'] ?? '';
                final status = data['status'] ?? 'Open';
                final createdAt = data['createdAt'] as Timestamp?;
                final userEmail = data['userEmail'] ?? '';
                final closedAt = data['closedAt'] as Timestamp?;
                final closedBy = data['closedBy'] ?? '';

                return Container(
                  padding: EdgeInsets.all(kDefaultPadding),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(kDefaultPadding)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(subject, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                      Text(status, style: TextStyle(color: status == 'Closed' ? Colors.green : Colors.orange)),
                    ]),
                    SizedBox(height: 4),
                    if (category.isNotEmpty) Text(category, style: TextStyle(fontSize: 9.sp)),
                    SizedBox(height: 6),
                    Text(description, style: TextStyle(fontSize: 9.sp, color: Colors.black87)),
                    SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('By: $userEmail', style: TextStyle(fontSize: 8.5.sp, color: Colors.black54)),
                        Text(_formatDate(createdAt), style: TextStyle(fontSize: 8.sp, color: Colors.black45)),
                        if (status == 'Closed' && closedAt != null)
                          Text('Closed: ${_formatDate(closedAt)} by $closedBy', style: TextStyle(fontSize: 8.sp, color: Colors.black45)),
                      ]),
                      if (status != 'Closed')
                        ElevatedButton(
                          onPressed: () => _closeComplaint(context, d.id),
                          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
                          child: Text('Close', style: TextStyle(fontSize: 9.sp)),
                        ),
                    ]),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '--';
    final d = ts.toDate();
    return "${d.day.toString().padLeft(2, '0')}/"
        "${d.month.toString().padLeft(2, '0')}/"
        "${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }
}
