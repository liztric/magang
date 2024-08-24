import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:securityapp/account_page.dart';
import 'package:securityapp/laporan_page.dart';

class UserPage extends StatefulWidget {
  final String username;
  final String userId;

  const UserPage({super.key, required this.username, required this.userId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  List<Map<String, String>> contacts = [];

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  Future<void> _fetchContacts() async {
    final DatabaseReference contactsRef =
        FirebaseDatabase.instance.ref('user/${widget.userId}/contacts');

    contactsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<Map<String, String>> newContacts = [];
        data.forEach((key, value) {
          final contact = Map<String, String>.from(value);
          contact['key'] = key; // Simpan key di dalam map
          newContacts.add(contact);
        });
        setState(() {
          contacts = newContacts;
        });
      }
    });
  }

  void _addContact(Map<String, String> newContact) {
    final DatabaseReference contactsRef =
        FirebaseDatabase.instance.ref('user/${widget.userId}/contacts');
    contactsRef.push().set(newContact);
  }

  void _editContact(int index, Map<String, String> updatedContact) {
    final String? key = contacts[index]['key']; // Menggunakan String?
    if (key != null) {
      final DatabaseReference contactRef =
          FirebaseDatabase.instance.ref('user/${widget.userId}/contacts/$key');
      contactRef.update(updatedContact);
    } else {
      // Handle error jika key tidak ditemukan
      print("Error: Key is null, cannot update contact.");
    }
  }

  void _deleteContact(int index) {
    final String? key = contacts[index]['key']; // Menggunakan String?
    if (key != null) {
      final DatabaseReference contactRef =
          FirebaseDatabase.instance.ref('user/${widget.userId}/contacts/$key');
      contactRef.remove();
    } else {
      // Handle error jika key tidak ditemukan
      print("Error: Key is null, cannot delete contact.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${widget.username}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Color.fromARGB(255, 80, 134, 192),
        centerTitle: true,
        leading: const Icon(Icons.shield_outlined, color: Colors.white),
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
            backgroundColor: Color.fromARGB(255, 80, 134, 192),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Report',
            backgroundColor: Color.fromARGB(255, 80, 134, 192),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Account',
            backgroundColor: Color.fromARGB(255, 80, 134, 192),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ContactFormPage(
                onSave: (newContact) {
                  _addContact(newContact);
                },
              ),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 80, 134, 192),
      ),
    );
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 1:
        return LaporanPage(username: widget.username, userId: widget.userId);
      case 2:
        return AccountPage(username: widget.username, userId: widget.userId);
      default:
        return UserPageContent(
          contacts: contacts,
          onEdit: _editContact,
          onDelete: _deleteContact,
        );
    }
  }
}

class UserPageContent extends StatelessWidget {
  final List<Map<String, String>> contacts;
  final Function(int, Map<String, String>) onEdit;
  final Function(int) onDelete;

  const UserPageContent({
    super.key,
    required this.contacts,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Gambar Latar Belakang
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/login/4.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Layer Transparan agar teks lebih terlihat
        Container(
          color: Colors.black.withOpacity(0.2), // Overlay semi-transparan
        ),
        // Konten Utama
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 20),
              Text(
                'Emergency Contacts',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFFFFF),
                ), // Warna lebih cerah untuk kontras
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return _buildContactCard(
                      context,
                      contact['name']!,
                      contact['phone']!,
                      index,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactCard(
      BuildContext context, String name, String phoneNumber, int index) {
    return Card(
      color: Colors.white.withOpacity(0.8), // Semi-transparan agar terlihat
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.person,
            color: Color.fromARGB(255, 80, 134, 192), size: 40),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 80, 134, 192),
          ),
        ),
        subtitle: Text(
          phoneNumber,
          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ContactFormPage(
                      contact: {'name': name, 'phone': phoneNumber},
                      onSave: (updatedContact) {
                        onEdit(index, updatedContact);
                      },
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                onDelete(index);
              },
            ),
          ],
        ),
        onTap: () {
          _makePhoneCall(context, phoneNumber);
        },
      ),
    );
  }

  void _makePhoneCall(BuildContext context, String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }
}

class ContactFormPage extends StatefulWidget {
  final Map<String, String>? contact;
  final Function(Map<String, String>) onSave;

  const ContactFormPage({super.key, this.contact, required this.onSave});

  @override
  _ContactFormPageState createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?['name']);
    _phoneController = TextEditingController(text: widget.contact?['phone']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final contact = {
        'name': _nameController.text,
        'phone': _phoneController.text,
      };
      widget.onSave(contact);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
        backgroundColor: Color.fromARGB(255, 80, 134, 192),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(widget.contact == null ? 'Add Contact' : 'Save'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color.fromARGB(255, 80, 134, 192),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
