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
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        leading: const Icon(Icons.shield_outlined),
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Reports',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addContact(context);  // Pass context to the addContact method
        },
        backgroundColor: Colors.blueGrey[900],
        child: const Icon(Icons.add),
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

  void _addContact(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContactFormPage(
          onSave: (newContact) {
            setState(() {
              contacts.add(newContact);
            });
          },
        ),
      ),
    );
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
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/security_home_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
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
                color: Colors.white,
                backgroundColor: Colors.blueGrey[900]?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return _buildContactCard(
                    context, // Pass context here
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
    );
  }

  Widget _buildContactCard(BuildContext context, String name, String phoneNumber, int index) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.person, color: Colors.blueGrey[900], size: 40), // Use a person icon
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          phoneNumber,
          style: const TextStyle(fontSize: 16, color: Colors.blueGrey),
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
          _makePhoneCall(context, phoneNumber);  // Pass context here
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
        backgroundColor: Colors.blueGrey[900],
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                ),
                child: Text(widget.contact != null ? 'Save' : 'Add'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
