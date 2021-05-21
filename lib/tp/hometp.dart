import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:team_project/tp/accountpagetp.dart';
import 'package:team_project/tp/honepagetp.dart';
import 'package:team_project/tp/logspagetp.dart';
import 'package:team_project/tp/transactpagetp.dart';

class Hometp extends StatefulWidget {
  @override
  _HometpState createState() => _HometpState();
}

class _HometpState extends State<Hometp> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          elevation: 10,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xff5798ee),
          unselectedItemColor: Color(0xff7c7f83),
          type: BottomNavigationBarType.fixed,
          currentIndex: pageIndex,
          onTap: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Ionicons.home_outline,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Ionicons.arrow_forward_outline,
              ),
              label: 'Transact',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Ionicons.list_outline,
              ),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Ionicons.person_circle_outline,
              ),
              label: 'Me',
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: pageIndex,
            children: <Widget>[
              Homepagetp(),
              Transactpagetp(),
              Logspagetp(),
              Accountpagetp(),
            ],
          ),
        ),
      ),
    );
  }
}
