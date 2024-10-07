import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moanaflutter/main.dart';

class LaporanAbsenPage extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const LaporanAbsenPage({super.key, this.startDate, this.endDate});

  @override
  _LaporanAbsenPageState createState() => _LaporanAbsenPageState();
}

class _LaporanAbsenPageState extends State<LaporanAbsenPage> {
  List<dynamic> reportAbsens = [];
  bool isLoading = false;
  bool noRecord = false;

  @override
  void initState() {
    super.initState();
    if (widget.startDate != null && widget.endDate != null) {
      loadData();
    }
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
      noRecord = false;
    });

    // Cek jika NIP null
    if (GlobalVar.nip == null) {
      _showAlert('Peringatan', 'NIP tidak ditemukan. Silakan login ulang.');
      setState(() {
        isLoading = false;
      });
      return;
    }

    final ipAddress = 'https://devportal.indolife.co.id/moanaapi/api/report/GetAllReportAllAbsent';

    final requestBody = {
      "NIP": GlobalVar.nip,
      "StartDate": widget.startDate!.toIso8601String(),
      "EndDate": widget.endDate!.toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(ipAddress),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          reportAbsens = data;
          noRecord = reportAbsens.isEmpty; // Mengatur status tidak ada data
        });
      } else {
        _showAlert('Peringatan', 'Tidak dapat terhubung ke server. Mohon periksa koneksi internet Anda.');
        setState(() {
          noRecord = true; // Mengatur status tidak ada data
        });
      }
    } catch (e) {
      _showAlert('Peringatan', 'Terjadi kesalahan: $e. Silakan coba lagi.');
    } finally {
      setState(() {
        isLoading = false; // Mengatur loading ke false setelah selesai
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Laporan Absen'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined),
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
        itemCount: reportAbsens.length,
        itemBuilder: (context, index) {
          final report = reportAbsens[index];
          return _buildReportCard(report);
        },
      ),
    );
  }

  Widget _buildReportCard(dynamic report) {
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
            Text(
              DateFormat('dd-MMM-yyyy').format(DateTime.parse(report['Tanggal'])),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('HH:mm:ss').format(DateTime.parse(report['JAMAS'])),
                  ),
                ),
                const Text('-'),
                Expanded(
                  child: Text(
                    DateFormat('HH:mm:ss').format(DateTime.parse(report['JAMKEL'])),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(report['Keterangan'] ?? ''),
          ],
        ),
      ),
    );
  }
}
