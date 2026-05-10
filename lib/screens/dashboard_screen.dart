import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'login_screen.dart';
import 'schedule_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 2. Initialize RTDB Reference
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  User? _user;
  
  // Local state to track motor status from DB
  Map<String, String> motorStates = {"motor1": "OFF", "motor2": "OFF"};

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    if (_user == null) {
      _redirectToLogin();
      return;
    }
    _listenToMotorChanges();
  }

  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  // 3. Listen to Realtime Updates
  void _listenToMotorChanges() {
    _dbRef.child('motors').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          motorStates['motor1'] = data['motor1']?['state'] ?? "OFF";
          motorStates['motor2'] = data['motor2']?['state'] ?? "OFF";
        });
      }
    });
  }

  // 4. Update Database for Motor Control
  Future<void> _toggleMotor(String motorId, String newState) async {
    try {
      // Update Realtime Database (This triggers your hardware/ESP32)
      await _dbRef.child('motors/$motorId').update({
        'state': newState,
        'lastUpdated': ServerValue.timestamp,
      });

      // Log to Firestore History (Keep your existing history logic)
      await _logHistory(motorId, newState, 'manual');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$motorId turned $newState")),
        );
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _logHistory(String motorId, String state, String trigger) async {
    try {
      await FirebaseFirestore.instance.collection('motor_history').add({
        'motorId': motorId,
        'state': state,
        'time': Timestamp.now(),
        'trigger': trigger,
        'user': _user!.uid,
      });
    } catch (e) {
      debugPrint('Error logging history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Motor Dashboard (RTDB)"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryScreen())),
            icon: const Icon(Icons.history),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              _redirectToLogin();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildUserHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildMotorCard('Motor 1', 'motor1'),
                        const SizedBox(height: 16),
                        _buildMotorCard('Motor 2', 'motor2'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildUserHeader() {
    return Card(
      child: ListTile(
        leading: Icon(Icons.account_circle, size: 48, color: Theme.of(context).colorScheme.primary),
        title: Text('Welcome, ${_user!.email}'),
        subtitle: Text('User ID: ${_user!.uid.substring(0, 8)}...'),
      ),
    );
  }

  Widget _buildMotorCard(String motorName, String motorId) {
    String currentState = motorStates[motorId] ?? "OFF";
    bool isOn = currentState == "ON";

    return Card(
      color: isOn ? Colors.green.shade50 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(motorName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Status: $currentState", 
              style: TextStyle(color: isOn ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: isOn ? null : () => _toggleMotor(motorId, 'ON'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  child: const Text('ON'),
                ),
                ElevatedButton(
                  onPressed: !isOn ? null : () => _toggleMotor(motorId, 'OFF'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('OFF'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScheduleScreen(motorId: motorId)));
                  },
                  child: const Text('Schedule'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}