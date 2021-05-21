import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ionicons/ionicons.dart';

class TransactScreen extends StatefulWidget {
  @override
  _TransactScreenState createState() => _TransactScreenState();
}

class _TransactScreenState extends State<TransactScreen> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController accountToID;
  TextEditingController amount;
  CollectionReference bitcoinBank =
      FirebaseFirestore.instance.collection('bitcoin');
  CollectionReference kenyaBank =
      FirebaseFirestore.instance.collection('kenyaBank');
  int _bitcoinbalance;
  Future getBankBInfo() async {
    FirebaseFirestore.instance
        .collection('bitcoin')
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .get()
        .then(
      (value) {
        setState(() {
          _bitcoinbalance = value.data()['balance'];
        });
      },
    );
  }

  int remainingAmount;
  int receiverNewAmount;
  int sentToBalance;
  sendBitcoins() async {
    if (accountToID.text.toString() !=
        FirebaseAuth.instance.currentUser.uid.toString()) {
      QuerySnapshot resultQuery = await bitcoinBank
          .where('accountID', isEqualTo: accountToID.text.toString())
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
        if (_bitcoinbalance > int.parse(amount.text)) {
          setState(() {
            remainingAmount = _bitcoinbalance - int.parse(amount.text);
          });
          bitcoinBank.doc(FirebaseAuth.instance.currentUser.uid).update(
            {
              'balance': remainingAmount,
            },
          ).then(
            (value) async {
              await FirebaseFirestore.instance
                  .collection('bitcoin')
                  .doc(accountToID.text.toString())
                  .get()
                  .then(
                (value) {
                  setState(() {
                    sentToBalance = value.data()['balance'];
                  });
                },
              );
              setState(() {
                receiverNewAmount = sentToBalance + int.parse(amount.text);
              });
              bitcoinBank.doc(accountToID.text.toString()).update(
                {
                  'balance': receiverNewAmount,
                },
              );
            },
          ).whenComplete(
            () {
              setState(() {
                getBankBInfo();
                Navigator.pop(context);
                accountToID.text = '';
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
        } else {
          Fluttertoast.showToast(
            msg: "Insuffient funds",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 40,
            backgroundColor: Colors.redAccent,
            textColor: Colors.white,
            fontSize: 15.0,
          );
        }
      }
    } else {
      Fluttertoast.showToast(
        msg: "Cannot send money to yourself",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    }
  }

  @override
  void initState() {
    amount = TextEditingController();
    accountToID = TextEditingController();
    super.initState();
    getBankBInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Transact'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Create an account :',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        QuerySnapshot resultQuery = await bitcoinBank
                            .where('accountID',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser.uid)
                            .get();
                        final List<DocumentSnapshot> _documentSnapshots =
                            resultQuery.docs;
                        if (_documentSnapshots.length == 0) {
                          bitcoinBank
                              .doc(FirebaseAuth.instance.currentUser.uid)
                              .set(
                            {
                              'accountID':
                                  FirebaseAuth.instance.currentUser.uid,
                              'balance': 0,
                              'accountCreated': FieldValue.serverTimestamp(),
                            },
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Already have an account",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 40,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 15.0,
                          );
                        }
                      },
                      child: Text('Bitcoin'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        QuerySnapshot resultQuery = await kenyaBank
                            .where('accountID',
                                isEqualTo:
                                    FirebaseAuth.instance.currentUser.uid)
                            .get();
                        final List<DocumentSnapshot> _documentSnapshots =
                            resultQuery.docs;
                        if (_documentSnapshots.length == 0) {
                          kenyaBank
                              .doc(FirebaseAuth.instance.currentUser.uid)
                              .set(
                            {
                              'accountID':
                                  FirebaseAuth.instance.currentUser.uid,
                              'balance': 0,
                              'accountCreated': FieldValue.serverTimestamp(),
                            },
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: "Already have an account",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 40,
                            backgroundColor: Colors.blue,
                            textColor: Colors.white,
                            fontSize: 15.0,
                          );
                        }
                      },
                      child: Text('KenyaBank'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Transfer funds :',
                      style: TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
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
                                  'Transfer Bitcoins',
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
                                            'Current balance :',
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
                                  Form(
                                    key: formkey,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: TextFormField(
                                            controller: accountToID,
                                            validator: (value) {
                                              if (value.isEmpty) {
                                                return "AccountID sending to is needed";
                                              }

                                              return null;
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Receiver acountID',
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
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
                                              hintText: 'Amount',
                                            ),
                                          ),
                                        ),
                                      ],
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
                                            sendBitcoins();
                                          }
                                        },
                                        child: Text('Transfer'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text('Bitcoin'),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text('KenyaBank'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
