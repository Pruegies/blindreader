import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:blindreader/service/toast.dart';
import 'package:blindreader/bluetooth/ChatPage.dart';
import 'package:blindreader/bluetooth/SelectBondedDevicePage.dart';
import 'package:http/http.dart' as http;

class Homepage extends StatelessWidget {
  //const Homepage({Key? key});
  final AudioPlayer _audioPlayer = AudioPlayer();

  Homepage({super.key});
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var data = snapshot.data?.data() as Map<String, dynamic>?;

          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Blind Reader",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.red,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // Logout button
                  child: ElevatedButton(
                    onPressed: () async {
                      FirebaseAuth.instance.signOut();
                      showToast(message: "Successfully signed out");
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 3,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.white,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: data != null && data.containsKey("url")
                                ? Image.network(
                                    data["url"],
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  )
                                : Image.asset(
                                    "assets/image/blindPerson.jpg",
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                  ),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          data?["username"] ?? "N/A",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    // method--------------------------------------------------------------------------
                    Navigator.pushNamed(context, '/history');
                    print('History Button Clicked!');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 193, 193, 193),
                    fixedSize: Size(200, 50),
                  ),
                  child: Text(
                    'History',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    // method--------------------------------------------------------------------------------
                    Navigator.pushNamed(context, '/profile');
                    print('Profile Button Clicked!');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 193, 193, 193),
                    fixedSize: Size(200, 50),
                  ),
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    // method--------------------------------------------------------------------------------
                    Navigator.pushNamed(context, '/howToUse_1');
                    print('How to use Button Clicked!');
                  },
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromARGB(255, 193, 193, 193),
                    fixedSize: Size(200, 50),
                  ),
                  child: Text(
                    'How to use',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                ),
                Spacer(), 
                GestureDetector(
                  onTap: () async {
                    final BluetoothDevice? selectedDevice =
                        await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        },
                      ),
                    );
                    fetchTTS("Blind Mode");
                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);
                      _startChat(context, selectedDevice);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Blind Mode",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }

  Future<void> fetchTTS(String text) async {
    final String apiKey = 'AIzaSyA4OMl8Cx4mZhFblEzvvnI6MNrnM7-RnXg';
    final String endpoint =
        'https://texttospeech.googleapis.com/v1/text:synthesize';

    final Map<String, dynamic> requestBody = {
      'input': {'text': text},
      'voice': {'languageCode': 'en-US', 'name': 'en-US-Wavenet-D'},
      'audioConfig': {'audioEncoding': 'LINEAR16'},
    };

    try {
      final http.Response response = await http.post(
        Uri.parse('$endpoint?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        String audioContent = responseData['audioContent'];
        File tempFile = File('${Directory.systemTemp.path}/temp_audio.wav');
        await tempFile.writeAsBytes(base64Decode(audioContent));
        print(tempFile.path);
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
      } else {
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
