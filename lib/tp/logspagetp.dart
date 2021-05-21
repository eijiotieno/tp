import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Logspagetp extends StatefulWidget {
  @override
  _LogspagetpState createState() => _LogspagetpState();
}

class _LogspagetpState extends State<Logspagetp> {
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _username;
  String _phone;
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
          _kcb = value.data()['kcb_balance'];
          _totalfunds = _equity + _kcb + _mpesa;
        });
      },
    );
  }

  // List<Map<String, dynamic>> logs = [];
  // Future getLogs() async {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(docID)
  //       .collection('logs')
  //       .doc()
  //       .get()
  //       .then(
  //     (value) {
  //       setState(() {
  //         logs.add(
  //           {
  //             // '_time': value.data()['accountCreated'],
  //             '_amount': value.data()['email'],
  //           },
  //         );
  //       });
  //     },
  //   );
  // }

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
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Transaction logs',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(docID.toString())
              .collection('logs')
              .where(
                'sender',
                isEqualTo: docID.toString(),
              )
              .orderBy(
                'time',
                descending: true,
              )
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            return new ListView(
              children: snapshot.data.docs.map((DocumentSnapshot document) {
                DateTime myDateTime = (document.data()['time']).toDate();
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  child: new ListTile(
                    title: Row(
                      children: [
                        document.data()['sender'].toString() == docID.toString()
                            ? Text(
                                document.data()['bank_from'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff5798ee),
                                ),
                              )
                            : Text(
                                document.data()['bank_to'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xff5798ee),
                                ),
                              ),
                        // Text(
                        //   ' . ',
                        //   style: TextStyle(
                        //     fontWeight: FontWeight.bold,
                        //     fontSize: 16,
                        //     color: Colors.black,
                        //   ),
                        // ),
                        Flexible(
                          child: Container(),
                        ),
                        Text(
                          DateFormat.yMMMd().add_jm().format(myDateTime),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Color(0xff7c7f83),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Wrap(
                      children: [
                        Text(
                          'Confirmed your have ',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                        document.data()['sender'].toString() == docID.toString()
                            ? Text(
                                'sent KSH. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                'received KSH. ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                        Text(
                          document.data()['amount'].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        document.data()['sender'].toString() == docID.toString()
                            ? Text(
                                ' to ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                ' from ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                        document.data()['sender'].toString() == docID.toString()
                            ? Text(
                                document.data()['bank_to'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xff5798ee),
                                ),
                              )
                            : Text(
                                document.data()['bank_from'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Color(0xff5798ee),
                                ),
                              ),
                        Text(
                          ' ',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        document.data()['sender'].toString() != docID.toString()
                            ? new Text(
                                document.data()['sender'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                document.data()['receiver'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              )
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
