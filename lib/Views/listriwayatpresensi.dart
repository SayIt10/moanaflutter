import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moanaflutter/main.dart';

class ListKehadiranCurrent extends StatefulWidget {
  final String fingerId;
  final DateTime startDate;
  final DateTime endDate;

  const ListKehadiranCurrent({
    super.key,
    required this.fingerId,
    required this.startDate,
    required this.endDate,
  });

  @override
  _ListKehadiranCurrentState createState() => _ListKehadiranCurrentState();
}

class _ListKehadiranCurrentState extends State<ListKehadiranCurrent> {
  List<dynamic> attendanceList = [];
  bool isLoading = true;
  bool noRecord = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      noRecord = false;
    });

    const ipAddress =
        'https://devportal.indolife.co.id/moanaapi/api/report/LoadAttendanceList';

    final requestBody = {
      "FingerId": GlobalVar.fingerId,
      "StartDate": widget.startDate.toIso8601String(),
      "EndDate": widget.endDate.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(ipAddress),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          attendanceList = data['AttendanceList'] ?? [];
          noRecord = attendanceList.isEmpty;
        });
      } else {
        _showAlert('Error', 'Unable to connect to the server.');
      }
    } catch (e) {
      _showAlert('Error', 'Something went wrong. Please try again.');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk mengonversi byte array ke MemoryImage
  Image _buildImageFromBytes(Uint8List? bytes) {
    if (bytes == null || bytes.isEmpty) {
      return Image.asset('assets/images/default_image.png', width: 80, height: 80); // Gambar default jika byte array kosong
    }
    return Image.memory(bytes, width: 80, height: 80, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Daftar Absensi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: Colors.red,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : noRecord
          ? const Center(child: Text('Data tidak ada'))
          : ListView.builder(
        itemCount: attendanceList.length,
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          Uint8List? pictureBytes;
          if (attendance['Picture'] != null) {
            pictureBytes = base64Decode(attendance['Picture']);
          }

          return Card(
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Tampilkan gambar dari byte array
                      _buildImageFromBytes(pictureBytes),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd-MMM-yyyy').format(DateTime.parse(attendance['EntryDate'] ?? '')),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            Text('${attendance['NamaCabang'] ?? ''}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Jarak: ${attendance['Distance'] ?? '0'} meters',
                                    style: TextStyle(fontSize: 16),
                                    overflow: TextOverflow.ellipsis,  // Tambahkan ini agar teks tidak overflow
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(DateTime.parse(attendance['EntryDate'])),
                                  style: const TextStyle(fontSize: 16),
                                ),

                              ],
                            )

                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
