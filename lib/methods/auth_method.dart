// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthMethod {
//   CollectionReference users = FirebaseFirestore.instance.collection('users');
//   DocumentReference docRef =
//       FirebaseFirestore.instance.collection('users').doc();
//   FirebaseAuth _auth = FirebaseAuth.instance;
//   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

//   Future<UserCredential> signInWithGoogle() async {
//     // Trigger the authentication flow
//     final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

//     // Obtain the auth details from the request
//     final GoogleSignInAuthentication googleAuth =
//         await googleUser.authentication;

//     // Create a new credential
//     final GoogleAuthCredential credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );
//     User _user = (await _auth.signInWithCredential(credential)).user;

//     if (_user != null) {
//       final QuerySnapshot resultQuery =
//           await users.where('userID', isEqualTo: _user.uid).get();
//       final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;
//       if (_documentSnapshots.length == 0) {
//         FirebaseFirestore.instance.collection('users').doc().set({
          
//           'userName': _user.displayName,
//           'profilePicture': _user.photoURL,
//           'userID': _user.uid,
//           'email': _user.email,
//           'accountCreated': FieldValue.serverTimestamp(),
//           'mpesa_balance': 1000,
//           'equity_balance': 2000,
//           'kcb_balance': 3000,
//         });
//       }
//     }
//     // Once signed in, return the UserCredential

//     return await FirebaseAuth.instance.signInWithCredential(credential);
//   }
// }
