import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:http/http.dart' as http;
import 'package:moanaflutter/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String employeeName = "Loading..."; // Placeholder for employee name
  String cutiBesar = "0"; // Placeholder for cuti besar
  String cutiTahunan = "0"; // Placeholder for cuti tahunan

  @override
  void initState() {
    super.initState();
    fetchEmployeeDetails();
    loadCutiTahunan();
  }

  // Fetch employee details and update the state
  Future<void> fetchEmployeeDetails() async {
    try {
      String deviceId = await getDeviceId();
      String ipAddress = "https://devportal.indolife.co.id/moanaapi";
      var response = await http.get(Uri.parse('$ipAddress/api/Registers/GetCheckRegisterDevice?devId=$deviceId'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Pastikan data tidak null dan memiliki key 'EmployeeName'
        if (data != null && data.containsKey('EmployeeName')) {
          setState(() {
            GlobalVar.employeeName = data['EmployeeName'] ?? 'Unknown';
            GlobalVar.nip = data['NIP'] ?? 'Unknown'; // Periksa juga NIP
            employeeName = GlobalVar.employeeName; // Update UI
          });
        } else {
          // Jika response body tidak valid
          showAlert("Error", "Employee data not found.");
        }
      } else {
        showAlert("Error", "Failed to fetch employee details. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      showAlert("Error fetching employee details", e.toString());
    }
  }


  // Load cuti tahunan and besar from API
  Future<void> loadCutiTahunan() async {
    try {
      String ipAddress = "https://devportal.indolife.co.id/moanaapi";
      var response = await http.get(Uri.parse('$ipAddress/api/cuti/GetSisaCutiTahunanAndBesar?NIP=${GlobalVar.nip}'));

      if (response.statusCode == 200) {
        var cutiData = jsonDecode(response.body);
        setState(() {
          cutiBesar = cutiData['CutiBesar'].toString();
          cutiTahunan = cutiData['CutiTahunan'].toString();
        });
      }
    } catch (e) {
      showAlert("Error loading cuti", e.toString());
    }
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;

    if (hour >= 0 && hour <= 11) {
      return "Selamat Pagi,";
    } else if (hour > 11 && hour <= 15) {
      return "Selamat Siang,";
    } else if (hour > 15 && hour <= 18) {
      return "Selamat Sore,";
    } else {
      return "Selamat Malam,";
    }
  }


  // Function to get the device ID (you can implement this based on your app's requirement)
  Future<String> getDeviceId() async {
    // Implement your logic to get the device ID
    return FlutterUdid.udid;
  }

  // Function to show alert dialog
  Future<void> showAlert(String title, String message) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 200,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/moana_header.png',
                          fit: BoxFit.fill,
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
                              getGreetingMessage(),
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
                                employeeName,
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
                      // Box cuti
                      Positioned(
                        top: 160,
                        left: MediaQuery.of(context).size.width / 2 - 160,
                        child: Container(
                          height: 60,
                          width: 320,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 40,
                                offset: const Offset(20, 20),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Cuti Besar',
                                    style: TextStyle(
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    cutiBesar,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Cuti Tahunan',
                                    style: TextStyle(
                                      color: Colors.black,
                                      height: 1.2,
                                    ),
                                  ),
                                  Text(
                                    cutiTahunan,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        _buildFeatureButton(
                          context,
                          'Laporan Absen',
                          'assets/images/laporan.png',
                              () {
                            // Implement action
                          },
                        ),
                        _buildFeatureButton(
                          context,
                          'Outstanding',
                          'assets/images/getoutstanding.png',
                              () {
                            // Implement action
                          },
                        ),
                        _buildFeatureButton(
                          context,
                          'Riwayat Presensi',
                          'assets/images/history.png',
                              () {
                            // Implement action
                          },
                        ),
                        _buildFeatureButton(
                          context,
                          'Request Absen',
                          'assets/images/request.png',
                              () {
                            // Implement action
                          },
                        ),
                        _buildFeatureButton(
                          context,
                          'Notification',
                          'assets/images/notification.png',
                              () {
                            // Implement action
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build feature buttons
  Widget _buildFeatureButton(
      BuildContext context, String label, String imagePath, VoidCallback onPressed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(2, 4),
                ),
              ],
            ),
            child: Image.asset(imagePath, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
