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
  List<Map<String, dynamic>> _prosesLaporanList = [];

  @override
  void initState() {
    super.initState();
    _fetchLaporan();
  }

  Future<void> _fetchLaporan() async {
    final DatabaseReference laporanRef = FirebaseDatabase.instance.ref('laporan');

    // Fetch laporan dengan status 'belum'
    DatabaseEvent belumEvent = await laporanRef.orderByChild('status').equalTo('belum').once();
    // Fetch laporan dengan status 'proses'
    DatabaseEvent prosesEvent = await laporanRef.orderByChild('status').equalTo('proses').once();

    List<Map<String, dynamic>> laporanBelumList = [];
    List<Map<String, dynamic>> laporanProsesList = [];

    if (belumEvent.snapshot.exists) {
      final laporanData = Map<String, dynamic>.from(belumEvent.snapshot.value as Map<dynamic, dynamic>? ?? {});
      laporanBelumList = laporanData.entries.map((entry) {
        return {
          'id': entry.key,
          ...Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic> ?? {})
        };
      }).toList();
      laporanBelumList.sort((a, b) => (b['tanggal'] as String).compareTo(a['tanggal'] as String));
    }

    if (prosesEvent.snapshot.exists) {
      final laporanData = Map<String, dynamic>.from(prosesEvent.snapshot.value as Map<dynamic, dynamic>? ?? {});
      laporanProsesList = laporanData.entries.map((entry) {
        return {
          'id': entry.key,
          ...Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic> ?? {})
        };
      }).toList();
      laporanProsesList.sort((a, b) => (b['tanggal'] as String).compareTo(a['tanggal'] as String));
    }

    setState(() {
      _laporanList = laporanBelumList;
      _prosesLaporanList = laporanProsesList;
    });
  }

  Future<void> _updateLaporanStatus(String laporanId, String status) async {
    try {
      final DatabaseReference laporanRef = FirebaseDatabase.instance.ref('laporan/$laporanId');
      final DatabaseReference speakerRef = FirebaseDatabase.instance.ref('speaker');

      Map<String, dynamic> updates = {
        'laporan/$laporanId/status': status,
      };

      // Update speaker hanya jika status adalah 'proses'
      if (status == 'proses') {
        updates['speaker'] = false;
      }

      await FirebaseDatabase.instance.ref().update(updates);
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
    return _laporanList.isEmpty && _prosesLaporanList.isEmpty
        ? const Center(child: Text('Tidak ada laporan baru.'))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Laporan Terkini',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _laporanList.length + _prosesLaporanList.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> laporan;
                    bool isProses = false;

                    if (index < _laporanList.length) {
                      laporan = _laporanList[index];
                    } else {
                      laporan = _prosesLaporanList[index - _laporanList.length];
                      isProses = true;
                    }

                    final laporanId = laporan['id'] as String? ?? 'unknown'; // Handle null

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 8, // Added elevation for card
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isProses ? Colors.blue[100] : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              laporan['category'] as String? ?? 'Tidak ada kategori',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Nama: ${laporan['nama'] ?? 'Tidak ada nama'}'),
                            Text('Deskripsi: ${laporan['deskripsi'] ?? 'Tidak ada deskripsi'}'),
                            Text('Tanggal: ${laporan['tanggal'] ?? 'Tidak ada tanggal'}'),
                            Text('Waktu: ${laporan['waktu'] ?? 'Tidak ada waktu'}'),
                            const SizedBox(height: 16),
                            if (isProses) // Show only if the laporan is in "proses" status
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton(
                                  onPressed: () {
                                    _updateLaporanStatus(laporanId, 'selesai');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 62, 216, 57),
                                  ),
                                  child: const Text('Sukses'),
                                ),
                              ),
                            if (!isProses) // Show only if the laporan is not in "proses" status
                              Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateLaporanStatus(laporanId, 'proses');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 240, 193, 75),
                                      ),
                                      child: const Text('Proses'),
                                    ),
                                    const SizedBox(width: 8), // Space between buttons
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateLaporanStatus(laporanId, 'selesai');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(255, 62, 216, 57),
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
