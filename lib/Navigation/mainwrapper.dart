import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Views/Mail.dart';
import '../Views/absenphoto.dart';
import '../Views/home.dart';
import '../Views/profiles.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<StatefulWidget> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan
  static final List<Widget> _screens = [
    const HomePage(),
    const CameraPage(),
    const MailPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildIconWithText(IconData iconData, String text, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(horizontal: isSelected ? 32 : 0),
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(20), // Sesuaikan dengan bentuk navbar
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            color: isSelected ? const Color(0xFFf25a5a) : Colors.white,
          ),
          if (isSelected)
            const SizedBox(width: 7),
          if (isSelected)
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFFf25a5a),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Menampilkan layar berdasarkan indeks yang dipilih
      extendBody: true,
      bottomNavigationBar: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: 55,
            margin: EdgeInsets.only(bottom: 20, right: 20, left: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFff9999), // Background color dari navbar
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                buildNavbarItem(CupertinoIcons.home, 'Home', 0),
                buildNavbarItem(CupertinoIcons.camera_fill, 'Absen', 1),
                buildNavbarItem(CupertinoIcons.mail_solid, "Mail", 2),
                buildNavbarItem(CupertinoIcons.profile_circled, 'Profiles', 3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavbarItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onItemTapped(index),
      child: _buildIconWithText(icon, label, isSelected),
    );
  }
}