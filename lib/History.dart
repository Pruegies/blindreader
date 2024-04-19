import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:blindreader/ImageDetail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class History extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('History Images'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('RPiImage')
            .where('id', isEqualTo: currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No images available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var imageData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return ListTile(
                  leading: Image.network(imageData['img']),
                  title: Text(imageData['detectObj']),
                  subtitle: Text('Time: ${imageData['time']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailPage(
                          imageUrl: imageData['img'],
                          detectObj: imageData['detectObj'],
                          time: imageData['time'],
                        ),
                      ),
                    );
                    fetchTTS(imageData['detectObj']);
                  },
                );
              },
            );
          }
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
