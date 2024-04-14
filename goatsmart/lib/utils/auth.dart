import 'package:firebase_auth/firebase_auth.dart';


class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user{
    return _auth.authStateChanges();
  }

  Future createAccount (String email, String password) async {

    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user);
      return (userCredential.user?.uid);
    }  
    on FirebaseAuthException catch (e){
      if (e.code == 'weak-password'){
        print('The password provided is too weak.');
        return 1;
      } else if (e.code == 'email-already-in-use'){
        print('The account already exists for that email.');
        return 2;
      }
      else if (e.code == 'invalid-email'){
        print('The email address is badly formatted.');
        return 3;
      }      
    } catch (e){
      print(e);
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      print(userCredential.user);
      final a = userCredential.user;
      if (a?.uid != null){
        return a?.uid;
      }
    } on FirebaseAuthException catch (e){
      if (e.code == 'user-not-found'){
        print('No user found for that email.');
        return 1;
      } else if (e.code == 'wrong-password'){
        print('Wrong password provided for that user.');
        return 2;
      } else if (e.code == 'invalid-email'){
        print('The email address is badly formatted.');
        return 3;
      }       
    }
  }
}    