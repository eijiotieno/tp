import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:team_project/finalsCode/finalhome.dart';
import 'package:team_project/homeApp.dart';
import 'package:team_project/localauth/localAuth.dart';
import 'package:team_project/methods/auth_method.dart';
import 'package:team_project/home.dart';
import 'package:team_project/tp/hometp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Check_Auth_Status(),
    );
  }
}

// ignore: camel_case_types
class Check_Auth_Status extends StatefulWidget {
  @override
  _Check_Auth_StatusState createState() => _Check_Auth_StatusState();
}

// AuthMethod _authMethod = AuthMethod();

// ignore: camel_case_types
class _Check_Auth_StatusState extends State<Check_Auth_Status> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AuthScreen();
            },
          ),
        );
      }
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LocalAuth();
            },
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  TextEditingController phoneNumber;
  processing() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.black38,
          body: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xff101010),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  FirebaseAuth _auth = FirebaseAuth.instance;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    User _user = (await _auth.signInWithCredential(credential)).user;

    if (_user != null) {
      final QuerySnapshot resultQuery =
          await users.where('userID', isEqualTo: _user.uid).get();
      final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;
      if (_documentSnapshots.length == 0) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(phoneNumber.text.toString())
            .set({
          'userName': _user.displayName,
          'profilePicture': _user.photoURL,
          'userID': _user.uid,
          'email': _user.email,
          'phone_number': phoneNumber.text.toString(),
          'accountCreated': FieldValue.serverTimestamp(),
          'mpesa_balance': 1000,
          'equity_balance': 2000,
          'kcb_balance': 3000,
        });
        final SharedPreferences prefs = await _prefs;
        setState(() {
          prefs.setString('userID', _user.uid);
          prefs.setString('email', _user.email);
          prefs.setString(
            'phone_number',
            phoneNumber.text.toString(),
          );
        });
      } else {
        final SharedPreferences prefs = await _prefs;
        setState(() {
          prefs.setString('userID', _documentSnapshots[0]['userID']);
          prefs.setString('email', _documentSnapshots[0]['email']);
          prefs.setString(
            'phone_number',
            phoneNumber.text.toString(),
          );
        });
      }
    }
    // Once signed in, return the UserCredential

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  void initState() {
    phoneNumber = TextEditingController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formkey,
            child: Center(
              child: Column(
                children: [
                  Flexible(
                    child: Container(),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Cross_platform money transfer',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 0,
                      vertical: 20,
                    ),
                    child: TextFormField(
                      controller: phoneNumber,
                      autofocus: true,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Phone number is needed";
                        }

                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'phone number(07.........)',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState.validate()) {
                            processing();
                            signInWithGoogle().then(
                              (value) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return LocalAuth();
                                    },
                                  ),
                                );
                              },
                            );
                            // _authMethod.signInWithGoogle().then((value) {
                            //   users
                            //       .doc(FirebaseAuth.instance.currentUser.uid)
                            //       .update(
                            //     {
                            //       'phone_number': phoneNumber.text.toString(),
                            //     },
                            //   ).then(
                            //     (value) {
                            //       Navigator.pushReplacement(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) {
                            //             return FinalHome();
                            //           },
                            //         ),
                            //       );
                            //     },
                            //   );
                            // });
                          }
                        },
                        child: Text('Get Started'),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
