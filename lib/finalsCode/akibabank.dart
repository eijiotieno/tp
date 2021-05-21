import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Akiba extends StatefulWidget {
  @override
  _AkibaState createState() => _AkibaState();
}

class _AkibaState extends State<Akiba> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  CollectionReference akibaBank =
      FirebaseFirestore.instance.collection('Akiba_Bank');
  CollectionReference citisenBank =
      FirebaseFirestore.instance.collection('Citizen_Bank');
  TextEditingController phoneNumber;
  TextEditingController amount;

  int _akibabalance;
  bool _hasAkibaAccount = false;
  int _phoneAkiba;
  Future getAkibaBankInfo() async {
    akibaBank.doc(FirebaseAuth.instance.currentUser.uid.toString()).get().then(
      (value) {
        setState(() {
          _hasAkibaAccount = true;
          _akibabalance = value.data()['balance'];
          _phoneAkiba = value.data()['phone_number'];
        });
      },
    );
  }

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

  String selectedBank ;
  List<String> banks = [
    'Akiba Bank',
    'Citizen Bank',
  ];

  int _akibaremainingAmount;
  int _akibareceiverNewAmount;
  int _akibasentToBalance;
  sendFunds() async {
    QuerySnapshot resultQuery = await akibaBank
        .where('phone_number', isEqualTo: phoneNumber.text.toString())
        .get();
    final List<DocumentSnapshot> _documentSnapshots = resultQuery.docs;
    if (_documentSnapshots.length == 0) {
      Fluttertoast.showToast(
        msg: "Account does not exist",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    } else {
      if (selectedBank == 'Akiba Bank') {
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

      if (selectedBank == 'Citizen Bank') {
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
              await citisenBank.doc(phoneNumber.text.toString()).get().then(
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
                getCitizenBankInfo();
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
    }
    if (phoneNumber.text.toString() == _phoneAkiba.toString()) {
      Fluttertoast.showToast(
        msg: "Cannot send funds to your own account",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 40,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    }
  }

  @override
  void initState() {
    phoneNumber = TextEditingController();
    amount = TextEditingController();
    super.initState();
    getAkibaBankInfo();
    getCitizenBankInfo();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              leading: CloseButton(
                color: Colors.black,
              ),
              centerTitle: true,
              title: Text(
                'Akiba Bank',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Total Funds : ',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        'KSH. $_akibabalance'.toString(),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () {
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
                                                padding: const EdgeInsets.all(
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
                                                      'KSH. $_akibabalance'
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
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Transfer fund to : ',
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                      DropdownButton<String>(
                                                        hint: Text(
                                                          '$selectedBank',
                                                        ),
                                                        value: selectedBank,
                                                        items: banks.map(
                                                            (String value) {
                                                          return new DropdownMenuItem<
                                                              String>(
                                                            value: value,
                                                            child:
                                                                new Text(value),
                                                          );
                                                        }).toList(),
                                                        onChanged:
                                                            (String val) {
                                                          setState(() {
                                                            selectedBank = val;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 0,
                                                    ),
                                                    child: TextFormField(
                                                      controller: phoneNumber,
                                                      autofocus: true,
                                                      keyboardType:
                                                          TextInputType.phone,
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
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 0,
                                                    ),
                                                    child: TextFormField(
                                                      controller: amount,
                                                      keyboardType:
                                                          TextInputType.number,
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 20,
                                              ),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    if (formkey.currentState
                                                        .validate()) {
                                                      sendFunds();
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.grey[100],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Transfer funds',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Logs',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
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
