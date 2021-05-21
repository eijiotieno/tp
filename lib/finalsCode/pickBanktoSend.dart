import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KcbTo extends StatefulWidget {
  @override
  _KcbToState createState() => _KcbToState();
}

class _KcbToState extends State<KcbTo> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
    if (_authorized == 'Authorized') {
      _processing = true;
      sendFunds().whenComplete(
        () {
          setState(() {
            _processing = false;
          });
        },
      );
    }
  }

  bool _processing = false;
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

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController phoneNumber;
  TextEditingController amount;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _username;
  String _phone;
  int _mpesa;
  int _equity;
  int _kcb;
  int _totalfunds;
  getUserInfo() async {
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

  String selectedBank;
  List<String> banks = [
    'Mpesa',
    'Equity Bank',
    'KCB Bank',
  ];
  int remainmpesa;
  int senttompesaCurrentBalance;
  int senttompesaNewBalance;
  int remainkcb;
  int senttokcbCurrentBalance;
  int senttokcbNewBalance;
  int remainequity;
  int senttoequityCurrentBalance;
  int senttoequityNewBalance;
  sendFunds() async {
    if (phoneNumber.text.toString() == _phone) {
      Fluttertoast.showToast(
        msg: "Cannot send money to yourself",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    } else {
      QuerySnapshot resultQuery = await users
          .where('phone_number', isEqualTo: phoneNumber.text.toString())
          .get();
      final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;
      if (_documentSnapshots.length == 0) {
        Fluttertoast.showToast(
          msg: "Account does not exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 40,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0,
        );
      } else {
        if (selectedBank == 'Mpesa') {
          if (_mpesa > int.parse(amount.text)) {
            setState(() {
              remainmpesa = _mpesa - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'mpesa_balance': remainmpesa,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttokcbCurrentBalance = value.data()['kcb_balance'];
                    });
                  },
                );
                setState(() {
                  senttokcbNewBalance =
                      senttokcbCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'kcb_balance': senttokcbNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'KCB',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'KCB',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
        if (selectedBank == 'Equity Bank') {
          if (_equity > int.parse(amount.text)) {
            setState(() {
              remainequity = _equity - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'equity_balance': remainequity,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttokcbCurrentBalance = value.data()['kcb_balance'];
                    });
                  },
                );
                setState(() {
                  senttokcbNewBalance =
                      senttokcbCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'kcb_balance': senttokcbNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'KCB',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'KCB',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
        if (selectedBank == 'KCB Bank') {
          if (_kcb > int.parse(amount.text)) {
            setState(() {
              remainkcb = _kcb - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'kcb_balance': remainkcb,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttokcbCurrentBalance = value.data()['kcb_balance'];
                    });
                  },
                );
                setState(() {
                  senttokcbNewBalance =
                      senttokcbCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'kcb_balance': senttokcbNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'KCB',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'KCB',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    phoneNumber = TextEditingController();
    amount = TextEditingController();
    super.initState();
    getUserDocID().then(
      (value) {
        getUserInfo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: CloseButton(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          'Transfer Funds',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        10.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Current balance :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Container(),
                          ),
                          selectedBank == 'Mpesa'
                              ? Text(
                                  'Ksh $_mpesa'.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : selectedBank == 'KCB Bank'
                                  ? Text(
                                      'Ksh $_kcb'.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : selectedBank == 'Equity Bank'
                                      ? Text(
                                          'Ksh $_equity'.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Text('Pick a bank'),
                        ],
                      ),
                    ),
                  ),
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Funds from : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              hint: Text('Select Bank'),
                              value: selectedBank,
                              items: banks.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (String val) {
                                setState(() {
                                  selectedBank = val;
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: TextFormField(
                            controller: phoneNumber,
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "account number is needed";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Receiver account number (07.........)',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: TextFormField(
                            controller: amount,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Amount is needed";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Amount',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState.validate()) {
                            _authenticate();
                          }
                        },
                        child: Text('Transfer'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EquityTo extends StatefulWidget {
  @override
  _EquityToState createState() => _EquityToState();
}

class _EquityToState extends State<EquityTo> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
    if (_authorized == 'Authorized') {
      _processing = true;
      sendFunds().whenComplete(
        () {
          setState(() {
            _processing = false;
          });
        },
      );
    }
  }

  bool _processing = false;
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

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController phoneNumber;
  TextEditingController amount;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _username;
  String _phone;
  int _mpesa;
  int _equity;
  int _kcb;
  int _totalfunds;
  getUserInfo() async {
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

  String selectedBank;
  List<String> banks = [
    'Mpesa',
    'Equity Bank',
    'KCB Bank',
  ];
  int remainmpesa;
  int senttompesaCurrentBalance;
  int senttompesaNewBalance;
  int remainkcb;
  int senttokcbCurrentBalance;
  int senttokcbNewBalance;
  int remainequity;
  int senttoequityCurrentBalance;
  int senttoequityNewBalance;
  sendFunds() async {
    if (phoneNumber.text.toString() == _phone) {
      Fluttertoast.showToast(
        msg: "Cannot send money to yourself",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    } else {
      QuerySnapshot resultQuery = await users
          .where('phone_number', isEqualTo: phoneNumber.text.toString())
          .get();
      final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;
      if (_documentSnapshots.length == 0) {
        Fluttertoast.showToast(
          msg: "Account does not exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 40,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0,
        );
      } else {
        if (selectedBank == 'Mpesa') {
          if (_mpesa > int.parse(amount.text)) {
            setState(() {
              remainmpesa = _mpesa - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'mpesa_balance': remainmpesa,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttoequityCurrentBalance =
                          value.data()['equity_balance'];
                    });
                  },
                );
                setState(() {
                  senttoequityNewBalance =
                      senttoequityCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'equity_balance': senttoequityNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'EQUITY',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'EQUITY',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
        if (selectedBank == 'Equity Bank') {
          if (_equity > int.parse(amount.text)) {
            setState(() {
              remainequity = _equity - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'equity_balance': remainequity,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttoequityCurrentBalance =
                          value.data()['equity_balance'];
                    });
                  },
                );
                setState(() {
                  senttoequityNewBalance =
                      senttoequityCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'equity_balance': senttoequityNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'EQUITY',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'EQUITY',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
        if (selectedBank == 'KCB Bank') {
          if (_kcb > int.parse(amount.text)) {
            setState(() {
              remainkcb = _kcb - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'kcb_balance': remainkcb,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttoequityCurrentBalance =
                          value.data()['equity_balance'];
                    });
                  },
                );
                setState(() {
                  senttoequityNewBalance =
                      senttoequityCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'equity_balance': senttoequityNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'EQUITY',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'EQUITY',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    phoneNumber = TextEditingController();
    amount = TextEditingController();
    super.initState();
    getUserDocID().then(
      (value) {
        getUserInfo();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: CloseButton(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          'Transfer Funds',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        10.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Current balance :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Container(),
                          ),
                          selectedBank == 'Mpesa'
                              ? Text(
                                  'Ksh $_mpesa'.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : selectedBank == 'KCB Bank'
                                  ? Text(
                                      'Ksh $_kcb'.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : selectedBank == 'Equity Bank'
                                      ? Text(
                                          'Ksh $_equity'.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Text('Pick a bank'),
                        ],
                      ),
                    ),
                  ),
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Funds from : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              hint: Text('Select Bank'),
                              value: selectedBank,
                              items: banks.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (String val) {
                                setState(() {
                                  selectedBank = val;
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: TextFormField(
                            controller: phoneNumber,
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "account number is needed";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText:
                                  'Receiver account number (07.........)',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: TextFormField(
                            controller: amount,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Amount is needed";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Amount',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState.validate()) {
                            _authenticate();
                          }
                        },
                        child: Text('Transfer'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MpesaTo extends StatefulWidget {
  @override
  _MpesaToState createState() => _MpesaToState();
}

class _MpesaToState extends State<MpesaTo> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authorized = 'Not Authorized';
  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
    if (_authorized == 'Authorized') {
      _processing = true;
      sendFunds().whenComplete(
        () {
          setState(() {
            _processing = false;
          });
        },
      );
    }
  }

  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController phoneNumber;
  TextEditingController amount;
  CollectionReference users = FirebaseFirestore.instance.collection('users');
  String _username;
  String _phone;
  int _mpesa;
  int _equity;
  int _kcb;
  int _totalfunds;
  getUserInfo() async {
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

  String selectedBank;
  List<String> banks = [
    'Mpesa',
    'Equity Bank',
    'KCB Bank',
  ];
  int remainmpesa;
  int senttompesaCurrentBalance;
  int senttompesaNewBalance;
  int remainkcb;
  int senttokcbCurrentBalance;
  int senttokcbNewBalance;
  int remainequity;
  int senttoequityCurrentBalance;
  int senttoequityNewBalance;
  Future sendFunds() async {
    if (phoneNumber.text.toString() == _phone) {
      Fluttertoast.showToast(
        msg: "Cannot send money to yourself",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    } else {
      QuerySnapshot resultQuery = await users
          .where('phone_number', isEqualTo: phoneNumber.text.toString())
          .get();
      final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;
      if (_documentSnapshots.length == 0) {
        Fluttertoast.showToast(
          msg: "Account does not exists",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 40,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 15.0,
        );
      } else {
        if (selectedBank == 'Mpesa') {
          if (_mpesa > int.parse(amount.text)) {
            setState(() {
              remainmpesa = _mpesa - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'mpesa_balance': remainmpesa,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttompesaCurrentBalance = value.data()['mpesa_balance'];
                    });
                  },
                );
                setState(() {
                  senttompesaNewBalance =
                      senttompesaCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'mpesa_balance': senttompesaNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'MPESA',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'MPESA',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
        if (selectedBank == 'Equity Bank') {
          if (_equity > int.parse(amount.text)) {
            setState(() {
              remainequity = _equity - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'equity_balance': remainequity,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttompesaCurrentBalance = value.data()['mpesa_balance'];
                    });
                  },
                );
                setState(() {
                  senttompesaNewBalance =
                      senttompesaCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'mpesa_balance': senttompesaNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'MPESA',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'MPESA',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
        if (selectedBank == 'KCB Bank') {
          if (_kcb > int.parse(amount.text)) {
            setState(() {
              remainkcb = _kcb - int.parse(amount.text);
            });
            users.doc(docID).update(
              {
                'kcb_balance': remainkcb,
              },
            ).then(
              (value) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .get()
                    .then(
                  (value) {
                    setState(() {
                      senttokcbCurrentBalance = value.data()['kcb_balance'];
                    });
                  },
                );
                setState(() {
                  senttokcbNewBalance =
                      senttokcbCurrentBalance + int.parse(amount.text);
                });
                users.doc(phoneNumber.text.toString()).update(
                  {
                    'kcb_balance': senttokcbNewBalance,
                  },
                );
              },
            ).then(
              (value) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(docID.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'MPESA',
                  },
                );
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(phoneNumber.text.toString())
                    .collection('logs')
                    .doc()
                    .set(
                  {
                    'time': FieldValue.serverTimestamp(),
                    'sender': docID.toString(),
                    'receiver': phoneNumber.text.toString(),
                    'amount': amount.text.toString(),
                    'bank_from': selectedBank.toString(),
                    'bank_to': 'MPESA',
                  },
                );
              },
            ).whenComplete(
              () {
                setState(() {
                  getUserInfo();
                  Navigator.pop(context);
                  phoneNumber.text = '';
                  amount.text = '';
                });
                Fluttertoast.showToast(
                  msg: "Funds received",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 40,
                  backgroundColor: Colors.blueAccent,
                  textColor: Colors.white,
                  fontSize: 15.0,
                );
              },
            );
          }
        }
      }
    }
  }

  @override
  void initState() {
    phoneNumber = TextEditingController();
    amount = TextEditingController();
    super.initState();
    getUserDocID().then(
      (value) {
        getUserInfo();
      },
    );
  }

  bool _processing = false;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        leading: CloseButton(
          color: Colors.black,
        ),
        centerTitle: true,
        title: Text(
          'Transfer Funds',
          style: TextStyle(
            color: Colors.black,
            fontSize: 15,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(
                        10.0,
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Current balance :',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Flexible(
                            child: Container(),
                          ),
                          selectedBank == 'Mpesa'
                              ? Text(
                                  'Ksh $_mpesa'.toString(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : selectedBank == 'KCB Bank'
                                  ? Text(
                                      'Ksh $_kcb'.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : selectedBank == 'Equity Bank'
                                      ? Text(
                                          'Ksh $_equity'.toString(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : Text('Pick a bank'),
                        ],
                      ),
                    ),
                  ),
                  Form(
                    key: formkey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Funds from : ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            DropdownButton<String>(
                              hint: Text('Select Bank'),
                              value: selectedBank,
                              items: banks.map((String value) {
                                return new DropdownMenuItem<String>(
                                  value: value,
                                  child: new Text(value),
                                );
                              }).toList(),
                              onChanged: (String val) {
                                setState(() {
                                  selectedBank = val;
                                });
                              },
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: TextFormField(
                            controller: phoneNumber,
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "account number is needed";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                                labelText:
                                    'Receiver account number (07.........)'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                          ),
                          child: TextFormField(
                            controller: amount,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Amount is needed";
                              }

                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Amount',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 20,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formkey.currentState.validate()) {
                            _authenticate();
                          }
                        },
                        child: Text('Transfer'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
