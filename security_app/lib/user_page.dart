import 'package:flutter/material.dart';
import 'package:securityapp/account_page.dart';
import 'package:securityapp/laporan_page.dart';
import 'package:url_launcher/url_launcher.dart';

class UserPage extends StatefulWidget {
  final String username;
  final String userId;

  const UserPage({super.key, required this.username, required this.userId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;
  List<Map<String, String>> contacts = [
    {"name": "Police", "phone": "089789876789"},
    {"name": "Developer", "phone": "089789876789"},
    {"name": "Hospital", "phone": "089789876789"},
    {"name": "Security", "phone": "089789876789"},
    {"name": "Fire Brigade", "phone": "089789876789"},
    {"name": "Ambulance", "phone": "089789876789"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${widget.username}'),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        leading: const Icon(Icons.shield_outlined, color: Colors.white),
      ),
      body: _getPage(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[900],
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: _selectedIndex == 0 ? Colors.yellow : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 0;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.bar_chart,
                  color: _selectedIndex == 1 ? Colors.yellow : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 2 ? Colors.yellow : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: _selectedIndex == 3 ? Colors.yellow : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: _selectedIndex == 4 ? Colors.yellow : Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    _selectedIndex = 4;
                  });
                },
              ),
            ],
          ),
        ),
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

  void _editContact(int index, Map<String, String> updatedContact) {
    setState(() {
      contacts[index] = updatedContact;
    });
  }

  void _deleteContact(int index) {
    setState(() {
      contacts.removeAt(index);
    });
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
              image: AssetImage(
                  'assets/security_background.jpg'), // Tambahkan gambar yang menarik
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Layer Transparan agar teks lebih terlihat
        Container(
          color: Colors.black.withOpacity(
              0.5), // Overlay semi-transparan untuk memberikan kontras
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
                  color: Colors
                      .white, // Warna putih agar kontras dengan latar belakang
                ),
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
      color: Colors.white.withOpacity(
          0.8), // Kartu semi-transparan agar tetap terlihat di atas latar
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.person, color: Colors.blue[900], size: 40),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
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
    _nameController = TextEditingController(
        text: widget.contact != null ? widget.contact!['name'] : '');
    _phoneController = TextEditingController(
        text: widget.contact != null ? widget.contact!['phone'] : '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact != null ? 'Edit Contact' : 'Add Contact'),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSave({
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                    });
                    Navigator.of(context).pop();
                  }
                },
                child: const Text('Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
