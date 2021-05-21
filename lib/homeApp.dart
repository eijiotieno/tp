import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:team_project/createAccount.dart';

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  CollectionReference akibaBank =
      FirebaseFirestore.instance.collection('Akiba_Bank');
  TextEditingController phoneNumber;
  TextEditingController amount;

  int _akibabalance;
  bool _hasAkibaAccount = false;
  Future getAkibaBankInfo() async {
    akibaBank.doc(FirebaseAuth.instance.currentUser.uid.toString()).get().then(
      (value) {
        setState(() {
          _hasAkibaAccount = true;
          _akibabalance = value.data()['balance'];
        });
      },
    );
  }

  int _akibaremainingAmount;
  int _akibareceiverNewAmount;
  int _akibasentToBalance;
  sendFundsAkiba() async {
    if (phoneNumber.text.toString() !=
        FirebaseAuth.instance.currentUser.uid.toString()) {
      QuerySnapshot resultQuery = await akibaBank
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
        if (_akibabalance > int.parse(amount.text)) {
          setState(() {
            _akibaremainingAmount = _akibabalance - int.parse(amount.text);
          });
          akibaBank.doc(FirebaseAuth.instance.currentUser.uid).update(
            {
              'balance': _akibaremainingAmount,
            },
          ).then(
            (value) async {
              await akibaBank.doc(phoneNumber.text.toString()).get().then(
                (value) {
                  setState(() {
                    _akibasentToBalance = value.data()['balance'];
                  });
                },
              );
              setState(() {
                _akibareceiverNewAmount =
                    _akibasentToBalance + int.parse(amount.text);
              });
              akibaBank.doc(phoneNumber.text.toString()).update(
                {
                  'balance': _akibareceiverNewAmount,
                },
              );
            },
          ).whenComplete(
            () {
              setState(() {
                getAkibaBankInfo();
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

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  CollectionReference citisenBank =
      FirebaseFirestore.instance.collection('Citizen_Bank');
  TextEditingController _phoneNumber;
  TextEditingController _amount;

  int _citizenbalance;
  bool _hasCitizenAccount = false;
  Future getCitizenBankInfo() async {
    citisenBank
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .get()
        .then(
      (value) {
        setState(() {
          _hasCitizenAccount = true;
          _citizenbalance = value.data()['balance'];
        });
      },
    );
  }

  String _username;
  String _email;
  getUserInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid.toString())
        .get()
        .then(
      (value) {
        setState(() {
          _username = value.data()['userName'];
          _email = value.data()['email'];
        });
      },
    );
  }

  int _citizenremainingAmount;
  int _citizenreceiverNewAmount;
  int _citizensentToBalance;
  sendFundsCitizen() async {
    if (phoneNumber.text.toString() !=
        FirebaseAuth.instance.currentUser.uid.toString()) {
      QuerySnapshot resultQuery = await citisenBank
          .where('phone_number', isEqualTo: _phoneNumber.text.toString())
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
        if (_citizenbalance > int.parse(amount.text)) {
          setState(() {
            _citizenremainingAmount = _citizenbalance - int.parse(_amount.text);
          });
          citisenBank.doc(FirebaseAuth.instance.currentUser.uid).update(
            {
              'balance': _citizenremainingAmount,
            },
          ).then(
            (value) async {
              await citisenBank.doc(_phoneNumber.text.toString()).get().then(
                (value) {
                  setState(() {
                    _citizensentToBalance = value.data()['balance'];
                  });
                },
              );
              setState(() {
                _citizenreceiverNewAmount =
                    _citizensentToBalance + int.parse(amount.text);
              });
              citisenBank.doc(_phoneNumber.text.toString()).update(
                {
                  'balance': _citizenreceiverNewAmount,
                },
              );
            },
          ).whenComplete(
            () {
              setState(() {
                getCitizenBankInfo();
                Navigator.pop(context);
                _phoneNumber.text = '';
                _amount.text = '';
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
    phoneNumber = TextEditingController();
    amount = TextEditingController();
    _phoneNumber = TextEditingController();
    _amount = TextEditingController();
    super.initState();
    getAkibaBankInfo();
    getCitizenBankInfo();
    getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            getAkibaBankInfo();
            getCitizenBankInfo();
            getUserInfo();
            print('refresh');
          },
          child: Icon(
            Icons.refresh_outlined,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Text(
                                  '$_username',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Icon(
                          Icons.account_circle_outlined,
                          size: 45,
                        ),
                      ),
                      Flexible(
                        child: Container(),
                      ),
                      GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                  'Choose a bank',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                                content: Wrap(
                                  children: [
                                    _hasAkibaAccount == true
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return AkibaAccountCreate();
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 10,
                                                    horizontal: 5,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Akiba group bank',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Container(),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Already have a Citizen Bank account',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                    Flexible(
                                      child: Container(),
                                    ),
                                    _hasCitizenAccount == true
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 2,
                                            ),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) {
                                                      return CitizenBankAccountCreate();
                                                    },
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    vertical: 10,
                                                    horizontal: 5,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        'Citizen bank',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      Flexible(
                                                        child: Container(),
                                                      ),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color: Colors.black,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Already have a Akiba Bank account',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ],
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Close'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Create funds account',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Akiba group funds',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Ksh. $_akibabalance'.toString(),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 40,
                                              ),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
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
                                        'Transfer Funds(Akiba Bank)',
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                      10.0,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Current balance :',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Container(),
                                                        ),
                                                        Text(
                                                          'Ksh $_akibabalance'
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 0,
                                                        ),
                                                        child: TextFormField(
                                                          controller:
                                                              phoneNumber,
                                                          autofocus: true,
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                          validator: (value) {
                                                            if (value.isEmpty) {
                                                              return "Phone number is needed";
                                                            }

                                                            return null;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Receiver phone number(07.........)',
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 0,
                                                        ),
                                                        child: TextFormField(
                                                          controller: amount,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          validator: (value) {
                                                            if (value.isEmpty) {
                                                              return "Amount is needed";
                                                            }

                                                            return null;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: 'Amount',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 20,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (formkey.currentState
                                                            .validate()) {
                                                          sendFundsAkiba();
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
                                },
                              );
                            },
                            child: Text(
                              'Transfer funds',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          child: Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Citizen bank funds',
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 30,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Container(),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 20,
                                          ),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Ksh. $_citizenbalance',
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontSize: 40,
                                              ),
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
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
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
                                        'Transfer Funds(Citizen Bank)',
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
                                                    padding:
                                                        const EdgeInsets.all(
                                                      10.0,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          'Current balance :',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        Flexible(
                                                          child: Container(),
                                                        ),
                                                        Text(
                                                          'Ksh $_akibabalance'
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Form(
                                                  key: _formkey,
                                                  child: Column(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 0,
                                                        ),
                                                        child: TextFormField(
                                                          controller:
                                                              _phoneNumber,
                                                          autofocus: true,
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                          validator: (value) {
                                                            if (value.isEmpty) {
                                                              return "Phone number is needed";
                                                            }

                                                            return null;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                'Receiver phone number(07.........)',
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 0,
                                                        ),
                                                        child: TextFormField(
                                                          controller: _amount,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          validator: (value) {
                                                            if (value.isEmpty) {
                                                              return "Amount is needed";
                                                            }

                                                            return null;
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            labelText: 'Amount',
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 10,
                                                    vertical: 20,
                                                  ),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        if (formkey.currentState
                                                            .validate()) {
                                                          sendFundsCitizen();
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
                                },
                              );
                            },
                            child: Text(
                              'Transfer funds',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // SliverToBoxAdapter(
              //   child: Align(
              //     alignment: Alignment.centerLeft,
              //     child: Text(
              //       'Logs',
              //       overflow: TextOverflow.ellipsis,
              //       maxLines: 3,
              //       style: TextStyle(
              //         fontWeight: FontWeight.bold,
              //         color: Colors.black,
              //         fontSize: 30,
              //       ),
              //     ),
              //   ),
              // ),
              // SliverList(
              //   delegate: SliverChildBuilderDelegate(
              //     (BuildContext context, int index) {
              //       return Container(
              //         child: Column(
              //           children: [
              //             Align(
              //               alignment: Alignment.centerLeft,
              //               child: Text(
              //                 snapshot.data.docs[index].data()['email'],
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     },
              //     childCount: snapshot.data.docs.length,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
