import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart'; // Replace with the actual import for your login page

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
      print('Error fetching data: $e');
      return null;
    }
  }

  Future<void> _updatePassword() async {
    final newPassword = _passwordController.text;
    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Password cannot be empty';
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
        const SnackBar(content: Text('Password successfully updated')),
      );
    } catch (e) {
      print('Error updating password: $e');
      setState(() {
        _errorMessage = 'Failed to update password';
      });
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              const LoginPage()), // Replace with your login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Color.fromARGB(255, 55, 71, 79),
          ),
        ),
        centerTitle: false, // Ensures the title is left-aligned
        automaticallyImplyLeading: false, // Disables default back button
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Account data not found.'));
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
                          const Text(
                            'Account Information',
                            style: TextStyle(
                              color: Color.fromARGB(255, 58, 60, 61),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('Name: ${userData['nama'] ?? 'Not available'}'),
                          Text(
                              'Address: ${userData['alamat'] ?? 'Not available'}'),
                          Text(
                              'Username: ${userData['username'] ?? 'Not available'}'),
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
                      child: ElevatedButton(
                        onPressed: _updatePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 62, 216, 57),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        onPressed: _logout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Logout'),
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
