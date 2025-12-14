import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class MessMenuScreen extends StatefulWidget {
  const MessMenuScreen({Key? key}) : super(key: key);
  static const routeName = 'MessMenuScreen';

  @override
  State<MessMenuScreen> createState() => _MessMenuScreenState();
}

class _MessMenuScreenState extends State<MessMenuScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  final List<String> _daysOrder = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  final Map<String, String> _dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  /// 🔑 SAFELY CAST FIRESTORE MAPS
  Map<String, dynamic> _castMap(dynamic value) {
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildMealTile(String label, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultPadding / 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 3),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          SizedBox(height: 6),
          Text(
            value.isEmpty ? 'Not set' : value,
            style: TextStyle(fontSize: 9.sp, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ NO orderBy — safe fetch
    final stream = _firestore.collection('mess_menus').snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Mess Menu')),
      body: Container(
        width: 100.w,
        decoration: BoxDecoration(
          color: kOtherColor,
          borderRadius: kTopBorderRadius,
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading menu'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return const Center(child: Text('No mess menu available'));
            }

            /// Convert Firestore docs → clean Dart objects
            final weeks = docs.map((doc) {
              final data = _castMap(doc.data());

              final int week = data['week'] is int
                  ? data['week']
                  : int.tryParse(data['week']?.toString() ?? '0') ?? 0;

              final Map<String, dynamic> days =
              _castMap(data['days']);

              return {
                'week': week,
                'days': days,
              };
            }).toList()
              ..sort((a, b) =>
                  (a['week'] as int).compareTo(b['week'] as int));

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Rotation',
                    style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black),
                  ),
                  SizedBox(height: 1.h),

                  SizedBox(
                    height: 70.h,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: weeks.length,
                      itemBuilder: (context, index) {
                        final weekData = weeks[index];
                        final int weekNumber = weekData['week'] as int;
                        final Map<String, dynamic> days =
                        weekData['days'] as Map<String, dynamic>;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Week $weekNumber',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black),
                            ),
                            SizedBox(height: 1.h),

                            Expanded(
                              child: ListView.separated(
                                itemCount: _daysOrder.length,
                                separatorBuilder: (_, __) =>
                                    SizedBox(height: 1.4.h),
                                itemBuilder: (context, dayIndex) {
                                  final dayKey = _daysOrder[dayIndex];
                                  final dayData =
                                  _castMap(days[dayKey]);

                                  final breakfast =
                                      dayData['breakfast']?.toString() ?? '';
                                  final lunch =
                                      dayData['lunch']?.toString() ?? '';
                                  final dinner =
                                      dayData['dinner']?.toString() ?? '';

                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _dayLabels[dayKey]!,
                                        style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black),
                                      ),
                                      SizedBox(height: 8),
                                      _buildMealTile(
                                          'Breakfast', breakfast),
                                      SizedBox(height: 8),
                                      _buildMealTile('Lunch', lunch),
                                      SizedBox(height: 8),
                                      _buildMealTile('Dinner', dinner),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
