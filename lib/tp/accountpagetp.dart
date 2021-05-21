import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Accountpagetp extends StatefulWidget {
  @override
  _AccountpagetpState createState() => _AccountpagetpState();
}

class _AccountpagetpState extends State<Accountpagetp> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _username;
  String _phone;
  String _email;
  String _dp;
  int _mpesa;
  int _equity;
  int _kcb;
  int _totalfunds;
  Future getUserInfo() async {
    users.doc(docID).get().then(
      (value) {
        setState(() {
          _username = value.data()['userName'];
          _phone = value.data()['phone_number'];
          _mpesa = value.data()['mpesa_balance'];
          _equity = value.data()['equity_balance'];
          _email = value.data()['email'];
          _dp = value.data()['profilePicture'];
          _kcb = value.data()['kcb_balance'];
          _totalfunds = _equity + _kcb + _mpesa;
        });
      },
    );
  }

  String docID;
  Future getUserDocID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //Return int
    String stringValue = prefs.getString('phone_number');
    setState(() {
      docID = stringValue;
    });
    return stringValue;
  }

  @override
  void initState() {
    super.initState();
    getUserDocID().then(
      (value) {
        getUserInfo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Colors.blueAccent,
                Colors.white,
              ],
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _dp != null
                          ? CircleAvatar(
                              radius: 80,
                              backgroundImage: NetworkImage(_dp),
                            )
                          // Container(
                          //     height: 200,
                          //     width: 200,
                          //     decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       image: DecorationImage(
                          //         image: NetworkImage(_dp),
                          //       ),
                          //     ),
                          //   )
                          : SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$_username',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$_phone',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '$_email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
