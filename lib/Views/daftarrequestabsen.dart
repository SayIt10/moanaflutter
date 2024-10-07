import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../Model/trequestabsenmodel.dart';
import '../main.dart';
import 'addrequestabsen.dart';

class DaftarRequestAbsent extends StatefulWidget {
  const DaftarRequestAbsent({super.key});

  @override
  _DaftarRequestAbsentState createState() => _DaftarRequestAbsentState();
}

class _DaftarRequestAbsentState extends State<DaftarRequestAbsent> {
  List<TRequestAbsen> reqDaftarAbsen = [];
  final String fixedIpAddress = 'https://devportal.indolife.co.id/moanaapi';

  @override
  void initState() {
    super.initState();
    loadDaftarAbsent(); // Load data on init
  }

  Future<void> loadDaftarAbsent() async {
    String mess = "";

    try {
      var client = http.Client();
      var item = {
        "StrSearchBy": "Requester",
        "StrSearch": GlobalVar.userId,
        "StrSortBy": "TglAwal",
        "StrSort": "DESC",
        "IntCurrPage": 1,
        "IntPageSize": 30,
        "StrWhere": ""
      };

      var uri = Uri.parse('$fixedIpAddress/api/TRequestAbsent/GetListDataTRequestAbsent');
      var response = await client.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(item),
      );

      if (response.statusCode == 200) {
        var reqAbsenList = jsonDecode(response.body) as List;
        setState(() {
          reqDaftarAbsen = reqAbsenList.map((json) => TRequestAbsen.fromJson(json)).toList();
        });
      } else {
        await showAlert("Peringatan", "Tidak dapat terhubung ke server. Mohon periksa paket data Anda atau Hubungi Administrator Anda.");
      }
    } catch (e) {
      mess = e.toString();
      if (mess.isNotEmpty) {
        await showAlert("Peringatan", "Terjadi kesalahan: $mess");
      }
    }
  }

  Future<void> showAlert(String title, String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(  // Tambahkan SafeArea di sini
        child: Column(
          children: [
            // Header with Image
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                image: DecorationImage(
                  image: AssetImage('assets/images/header_request.png'),
                  fit: BoxFit.fitWidth,
                ),
              ),
              child: Stack(
                children: [
                  // Tombol Back
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  // Teks Daftar Request Absent
                  Positioned(
                    bottom: 5, // Jarak dari bagian bawah gambar
                    left: 20,   // Rata kiri
                    child: Text(
                      'Daftar Request Absent',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Warna teks putih agar terlihat di atas gambar
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // ListView for Request Absen
            Expanded(
              child: ListView.builder(
                itemCount: reqDaftarAbsen.length,
                itemBuilder: (context, index) {
                  final item = reqDaftarAbsen[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Row(
                          children: [
                            Text(
                              DateFormat('dd/MMM/yyyy').format(item.tglAwal!),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(" - "),
                            Text(
                              DateFormat('dd/MMM/yyyy').format(item.tglAkhir!),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("Jenis: "),
                                Text(item.nmAbsen ?? ''),
                              ],
                            ),
                            Text(
                              item.status ?? '',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Logika navigasi ke detail absensi
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            // Floating action button for adding new request
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestAbsent(""), // Navigasi ke halaman DaftarRequestAbsent
                    ),
                  );
                },
                child: Container(
                  width: 56,  // Lebar lingkaran
                  height: 56, // Tinggi lingkaran
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,  // Bentuk lingkaran
                    color: Colors.black87.withOpacity(0.5), // Warna hitam dengan opacity 70%
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
