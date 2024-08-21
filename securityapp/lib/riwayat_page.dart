import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class RiwayatPage extends StatefulWidget {
  final String userId;

  const RiwayatPage({super.key, required this.userId});

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
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
        await laporanRef.orderByChild('status').equalTo('selesai').once();
    DataSnapshot snapshot = event.snapshot;

    List<Map<String, dynamic>> laporanList = [];

    if (snapshot.exists) {
      Map<String, dynamic> laporanData =
          Map<String, dynamic>.from(snapshot.value as Map);
      laporanData.forEach((key, value) {
        // Gunakan try-catch untuk menangani data yang tidak lengkap
        try {
          Map<String, dynamic> laporan = Map<String, dynamic>.from(value);
          laporanList.add({
            'category': laporan['category'] ?? 'Tidak diketahui',
            'nama': laporan['nama'] ?? 'Tidak diketahui',
            'deskripsi': laporan['deskripsi'] ?? 'Tidak ada deskripsi',
            'tanggal': laporan['tanggal'] ?? 'Tanggal tidak tersedia',
            'waktu': laporan['waktu'] ?? 'Waktu tidak tersedia',
          });
        } catch (e) {
          print('Error saat memproses data laporan: $e');
        }
      });

      // Urutkan laporan berdasarkan tanggal terbaru
      laporanList.sort((a, b) => b['tanggal'].compareTo(a['tanggal']));
    }

    setState(() {
      _laporanList = laporanList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Laporan'),
      ),
      body: _laporanList.isEmpty
          ? const Center(child: Text('Tidak ada laporan selesai.'))
          : ListView.builder(
              itemCount: _laporanList.length,
              itemBuilder: (context, index) {
                final laporan = _laporanList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: ListTile(
                    title: Text(laporan['category']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama: ${laporan['nama']}'),
                        Text('Deskripsi: ${laporan['deskripsi']}'),
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
            ),
    );
  }
}
