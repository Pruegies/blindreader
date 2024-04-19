//root of application
import 'package:blindreader/service/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'HowToUse.dart';
import './Profile.dart';
import './CreateAcc.dart';
import './EditAcc.dart';
import './Login.dart';
import './HomePage.dart';
import './History.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  var app = MyApp();
  runApp(app);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: const Login(),
        routes: {
          '/homepage': (context) => Homepage(),
          '/editAcc': (context) => const EditAccount(),
          '/createAcc': (context) => const CreateAcc(),
          '/howToUse_1': (context) => HowtoUse_1(),
          '/howToUse_2': (context) => HowtoUse_2(),
          '/howToUse_3': (context) => HowtoUse_3(),
          '/howToUse_4': (context) => HowtoUse_4(),
          '/howToUse_5': (context) => HowtoUse_5(),
          '/login': (context) => const Login(),
          '/profile': (context) => const Profile(),
          '/history': (context) => History(),
        },
      );
  }
}

