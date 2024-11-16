import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Menampilkan loading selama 3 detik
    print("LoadingPage: Memulai loading..."); // Debugging

    Future.delayed(const Duration(seconds: 1), () {
      print("LoadingPage: Selesai loading, navigasi ke halaman sebelumnya."); 
      // Navigasi ke halaman sebelumnya atau halaman utama
      Navigator.of(context).pushReplacementNamed('/home'); // Ganti dengan rute yang sesuai
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/aquascape_loading.json', // Pastikan path sesuai
              width: 150, // Ukuran lebih kecil agar lebih dekat
              height: 150,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 20), // Jarak antara animasi dan teks
            const Text(
              'Sedang memuat, harap tunggu...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E3E5C), // Warna teks sesuai tema
              ),
            ),
          ],
        ),
      ),
    );
  }
} 