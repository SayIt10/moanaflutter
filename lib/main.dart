import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:http/http.dart' as http;
import 'Model/registers.dart';
import 'Navigation/mainwrapper.dart';
import 'Views/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: FutureBuilder(
        future: _checkDeviceRegistration(), // Panggil fungsi pengecekan
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error: ${snapshot.error}')),
            );
          } else {
            final registered = snapshot.data as bool;
            return registered ? MainWrapper() : LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<bool> _checkDeviceRegistration() async {
    try {
      // Get the device UDID
      final deviceId = await FlutterUdid.udid;
      final url = 'https://devportal.indolife.co.id/moanaapi/api/Registers/GetCheckRegisterDevice?devId=$deviceId';

      // Make the HTTP request
      final response = await http.get(Uri.parse(url));

      if (kDebugMode) {
        print('Response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('Response body: ${response.body}');
      }

      // Check if the status code is OK
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Parse the response if it is a valid Map
        if (jsonResponse is Map<String, dynamic>) {
          final registers = Registers.fromJson(jsonResponse);

          // Store values in GlobalVar
          GlobalVar.deviceId = registers.deviceId;
          GlobalVar.fingerId = registers.fingerId;
          GlobalVar.employeeName = registers.employeeName;
          GlobalVar.nip = registers.nip;

          print('Device ID from response: ${registers.deviceId}');

          // Call GetUserId to retrieve user details
          await _getUserId();

          return registers.deviceId.isNotEmpty; // Return true if device is registered
        }
      }
      return false; // Device is not registered
    } catch (e) {
      print('Error checking registration: $e');
      return false; // Return false on error
    }
  }

  Future<void> _getUserId() async {
    try {
      // Use the NIP from the GlobalVar
      final nip = GlobalVar.nip;
      final url = 'https://devportal.indolife.co.id/moanaapi/api/User/GetUserAccountByUsername?Username=$nip';

      // Make the HTTP request
      final response = await http.get(Uri.parse(url));

      if (kDebugMode) {
        print('User Response status: ${response.statusCode}');
      }
      if (kDebugMode) {
        print('User Response body: ${response.body}');
      }

      // Check if the status code is OK
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Parse the response if it is a valid Map
        if (jsonResponse is Map<String, dynamic>) {
          // Assuming the response contains Nik and UserID
          final user = User.fromJson(jsonResponse);

          // Store user data in GlobalVar
          GlobalVar.nik = user.nik;
          GlobalVar.userId = user.userId;

          if (kDebugMode) {
            print('User NIK: ${user.nik}');
          }
          if (kDebugMode) {
            print('User ID: ${user.userId}');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user ID: $e');
      }
    }
  }
}

// Model for User response
class User {
  final String nik;
  final String userId;

  User({required this.nik, required this.userId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nik: json['Nik'] ?? '',
      userId: json['UserID'] ?? '',
    );
  }
}

// Global variable class for storing app-wide data
class GlobalVar {
  static String deviceId = '';
  static String fingerId = '';
  static String employeeName = '';
  static String nip = '';
  static String nik = '';
  static String userId = '';
  static String errorResponse = '';
}
