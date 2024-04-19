import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:blindreader/service/auth.dart';
import 'package:blindreader/service/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSigning = false;
  final AuthService _auth = AuthService();

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Login'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: _emailcontroller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'email',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: TextFormField(
                    controller: _passwordcontroller,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _signIn();
                          print('Login Clicked!');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          fixedSize: Size(200, 50),
                        ),
                        child: _isSigning
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                      ),
                      SizedBox(height: 40),
                      Text(
                        "Don't have an account yet?",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/createAcc');
                          print('Register Clicked!');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromARGB(255, 193, 193, 193),
                          fixedSize: Size(200, 50),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });
    String email = _emailcontroller.text;
    String password = _passwordcontroller.text;

    User? user = await _auth.signInWhitEmailAndPassword(email, password);
    setState(() {
      _isSigning = false;
    });

    if (user != null) {
      print("User successful signIn");
      showToast(message: "successfully signin");
      Navigator.pushNamed(context, '/homepage');
      fetchTTS("Welcome to BlindReader");
    } else {
      showToast(message: "some error occured");
      print("Some error happend");
    }
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
