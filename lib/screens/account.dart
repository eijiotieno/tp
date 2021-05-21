import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController nm;
  String _username;
  String _dp;
  String _email;
  Future getMyProfile() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .get()
        .then(
      (value) {
        setState(() {
          _username = value.data()['userName'].toString();
          _dp = value.data()['profilePicture'].toString();
          _email = value.data()['email'].toString();
        });
      },
    );
  }

  int _bitcoinbalance;
  String _bitcoinId;
  int _newAmount;
  Future getBankBInfo() async {
    FirebaseFirestore.instance
        .collection('bitcoin')
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .get()
        .then(
      (value) {
        setState(() {
          _bitcoinId = value.data()['accountID'].toString();
          _bitcoinbalance = value.data()['balance'];
        });
      },
    );
  }

  Future depositBitcoins() async {
    if (nm.text.isNotEmpty) {
      setState(() {
        _newAmount = _bitcoinbalance + int.parse(nm.text);
      });
      await FirebaseFirestore.instance
          .collection('bitcoin')
          .doc(FirebaseAuth.instance.currentUser.uid.toString())
          .update(
        {
          'balance': _newAmount,
        },
      ).then(
        (value) {
          Fluttertoast.showToast(
            msg: "Deposit made successful",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.SNACKBAR,
            timeInSecForIosWeb: 40,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
          );
        },
      );
    }
  }

  String _kenyabalance;
  Future getBankKInfo() async {
    FirebaseFirestore.instance
        .collection('kenyaBank')
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .get()
        .then(
      (value) {
        setState(() {
          _kenyabalance = value.data()['balance'].toString();
        });
      },
    );
  }

  @override
  initState() {
    nm = TextEditingController();
    super.initState();
    getMyProfile();
    getBankBInfo();
    getBankKInfo();
  }

  // Future<void> depositBitcoins() async {
  //   await FirebaseFirestore.instance.runTransaction(
  //     (transaction) async {
  //       int newAmount = _bitcoinbalance + _newAmount;
  //       transaction.update(
  //           FirebaseFirestore.instance
  //               .collection('bitcoin')
  //               .doc(FirebaseAuth.instance.currentUser.uid.toString()),
  //           {'balance': newAmount});
  //       return newAmount;
  //     },
  //   ).then(
  //     (value) {
  //       Fluttertoast.showToast(
  //         msg: "Deposit made successful",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.SNACKBAR,
  //         timeInSecForIosWeb: 40,
  //         backgroundColor: Colors.blue,
  //         textColor: Colors.white,
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Column(
                children: [
                  // _dp != null
                  //     ? ClipOval(
                  //         child: Image.network(
                  //           _dp,
                  //         ),
                  //       )
                  //     : SizedBox.shrink(),
                  Text('$_username'),
                  Text('$_email'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Text(
                  'Bank balance',
                  style: TextStyle(
                    fontSize: 25,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Scaffold(
                          appBar: AppBar(
                            elevation: 1,
                            backgroundColor: Colors.white,
                            leading: CloseButton(
                              color: Colors.black,
                            ),
                            centerTitle: true,
                            title: Text(
                              'Bitcoin',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          body: Column(
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
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Account ID:',
                                        style: TextStyle(),
                                      ),
                                      Flexible(
                                        child: Container(),
                                      ),
                                      Text(
                                        '$_bitcoinId',
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 3,
                                        style: TextStyle(
                                          // fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Bitcoin balance :',
                                        style: TextStyle(),
                                      ),
                                      Flexible(
                                        child: Container(),
                                      ),
                                      Icon(
                                        Ionicons.logo_bitcoin,
                                      ),
                                      Text(
                                        '$_bitcoinbalance'.toString(),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Make a deposit :',
                                    style: TextStyle(),
                                  ),
                                ),
                              ),
                              Form(
                                key: formkey,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: TextFormField(
                                    controller: nm,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value.isEmpty) {
                                        return "Amount is needed";
                                      }

                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'Amount',
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (formkey.currentState.validate()) {
                                        depositBitcoins().whenComplete(
                                          () {
                                            setState(() {
                                              getBankBInfo();
                                              Navigator.pop(context);
                                              nm.text = '';
                                            });
                                          },
                                        );
                                      }
                                    },
                                    child: Text('Deposit'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          Text(
                            'Bitcoin',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Flexible(
                            child: Container(),
                          ),
                          _bitcoinbalance != null
                              ? Row(
                                  children: [
                                    Icon(
                                      Ionicons.logo_bitcoin,
                                    ),
                                    Text(
                                      '$_bitcoinbalance',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text("don't have an account"),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey[300],
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      children: [
                        Text(
                          'Kenya Bank',
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Flexible(
                          child: Container(),
                        ),
                        _kenyabalance != null
                            ? Row(
                                children: [
                                  Icon(
                                    Ionicons.cash_outline,
                                  ),
                                  Text(
                                    'KSH. $_kenyabalance',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Text("don't have an account"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
