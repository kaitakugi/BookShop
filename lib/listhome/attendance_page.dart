import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final DateTime _focusedDay = DateTime.now();
  Set<String> checkedInDays = {};

  @override
  void initState() {
    super.initState();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .get();

    final days = snapshot.docs.map((doc) => doc.id).toSet();

    setState(() {
      checkedInDays = days;
    });
  }

  Future<void> handleCheckIn() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .doc(today);

    final snap = await docRef.get();
    if (!snap.exists) {
      await docRef.set({
        'checkedIn': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // cộng xu
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'coins': FieldValue.increment(1)});

      setState(() {
        checkedInDays.add(today);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Điểm danh thành công! +1 xu")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn đã điểm danh hôm nay rồi!")),
      );
    }
  }

  bool _isCheckedIn(DateTime day) {
    final formatted = DateFormat('yyyy-MM-dd').format(day);
    return checkedInDays.contains(formatted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch điểm danh")),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: CalendarFormat.month,
            calendarStyle: const CalendarStyle(
              todayDecoration:
                  BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration:
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
            selectedDayPredicate: _isCheckedIn,
            onDaySelected: (day, _) {},
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: handleCheckIn,
            child: const Text("Điểm danh hôm nay"),
          ),
        ],
      ),
    );
  }
}
