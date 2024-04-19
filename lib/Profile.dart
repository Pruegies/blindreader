import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Blind Reader",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
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

            return data != null
                ? SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 3,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 65,
                                backgroundColor: Colors.white,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: data.containsKey("url")
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
                                data["username"] ?? "N/A",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ListTile(
                          title: Text("Full Name:"),
                          subtitle: Text(data["fullname"] ?? "N/A"),
                        ),
                        ListTile(
                          title: Text("Username:"),
                          subtitle: Text(data["username"] ?? "N/A"),
                        ),
                        ListTile(
                          title: Text("Date of Birth:"),
                          subtitle: Text(data["dob"] ?? "N/A"),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  )
                : Center(child: Text('No data available'));
          }
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/editAcc');
            print('Edit Profile Button Clicked!');
          },
          style: ElevatedButton.styleFrom(
            primary: const Color.fromARGB(255, 193, 193, 193),
            fixedSize: Size(200, 50),
          ),
          child: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
