# AgreeControl

A cross-platform Flutter application for remote motor control and scheduling via IoT. The app communicates with an ESP32 microcontroller over MQTT, allowing users to manually operate motors and set automated schedules from their phone.

## Features

### Remote Motor Control
- Control two independent motors (ON/OFF) from the dashboard
- Real-time status display with colour-coded indicators (green = ON, red = OFF)
- Bi-directional sync between the app and ESP32 hardware via Firebase Realtime Database

### Automated Scheduling
- Set ON and OFF times for each motor using a time picker
- Supports same-day schedules (e.g. 06:00 - 19:30) and overnight schedules (e.g. 22:00 - 06:00)
- Schedules are stored persistently on the ESP32 (EEPROM) and survive power cycles
- RTC-based (DS3231) scheduling runs independently on the device, no phone connection required

### History and Audit Log
- View the last 100 motor state changes in real time
- Each entry shows timestamp, motor ID, state, trigger type (manual or scheduled), and user
- Streamed live from Firestore

### User Authentication
- Email and password authentication via Firebase Auth
- User registration with password confirmation
- Password reset via email

## Architecture

```
Flutter App  <──MQTT──>  HiveMQ Cloud  <──MQTT──>  ESP32 + Relay + RTC
     │                                                    │
     └──── Firebase (Auth, Firestore, Realtime DB) ───────┘
```

| Layer | Technology | Role |
|-------|------------|------|
| Mobile App | Flutter (Android, iOS, Windows) | User interface and control |
| Backend | Firebase Auth, Firestore, Realtime DB | Authentication, history logging, state sync |
| Messaging | MQTT via HiveMQ Cloud (TLS) | Command and schedule delivery to hardware |
| Hardware | ESP32, DS3231 RTC, Relay module | Motor switching and local schedule execution |

## Screens

| Screen | Description |
|--------|-------------|
| **Login** | Email/password sign-in with forgot password support |
| **Register** | New account creation with password validation |
| **Dashboard** | Main control hub with ON/OFF buttons for both motors and live status |
| **Schedule** | Time picker UI to set automated ON/OFF times per motor |
| **History** | Scrollable audit log of all motor state changes |

## MQTT Topics

| Topic | Direction | Purpose |
|-------|-----------|---------|
| `motor/1/command` | App -> ESP32 | Manual ON/OFF commands |
| `motor/1/schedule` | App -> ESP32 | Schedule updates (JSON: `{"on":"HH:mm","off":"HH:mm"}`) |
| `motor/1/log` | ESP32 -> App | State change logs written back to Firestore |

## ESP32 Hardware

- **Microcontroller**: ESP32
- **Real-time Clock**: DS3231 RTC module for accurate local scheduling
- **Motor Control**: Relay module on GPIO pin 2
- **Persistence**: EEPROM (512 bytes) for schedule storage across power cycles
- **Connectivity**: WiFi + MQTT (PubSubClient library)

The ESP32 firmware is located in [`esp32/scheduling.ino`](esp32/scheduling.ino).

## Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core` | Firebase SDK initialisation |
| `firebase_auth` | Email/password authentication |
| `cloud_firestore` | Motor history storage and queries |
| `firebase_database` | Real-time motor state sync |
| `mqtt_client` | MQTT communication with ESP32 |
| `logger` | Debug logging |

## Getting Started

### Prerequisites
- Flutter SDK (Dart 3.10.0+)
- Firebase project configured with Auth, Firestore, and Realtime Database
- ESP32 with DS3231 RTC and relay module
- HiveMQ Cloud MQTT broker (or compatible broker)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Dchamuditha9/AgreeControl.git
   cd AgreeControl
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Set up a Firebase project and enable Authentication, Firestore, and Realtime Database
   - Replace `lib/firebase_options.dart` and `android/app/google-services.json` with your own Firebase config files

4. **Configure MQTT**
   - Update the broker URL and credentials in `lib/services/mqtt_service.dart`

5. **Flash the ESP32**
   - Open `esp32/scheduling.ino` in Arduino IDE
   - Update WiFi credentials and MQTT broker details
   - Upload to your ESP32 board

6. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
AgreeControl/
├── lib/
│   ├── main.dart                  # App entry point, Firebase init
│   ├── firebase_options.dart      # Platform-specific Firebase config
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── schedule_screen.dart
│   │   └── history_screen.dart
│   └── services/
│       └── mqtt_service.dart      # MQTT broker communication
├── esp32/
│   └── scheduling.ino             # ESP32 firmware (motor + RTC + MQTT)
├── firestore.rules                # Firestore security rules
├── firebase.json                  # Firebase project config
└── pubspec.yaml                   # Dart dependencies
```
