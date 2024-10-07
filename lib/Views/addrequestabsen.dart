import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:moanaflutter/Views/home.dart';

import '../main.dart'; // Assuming you have a constants file

class RequestAbsent extends StatefulWidget {
  final String kdAbsen;

  const RequestAbsent(this.kdAbsen, {super.key});

  @override
  _RequestAbsentState createState() => _RequestAbsentState();
}

class _RequestAbsentState extends State<RequestAbsent> {
  final _keteranganController = TextEditingController();
  final _jumlahHariController = TextEditingController(text: '1');
  String _kodeAbsen = '';
  String _jenisAbsen = '';
  final String _jenisCuti = '';
  final String _jenisDaerah = '';
  String _sisaCutiTahunan = '';
  String _sisaCutiBesar = '';
  final DateTime _startDate = DateTime.now();
  final DateTime _endDate = DateTime.now();
  bool _isCutiTahunanEnabled = false;
  bool _isCutiBesarEnabled = false;
  final String _apiUrl = "https://devportal.indolife.co.id/moanaapi";

  @override
  void initState() {
    super.initState();
    _loadInitialData(widget.kdAbsen);
    _displayKeterangan(widget.kdAbsen);
  }

  Future<void> _loadInitialData(String kdAbsen) async {
    setState(() {
      _sisaCutiTahunan = "Sisa Cuti Tahunan ${globalVar.cutiTahunan} Hari";
      _sisaCutiBesar = "Sisa Cuti Besar ${globalVar.cutiBesar} Hari";
    });

    if (kdAbsen.isNotEmpty) {
      List<String> skodeAbsen = kdAbsen.split("-");
      setState(() {
        _kodeAbsen = skodeAbsen[0];
        _jenisAbsen = skodeAbsen[1];
      });

      if (_jenisAbsen.contains("1/2")) {
        _jumlahHariController.text = "0.5";
      }
    }

    if (globalVar.cbtgl_awal.isNotEmpty) {
      setState(() {
        _isCutiTahunanEnabled = true;
        _isCutiBesarEnabled = true;
      });
    } else {
      setState(() {
        _isCutiTahunanEnabled = false;
        _isCutiBesarEnabled = false;
      });
    }
  }

  Future<void> _displayKeterangan(String kdAbsen) async {
    if (kdAbsen.isEmpty) {
      await _showAlertDialog(
        'Keterangan :',
        '* Cuti 1/2 Hari wajib absen datang dan absen pulang. ...',
      );
    }
  }

  Future<void> _showAlertDialog(String title, String content) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[Text(content)],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveForm() async {
    if (!_initValidError()) {
      try {
        var item = {
          "NIK": GlobalVar.nik,
          "TglAwal": DateFormat('yyyy-MM-dd').format(_startDate),
          "TglAkhir": DateFormat('yyyy-MM-dd').format(_endDate),
          "KD_ABSEN": _kodeAbsen,
          "JenisKota": _jenisDaerah,
          "JenisCuti": _jenisCuti,
          "JmlHari": double.parse(_jumlahHariController.text),
          "Requester": GlobalVar.userId,
          "Keterangan": _keteranganController.text,
        };

        var response = await http.post(
          Uri.parse('$_apiUrl/api/TRequestAbsent/InsertRequestAbsent'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(item),
        );

        if (response.statusCode == 200) {
          var res = jsonDecode(response.body);
          await _showAlertDialog('Alert', res);
          if (res == 'SUCCESS') {
            Navigator.pop(context); // Go back to the previous page
          }
        } else {
          await _showAlertDialog('Error', 'Failed to save data.');
        }
      } catch (e) {
        await _showAlertDialog('Error', e.toString());
      }
    }
  }

  bool _initValidError() {
    bool hasError = false;
    String message = '';

    if (_kodeAbsen.isEmpty) {
      message = 'Jenis absen belum di pilih';
    } else if (_startDate.isBefore(DateTime.now().subtract(Duration(days: 30)))) {
      message = 'Request absen tidak dapat dilakukan karena melebihi batas waktu.';
    } else if (_jenisCuti.isEmpty) {
      message = 'Cuti belum di pilih';
    } else {
      hasError = false;
    }

    if (message.isNotEmpty) {
      _showAlertDialog('Alert', message);
    }

    return hasError;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entry Request Absent'),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Header Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: DecorationImage(
                  image: AssetImage('assets/images/header_request.png'), // Ganti dengan path gambar yang sesuai
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _buildTextField('Nama:', 'Masukkan nama'),
                    _buildTextField('Sisa Cuti:', 'Masukkan sisa cuti'),
                    _buildTextField('Sisa Cuti Besar:', 'Masukkan sisa cuti besar'),
                    _buildCutiRadioButtons(),
                    _buildTextField('Jenis Absen:', 'Pilih jenis absen', isDropdown: true),
                    _buildDaerahRadioButtons(),
                    _buildDatePickers(),
                    _buildTextField('Jumlah:', 'Masukkan jumlah', controller: _jumlahHariController),
                    _buildTextField('Keterangan:', 'Masukkan keterangan', controller: _keteranganController),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {TextEditingController? controller, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(height: 8),
        isDropdown
            ? DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint,
          ),
          items: <String>['Absen', 'Cuti']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? value) {},
        )
            : TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: hint,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCutiRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Cuti:'),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Radio(value: 'CT', groupValue: 'Cuti', onChanged: (value) {}),
                Text('Cuti Tahunan'),
              ],
            ),
            Row(
              children: [
                Radio(value: 'CB', groupValue: 'Cuti', onChanged: (value) {}),
                Text('Cuti Besar'),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDaerahRadioButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Daerah:'),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Radio(value: 'DK', groupValue: 'Daerah', onChanged: (value) {}),
                Text('Dalam Kota'),
              ],
            ),
            Row(
              children: [
                Radio(value: 'LK', groupValue: 'Daerah', onChanged: (value) {}),
                Text('Luar Kota'),
              ],
            ),
          ],
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDatePickers() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tanggal Mulai',
            ),
            readOnly: true,
            onTap: () async {
              // Implement date picker
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Tanggal Selesai',
            ),
            readOnly: true,
            onTap: () async {
              // Implement date picker
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
            // Kembali action
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Kembali'),
        ),
        ElevatedButton(
          onPressed: () {
            // Simpan action
            // Implement save logic
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}