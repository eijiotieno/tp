// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:team_project/finalsCode/akibabank.dart';
// import 'package:team_project/finalsCode/citizenbank.dart';
// import 'package:team_project/finalsCode/pickBanktoSend.dart';
// import 'package:team_project/finalsCode/transferfunds.dart';

// class FinalHome extends StatefulWidget {
//   @override
//   _FinalHomeState createState() => _FinalHomeState();
// }

// class _FinalHomeState extends State<FinalHome> {
//   CollectionReference users = FirebaseFirestore.instance.collection('users');
//   String _username;
//   String _phone;
//   int _mpesa;
//   int _equity;
//   int _kcb;
//   int _totalfunds;
//   Future getUserInfo() async {
//     users.doc(docID).get().then(
//       (value) {
//         setState(() {
//           _username = value.data()['userName'];
//           _phone = value.data()['phone_number'];
//           _mpesa = value.data()['mpesa_balance'];
//           _equity = value.data()['equity_balance'];
//           _kcb = value.data()['kcb_balance'];
//           _totalfunds = _equity + _kcb + _mpesa;
//         });
//       },
//     );
//   }

//   // List<Map<String, dynamic>> logs = [];
//   // Future getLogs() async {
//   //   FirebaseFirestore.instance
//   //       .collection('users')
//   //       .doc(docID)
//   //       .collection('logs')
//   //       .doc()
//   //       .get()
//   //       .then(
//   //     (value) {
//   //       setState(() {
//   //         logs.add(
//   //           {
//   //             // '_time': value.data()['accountCreated'],
//   //             '_amount': value.data()['email'],
//   //           },
//   //         );
//   //       });
//   //     },
//   //   );
//   // }

//   String docID;
//   Future getUserDocID() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     //Return int
//     String stringValue = prefs.getString('phone_number');
//     setState(() {
//       docID = stringValue;
//     });
//     return stringValue;
//   }

//   @override
//   void initState() {
//     super.initState();
//     getUserDocID().then(
//       (value) {
//         getUserInfo();
//       },
//     );
//   }

