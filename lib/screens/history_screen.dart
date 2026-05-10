import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Motor History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('motor_history')
            .orderBy('time', descending: true)
            .limit(100)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('No history yet'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final timestamp = (data['time'] as Timestamp).toDate();
              final motorId = data['motorId'] ?? 'Unknown';
              final state = data['state'] ?? 'Unknown';
              final trigger = data['trigger'] ?? 'Unknown';
              final user = data['user'] ?? 'Unknown';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Icon(
                    state == 'ON' ? Icons.power : Icons.power_off,
                    color: state == 'ON' ? Colors.green : Colors.red,
                  ),
                  title: Text('$motorId - $state'),
                  subtitle: Text(
                    '${timestamp.toString().substring(0, 19)} | Trigger: $trigger | User: ${user == _user?.uid ? 'You' : user}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
