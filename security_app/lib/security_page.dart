import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'riwayat_page.dart';
import 'account_page.dart';

class SecurityPage extends StatefulWidget {
  final String username;
  final String userId;

  const SecurityPage({super.key, required this.username, required this.userId});

  @override
  _SecurityPageState createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _laporanList = [];

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    final DatabaseReference laporanRef =
        FirebaseDatabase.instance.ref('laporan');
    DatabaseEvent event =
        await laporanRef.orderByChild('status').equalTo('belum').once();

    if (event.snapshot.exists) {
      final laporanData =
          Map<String, dynamic>.from(event.snapshot.value as Map);
      List<Map<String, dynamic>> laporanList = laporanData.entries.map((entry) {
        return Map<String, dynamic>.from(entry.value as Map);
      }).toList();

      // Urutkan laporan berdasarkan tanggal terbaru
      laporanList.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));

      setState(() {
        _laporanList = laporanList;
      });
    } else {
      print('Tidak ada laporan dengan status "belum".');
    }
  }

  Future<void> _updateLaporanStatus(String laporanId, String status,
      {bool speaker = true}) async {
    try {
      final DatabaseReference laporanRef =
          FirebaseDatabase.instance.ref('laporan/$laporanId');
      await laporanRef.update({
        'status': status,
        'speaker': speaker,
      });
      _fetchLaporan(); // Refresh the laporan list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laporan status updated to "$status".')),
      );
    } catch (e) {
      print('Error updating laporan status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update laporan status.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Security - ${widget.username}'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[800],
        centerTitle: true,
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 1:
        return RiwayatPage(userId: widget.userId);
      case 2:
        return AccountPage(username: widget.username, userId: widget.userId);
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    return _laporanList.isEmpty
        ? const Center(child: Text('Tidak ada laporan baru.'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Laporan Terkini',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _laporanList.length,
                  itemBuilder: (context, index) {
                    final laporan = _laporanList[index];
                    final laporanId = laporan['id']; // Assuming 'id' is a field

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 8, // Added elevation for card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              laporan['category'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Nama: ${laporan['nama']}'),
                            Text(
                                'Deskripsi: ${laporan['deskripsi'] ?? 'Tidak ada deskripsi'}'),
                            Text('Tanggal: ${laporan['tanggal']}'),
                            Text('Waktu: ${laporan['waktu']}'),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateLaporanStatus(laporanId, 'proses',
                                          speaker: false);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 240, 193, 75),
                                    ),
                                    child: const Text('Proses'),
                                  ),
                                  const SizedBox(
                                      width: 8), // Space between buttons
                                  ElevatedButton(
                                    onPressed: () {
                                      _updateLaporanStatus(
                                          laporanId, 'selesai');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 62, 216, 57),
                                    ),
                                    child: const Text('Sukses'),
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
}
