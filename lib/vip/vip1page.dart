import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Vip1Page extends StatefulWidget {
  const Vip1Page({super.key});

  @override
  State<Vip1Page> createState() => _Vip1PageState();
}

class _Vip1PageState extends State<Vip1Page> {
  bool hasCheckedIn = false;
  String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
  late DocumentReference userDocRef;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      checkTodayVip1Attendance();
    }
  }

  Future<void> checkTodayVip1Attendance() async {
    final snapshot = await userDocRef.get();
    final data = snapshot.data() as Map<String, dynamic>?;

    final vip1LastCheckIn = data?['vip1_lastCheckIn'];
    setState(() {
      hasCheckedIn = vip1LastCheckIn == today;
    });
  }

  Future<void> handleCheckIn() async {
    if (hasCheckedIn) return;

    await userDocRef.update({
      'vip1_lastCheckIn': today,
      'coins': FieldValue.increment(1),
    });

    setState(() {
      hasCheckedIn = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã điểm danh VIP1! +1 xu")),
    );
  }

  Stream<QuerySnapshot> getVip1Books() {
    return FirebaseFirestore.instance
        .collection('books')
        .where('tags', arrayContains: 'VIP1')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("VIP 1")),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white70,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.5),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    hasCheckedIn ? Icons.check_circle : Icons.add_circle,
                    color: hasCheckedIn ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasCheckedIn
                          ? "Đã điểm danh hôm nay"
                          : "Chưa điểm danh hôm nay",
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  if (!hasCheckedIn)
                    ElevatedButton(
                      onPressed: handleCheckIn,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                      child: const Icon(Icons.add, size: 24),
                    ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Được phép đọc sách có tag VIP1",
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
