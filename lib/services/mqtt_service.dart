import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'dart:io';

class MQTTService {
  late MqttServerClient client;
  bool _isConnected = false;
  final Logger logger = Logger();

  // HiveMQ Cloud cluster endpoint (TLS, port 8883)
  final String broker = "f3179861615341aaa2a4d7f14d18a3a4.s1.eu.hivemq.cloud";
  final int port = 8883;
  // IMPORTANT: Use MQTT credentials from HiveMQ Cloud Console → Access Management → Credentials
  // NOT your account login email/password
  final String username = "Dushan";
  final String password = "Dushan123456";

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    client = MqttServerClient(
      broker,
      "flutter_${DateTime.now().millisecondsSinceEpoch}",
    );

    client.port = port;
    client.secure = true;
    client.securityContext = SecurityContext.defaultContext;
    client.onBadCertificate = (dynamic cert) => true;
    client.setProtocolV311();

    client.keepAlivePeriod = 20;
    client.autoReconnect = false; // Disabled for debugging
    client.logging(on: true);

    client.onConnected = () {
      _isConnected = true;
      logger.i("MQTT Connected");
    };

    client.onDisconnected = () {
      _isConnected = false;
      logger.i("MQTT Disconnected");
    };

    client.onSubscribed = (topic) {
      logger.i("Subscribed to $topic");
    };

    client.pongCallback = () {
      logger.i("Ping response received");
    };

    final connMessage = MqttConnectMessage()
        .authenticateAs(username, password)
        .withClientIdentifier(client.clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMessage;

    try {
      await client.connect();

      // Start listening AFTER connection
      client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
        final recMessage = messages[0].payload as MqttPublishMessage;
        final String topic = messages[0].topic;
        final String payload = MqttPublishPayload.bytesToStringAsString(
          recMessage.payload.message,
        );

        logger.i("📥 $topic -> $payload");

        if (topic.startsWith('motor/') && topic.endsWith('/log')) {
          _handleLogMessage(payload);
        }
      });

      logger.i("🚀 MQTT connection successful");
    } catch (e) {
      _isConnected = false;
      logger.e("❌ MQTT connection failed: $e");
      if (e.toString().contains('NoConnectionException')) {
        logger.i("🔍 Possible causes:");
        logger.i(
          "   - Invalid MQTT credentials (check HiveMQ Cloud Access Management)",
        );
        logger.i("   - HiveMQ Cloud cluster may be paused");
        logger.i("   - Duplicate client ID (ESP32 using same ID)");
        logger.i("   - Check HiveMQ Cloud console for cluster status");
      }
      client.disconnect();
    }
  }

  // Publish message
  void publish(String topic, String message) {
    if (!_isConnected) {
      logger.w("⚠️ MQTT not connected. Cannot publish.");
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);

    logger.i("📤 Published: $topic -> $message");
  }

  // Subscribe to topic
  void subscribe(String topic) {
    if (!_isConnected) {
      logger.w("⚠️ MQTT not connected. Cannot subscribe.");
      return;
    }
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  // Test connection method
  Future<bool> testConnection() async {
    try {
      logger.i("🧪 Testing MQTT connection...");
      await connect();
      await Future.delayed(
        Duration(seconds: 2),
      ); // Wait for connection to establish
      bool connected = _isConnected;
      if (connected) {
        logger.i("✅ Connection test successful");
      } else {
        logger.w("❌ Connection test failed - not connected after 2 seconds");
      }
      return connected;
    } catch (e) {
      logger.e("❌ Connection test failed with error: $e");
      return false;
    }
  }

  // Disconnect from MQTT broker
  void disconnect() {
    if (_isConnected) {
      client.disconnect();
      _isConnected = false;
      logger.i("🔌 MQTT disconnected");
    }
  }

  // Store motor history in Firestore
  void _handleLogMessage(String message) async {
    try {
      final data = jsonDecode(message);

      await FirebaseFirestore.instance.collection('motor_history').add({
        'motorId': data['motorId'],
        'state': data['state'],
        'time': Timestamp.fromMillisecondsSinceEpoch(data['time'] * 1000),
        'trigger': data['trigger'],
        'source': 'esp32',
      });

      logger.i("📝 Log saved to Firestore");
    } catch (e) {
      logger.e("❌ Log handling error: $e");
    }
  }
}
