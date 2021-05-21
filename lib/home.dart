import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:team_project/screens/account.dart';
import 'package:team_project/screens/home.dart';
import 'package:team_project/screens/notification.dart';
import 'package:team_project/screens/statements.dart';
import 'package:team_project/screens/transact.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey[500],
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
                Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.double_arrow_outlined,
              ),
              label: 'Transact',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.notifications_none_outlined,
              ),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.person_outline,
              ),
              label: 'Account',
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: pageIndex,
            children: <Widget>[
              HomeScreen(),
              TransactScreen(),
              NotificationScreen(),
              Account(),
            ],
          ),
        ),
      ),
    );
  }
}
