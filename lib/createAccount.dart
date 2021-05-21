import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AkibaAccountCreate extends StatefulWidget {
  @override
  _AkibaAccountCreateState createState() => _AkibaAccountCreateState();
}

class _AkibaAccountCreateState extends State<AkibaAccountCreate> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  CollectionReference akibaBank =
      FirebaseFirestore.instance.collection('Akiba_Bank');
  TextEditingController phoneNumber;
  TextEditingController nationalID;

  @override
  void initState() {
    phoneNumber = TextEditingController();
    nationalID = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: CloseButton(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            'Akiba Bank',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: phoneNumber,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Phone number is needed";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone number(07........)',
                        ),
                      ),
                      TextFormField(
                        controller: nationalID,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "NationalID number is needed";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'NationalID number',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState.validate()) {
                                QuerySnapshot resultQuery = await akibaBank
                                    .where('accountID',
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser.uid)
                                    .get();
                                final List<DocumentSnapshot>
                                    _documentSnapshots = resultQuery.docs;
                                if (_documentSnapshots.length == 0) {
                                  akibaBank
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .set(
                                    {
                                      'phone_number': phoneNumber.text,
                                      'nationalID': nationalID.text,
                                      'accountID':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'balance': 1000,
                                      'accountCreated':
                                          FieldValue.serverTimestamp(),
                                    },
                                  ).whenComplete(
                                    () {
                                      phoneNumber.text = '';
                                      nationalID.text = '';
                                      Navigator.pop(context);
                                      Navigator.pop(context);
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
                              }
                            },
                            child: Text('Create Account'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CitizenBankAccountCreate extends StatefulWidget {
  @override
  _CitizenBankAccountCreateState createState() =>
      _CitizenBankAccountCreateState();
}

class _CitizenBankAccountCreateState extends State<CitizenBankAccountCreate> {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  CollectionReference citizenBank =
      FirebaseFirestore.instance.collection('Citizen_Bank');
  TextEditingController phoneNumber;
  TextEditingController nationalID;

  @override
  void initState() {
    phoneNumber = TextEditingController();
    nationalID = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: CloseButton(
            color: Colors.black,
          ),
          centerTitle: true,
          title: Text(
            'Citizen Bank',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Form(
                  key: formkey,
                  child: Column(
                    children: [
                      TextFormField(
                        autofocus: true,
                        controller: phoneNumber,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Phone number is needed";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone number(07........)',
                        ),
                      ),
                      TextFormField(
                        controller: nationalID,
                        validator: (value) {
                          if (value.isEmpty) {
                            return "NationalID number is needed";
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'NationalID number',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20,
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formkey.currentState.validate()) {
                                QuerySnapshot resultQuery = await citizenBank
                                    .where('accountID',
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser.uid)
                                    .get();
                                final List<DocumentSnapshot>
                                    _documentSnapshots = resultQuery.docs;
                                if (_documentSnapshots.length == 0) {
                                  citizenBank
                                      .doc(
                                          FirebaseAuth.instance.currentUser.uid)
                                      .set(
                                    {
                                      'phone_number': phoneNumber.text,
                                      'nationalID': nationalID.text,
                                      'accountID':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'balance': 1000,
                                      'accountCreated':
                                          FieldValue.serverTimestamp(),
                                    },
                                  ).whenComplete(
                                    () {
                                      phoneNumber.text = '';
                                      nationalID.text = '';
                                      Navigator.pop(context);
                                      Navigator.pop(context);
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
                              }
                            },
                            child: Text('Create Account'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
