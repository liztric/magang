import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk SystemNavigator
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';

class SettingsPageUI extends StatefulWidget {
  const SettingsPageUI({super.key});

  @override
  _SettingsPageUIState createState() => _SettingsPageUIState();
}

class _SettingsPageUIState extends State<SettingsPageUI> {
  bool isDarkMode = false;
  bool isSystemMode = true;
  bool keepScreenOn = false;
  bool skipTilesView = false;
  bool valNotify1 = false;
  bool valNotify2 = false;
  bool valNotify3 = false;
  bool valNotify4 = false;
  bool valNotify5 = false;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  Timer? _timer;

  // Kunci untuk SharedPreferences
  static const String keyNotify1 = 'notify_suhu';
  static const String keyNotify2 = 'notify_ph';
  static const String keyNotify3 = 'notify_kejernihan';
  static const String keyNotify4 = 'notify_cahaya';
  static const String keyNotify5 = 'notify_lampu';

  // Tambahkan referensi Firebase
  final DatabaseReference settingsRef = FirebaseDatabase.instance.ref().child('settings');
  String currentTimer = "00:00";

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _initializeNotifications();
    _mulaiPemeriksaanBerkala();
    _listenToTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _mulaiPemeriksaanBerkala() {
    // Periksa setiap menit
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _periksaKondisiAir();
      _periksaTimer();
    });
  }

  void _periksaKondisiAir() {
    print("Memeriksa kondisi air..."); // Debug print

    // Periksa suhu (24-27°C)
    if (valNotify1) {
      double suhu = getSuhuAir();
      print("Suhu saat ini: $suhu"); // Debug print
      if (suhu < 24 || suhu > 27) {
        tampilkanNotifikasi(
          judul: "Peringatan Suhu Air",
          pesan: _getTemperatureStatus(suhu),
          id: 1,
        );
      }
    }

    // Periksa pH (6-8)
    if (valNotify2) {
      double ph = getPHAir();
      print("pH saat ini: $ph"); // Debug print
      if (ph < 6 || ph > 8) {
        tampilkanNotifikasi(
          judul: "Peringatan pH Air",
          pesan: _getPhStatus(ph),
          id: 2,
        );
      }
    }

    // Periksa kejernihan (minimal 90)
    if (valNotify3) {
      double kejernihan = getKejernihanAir();
      print("Kejernihan saat ini: $kejernihan"); // Debug print
      if (kejernihan < 90) {
        tampilkanNotifikasi(
          judul: "Peringatan Kejernihan Air",
          pesan: _getClarityStatus(kejernihan),
          id: 3,
        );
      }
    }

    // // Periksa cahaya (50-100 lux)
    // if (valNotify4) {
    //   double cahaya = getCahayaAir();
    //   print("Cahaya saat ini: $cahaya"); // Debug print
    //   if (cahaya < 50 || cahaya > 100) {
    //     tampilkanNotifikasi(
    //       judul: "Peringatan Intensitas Cahaya",
    //       pesan: _getLuxStatus(cahaya),
    //       id: 4,
    //     );
    //   }
    // }

    // Periksa timer lampu
    if (valNotify5) {
      print("Timer saat ini: $currentTimer"); // Debug print
      
      // Parse waktu saat ini
      final now = TimeOfDay.now();
      final currentTimeInMinutes = now.hour * 60 + now.minute;
      
      // Parse timer yang diset
      final timerParts = currentTimer.split(':');
      final timerHour = int.parse(timerParts[0]);
      final timerMinute = int.parse(timerParts[1]);
      final timerInMinutes = timerHour * 60 + timerMinute;
      
      // Jika waktu saat ini sama dengan timer yang diset
      if (currentTimeInMinutes == timerInMinutes) {
        tampilkanNotifikasi(
          judul: "Peringatan Timer Lampu",
          pesan: "Waktu yang diset ($currentTimer) telah tercapai. Silakan periksa lampu Anda.",
          id: 5,
        );
      }
    }
  }

  void _periksaTimer() {
    // Periksa apakah timer sama dengan "00:00"
    if (currentTimer == "00:00") {
      tampilkanNotifikasi(
        judul: "Peringatan Timer",
        pesan: "Timer telah mencapai 0. Silakan periksa pengaturan Anda.",
        id: 6, // ID unik untuk notifikasi ini
      );
    }
  }

  Future<void> tampilkanNotifikasi({
    required String judul,
    required String pesan,
    required int id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'aquascape_channel',
      'Notifikasi Aquascape',
      channelDescription: 'Kanal untuk notifikasi kondisi aquascape',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      judul,
      pesan,
      notificationDetails,
    );
  }

  // Fungsi untuk mendapatkan nilai sensor (ganti dengan nilai sebenarnya dari sensor)
  double getSuhuAir() {
    // Contoh nilai yang akan memicu notifikasi
    return 28.5; // Di atas batas normal (24-27°C)
  }

  double getPHAir() {
    // Contoh nilai yang akan memicu notifikasi
    return 5.5; // Di bawah batas normal (6-8)
  }

  double getKejernihanAir() {
    // Contoh nilai yang akan memicu notifikasi
    return 85.0; // Di bawah batas normal (90)
  }

  double getCahayaAir() {
    // Contoh nilai yang akan memicu notifikasi
    return 120.0; // Di atas batas normal (50-100 lux)
  }

  int getWaktuLampu() {
    // Contoh nilai yang akan memicu notifikasi
    return 50; // Di atas batas normal (48 jam)
  }

  // Fungsi helper untuk format pesan
  String _getPhStatus(double value) {
    if (value < 6) {
      return "pH $value - Naikkan ke 6 - 8";
    } else if (value > 8) {
      return "pH $value - Turunkan ke 6 - 8";
    }
    return "pH $value - Normal";
  }

  // String _getLuxStatus(double value) {
  //   if (value < 50) {
  //     return "Cahaya $value lux - Tambah hingga 50+ lux";
  //   } else if (value > 100) {
  //     return "Cahaya $value lux - Kurangi intensitas";
  //   }
  //   return "Cahaya $value lux - Normal";
  // }

  String _getTemperatureStatus(double value) {
    if (value < 24) {
      return "Suhu $value°C - Naikkan ke 24 - 27°C";
    } else if (value > 27) {
      return "Suhu $value°C - Turunkan ke 24 - 27°C";
    }
    return "Suhu $value°C - Normal";
  }

  String _getClarityStatus(double value) {
    if (value < 90) {
      return "Kejernihan $value - Air keruh, bersihkan";
    }
    return "Kejernihan $value - Air jernih";
  }

  // Memuat pengaturan yang tersimpan
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      valNotify1 = prefs.getBool(keyNotify1) ?? false;
      valNotify2 = prefs.getBool(keyNotify2) ?? false;
      valNotify3 = prefs.getBool(keyNotify3) ?? false;
      valNotify4 = prefs.getBool(keyNotify4) ?? false;
      valNotify5 = prefs.getBool(keyNotify5) ?? false;
    });
  }

  // Menyimpan pengaturan
  Future<void> _saveSettings(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Mendengarkan perubahan timer dari Firebase
  Future<void> _listenToTimer() async {
    settingsRef.child('timer').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          currentTimer = event.snapshot.value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gambar latar belakang
          Positioned(
            top: -50,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height, // Atur tinggi gambar
              child: Image.asset(
                'assets/bgikan.png', // Pastikan path sesuai
                fit: BoxFit.cover, // Mengisi area yang ditentukan
              ),
            ),
          ),
          // Konten utama
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              _buildNotificationContainer(),
              const SizedBox(height: 24),
              // _buildLogoutButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_none, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Text(
                "Notifikasi",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          _buildNotificationOption(
            "Peringatan Suhu Air", 
            valNotify1, 
            (newValue) async {
              setState(() => valNotify1 = newValue);
              await _saveSettings(keyNotify1, newValue);
              if (newValue) _periksaKondisiAir();
            }
          ),
          _buildNotificationOption(
            "Peringatan pH Air", 
            valNotify2, 
            (newValue) async {
              setState(() => valNotify2 = newValue);
              await _saveSettings(keyNotify2, newValue);
              if (newValue) _periksaKondisiAir();
            }
          ),
          _buildNotificationOption(
            "Peringatan Kejernihan", 
            valNotify3, 
            (newValue) async {
              setState(() => valNotify3 = newValue);
              await _saveSettings(keyNotify3, newValue);
              if (newValue) _periksaKondisiAir();
            }
          ),
          // _buildNotificationOption(
          //   "Peringatan Cahaya", 
          //   valNotify4, 
          //   (newValue) async {
          //     setState(() => valNotify4 = newValue);
          //     await _saveSettings(keyNotify4, newValue);
          //     if (newValue) _periksaKondisiAir();
          //   }
          // ),
          _buildNotificationOption(
            "Peringatan Timer Lampu", 
            valNotify5, 
            (newValue) async {
              setState(() => valNotify5 = newValue);
              await _saveSettings(keyNotify5, newValue);
              if (newValue) _periksaKondisiAir();
            }
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String title, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          CupertinoSwitch(
            activeColor: Colors.blue,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Widget _buildLogoutButton() {
  //   return Container(
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.withOpacity(0.1),
  //           spreadRadius: 1,
  //           blurRadius: 10,
  //           offset: const Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         borderRadius: BorderRadius.circular(15),
  //         onTap: () => _showExitConfirmationDialog(context),
  //         child: const Padding(
  //           padding: EdgeInsets.all(16),
  //           child: Text(
  //             "Logout",
  //             style: TextStyle(
  //               fontSize: 16,
  //               letterSpacing: 2.2,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.black,
  //             ),
  //             textAlign: TextAlign.center,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  void _showExitConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Konfirmasi",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text("Apakah Anda yakin ingin keluar dari aplikasi?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text(
                "Keluar",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
