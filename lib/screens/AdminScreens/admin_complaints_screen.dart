// lib/screens/admin/admin_complaints_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class AdminComplaintsScreen extends StatelessWidget {
  static const routeName = 'AdminComplaints';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminComplaintsScreen({Key? key}) : super(key: key);

  Future<void> _closeComplaint(BuildContext context, String docId) async {
    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) return;

    await _firestore.collection('complaints').doc(docId).update({
      'status': 'Closed',
      'closedAt': FieldValue.serverTimestamp(),
      'closedBy': admin.uid,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Complaint closed')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaints'),
        centerTitle: true,
      ),
      body: Container(
        color: kOtherColor,
        padding: EdgeInsets.all(3.w),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('complaints')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final complaints = snap.data!.docs;
            if (complaints.isEmpty) {
              return const Center(child: Text('No complaints found'));
            }

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final doc = complaints[index];
                final data = doc.data() as Map<String, dynamic>;

                return _ComplaintCard(
                  data: data,
                  docId: doc.id,
                  onClose: () => _closeComplaint(context, doc.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               COMPLAINT CARD                               */
/* -------------------------------------------------------------------------- */

class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;
  final VoidCallback onClose;

  const _ComplaintCard({
    required this.data,
    required this.docId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'Open';
    final subject = data['subject'] ?? 'No subject';
    final category = data['category'] ?? '';
    final description = data['description'] ?? '';
    final createdAt = data['createdAt'] as Timestamp?;
    final closedAt = data['closedAt'] as Timestamp?;
    final userId = data['userId'];

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
      builder: (context, userSnap) {
        final userName =
            userSnap.data?.get('name') ?? 'Unknown User';
        final userEmail =
            userSnap.data?.get('email') ?? '';

        return Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),

              if (category.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // DESCRIPTION
              Text(
                description,
                style: const TextStyle(fontSize: 14,color: Colors.black),
              ),

              const Divider(height: 28),

              // USER INFO
              Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(
                    '$userName ($userEmail)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // DATE INFO
              Text(
                'Created: ${_formatDate(createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.black45),
              ),

              if (status == 'Closed')
                Text(
                  'Closed: ${_formatDate(closedAt)}',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),

              const SizedBox(height: 12),

              // ACTION BUTTON
              if (status != 'Closed')
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Close Complaint'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                STATUS BADGE                                */
/* -------------------------------------------------------------------------- */

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isClosed = status == 'Closed';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isClosed ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isClosed ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                DATE FORMAT                                 */
/* -------------------------------------------------------------------------- */

String _formatDate(Timestamp? ts) {
  if (ts == null) return '--';
  final d = ts.toDate();
  return "${d.day.toString().padLeft(2, '0')}/"
      "${d.month.toString().padLeft(2, '0')}/"
      "${d.year}  ${d.hour.toString().padLeft(2, '0')}:"
      "${d.minute.toString().padLeft(2, '0')}";
}
