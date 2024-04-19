import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel{
  final String? username;
  final String? fullname;
  final String? dob;
  final String? id;
  final String? url;

  UserModel({required this.id, required this.username, required this.fullname, required this.dob, required this.url});

  static UserModel fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot){
    return UserModel(
      username: snapshot['username'], 
      fullname: snapshot['fullname'], 
      dob: snapshot['dob'], 
      id: snapshot['id'],
      url: snapshot['url']
    );
  }
  
  //convert instance of user to json
  Map<String, dynamic> toJson(){
    return {
      "username": username,
      "fullname": fullname,
      "dob": dob,
      "id": id,
      "url": url
    };
  }

}