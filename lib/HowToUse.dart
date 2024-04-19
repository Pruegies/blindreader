import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class HowtoUse_1 extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How to Use',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'How to Use',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '1. Turn on the IoT devices',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  fetchTTS('Turn on the IoT device');
                  print('Image Button Pressed');
                },
                child: Center(
                  child: Image.asset(
                    "assets/image/sound.jpg",
                    height: MediaQuery.of(context).size.height /
                        2, 
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_2');
                },
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class HowtoUse_2 extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How to Use',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'How to Use',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '2. Make sure that the mobile phone connect to Internet wifi',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  fetchTTS(
                      'Make sure that the mobile phone connect to Internet wifi');
                  print('Image Button Pressed');
                },
                child: Center(
                  child: Image.asset(
                    "assets/image/sound.jpg",
                    height: MediaQuery.of(context).size.height /
                        2,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_1');
                },
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_3');
                },
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class HowtoUse_3 extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How to Use',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'How to Use',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '3. Turn on the blutooth connection of your mobile phone',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  fetchTTS(
                      'Turn on the blutooth connection of your mobile phone');
                  print('Image Button Pressed');
                },
                child: Center(
                  child: Image.asset(
                    "assets/image/sound.jpg",
                    height: MediaQuery.of(context).size.height /
                        2, 
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_2');
                },
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_4');
                },
                child: Text(
                  'Next',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class HowtoUse_4 extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How to Use',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'How to Use',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '4. After login to the account, select blind mode and select bluetooth device to connect',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  fetchTTS(
                      'After login to the account, select blind mode and select bluetooth device to connect');
                  print('Image Button Pressed');
                },
                child: Center(
                  child: Image.asset(
                    "assets/image/sound.jpg",
                    height: MediaQuery.of(context).size.height /
                        2, 
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_3');
                },
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_5');
                },
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}

class HowtoUse_5 extends StatelessWidget {
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'How to Use',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            'How to Use',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '5. Press the button on IoT device to capture the image',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  fetchTTS(
                      'Press the button on IoT device to capture the image');
                  print('Image Button Pressed');
                },
                child: Center(
                  child: Image.asset(
                    "assets/image/sound.jpg",
                    height: MediaQuery.of(context).size.height / 2,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/howToUse_4');
                },
                child: Text(
                  'Back',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Colors.red,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/homepage');
                },
                child: Text(
                  'Done',
                  style: TextStyle(fontSize: 15),
                ),
                backgroundColor: Color.fromARGB(255, 29, 206, 53),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
