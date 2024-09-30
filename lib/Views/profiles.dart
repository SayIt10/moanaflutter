import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:qr_flutter/qr_flutter.dart';
import '../Model/findclosestbranch.dart';
import '../Model/fotoabsen.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  double latitude = 0;
  double longitude = 0;
  String nip = '';
  String fingerId = '';
  String lokasi = '';
  String qrCodeData = '';

  final String baseUrl = "https://devportal.indolife.co.id/moanaapi/";

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission is required to access location.')),
        );
        return;
      }
    }

    try {
      Position? position = await Geolocator.getLastKnownPosition();
      position ??= await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
      }

      var item = FotoAbsen(
        fingerId: GlobalVar.fingerId,
        latitude: latitude,
        longitude: longitude,
      );

      String data = json.encode(item);
      var response = await http.post(
        Uri.parse("${baseUrl}api/Absent/FindClosestBranch"),
        headers: {'Content-Type': 'application/json'},
        body: data,
      );

      if (response.statusCode == 200) {
        FindClosestBranch findClosest = FindClosestBranch.fromJson(json.decode(response.body));
        setState(() {
          nip = GlobalVar.nip;
          fingerId = GlobalVar.fingerId;
          lokasi = findClosest.cabangID.toString();
          generateQrCode();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error loading profile')));
    }
  }

  void generateQrCode() {
    if (lokasi.isNotEmpty) {
      String inputCode = "${GlobalVar.fingerId}-${DateTime.now().toString()}-$lokasi";
      setState(() {
        qrCodeData = inputCode; // Menyimpan data QR code
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 220, // Total tinggi container pertama
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24), // Radius pada bagian bawah kiri
                      bottomRight: Radius.circular(24), // Radius pada bagian bawah kanan
                    ),
                    child: SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Image.asset(
                        'assets/images/moana_header_2.png',
                        fit: BoxFit.cover, // Menyesuaikan ukuran gambar
                      ),
                    ),
                  ),
                  // Salam dan nama employee di atas gambar
                  Positioned(
                    left: 20,
                    top: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            shadows: [
                              Shadow(
                                offset: const Offset(4, 4),
                                blurRadius: 40,
                                color: Colors.black.withOpacity(0.8),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          margin: const EdgeInsets.only(left: 20),
                          child: Text(
                            GlobalVar.employeeName,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              shadows: [
                                Shadow(
                                  offset: const Offset(4, 4),
                                  blurRadius: 40,
                                  color: Colors.black.withOpacity(0.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Bagian QR Code dan Tombol Refresh
                      Container(
                        width: double.infinity, // Lebar container mengikuti lebar layar
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Background transparan
                          border: Border.all(
                            color: Colors.grey, // Warna border
                            width: 1, // Ketebalan border
                          ),
                          borderRadius: BorderRadius.circular(16), // Radius sudut
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            if (qrCodeData.isNotEmpty)
                              QrImageView(
                                data: qrCodeData,
                                version: QrVersions.auto,
                                size: 145.0,
                              ),
                            const SizedBox(height: 20), // Jarak antara QR dan tombol
                            SizedBox(
                              width: double.infinity, // Tombol Refresh dengan lebar penuh
                              child: ElevatedButton(
                                onPressed: () async {
                                  await loadProfile();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF034ea2), // Warna background tombol
                                  foregroundColor: Colors.white, // Warna teks tombol
                                  padding: const EdgeInsets.symmetric(vertical: 10), // Jarak vertikal dalam tombol
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24), // Radius sudut tombol
                                  ),
                                ),
                                child: const Text(
                                  "Refresh Qr Code",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, // Mengubah teks menjadi bold
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20), // Jarak antara frame QR dan frame informasi

                      // Bagian Informasi dengan judul "Informasi Profile"
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Informasi Profile",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10), // Jarak antara judul dan frame informasi
                          Container(
                            width: double.infinity, // Lebar container mengikuti lebar layar
                            decoration: BoxDecoration(
                              color: Colors.transparent, // Background transparan
                              border: Border.all(
                                color: Colors.grey, // Warna border
                                width: 1, // Ketebalan border
                              ),
                              borderRadius: BorderRadius.circular(16), // Radius sudut
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _infoRow("NIP", nip),
                                _infoRow("Finger ID", fingerId),
                                _infoRow("Lokasi", lokasi),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _getGreeting() {
    var dateTime = DateTime.now().hour;
    if (dateTime >= 0 && dateTime <= 11) return "Selamat Pagi,";
    if (dateTime >= 11 && dateTime <= 15) return "Selamat Siang,";
    if (dateTime >= 15 && dateTime <= 18) return "Selamat Sore,";
    return "Selamat Malam,";
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
