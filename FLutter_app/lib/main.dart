import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "smartlocker-519a0.firebaseapp.com",
      databaseURL:
          "https://smartlocker-519a0-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "smartlocker-519a0",
      storageBucket: "smartlocker-519a0.appspot.com",
      messagingSenderId: "446769909483",
      appId: "1:446769909483:web:b1ba5e9c9f017371bd78ae",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbRef = FirebaseDatabase.instance.ref("locker");

  int attempts = 0;
  String lockStatus = "LOCKED";
  String vibration = "SAFE";
  String mlResult = "SAFE";

  double temperature = 0;
  double humidity = 0;
  int gas = 0;

  String alertMessage = "System Normal";
  Color alertColor = Colors.green;
  String lastAlert = "";

  @override
  void initState() {
    super.initState();
    listenData();
  }

  void listenData() {
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;

      if (data != null) {
        setState(() {
          attempts = data["attempts"] ?? 0;
          lockStatus = data["lock_status"] ?? "LOCKED";
          vibration = data["vibration"] ?? "SAFE";
          mlResult = data["ml_result"] ?? "SAFE";

          temperature = (data["temperature"] ?? 0).toDouble();
          humidity = (data["humidity"] ?? 0).toDouble();
          gas = data["gas"] ?? 0;
        });

        updateAlert();
      }
    });
  }

void updateAlert() {
  String newAlert = "System Normal";
  Color newColor = Colors.green;

  // 🚨 PRIORITY 1: Vibration-based intrusion (from ML)
  if (mlResult == "INTRUSION" && vibration == "DETECTED") {
    newAlert = "🚨 Vibration  Detected!";
    newColor = Colors.red;
  }

  // 🔐 PRIORITY 2: Multiple wrong attempts
  else if (mlResult == "INTRUSION" && attempts >= 3) {
    newAlert = "🔐 Multiple Wrong Attempts Detected!";
    newColor = Colors.orange;
  }

  // ⚠ PRIORITY 3: Warning state
  else if (mlResult == "WARNING") {
    newAlert = "⚠ Suspicious Activity!";
    newColor = Colors.yellow;
  }

  // 🔥 SHOW POPUP ONLY ON CHANGE
  if (newAlert != lastAlert && newAlert != "System Normal") {
    showPopup(newAlert);
    lastAlert = newAlert;
  }

  setState(() {
    alertMessage = newAlert;
    alertColor = newColor;
  });
}
  void showPopup(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text("⚠ ALERT",
            style: TextStyle(color: Colors.white)),
        content: Text(msg,
            style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK",
                style: TextStyle(color: Colors.yellow)),
          )
        ],
      ),
    );
  }

  Widget buildCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 5),
          Text(title),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Text(
                "🔐 Smart Locker",
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 25),

              // 🔥 TOP CARDS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCard("Attempts", "$attempts",
                      Icons.lock, Colors.orange),
                  buildCard("Lock", lockStatus,
                      Icons.shield, Colors.blue),
                  buildCard("Vibration", vibration,
                      Icons.vibration,
                      vibration == "DETECTED"
                          ? Colors.red
                          : Colors.green),
                  buildCard("ML", mlResult,
                      Icons.bar_chart,
                      mlResult == "INTRUSION"
                          ? Colors.red
                          : Colors.green),
                ],
              ),

              const SizedBox(height: 25),

              // 🌡 SENSOR CARDS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  buildCard("Temp", "$temperature°C",
                      Icons.thermostat, Colors.red),
                  buildCard("Humidity", "$humidity%",
                      Icons.water_drop, Colors.blue),
                  buildCard("Gas", "$gas",
                      Icons.cloud,
                      gas > 500
                          ? Colors.red
                          : Colors.green),
                ],
              ),

              const Spacer(),

              // 🚨 ALERT BAR
              Container(
                margin: const EdgeInsets.all(15),
                padding: const EdgeInsets.all(18),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: alertColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning,
                        color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alertMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}