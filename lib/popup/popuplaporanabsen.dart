import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Views/laporanabsen.dart';

class DateRangePopup extends StatefulWidget {
  final Function(DateTime?, DateTime?) onDateSelected;

  const DateRangePopup({super.key, required this.onDateSelected});

  @override
  _DateRangePopupState createState() => _DateRangePopupState();
}

class _DateRangePopupState extends State<DateRangePopup> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Start Date
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(153, 153, 155, .60),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    child: Text(
                      "Tanggal Mulai:",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectStartDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _startDate == null
                              ? 'Pilih Tanggal Mulai'
                              : DateFormat('dd MMMM yyyy').format(_startDate!),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // End Date
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(153, 153, 155, .60),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade200,
                        ),
                      ),
                    ),
                    child: Text(
                      "Tanggal Akhir:",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _selectEndDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: _endDate == null
                              ? 'Pilih Tanggal Akhir'
                              : DateFormat('dd MMMM yyyy').format(_endDate!),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            // Preview and Close Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_startDate != null && _endDate != null) {
                      print('Start Date: $_startDate, End Date: $_endDate'); // Debugging log
                      // Kirim data tanggal yang dipilih ke halaman baru
                      Navigator.of(context).pop(); // Tutup dialog terlebih dahulu
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LaporanAbsenPage(startDate: _startDate!, endDate: _endDate!),
                      )); // Navigasi ke LaporanAbsenPage
                    } else {
                      // Jika tanggal belum dipilih, tampilkan pesan kesalahan
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Silakan pilih tanggal mulai dan akhir')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Preview',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
