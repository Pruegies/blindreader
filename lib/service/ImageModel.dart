import 'package:cloud_firestore/cloud_firestore.dart';

class ImageModel {
  final String? img;
  final String? id;
  final String? detectObj;
  final String? time;

  ImageModel({required this.id, required this.img, required this.detectObj, required this.time});

  static ImageModel fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return ImageModel(
      img: snapshot['img'], 
      detectObj: snapshot['detectObj'], 
      time: snapshot['time'],
      id: snapshot['id']);
  }

  //convert instance of user to json
  Map<String, dynamic> toJson() {
    return {"img": img, 
    "id": id,
    "detectObj" : detectObj,
    "time" : time
    };
  }
}
