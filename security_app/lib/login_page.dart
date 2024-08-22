import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'security_page.dart';
import 'user_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      DatabaseReference userRef = FirebaseDatabase.instance.ref('user');

      try {
        DataSnapshot snapshot = await userRef.get();

        if (snapshot.exists) {
          Map<dynamic, dynamic> users = snapshot.value as Map<dynamic, dynamic>;

          bool userFound = false;
          for (var key in users.keys) {
            Map<dynamic, dynamic> userData =
                users[key] as Map<dynamic, dynamic>;
            String storedUsername = userData['username'] ?? '';
            String storedPassword = userData['password'] ?? '';
            String role = userData['role'] ?? '';

            if (username == storedUsername && password == storedPassword) {
              userFound = true;

              if (role == 'satpam') {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SecurityPage(username: username, userId: key)),
                  );
                }
              } else if (role == 'warga') {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UserPage(username: username, userId: key)),
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Role tidak valid')),
                  );
                }
              }
              break;
            }
          }

          if (!userFound) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Username atau password salah')),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data pengguna tidak ditemukan')),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Terjadi kesalahan saat login')),
          );
        }
        debugPrint('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporin App',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: const Color.fromARGB(255, 38, 50, 56),
        centerTitle: true,
        leading: const Icon(Icons.shield),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/secure.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                elevation: 8,
                color: Colors.white.withOpacity(0.8),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.home_outlined,
                            size: 100, color: Color.fromARGB(255, 38, 50, 56)),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.blueGrey[700],
                            ),
                            prefixIcon: const Icon(Icons.person_outline,
                                color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.blueGrey[700],
                            ),
                            prefixIcon: const Icon(Icons.lock_outline,
                                color: Colors.blueGrey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Masukkan password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blueGrey[700],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 80.0),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
