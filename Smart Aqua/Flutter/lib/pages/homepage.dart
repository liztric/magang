import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/menu.dart';
import 'package:flutter_application_1/pages/settings.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_application_1/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'loading_page.dart';

class AquascapeStatus {
  final double ph;
  final double temperature;
  final double clarity;
  final double lux;
  final DateTime timestamp;

  AquascapeStatus({
    required this.ph,
    required this.temperature,
    required this.clarity,
    required this.lux,
    required this.timestamp,
  });
}

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('sensors');
  final DatabaseReference relaysRef = FirebaseDatabase.instance.ref('relays');
  final List<AquascapeStatus> _statusHistory = [];
  int currentIndex = 0;
  bool isLoading = true;
  
  double ph = 0;
  double temperature = 0;
  double clarity = 0;
  double lux = 0;

  List<Map<String, String>> tips = [];

  bool fanState = false;
  bool ledState = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _loadTips();
    _getRelayStates();
  }

  Future<void> _initializeData() async {
    setState(() => isLoading = true);
    _getSensorData();
    setState(() => isLoading = false);
  }

  Future<void> _loadTips() async {
    final prefs = await SharedPreferences.getInstance();
    final tipsString = prefs.getString('tips');
    if (tipsString != null) {
      final List<dynamic> decodedTips = jsonDecode(tipsString);
      setState(() {
        tips = decodedTips.map((tip) => Map<String, String>.from(tip)).toList();
      });
    } else {
      setState(() {
        tips = [
          {
            'title': 'Pencahayaan Optimal',
            'description': 'Pastikan aquascape mendapat cahaya 8-10 jam per hari'
          },
          {
            'title': 'Ganti Air Rutin',
            'description': 'Lakukan pergantian air 20-30% setiap minggu'
          },
        ];
      });
      _saveTips();
    }
  }

  Future<void> _saveTips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tips', jsonEncode(tips));
  }

  Future<void> _getSensorData() async {
    databaseRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);
        
        setState(() {
          temperature = double.tryParse(data['temperature']?.toString() ?? '0') ?? 0.0;
          ph = double.tryParse(data['ph']?.toString() ?? '0') ?? 0.0;
          clarity = double.tryParse(data['clarity']?.toString() ?? '0') ?? 0.0;
          lux = double.tryParse(data['lux']?.toString() ?? '0') ?? 0.0;
          isLoading = false;

          // Update status history
          final newStatus = AquascapeStatus(
            ph: ph,
            temperature: temperature,
            clarity: clarity,
            lux: lux,
            timestamp: DateTime.now(),
          );
          _statusHistory.add(newStatus);
          
          if (_statusHistory.length > 24) {
            _statusHistory.removeAt(0);
          }
        });
      }
    });
  }

  Future<void> _getRelayStates() async {
    relaysRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          fanState = data['fan'] ?? false;
          ledState = data['led'] ?? false;
        });
      }
    });
  }

  String _getPhStatus(double value) {
    if (value < 6) {
      return "pH $value - Naikkan ke 6 - 8";
    } else if (value > 8) {
      return "pH $value - Turunkan ke 6 - 8";
    }
    return "pH $value - Normal";
  }

  String _getLuxStatus(double value) {
    if (value < 50) {
      return "Cahaya $value lux - Tambah hingga 50+ lux";
    } else if (value > 100) {
      return "Cahaya $value lux - Kurangi intensitas";
    }
    return "Cahaya $value lux - Normal";
  }

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

  Color _getStatusColor(String type, double value) {
    switch (type) {
      case 'ph':
        return (value >= 6 && value <= 8) 
          ? Colors.green  
          : Colors.red;   
      case 'temperature':
        return (value >= 24 && value <= 27) 
          ? Colors.green  
          : Colors.red;   
      case 'clarity':
        return (value >= 90) 
          ? Colors.green  
          : Colors.red;   
      case 'lux':
        return (value >= 50 && value <= 100) 
          ? Colors.green  
          : Colors.red;   
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AquascapeTheme.lightTheme,
      child: Scaffold(
        body: Stack(
          children: [
            // Gambar latar belakang dengan ukuran lebih kecil
            Positioned(
              top: -10,
              left: 0,
              right: 0,
              child: Container(
                height: MediaQuery.of(context).size.height * 1, // Atur tinggi gambar
                child: Image.asset(
                  'assets/bgikan.png', // Pastikan path sesuai
                  fit: BoxFit.cover, // Mengisi area yang ditentukan
                ),
              ),
            ),
            // Konten utama
            Column(
              children: [
                Expanded(
                  child: SafeArea(
                    child: _getCurrentPage(),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: CurvedNavigationBar(
                    backgroundColor: Colors.transparent, // Transparan agar gambar terlihat
                    color: const Color.fromARGB(255, 78, 130, 225),
                    height: 50,
                    items: const [
                      Icon(Icons.home, color: Colors.white, size: 20),
                      Icon(Icons.menu, color: Colors.white, size: 20),
                      Icon(Icons.settings, color: Colors.white, size: 20),
                    ],
                    onTap: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                      _navigateToPage(index);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingPage(),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
      setState(() {
        currentIndex = index;
      });
    });
  }

  Widget _getCurrentPage() {
    switch (currentIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return const MenuPage();
      case 2:
        return const SettingsPageUI();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    if (isLoading) {
      return _buildLoadingState();
    }

    return Container(
      constraints: const BoxConstraints.expand(),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  _buildSensorCards(),
                  const SizedBox(height: 20),
                  _buildTips(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Selamat Datang !",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E5C), 
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Let's schedule your aquascape",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF9FA5C0), 
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCards() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              "Status Aquascape",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E5C),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor('ph', ph),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kadar pH: $ph",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getPhStatus(ph),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor('clarity', clarity),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Kejernihan Air: $clarity",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getClarityStatus(clarity),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor('temperature', temperature),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Suhu: $temperature°C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getTemperatureStatus(temperature),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getStatusColor('lux', lux),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Intensitas Cahaya: $lux lux",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getLuxStatus(lux),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tips Perawatan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E5C),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  _showTipDialog();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];
              return Container(
                width: MediaQuery.of(context).size.width * 0.4,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tip['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Expanded(
                              child: Text(
                                tip['description'] ?? '',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => _showTipDialog(isEdit: true, index: index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.edit, size: 16),
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: () => _deleteTip(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.delete, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTipDialog({bool isEdit = false, int? index}) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    if (isEdit && index != null) {
      titleController.text = tips[index]['title'] ?? '';
      descriptionController.text = tips[index]['description'] ?? '';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Tips" : "Tambah Tips Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Judul",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Deskripsi",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (isEdit && index != null) {
                  tips[index] = {
                    'title': titleController.text,
                    'description': descriptionController.text,
                  };
                } else {
                  tips.add({
                    'title': titleController.text,
                    'description': descriptionController.text,
                  });
                }
              });
              _saveTips();
              Navigator.pop(context);
            },
            child: Text(isEdit ? "Simpan" : "Tambah"),
          ),
        ],
      ),
    );
  }

  void _deleteTip(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hapus Tips"),
        content: const Text("Apakah Anda yakin ingin menghapus tips ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tips.removeAt(index);
              });
              _saveTips();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
