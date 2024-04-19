import 'package:blindreader/service/toast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //sign up with email and pw ------------------------------------------------------------------------------------------------
  Future<User?> signUpWhitEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if(e.code == 'email-already-in-use'){
          showToast(message: 'The email already in use');
      }else{
          showToast(message: 'An error occured: ${e.code}');
      }
    }
    return null;
  }

  //sign in with email and pw ------------------------------------------------------------------------------------------------
  Future<User?> signInWhitEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      if(e.code == 'user-not-found' || e.code == 'wrong-password'){
          showToast(message: 'Invalid email or password');
      }else{
          showToast(message: 'An error occured: ${e.code}');
      }
    }
    return null;
  }
  
}
