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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Security - ${widget.username}'),
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
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
        : ListView.builder(
            itemCount: _laporanList.length,
            itemBuilder: (context, index) {
              final laporan = _laporanList[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Text(laporan['category']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nama: ${laporan['nama']}'),
                      Text(
                          'Deskripsi: ${laporan['deskripsi'] ?? 'Tidak ada deskripsi'}'),
                      Text('Tanggal: ${laporan['tanggal']}'),
                      Text('Waktu: ${laporan['waktu']}'),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Tambahkan aksi saat laporan ditekan
                  },
                ),
              );
            },
          );
  }
}
