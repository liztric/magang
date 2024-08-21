import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class LaporanPage extends StatefulWidget {
  final String username;
  final String userId;

  const LaporanPage({super.key, required this.username, required this.userId});

  @override
  _LaporanPageState createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  String _selectedCategory = 'Maling';
  final TextEditingController _deskripsiController = TextEditingController();
  String _alamat = '';
  String _nama = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref('user/${widget.userId}');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        final userData = Map<String, dynamic>.from(snapshot.value as Map);
        setState(() {
          _alamat = userData['alamat'] ?? '';
          _nama = userData['nama'] ?? ''; // Ambil nama dari database
        });
      }
    } catch (e) {
      print('Error saat mengambil data: $e');
    }
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin mengirim laporan ini?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _submitLaporan(); // Submit the report
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitLaporan() async {
    final DatabaseReference laporanRef =
        FirebaseDatabase.instance.ref('laporan');
    final DatabaseReference speakerRef =
        FirebaseDatabase.instance.ref('speaker');
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm');

    final laporanData = {
      'username': widget.username,
      'nama': _nama,
      'category': _selectedCategory,
      'deskripsi': _deskripsiController.text,
      'alamat': _alamat,
      'tanggal': dateFormat.format(now),
      'waktu': timeFormat.format(now),
      'status': 'belum',
    };

    try {
      // Submit laporan data
      await laporanRef.push().set(laporanData);

      // Update speaker data separately
      await speakerRef.set(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan terkirim')),
      );
      // Tambahkan delay sebelum navigasi untuk memastikan SnackBar terlihat
      Future.delayed(const Duration(seconds: 1), () {
        // Navigate back or perform any other action
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Laporan'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // Background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Isi laporan keadaan darurat:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 38, 50, 56),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: <String>[
                    'Maling',
                    'Kebakaran',
                    'Butuh Pertolongan',
                    'Hewan Buas',
                    'Orang Mencurigakan',
                    'Lainnya'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  isExpanded: true,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _deskripsiController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Deskripsi (opsional)',
                    contentPadding: EdgeInsets.all(10),
                  ),
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 150,
                    height: 150,
                    child: ElevatedButton(
                      onPressed: _showConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.redAccent[700],
                        padding: const EdgeInsets.all(20),
                        elevation: 5,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.send, color: Colors.white, size: 40),
                          SizedBox(height: 10),
                          Text(
                            'Kirim',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
