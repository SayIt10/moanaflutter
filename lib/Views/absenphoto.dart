import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:moanaflutter/Model/fotoabsen.dart';
import 'package:moanaflutter/main.dart';

import '../Model/findclosestbranch.dart'; // Untuk formatting waktu

class AbsenPhoto extends StatefulWidget {
  final XFile? file; // Foto yang dikirim dari MainWrapper

  const AbsenPhoto({super.key, this.file});

  @override
  _AbsenPhotoState createState() => _AbsenPhotoState();
}

class _AbsenPhotoState extends State<AbsenPhoto> {
  Uint8List? imageBytes;
  String filePath = "";
  bool tapHandled = false;
  Map<String, dynamic>? wifiData;
  bool loading = false;
  double latitude = 0;
  double longitude = 0;
  String serverTime = ''; // Variabel untuk menyimpan waktu server
  String closestBranch = ''; // Variabel untuk cabang terdekat
  double distance = 0; // Variabel untuk jarak
  String apiBaseUrl = "https://devportal.indolife.co.id/moanaapi/";

  @override
  void initState() {
    super.initState();
    if (widget.file != null) {
      loadPhoto(widget.file!); // Memuat foto yang dikirim dari MainWrapper
      loadServerTime(); // Memuat waktu server dan lokasi
    }
  }

  Future<void> loadPhoto(XFile file) async {
    imageBytes = await file.readAsBytes();
    setState(() {
      filePath = file.path;
    });
  }

  Future<void> loadServerTime() async {
    setState(() {
      loading = true; // Start loading
    });

    try {
      // Fetch server time
      var response = await http.get(Uri.parse("${apiBaseUrl}api/commonapi/GetServerTime"));
      if (response.statusCode == 200) {
        var serverTimeResponse = json.decode(response.body);
        var serverTimeString = serverTimeResponse['datetime'];
        DateTime parsedTime = DateTime.parse(serverTimeString);
        DateTime localTime = parsedTime.toLocal();
        String formattedTime = DateFormat('HH:mm:ss').format(localTime);

        setState(() {
          serverTime = formattedTime;
        });
      }

      // Get GPS position
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;

      // Send GPS data to get closest branch and distance
      var item = FotoAbsen(
        fingerId: GlobalVar.fingerId,
        latitude: latitude,
        longitude: longitude,
      );
      String data = json.encode(item);
      var closestBranchResponse = await http.post(
        Uri.parse("${apiBaseUrl}api/Absent/FindClosestBranch"),
        headers: {"Content-Type": "application/json"},
        body: data,
      );
      if (closestBranchResponse.statusCode == 200) {
        FindClosestBranch findClosest = FindClosestBranch.fromJson(json.decode(closestBranchResponse.body));
        setState(() {
          closestBranch = findClosest.namaCabang ?? 'Unknown Branch';
          distance = findClosest.distance ?? 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading server time and location')),
      );
      if (kDebugMode) {
        print("Error: $e");
      }
    } finally {
      setState(() {
        loading = false; // Stop loading
      });
    }
  }


  Future<void> takeNewPhoto() async {
    // Mengecek apakah kamera tersedia
    final ImagePicker picker = ImagePicker();
    try {
      // Mengambil foto menggunakan kamera
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 480,  // Maksimal lebar foto
        maxHeight: 480, // Maksimal tinggi foto
        imageQuality: 20,  // Kompresi foto
      );

      if (photo == null) {
        // Jika tidak ada foto yang diambil
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("No Camera"),
            content: Text(":( No camera available."),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK"))],
          ),
        );
        return;
      }

      // Memuat foto baru yang diambil
      await loadPhoto(photo);

      // Memuat ulang waktu server dan lokasi
      await loadServerTime();
    } catch (e) {
      print("Error: $e");
    }
  }


  Future<void> saveProcess() async {
    try {
      // Mendapatkan posisi GPS (latitude dan longitude)
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      double latitude = position.latitude;
      double longitude = position.longitude;

      // Mempersiapkan data untuk dikirim
      Map<String, dynamic> item = {
        'DeviceID': GlobalVar.deviceId, // Mengambil Device ID
        'Latitude': latitude,
        'Longitude': longitude,
        'Picture': base64Encode(imageBytes!), // Mengubah gambar ke base64
        'Description': '',
        'WifiSSID': wifiData != null ? wifiData!['WifiSSID'] : '',
        'IPAddress': wifiData != null ? wifiData!['IPAddress'] : ''
      };

      String data = json.encode(item);

      // Membuat client HTTP
      var client = http.Client();
      var ip = "https://devportal.indolife.co.id/moanaapi/"; // Ganti sesuai dengan IP atau URL

      // Endpoint API untuk menyimpan absen
      var uri = Uri.parse("${ip}api/Absent/");

      // Mengirim data ke server
      var response = await client.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: data,
      );

      if (response.statusCode == 200) {
        // Respons dari server berhasil
        var message = json.decode(response.body);
        print("Response: $message");

        // Menghapus foto setelah berhasil disimpan ke server
        deleteFileByPath(filePath);

        // Menampilkan pesan sukses kepada pengguna
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Success"),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (message.startsWith("Success Absent")) {
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                  }
                },
                child: Text("OK"),
              )
            ],
          ),
        );
      } else {
        // Gagal mengirim data
        throw Exception("Failed to save data: ${response.body}");
      }
    } catch (e) {
      // Menangkap error dan menampilkan pesan kesalahan
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            )
          ],
        ),
      );
    }
  }

  void deleteFileByPath(String filePath) {
    final file = File(filePath);

    if (file.existsSync()) {
      file.deleteSync();
      print("File deleted: $filePath");
    } else {
      print("File not found: $filePath");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Absen Photo"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            imageBytes != null
                ? Center(
              child: SizedBox(
                width: 350,
                height: 400,
                child: Image.memory(imageBytes!, fit: BoxFit.cover),
              ),
            )
                : Center(child: Text("No image loaded")),
            SizedBox(height: 20),

            // Displaying loading indicator while fetching data
            if (loading)
              Center(child: CircularProgressIndicator())
            else ...[
              // Displaying location with margin
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.red),
                    SizedBox(width: 5),
                    Text(
                      closestBranch.isNotEmpty ? closestBranch : 'Unknown',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 33),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Jarak  : ${distance != null ? distance.toInt().toString() : 'N/A'} Meter",
                      style: TextStyle(color: distance < 100 ? Colors.green : Colors.red),
                    ),
                    Text("Posisi : ${latitude != 0 ? latitude.toString() : 'N/A'}, ${longitude != 0 ? longitude.toString() : 'N/A'}"),
                    Text("Jam    : ${serverTime.isNotEmpty ? serverTime : 'N/A'}"),
                  ],
                ),
              ),
              SizedBox(height: 20),

              // Buttons for saving attendance, retaking photo, and reloading GPS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: takeNewPhoto,
                      child: Text("Ulangi Foto", style: TextStyle(color: Colors.blue[800])),
                    ),
                    TextButton(
                      onPressed: loadServerTime,
                      child: Text("Reload GPS", style: TextStyle(color: Colors.blue[800])),
                    ),
                    TextButton(
                      onPressed: saveProcess,
                      child: Text("Simpan Absen", style: TextStyle(color: Colors.blue[800])),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
