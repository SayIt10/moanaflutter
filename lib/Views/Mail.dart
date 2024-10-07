import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Model/info.dart';

class MailPage extends StatefulWidget {
  const MailPage({super.key});

  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  late Future<List<Info>> _infoList;

  @override
  void initState() {
    super.initState();
    _infoList = fetchInfo();
  }

  Future<List<Info>> fetchInfo() async {
    String mess = '';
    List<Info> infoList = [];

    try {
      String ipAddress = 'https://moana1.indolife.co.id/';

      final response = await http.get(Uri.parse('${ipAddress}api/Info/GetInfo'));
      if (response.statusCode == 200) {
        var resData = json.decode(response.body);
        infoList = (resData as List).map((data) => Info.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      mess = e.toString();
    }

    if (mess.isNotEmpty) {
      // Show alert
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Alert'),
            content: Text(mess),
            actions: [
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

    return infoList;
  }


  Future<bool> checkServerConnectivity(String ip) async {
    // Implementasi logika untuk mengecek konektivitas server
    return true; // Implement proper connectivity check logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Info>>(
        future: _infoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No Records'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var info = snapshot.data![index];
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy').format(info.createdDate).toString(), // Format date in your fetchInfo function
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(info.infoText),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Text('By: '),
                          Text(info.createdBy),
                        ],
                      ),
                      Divider(color: Colors.grey),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


