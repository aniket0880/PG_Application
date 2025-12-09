import 'package:untitled/constants.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AssignmentScreen extends StatefulWidget {
  const AssignmentScreen({Key? key}) : super(key: key);
  static String routeName = 'AssignmentScreen';

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final List<_Complaint> _complaints = [];

  void _submitComplaint() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _complaints.insert(
        0,
        _Complaint(
          subject: _subjectController.text.trim(),
          category: _categoryController.text.trim(),
          description: _descriptionController.text.trim(),
          createdAt: DateTime.now(),
          status: 'Open',
        ),
      );
    });

    _subjectController.clear();
    _categoryController.clear();
    _descriptionController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint ticket raised successfully')),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint', style: TextStyle(fontSize: 11.sp)),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: kOtherColor,
                borderRadius: kTopBorderRadius,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(kDefaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raise a Ticket',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 1.h),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _subjectController,
                            style: TextStyle(color: Colors.black, fontSize: 10.sp),
                            decoration: _formDecoration('Subject'),
                            validator: (value) =>
                            value!.trim().isEmpty ? 'Enter subject' : null,
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
                            validator: (value) =>
                            value!.trim().isEmpty ? 'Enter description' : null,
                          ),
                          SizedBox(height: 2.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _submitComplaint,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimaryColor,
                                padding: EdgeInsets.symmetric(vertical: 1.3.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(kDefaultPadding),
                                ),
                              ),
                              child: Text(
                                'Submit Ticket',
                                style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 2.5.h),

                    if (_complaints.isNotEmpty) ...[
                      Text(
                        'Your Tickets',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 10.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 1.h),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _complaints.length,
                        itemBuilder: (context, index) {
                          final ticket = _complaints[index];

                          return Container(
                            margin: EdgeInsets.only(bottom: 1.5.h),
                            padding: EdgeInsets.all(kDefaultPadding),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(kDefaultPadding),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 3),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ticket.subject,
                                  style: TextStyle(
                                    fontSize: 9.8.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                if (ticket.category.isNotEmpty)
                                  Text(
                                    ticket.category,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.black87,
                                    ),
                                  ),
                                SizedBox(height: 0.4.h),
                                Text(
                                  ticket.description,
                                  style: TextStyle(
                                    fontSize: 8.8.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                                SizedBox(height: 0.6.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Status: ${ticket.status}',
                                      style: TextStyle(fontSize: 8.5.sp, color: Colors.black87),
                                    ),
                                    Text(
                                      _formatDate(ticket.createdAt),
                                      style: TextStyle(fontSize: 8.2.sp, color: Colors.black54),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration _formDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 9.5.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 1.3.h, horizontal: 2.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kDefaultPadding),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}  "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
}

class _Complaint {
  final String subject, category, description, status;
  final DateTime createdAt;

  _Complaint({
    required this.subject,
    required this.category,
    required this.description,
    required this.createdAt,
    required this.status,
  });
}
