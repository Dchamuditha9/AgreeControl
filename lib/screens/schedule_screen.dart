import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';

class ScheduleScreen extends StatefulWidget {
  final String motorId;
  const ScheduleScreen({super.key, required this.motorId});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  TimeOfDay? onTime;
  TimeOfDay? offTime;
  final MQTTService mqtt = MQTTService();

  @override
  void initState() {
    super.initState();
    mqtt.connect();
  }

  @override
  void dispose() {
    mqtt.disconnect();
    super.dispose();
  }

  Future<void> _selectTime(bool isOnTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isOnTime) {
          onTime = picked;
        } else {
          offTime = picked;
        }
      });
    }
  }

  void _sendSchedule() {
    if (onTime == null || offTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please set both ON and OFF times')),
      );
      return;
    }

    final schedule = {
      'on':
          '${onTime!.hour.toString().padLeft(2, '0')}:${onTime!.minute.toString().padLeft(2, '0')}',
      'off':
          '${offTime!.hour.toString().padLeft(2, '0')}:${offTime!.minute.toString().padLeft(2, '0')}',
    };

    mqtt.publish('motor/${widget.motorId}/schedule', schedule.toString());
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schedule sent to ESP32')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule for ${widget.motorId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('ON Time'),
              subtitle: Text(onTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(true),
            ),
            ListTile(
              title: const Text('OFF Time'),
              subtitle: Text(offTime?.format(context) ?? 'Not set'),
              trailing: const Icon(Icons.access_time),
              onTap: () => _selectTime(false),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendSchedule,
              child: const Text('Set Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