//   // final Stream<QuerySnapshot> _usersStream =
//   //     FirebaseFirestore.instance.collection('users').doc(docID.toString()).collection('logs').snapshots();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         floatingActionButton: FloatingActionButton(
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (context) {
//                   return PickBank();
//                 },
//               ),
//             );
//           },
//           child: Icon(
//             Icons.arrow_forward,
//           ),
//         ),
//         body: CustomScrollView(
//           slivers: [
//             SliverToBoxAdapter(
//               child: Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Container(
//                       child: Column(
//                         children: [
//                           Text(
//                             'Total Funds',
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                           Text(
//                             'KSH. $_totalfunds',
//                             style: TextStyle(
//                               fontSize: 40,
//                               fontWeight: FontWeight.w300,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   Container(
//                     height: MediaQuery.of(context).size.height * 0.35,
//                     child: ListView(
//                       scrollDirection: Axis.horizontal,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             top: 10,
//                             bottom: 10,
//                             left: 10,
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return Scaffold(
//                                     appBar: AppBar(
//                                       elevation: 1,
//                                       backgroundColor: Colors.white,
//                                       leading: CloseButton(
//                                         color: Colors.black,
//                                       ),
//                                       centerTitle: true,
//                                       title: Text(
//                                         'Mpesa logs',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                     ),
//                                     body: StreamBuilder<QuerySnapshot>(
//                                       stream: FirebaseFirestore.instance
//                                           .collection('users')
//                                           .doc(docID.toString())
//                                           .collection('logs')
//                                           .where(
//                                             'sender',
//                                             isEqualTo: docID.toString(),
//                                           )
//                                           .snapshots(),
//                                       builder: (BuildContext context,
//                                           AsyncSnapshot<QuerySnapshot>
//                                               snapshot) {
//                                         if (snapshot.hasError) {
//                                           return Text('Something went wrong');
//                                         }

//                                         if (snapshot.connectionState ==
//                                             ConnectionState.waiting) {
//                                           return Text("Loading");
//                                         }

//                                         return new ListView(
//                                           children: snapshot.data.docs
//                                               .map((DocumentSnapshot document) {
//                                             DateTime myDateTime =
//                                                 (document.data()['time'])
//                                                     .toDate();
//                                             return new ListTile(
//                                               title: Row(
//                                                 children: [
//                                                   document
//                                                               .data()['sender']
//                                                               .toString() ==
//                                                           docID.toString()
//                                                       ? Text(
//                                                           document
//                                                               .data()[
//                                                                   'bank_from']
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         )
//                                                       : Text(
//                                                           document
//                                                               .data()['bank_to']
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                   Text(
//                                                     '.',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 16,
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                   Text(
//                                                     DateFormat.yMMMd()
//                                                         .add_jm()
//                                                         .format(myDateTime),
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 16,
//                                                       color: Colors.blue,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                               subtitle: Wrap(
//                                                 children: [
//                                                   Text(
//                                                     'Confirmed your have ',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontSize: 16,
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                   document
//                                                               .data()['sender']
//                                                               .toString() ==
//                                                           docID.toString()
//                                                       ? Text(
//                                                           'sent KSH. ',
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         )
//                                                       : Text(
//                                                           'received KSH. ',
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                   Text(
//                                                     document
//                                                         .data()['amount']
//                                                         .toString(),
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 16,
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                   document
//                                                               .data()['sender']
//                                                               .toString() ==
//                                                           docID.toString()
//                                                       ? Text(
//                                                           ' to ',
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         )
//                                                       : Text(
//                                                           ' from ',
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.w600,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                   document
//                                                               .data()['sender']
//                                                               .toString() ==
//                                                           docID.toString()
//                                                       ? Text(
//                                                           document
//                                                               .data()[
//                                                                   'bank_to']
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         )
//                                                       : Text(
//                                                           document
//                                                               .data()['bank_from']
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 16,
//                                                             color: Colors.black,
//                                                           ),
//                                                         ),
//                                                   Text(
//                                                     ' ',
//                                                     style: TextStyle(
//                                                       fontWeight:
//                                                           FontWeight.w600,
//                                                       fontSize: 16,
//                                                       color: Colors.black,
//                                                     ),
//                                                   ),
//                                                   document
//                                                               .data()['sender']
//                                                               .toString() !=
//                                                           docID.toString()
//                                                       ? new Text(
//                                                           document
//                                                               .data()['sender']
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 18,
//                                                             color: Colors.black,
//                                                           ),
//                                                         )
//                                                       : Text(
//                                                           document
//                                                               .data()[
//                                                                   'receiver']
//                                                               .toString(),
//                                                           style: TextStyle(
//                                                             fontWeight:
//                                                                 FontWeight.bold,
//                                                             fontSize: 18,
//                                                             color: Colors.black,
//                                                           ),
//                                                         )
//                                                 ],
//                                               ),
//                                             );
//                                           }).toList(),
//                                         );
//                                       },
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.9,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Colors.grey[300],
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(15.0),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       'Mpesa funds',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     ),
//                                     Flexible(
//                                       child: Container(),
//                                     ),
//                                     Text(
//                                       'KSH. $_mpesa',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             top: 10,
//                             bottom: 10,
//                             left: 10,
//                             right: 10,
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               // Navigator.push(
//                               //   context,
//                               //   MaterialPageRoute(
//                               //     builder: (context) {
//                               //       return Citizen();
//                               //     },
//                               //   ),
//                               // );
//                             },
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.9,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Colors.grey[300],
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(15.0),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       'KCB funds',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     ),
//                                     Flexible(
//                                       child: Container(),
//                                     ),
//                                     Text(
//                                       'KSH. $_kcb',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(
//                             top: 10,
//                             bottom: 10,
//                             left: 10,
//                             right: 10,
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               // Navigator.push(
//                               //   context,
//                               //   MaterialPageRoute(
//                               //     builder: (context) {
//                               //       return Citizen();
//                               //     },
//                               //   ),
//                               // );
//                             },
//                             child: Container(
//                               width: MediaQuery.of(context).size.width * 0.9,
//                               decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(10),
//                                 border: Border.all(
//                                   color: Colors.grey[300],
//                                 ),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(15.0),
//                                 child: Column(
//                                   children: [
//                                     Text(
//                                       'Equity funds',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     ),
//                                     Flexible(
//                                       child: Container(),
//                                     ),
//                                     Text(
//                                       'KSH. $_equity',
//                                       style: TextStyle(
//                                         fontSize: 40,
//                                         fontWeight: FontWeight.w300,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
