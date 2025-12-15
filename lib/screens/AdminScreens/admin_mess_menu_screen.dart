// lib/screens/admin/admin_mess_menu_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:untitled/constants.dart';

class AdminMessMenuScreen extends StatefulWidget {
  static const routeName = 'AdminMessMenu';
  const AdminMessMenuScreen({Key? key}) : super(key: key);

  @override
  State<AdminMessMenuScreen> createState() => _AdminMessMenuScreenState();
}

class _AdminMessMenuScreenState extends State<AdminMessMenuScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedWeek = 1;
  String _selectedDay = 'monday';

  final _breakfastController = TextEditingController();
  final _lunchController = TextEditingController();
  final _dinnerController = TextEditingController();

  final List<String> _days = [
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
    'sunday': 'Sunday'
  };

  bool _isSaving = false;

  @override
  void dispose() {
    _breakfastController.dispose();
    _lunchController.dispose();
    _dinnerController.dispose();
    super.dispose();
  }

  Future<void> _loadDayData() async {
    final docRef = _firestore.collection('mess_menus').doc('week_$_selectedWeek');
    final snap = await docRef.get();
    if (!snap.exists) {
      _breakfastController.text = '';
      _lunchController.text = '';
      _dinnerController.text = '';
      return;
    }
    final data = snap.data() ?? {};
    final days = (data['days'] is Map) ? Map<String, dynamic>.from(data['days']) : {};
    final dayData = (days[_selectedDay] is Map) ? Map<String, dynamic>.from(days[_selectedDay]) : {};
    _breakfastController.text = dayData['breakfast']?.toString() ?? '';
    _lunchController.text = dayData['lunch']?.toString() ?? '';
    _dinnerController.text = dayData['dinner']?.toString() ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _saveDayData() async {
    final breakfast = _breakfastController.text.trim();
    final lunch = _lunchController.text.trim();
    final dinner = _dinnerController.text.trim();

    final docRef = _firestore.collection('mess_menus').doc('week_$_selectedWeek');

    final Map<String, dynamic> updateData = {
      'week': _selectedWeek,
      'updatedAt': FieldValue.serverTimestamp(),
      'days': {
        _selectedDay: {
          'breakfast': breakfast,
          'lunch': lunch,
          'dinner': dinner,
        }
      }
    };

    await docRef.set(updateData, SetOptions(merge: true));


    try {
      setState(() => _isSaving = true);
      await docRef.set(updateData, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved for ${_dayLabels[_selectedDay]} (Week $_selectedWeek)')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    // load initial selection after frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDayData());
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.black87, fontSize: 11.sp, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.black45, fontSize: 10.sp),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kDefaultPadding / 1.5)),
    );
  }

  Widget _labeledCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kDefaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(kDefaultPadding / 1.5),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyleInput = TextStyle(color: Colors.black87, fontSize: 12.sp);
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin: Mess Menu', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      backgroundColor: kPrimaryColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top card: pick week + day
              _labeledCard(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Week', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: kOtherColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<int>(
                          value: _selectedWeek,
                          underline: SizedBox.shrink(),
                          items: List.generate(4, (i) => i + 1)
                              .map((w) => DropdownMenuItem(
                            value: w,
                            child: Text('Week $w', style: TextStyle(color: Colors.black87)),
                          ))
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() => _selectedWeek = val);
                            _loadDayData();
                          },
                        ),
                      ),
                      SizedBox(width: 20),
                      Text('Day', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kOtherColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedDay,
                          underline: SizedBox.shrink(),
                          items: _days
                              .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(_dayLabels[d]!, style: TextStyle(color: Colors.black87)),
                          ))
                              .toList(),
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() => _selectedDay = val);
                            _loadDayData();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 2.h),

              // Breakfast card
              _labeledCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Breakfast', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _breakfastController,
                      style: textStyleInput,
                      maxLines: 3,
                      decoration: _inputDecoration('E.g. Poha, Upma, Bread & Eggs'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.5.h),

              // Lunch card
              _labeledCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Lunch', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _lunchController,
                      style: textStyleInput,
                      maxLines: 3,
                      decoration: _inputDecoration('E.g. Rice, Dal, Sabzi'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 1.5.h),

              // Dinner card
              _labeledCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dinner', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _dinnerController,
                      style: textStyleInput,
                      maxLines: 3,
                      decoration: _inputDecoration('E.g. Chapati, Sabzi, Raita'),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveDayData,
                  icon: _isSaving ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Icon(Icons.save, size: 18),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('Save Menu', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700,color:Colors.white)),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // accent color for visibility
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              SizedBox(height: 3.h),

              // Quick preview card (shows current saved values)
              _labeledCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Preview (${_dayLabels[_selectedDay]})', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
                    SizedBox(height: 8),
                    Text('Breakfast: ${_breakfastController.text.isEmpty ? '—' : _breakfastController.text}', style: TextStyle(fontSize: 10.sp, color: Colors.black87)),
                    SizedBox(height: 6),
                    Text('Lunch: ${_lunchController.text.isEmpty ? '—' : _lunchController.text}', style: TextStyle(fontSize: 10.sp, color: Colors.black87)),
                    SizedBox(height: 6),
                    Text('Dinner: ${_dinnerController.text.isEmpty ? '—' : _dinnerController.text}', style: TextStyle(fontSize: 10.sp, color: Colors.black87)),
                  ],
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
