import 'package:flutter/material.dart';
import 'package:securityapp/account_page.dart';
import 'package:securityapp/laporan_page.dart';
import 'package:url_launcher/url_launcher.dart'; // Ensure this import for phone call functionality

class UserPage extends StatefulWidget {
  final String username;
  final String userId;

  const UserPage({super.key, required this.username, required this.userId});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selamat Datang, ${widget.username}'),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        leading: const Icon(Icons.shield_outlined),
      ),
      body: _getPage(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blueGrey[800],
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report),
            label: 'Laporan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Akun',
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
        return LaporanPage(username: widget.username, userId: widget.userId);
      case 2:
        return AccountPage(username: widget.username, userId: widget.userId);
      default:
        return UserPageContent(); // Updated content with emergency contacts
    }
  }
}

class UserPageContent extends StatelessWidget {
  const UserPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/security_home_bg.jpg'), // Background image
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
              'Kontak Darurat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
                backgroundColor: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Table(
                  columnWidths: {
                    0: FixedColumnWidth(50), // Adjust width for icons
                    1: FlexColumnWidth(), // Adjust width for names
                    2: FixedColumnWidth(150), // Adjust width for phone numbers
                    3: FixedColumnWidth(50), // Adjust width for call button
                  },
                  border: TableBorder.all(
                    color: Colors.grey[300]!,
                    borderRadius: BorderRadius.circular(8),
                    width: 1,
                  ),
                  children: [
                    _buildTableHeader(),
                    _buildEmergencyContactRow(
                        'Polisi', '089789876789', Icons.local_police),
                    _buildEmergencyContactRow(
                        'Developer', '089789876789', Icons.build),
                    _buildEmergencyContactRow(
                        'Rumah Sakit', '089789876789', Icons.local_hospital),
                    _buildEmergencyContactRow(
                        'Satpam', '089789876789', Icons.security),
                    _buildEmergencyContactRow('Pemadam Kebakaran',
                        '089789876789', Icons.fire_extinguisher),
                    _buildEmergencyContactRow(
                        'Ambulance', '089789876789', Icons.local_hospital),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        _buildHeaderCell('Icon'),
        _buildHeaderCell('Name'),
        _buildHeaderCell('Phone Number'),
        _buildHeaderCell('Call'),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      color: Colors.blueGrey[900],
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  TableRow _buildEmergencyContactRow(
      String name, String phoneNumber, IconData icon) {
    return TableRow(
      children: [
        _buildIconCell(icon),
        _buildTextCell(name),
        _buildTextCell(phoneNumber),
        _buildCallButton(phoneNumber),
      ],
    );
  }

  Widget _buildIconCell(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.red, size: 30),
    );
  }

  Widget _buildTextCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildCallButton(String phoneNumber) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(Icons.call, color: Colors.green),
        onPressed: () {
          _makePhoneCall(phoneNumber);
        },
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
}
