import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart'; // Ganti dengan import untuk halaman login Anda

class AccountPage extends StatefulWidget {
  final String username;
  final String userId;

  const AccountPage({super.key, required this.username, required this.userId});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage>
    with TickerProviderStateMixin {
  late Future<Map<String, dynamic>?> _userData;
  bool _passwordVisible = false;
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _userData = _fetchUserData();
  }

  Future<Map<String, dynamic>?> _fetchUserData() async {
    try {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref('user/${widget.userId}');
      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        Map<String, dynamic> userData =
            Map<String, dynamic>.from(snapshot.value as Map);
        _passwordController.text =
            userData['password'] ?? ''; // Mengatur nilai awal untuk password
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = _passwordController.text;
    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Password tidak boleh kosong';
      });
      return;
    }

    try {
      final DatabaseReference userRef =
          FirebaseDatabase.instance.ref('user/${widget.userId}');
      await userRef.update({'password': newPassword});
      setState(() {
        _errorMessage = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui')),
      );
    } catch (e) {
      print('Error updating password: $e');
      setState(() {
        _errorMessage = 'Gagal memperbarui password';
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginPage(), // Ganti dengan halaman login Anda
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/login/1.jpg'), // Ganti dengan gambar latar belakang Anda
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
          color: Colors.black.withOpacity(0.2), // Overlay semi-transparan
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Informasi akun',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: const Color.fromARGB(255, 55, 71, 79),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: FutureBuilder<Map<String, dynamic>?>(
                    future: _userData,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data == null) {
                        return const Center(
                            child: Text('Data akun tidak ditemukan.'));
                      } else {
                        final userData = snapshot.data!;
                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Card(
                                elevation: 5,
                                margin: const EdgeInsets.only(bottom: 20),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      const Text(
                                        'Akun',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 58, 60, 61),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                          'Nama: ${userData['nama'] ?? 'Tidak tersedia'}'),
                                      Text(
                                          'Alamat: ${userData['alamat'] ?? 'Tidak tersedia'}'),
                                      Text(
                                          'Username: ${userData['username'] ?? 'Tidak tersedia'}'),
                                    ],
                                  ),
                                ),
                              ),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_passwordVisible,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _passwordVisible = !_passwordVisible;
                                      });
                                    },
                                  ),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (_errorMessage.isNotEmpty)
                                Text(
                                  _errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.greenAccent.withOpacity(
                                              0.5), // Bayangan saat tidak ditekan
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _updatePassword,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color.fromARGB(
                                            255, 62, 216, 57),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                      ),
                                      child: const Text('Simpan Perubahan',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: SizedBox(
                                  width: 200,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.red.withOpacity(0.5),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _logout,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .red, // Background color changed to red
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                      ),
                                      child: const Text(
                                        'Logout',
                                        style: TextStyle(
                                            color: Colors
                                                .white), // Text color changed to white
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
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
