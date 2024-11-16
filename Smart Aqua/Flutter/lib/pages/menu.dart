import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_application_1/theme/app_theme.dart';

class StatusInfo {
  final Color color;
  final String message;

  StatusInfo(this.color, this.message);
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  double temperature = 0.0;
  double ph = 0.0;
  double clarity = 0.0;
  double lux = 0.0;
  bool isLoading = true;
  bool fanState = false;
  bool ledState = false;
  bool autoMode = false;

  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref('sensors');
  final DatabaseReference relaysRef = FirebaseDatabase.instance.ref('relays');
  final DatabaseReference settingsRef = FirebaseDatabase.instance.ref('settings');
  final DatabaseReference modeRef = FirebaseDatabase.instance.ref('mode');

  List mySmartDevices = [
    ["Lampu", "lib/icon/lampu.png", false],
    ["Pendingin", "lib/icon/kipas.png", false],
  ];

  String timer = "00:00";
  String suhuMin = "24.00";
  String suhuMax = "27.00";

  @override
  void initState() {
    super.initState();
    _getSensorData();
    _getRelayStates();
    _getSettings();
    _getMode();
  }

  Future<void> _getSensorData() async {
    // Mendengarkan perubahan data secara real-time
    databaseRef.onValue.listen((event) {
      final snapshot = event.snapshot;
      _logInfo('Snapshot exists: ${snapshot.exists}');
      _logInfo('Snapshot value: ${snapshot.value}');

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(snapshot.value as Map);

        setState(() {
          temperature =
              double.tryParse(data['temperature']?.toString() ?? '0') ?? 0.0;
          ph = double.tryParse(data['ph']?.toString() ?? '0') ?? 0.0;
          clarity = double.tryParse(data['clarity']?.toString() ?? '0') ?? 0.0;
          lux = double.tryParse(data['lux']?.toString() ?? '0') ?? 0.0;
          isLoading = false; // Menandakan bahwa data sudah berhasil dimuat
        });
      } else {
        _logInfo('Data tidak ditemukan!');
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

  Future<void> _toggleRelay(String relay, bool currentState) async {
    try {
      await relaysRef.child(relay).set(!currentState);
    } catch (e) {
      _logInfo('Error toggling relay: $e');
    }
  }

  Future<void> _getSettings() async {
    settingsRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          timer = data['timer'] ?? "00:00";
          String batasSuhu = data['batasSuhu'] ?? "24.00,27.00";
          List<String> suhuValues = batasSuhu.split(',');
          suhuMin = suhuValues[0];
          suhuMax = suhuValues[1];
        });
      }
    });
  }

  Future<void> _getMode() async {
    modeRef.onValue.listen((event) {
      if (event.snapshot.exists && event.snapshot.value is Map) {
        final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
        setState(() {
          autoMode = data['otomatis'] ?? false;
        });
      }
    });
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: _parseTimeString(timer),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.white,
              hourMinuteColor: MaterialStateColor.resolveWith((states) => 
                states.contains(MaterialState.selected) 
                  ? const Color.fromARGB(255, 68, 146, 255) // Warna hijau saat dipilih
                  : const Color.fromARGB(255, 78, 130, 225).withOpacity(0.8) // Warna hijau sedikit transparan saat tidak dipilih
              ),
              dayPeriodTextColor: const Color(0xFF2E7D32),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF2E7D32),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child!,
          ),
        );
      },
    );

    if (selectedTime != null) {
      final newTime = '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      try {
        await settingsRef.update({'timer': newTime});
      } catch (e) {
        _logInfo('Error updating timer: $e');
      }
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  Future<void> _showTemperatureDialog() async {
    String tempMinValue = suhuMin;
    String tempMaxValue = suhuMax;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atur Batas Suhu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Suhu Minimal (°C)',
                hintText: 'Contoh: 24.00',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              controller: TextEditingController(text: suhuMin),
              onChanged: (value) {
                tempMinValue = value;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Suhu Maksimal (°C)',
                hintText: 'Contoh: 27.00',
                hintStyle: TextStyle(
                  color: Colors.grey.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              controller: TextEditingController(text: suhuMax),
              onChanged: (value) {
                tempMaxValue = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                double? min = double.tryParse(tempMinValue);
                double? max = double.tryParse(tempMaxValue);
                
                if (min != null && max != null && 
                    min >= 20 && max <= 35 && min < max) {
                  String batasSuhu = '$tempMinValue,$tempMaxValue';
                  await settingsRef.update({'batasSuhu': batasSuhu});
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Masukkan suhu yang valid:\n- Min: 20-35°C\n- Max: harus lebih besar dari Min'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                _logInfo('Error updating suhu: $e');
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building MenuPage');
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
          isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDashboardRow(),
                        const SizedBox(height: 16),
                        _buildControlButtons(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.grey.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
              child: Text(
                'Menu Control',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E3E5C),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 81, 137, 240),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 12.0),
                          child: Text(
                            'Mode Otomatis',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Switch(
                          value: autoMode,
                          onChanged: (value) {
                            modeRef.update({
                              'otomatis': value
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: const Color(0xFF2E3E5C),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Padding(
                    padding: EdgeInsets.only(left: 4.0),
                    child: Text(
                      'Ketuk untuk mengubah mode menjadi mode otomatis',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildControlButton(
                      deviceName: mySmartDevices[1][0],
                      isOn: fanState,
                      onChanged: (value) => _toggleRelay('fan', fanState),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: _buildControlButton(
                      deviceName: mySmartDevices[0][0],
                      isOn: ledState,
                      onChanged: (value) => _toggleRelay('led', ledState),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pengaturan Waktu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showTimePicker,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E3E5C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Timer:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF2E3E5C),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                timer,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E3E5C),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit,
                                color: Color(0xFF2E3E5C),
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk untuk mengubah waktu',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Otomatisasi Suhu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E3E5C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showTemperatureDialog,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E3E5C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Suhu Minimal:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2E3E5C),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$suhuMin°C',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E3E5C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Suhu Maksimal:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF2E3E5C),
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '$suhuMax°C',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E3E5C),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: const [
                              Icon(
                                Icons.edit,
                                color: Color(0xFF2E3E5C),
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ketuk untuk mengubah otomatisasi suhu',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required String deviceName,
    required bool isOn,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: const Color.fromARGB(255, 81, 137, 240),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              deviceName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            Switch(
              value: isOn,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 8.0, bottom: 16.0),
          child: Text(
            'Menu Monitoring',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E3E5C),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildDashboardItem(
                  title: 'Temperature',
                  value: '$temperature°C',
                  icon: Icons.thermostat_rounded,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildDashboardItem(
                  title: 'pH Level',
                  value: '$ph',
                  icon: Icons.science_outlined,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildDashboardItem(
                  title: 'Kejernihan Air',
                  value: '${clarity.toStringAsFixed(1)}%',
                  icon: Icons.water_drop_outlined,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildDashboardItem(
                  title: 'Intensitas Cahaya',
                  value: '${lux.toStringAsFixed(1)}',
                  icon: Icons.light_mode_outlined,
                  color: Colors.yellowAccent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

   Widget _buildStatusItem(String label, StatusInfo status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  status.message,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusInfo _getPhStatus() {
    if (ph < 6) {
      return StatusInfo(Colors.red, "pH terlalu rendah (< 6.0)");
    } else if (ph > 8) {
      return StatusInfo(Colors.red, "pH terlalu tinggi (> 8.0)");
    }
    return StatusInfo(Colors.green, "pH normal (6.0 - 8.0)");
  }

  StatusInfo _getTemperatureStatus() {
    if (temperature < 24) {
      return StatusInfo(Colors.red, "Suhu terlalu rendah (< 24°C)");
    } else if (temperature > 27) {
      return StatusInfo(Colors.red, "Suhu terlalu tinggi (> 27°C)");
    }
    return StatusInfo(Colors.green, "Suhu normal (24°C - 27°C)");
  }

  StatusInfo _getClarityStatus() {
    if (clarity < 90) {
      return StatusInfo(Colors.red, "Kejernihan air rendah (< 90%)");
    }
    return StatusInfo(Colors.green, "Kejernihan air normal (≥ 90%)");
  }

  StatusInfo _getLightStatus() {
    if (lux < 50) {
      return StatusInfo(Colors.red, "Intensitas cahaya rendah (< 50 lux)");
    } else if (lux > 100) {
      return StatusInfo(Colors.red, "Intensitas cahaya tinggi (> 100 lux)");
    }
    return StatusInfo(Colors.green, "Intensitas cahaya normal (50-100 lux)");
  }

  void _logInfo(String message) {
    debugPrint(message); // Menggunakan debugPrint sebagai pengganti print
  }
}