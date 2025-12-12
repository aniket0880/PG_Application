// lib/screens/messmenu_screen/mess_menu_screen.dart
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
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 3)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 6),
          Text(value.isEmpty ? 'Not set' : value, style: TextStyle(fontSize: 9.sp, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stream = _firestore.collection('mess_menus').orderBy('week').snapshots();

    return Scaffold(
      appBar: AppBar(title: Text('Mess Menu')),
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
              debugPrint('mess_menus stream error: ${snapshot.error}');
              return Center(child: Text('Error loading menu'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Text('No mess menus available yet.'),
                ),
              );
            }

            // Convert docs to ordered list of weeks with safe casting
            final weeks = docs.map((d) {
              final raw = d.data();
              final data = (raw is Map) ? Map<String, dynamic>.from(raw as Map) : <String, dynamic>{};

              final week = data['week'] is int
                  ? data['week'] as int
                  : int.tryParse(data['week']?.toString() ?? '') ?? 0;

              final daysMap = (data['days'] is Map)
                  ? Map<String, dynamic>.from(data['days'] as Map)
                  : <String, dynamic>{};

              return {'id': d.id, 'week': week, 'days': daysMap};
            }).toList()
              ..sort((a, b) => (a['week'] as int).compareTo(b['week'] as int));

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 2.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weekly rotation', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
                  SizedBox(height: 1.h),
                  SizedBox(
                    height: 70.h,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: weeks.length,
                      itemBuilder: (context, idx) {
                        final weekDoc = weeks[idx];
                        final weekNumber = weekDoc['week'] as int;
                        final daysMapRaw = weekDoc['days'];
                        final daysMap = (daysMapRaw is Map) ? Map<String, dynamic>.from(daysMapRaw as Map) : <String, dynamic>{};

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Week $weekNumber', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700)),
                            SizedBox(height: 1.h),
                            Expanded(
                              child: ListView.separated(
                                itemCount: _daysOrder.length,
                                separatorBuilder: (_, __) => SizedBox(height: 1.2.h),
                                itemBuilder: (context, dayIdx) {
                                  final dayKey = _daysOrder[dayIdx];

                                  final dayDataRaw = daysMap[dayKey];
                                  final dayData = (dayDataRaw is Map) ? Map<String, dynamic>.from(dayDataRaw as Map) : <String, dynamic>{};

                                  final breakfast = (dayData['breakfast']?.toString() ?? '').trim();
                                  final lunch = (dayData['lunch']?.toString() ?? '').trim();
                                  final dinner = (dayData['dinner']?.toString() ?? '').trim();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_dayLabels[dayKey] ?? dayKey, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600)),
                                      SizedBox(height: 8),
                                      _buildMealTile('Breakfast', breakfast),
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
