#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <EEPROM.h>
#include <RTClib.h>

// WiFi and MQTT settings
const char *ssid = "YOUR_WIFI_SSID";
const char *password = "YOUR_WIFI_PASSWORD";
const char *mqtt_server = "YOUR_MQTT_BROKER_IP";

// MQTT topics
const char *motorTopic = "motor/1/command"; // Adjust for motor ID
const char *scheduleTopic = "motor/1/schedule";
const char *logTopic = "motor/1/log";
// Pins
const int relayPin = 2; // Relay control pin

WiFiClient espClient;
PubSubClient client(espClient);
RTC_DS3231 rtc; // Assuming DS3231 RTC module

// Schedule structure
struct Schedule
{
    int onHour;
    int onMinute;
    int offHour;
    int offMinute;
};

Schedule schedule = {6, 0, 7, 30}; // Default 6:00 ON, 7:30 OFF
bool currentState = false;         // Track current motor state

void setup()
{
    Serial.begin(115200);
    pinMode(relayPin, OUTPUT);
    digitalWrite(relayPin, LOW); // Start OFF

    // Initialize EEPROM
    EEPROM.begin(512);

    // Load schedule from EEPROM
    loadSchedule();

    // Initialize RTC
    if (!rtc.begin())
    {
        Serial.println("Couldn't find RTC");
        while (1)
            ;
    }

    // Connect to WiFi
    setup_wifi();

    // Setup MQTT
    client.setServer(mqtt_server, 1883);
    client.setCallback(callback);
}

void setup_wifi()
{
    delay(10);
    Serial.println();
    Serial.print("Connecting to ");
    Serial.println(ssid);

    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("WiFi connected");
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());
}

void callback(char *topic, byte *payload, unsigned int length)
{
    String message;
    for (int i = 0; i < length; i++)
    {
        message += (char)payload[i];
    }

    if (strcmp(topic, motorTopic) == 0)
    {
        if (message == "ON")
        {
            digitalWrite(relayPin, HIGH);
            Serial.println("Motor ON");
            sendLog("ON", "manual");
        }
        else if (message == "OFF")
        {
            digitalWrite(relayPin, LOW);
            Serial.println("Motor OFF");
            sendLog("OFF", "manual");
        }
    }
    else if (strcmp(topic, scheduleTopic) == 0)
    {
        // Parse JSON schedule
        DynamicJsonDocument doc(1024);
        deserializeJson(doc, message);
        String onTime = doc["on"];
        String offTime = doc["off"];

        // Parse times
        int onH = onTime.substring(0, 2).toInt();
        int onM = onTime.substring(3, 5).toInt();
        int offH = offTime.substring(0, 2).toInt();
        int offM = offTime.substring(3, 5).toInt();

        schedule.onHour = onH;
        schedule.onMinute = onM;
        schedule.offHour = offH;
        schedule.offMinute = offM;

        // Save to EEPROM
        saveSchedule();

        Serial.println("Schedule updated");
    }
}

void reconnect()
{
    while (!client.connected())
    {
        Serial.print("Attempting MQTT connection...");
        if (client.connect("ESP32Client"))
        {
            Serial.println("connected");
            client.subscribe(motorTopic);
            client.subscribe(scheduleTopic);
        }
        else
        {
            Serial.print("failed, rc=");
            Serial.print(client.state());
            Serial.println(" try again in 5 seconds");
            delay(5000);
        }
    }
}

void loop()
{
    if (!client.connected())
    {
        reconnect();
    }
    client.loop();

    // Check schedule
    DateTime now = rtc.now();
    int currentHour = now.hour();
    int currentMinute = now.minute();

    bool shouldBeOn = false;
    if (schedule.onHour < schedule.offHour)
    {
        // Same day
        if (currentHour > schedule.onHour || (currentHour == schedule.onHour && currentMinute >= schedule.onMinute))
        {
            if (currentHour < schedule.offHour || (currentHour == schedule.offHour && currentMinute < schedule.offMinute))
            {
                shouldBeOn = true;
            }
        }
    }
    else
    {
        // Overnight
        if (currentHour > schedule.onHour || (currentHour == schedule.onHour && currentMinute >= schedule.onMinute) ||
            currentHour < schedule.offHour || (currentHour == schedule.offHour && currentMinute < schedule.offMinute))
        {
            shouldBeOn = true;
        }
    }

    digitalWrite(relayPin, shouldBeOn ? HIGH : LOW);

    // Log if state changed
    if (shouldBeOn != currentState)
    {
        currentState = shouldBeOn;
        sendLog(shouldBeOn ? "ON" : "OFF", "schedule");
    }
}

void sendLog(String state, String trigger)
{
    DynamicJsonDocument doc(256);
    doc["motorId"] = "motor1";
    doc["state"] = state;
    doc["trigger"] = trigger;
    doc["time"] = rtc.now().unixtime(); // Unix timestamp

    String jsonString;
    serializeJson(doc, jsonString);
    client.publish(logTopic, jsonString.c_str());
}

void saveSchedule()
{
    EEPROM.put(0, schedule);
    EEPROM.commit();
}

void loadSchedule()
{
    EEPROM.get(0, schedule);
}