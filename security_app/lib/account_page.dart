import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart'; // Ganti dengan import yang sesuai untuk halaman login

class AccountPage extends StatefulWidget {
  final String username;
  final String userId;

  const AccountPage({super.key, required this.username, required this.userId});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
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
            userData['password'] ?? ''; // Set initial value for password
        return userData;
      } else {
        return null;
      }
    } catch (e) {
      print('Error saat mengambil data: $e');
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
        SnackBar(content: Text('Password berhasil diperbarui')),
      );
    } catch (e) {
      print('Error saat memperbarui password: $e');
      setState(() {
        _errorMessage = 'Gagal memperbarui password';
      });
    }
  }

  void _logout() {
    // Log out the user and navigate to the login page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              LoginPage()), // Ganti dengan nama rute atau halaman login Anda
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halaman Akun'),
        foregroundColor: Color.fromARGB(255, 38, 50, 56),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Data akun tidak ditemukan.'));
          } else {
            final userData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 5,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Informasi Akun',
                            style: TextStyle(
                              color: Color.fromARGB(255, 58, 60, 61),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text('Nama: ${userData['nama'] ?? 'Tidak tersedia'}'),
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
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 200, // Set width for the button
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 62, 216, 57),
                          padding: EdgeInsets.symmetric(
                              vertical: 10), // Smaller height
                        ),
                        child: Text('Simpan Perubahan'),
                      ),
                    ),
                  ),
                  Spacer(), // Pushes the logout button to the bottom
                  Center(
                    child: SizedBox(
                      width: 200, // Set width for the button
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: BorderSide(color: Colors.red),
                          padding: EdgeInsets.symmetric(
                              vertical: 10), // Smaller height
                        ),
                        child: Text('Logout'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
