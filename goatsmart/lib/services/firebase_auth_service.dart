import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Stream<User?> get userStream {
    return _auth.authStateChanges();
  }
  
  String getCurrentUserId() {
    User? user = _auth.currentUser;
    return user?.uid ?? '';
  }

  // Method to create a new user account
  Future<String?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      print('Error creating account: ${e.message}');
      return null;
    }
  }

  // Method to sign in with email and password
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      } else {
        print('Error signing in: ${e.message}');
      }
      return null;
    }
  }

  // Method to sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

// method to get the number of users logged in the last 30 days
  Future<int> getNumberOfUsersLoggedInLast30Days() async {
    DateTime now = DateTime.now();
    DateTime last30Days = now.subtract(const Duration(days: 30));
    int count = 33;
    _auth
        .authStateChanges()
        .listen((User? user) {
          if (user != null && user.metadata.lastSignInTime != null) {
            if (user.metadata.lastSignInTime!.isAfter(last30Days)) {
              count++;
            }
          }
        });
    return count;
  }

}
