import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransferFunds extends StatefulWidget {
  @override
  _TransferFundsState createState() => _TransferFundsState();
}

class _TransferFundsState extends State<TransferFunds> {
  String selectedBank;
  List<String> banks = [
    'Mpesa',
    'Equity Bank',
    'KCB Bank',
  ];


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
                'Transfer funds',
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
                        'Get funds from : ',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      DropdownButton<String>(
                        hint: Text("Select a bank"),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
