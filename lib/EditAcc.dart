import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:blindreader/service/UserModel.dart';

class EditAccount extends StatefulWidget {
  const EditAccount({Key? key}) : super(key: key);

  @override
  State<EditAccount> createState() => _EditAccState();
}

class _EditAccState extends State<EditAccount> {
  TextEditingController _usernamecontroller = TextEditingController();
  TextEditingController _fullnameontroller = TextEditingController();
  TextEditingController _dobcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Edit Account Information'),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: _fullnameontroller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Full name',
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
                  controller: _dobcontroller,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Date of Birth',
                  ),
                  keyboardType: TextInputType.datetime,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              _updateData(UserModel(
                  username: _usernamecontroller.text,
                  fullname: _fullnameontroller.text,
                  dob: _dobcontroller.text,
                  url: '',
                  id: FirebaseAuth.instance.currentUser?.uid));
              print('Save Button Clicked!');
              Navigator.pushNamed(context, '/homepage');
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.red,
            ),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  // read data from firebase
  Stream<List<UserModel>> _readData() {
    final userCollection = FirebaseFirestore.instance.collection("users");

    return userCollection.snapshots().map((querySnapshot) =>
        querySnapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList());
  }

  // Update user data
  void _updateData(UserModel userModel) {
    final userCollection = FirebaseFirestore.instance.collection("users");

    // Get the current user's ID
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      // Create a map containing the updated user data
      Map<String, dynamic> newData = {
        "username": userModel.username,
        "fullname": userModel.fullname,
        "dob": userModel.dob,
      };

      // Update the document in Firestore with the new data
      userCollection.doc(userId).update(newData).then((_) {
        print("User data updated successfully");
      }).catchError((error) {
        print("Failed to update user data: $error");
      });
    } else {
      print("User not logged in");
    }
  }
}
