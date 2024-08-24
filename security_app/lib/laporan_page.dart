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
  String _selectedCategory = 'Emergency';
  final TextEditingController _deskripsiController = TextEditingController();
  String _alamat = '';
  String _nama = '';
  bool _isLoading = false;

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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Konfirmasi',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Apakah Anda yakin ingin mengirim laporan ini?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            _submitLaporan(); // Submit the report
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Kirim',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -40,
                child: CircleAvatar(
                  backgroundColor: Colors.blueGrey[800],
                  radius: 40,
                  child: const Icon(
                    Icons.report_problem,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitLaporan() async {
    if (_selectedCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kategori tidak boleh kosong')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

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

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog();
    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim laporan: $error')),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 80,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                'Laporan terkirim!!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Petugas sedang menuju rumah Anda.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login/3.jpg'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.1), // Overlay semi-transparan
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Isi laporan keadaan darurat:',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 80, 134, 192),
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
                      'Emergency',
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
                    child: GestureDetector(
                      onTap: _showConfirmationDialog,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.redAccent.withOpacity(0.6),
                              Colors.redAccent.withOpacity(0.8),
                              Colors.redAccent,
                            ],
                            stops: [0.6, 0.85, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.redAccent.withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 15,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            Icons.touch_app,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
