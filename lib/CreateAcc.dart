import 'dart:io';

import 'package:blindreader/service/UserModel.dart';
import 'package:blindreader/service/auth.dart';
import 'package:blindreader/service/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class CreateAcc extends StatefulWidget {
  const CreateAcc({Key? key}) : super(key: key);

  @override
  State<CreateAcc> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<CreateAcc> {
  final AuthService _auth = AuthService();

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  TextEditingController _usernamecontroller = TextEditingController();
  TextEditingController _fullnameontroller = TextEditingController();
  TextEditingController _dobcontroller = TextEditingController();

  String imgUrl = '';
  File? imageFile;

  @override
  void dispose() {
    _usernamecontroller.dispose();
    _dobcontroller.dispose();
    _fullnameontroller.dispose();

    _emailcontroller.dispose();
    _passwordcontroller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create account information'),
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
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _usernamecontroller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Username',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _passwordcontroller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                  ),
                  obscureText: true,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _fullnameontroller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Fullname',
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _dobcontroller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Date of Birth',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {
                    pickImage();
                  },
                  child: Text('Upload Profile Picture'),
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _signUp();
                        showToast(message: "successfully create");
                        Navigator.pop(context);
                        print('Create Account Clicked!');
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Already have an account? Click to sign in",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

void _signUp() async {
  String email = _emailcontroller.text;
  String password = _passwordcontroller.text;

  String username = _usernamecontroller.text;
  String fullname = _fullnameontroller.text;
  String dob = _dobcontroller.text;

  // Sign up the user
  User? user = await _auth.signUpWhitEmailAndPassword(email, password);
  
  if (user != null) {
    print("User successfully created");

    // Upload the image
    await confirmUpload(imageFile!);

    // Create user data
    _createData(UserModel(
      username: username,
      fullname: fullname,
      dob: dob,
      id: user.uid,
      url: imgUrl
    ));

    // Navigate to the homepage
    Navigator.pushNamed(context, '/homepage');
  } else {
    print("Error occurred while signing up");
  }
}



  void _createData(UserModel userModel) async {
    final userCollection = FirebaseFirestore.instance.collection("users");
    String? uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final newUser = UserModel(
              username: userModel.username,
              fullname: userModel.fullname,
              dob: userModel.dob,
              id: uid,
              url: userModel.url)
          .toJson();

      await userCollection.doc(uid).set(newUser);
      print("User data added successfully");
    } else {
      print("User not logged in");
    }
  }

  Future pickImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() {
      imageFile = File(file.path);
    });
    confirmUpload(imageFile!);
  }

  Future confirmUpload(File file) async {
    String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDirImages = referenceRoot.child('image');
    Reference referenceImageToUpload =
        referenceDirImages.child('$uniqueFileName.jpg');
    try {
      await referenceImageToUpload.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      imgUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      print('Error uploading image: $error');
    }
  }
  
}
