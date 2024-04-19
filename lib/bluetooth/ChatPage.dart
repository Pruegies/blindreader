import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:blindreader/ImageDetail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:http/http.dart' as http;
import 'package:blindreader/service/ImageModel.dart';

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({required this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _Message {
  int whom;
  String text;

  _Message(this.whom, this.text);
}

class _ChatPage extends State<ChatPage> {
  File? imageFile; // for keep image from RPi

  final AudioPlayer _audioPlayer = AudioPlayer();

  //static final clientID = 0;
  BluetoothConnection? connection;

  List<_Message> messages = List<_Message>.empty(growable: true);
  String _messageBuffer = '';

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print(isConnecting);
      print('Cannot connect, exception occurred');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recent image'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("RPiImage")
            .where('time',
                isGreaterThan: DateTime.now().millisecondsSinceEpoch.toString())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var imageData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
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
                },
              );
            },
          );
        },
      ),
    );
  }

  //------------------------------------------------Receive data from RPi--------------------------------------------
  // note : the limitation is the image data sent from RPi is take too long time too recieve at mobile app
  // so to demo this process in class, we use text to send image instead
  // when this function recieve data, it will upload prepared data to clound
  Future<void> _onDataReceived(Uint8List data) async {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });

    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
    // Create message if there is a new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.add(
          _Message(
            1,
            backspacesCounter > 0
                ? _messageBuffer.substring(
                    0, _messageBuffer.length - backspacesCounter)
                : _messageBuffer + dataString.substring(0, index),
          ),
        );
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    //prepared data to upload when recieve data from RPi
    await _createData(ImageModel(
      id: FirebaseAuth.instance.currentUser?.uid,
      detectObj: "Person",
      time: DateTime.now().millisecondsSinceEpoch.toString(),
      img:
          "https://firebasestorage.googleapis.com/v0/b/blindreader-aee46.appspot.com/o/rpi_image%2Fhdr.jpg?alt=media&token=fb58a74b-4bc1-4979-8867-bbbdfb112f22",
    ));
    print(dataString);
    await fetchTTS(dataString);
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

        // Save audio content to a temporary file
        File tempFile = File('${Directory.systemTemp.path}/temp_audio.wav');
        await tempFile.writeAsBytes(base64Decode(audioContent));
        print(tempFile.path);
        // Play the audio file
        await _audioPlayer.play(DeviceFileSource(tempFile.path));
      } else {
        // Error handling
        print('Error ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _createData(ImageModel imgModel) async {
    final userCollection = FirebaseFirestore.instance.collection("RPiImage");
    try {
      final newUser = imgModel.toJson();
      await userCollection.add(newUser); // Use add() instead of doc(uid).set()
      print("User data added successfully");
    } catch (e) {
      print("Error creating data: $e");
    }
  }

  //---------------------------------------recieve image data------------------------------------------
  // note : to user this code chang the mane of "_onDataReceivedImg" to "_onDataReceived"
  // and comment the function "_onDataReceived" above
  Future<void> _onDataReceivedImg(Uint8List data) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('images');
    Reference referenceImageToUpload =
        referenceDirImages.child('$uniqueFileName.jpg');
    try {
      await referenceImageToUpload.putData(
        data,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      String imgUrl = await referenceImageToUpload.getDownloadURL();
      await _createData(ImageModel(
        id: FirebaseAuth.instance.currentUser?.uid,
        detectObj: "cattt",
        time: DateTime.now().millisecondsSinceEpoch.toString(),
        img: imgUrl,
      ));
    } catch (error) {
      print('Error uploading image: $error');
    }
  }
}
