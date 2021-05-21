
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:team_project/homeApp.dart';
import 'package:team_project/tp/hometp.dart';
import 'package:team_project/tp/honepagetp.dart';

class LocalAuth extends StatefulWidget {
  @override
  _LocalAuthState createState() => _LocalAuthState();
}

class _LocalAuthState extends State<LocalAuth> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

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
      Navigator.pushReplacement(
        this.context,
        MaterialPageRoute(
          builder: (context) {
            return Hometp();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Flexible(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 50,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Verify with fingerprint ...',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: _authenticate,
                child: Icon(
                  Icons.fingerprint_outlined,
                  size: 100,
                  color: Colors.blueAccent,
                ),
              ),
            ),
            Flexible(
              child: Container(),
            ),
          ],
        ),
        // ConstrainedBox(
        //   constraints: const BoxConstraints.expand(),
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.spaceAround,
        //     children: <Widget>[
        //       Text('Can check biometrics: $_canCheckBiometrics\n'),
        //       RaisedButton(
        //         child: const Text('Check biometrics'),
        //         onPressed: _checkBiometrics,
        //       ),
        //       Text('Available biometrics: $_availableBiometrics\n'),
        //       RaisedButton(
        //         child: const Text('Get available biometrics'),
        //         onPressed: _getAvailableBiometrics,
        //       ),
        //       Text('Current State: $_authorized\n'),
        //       RaisedButton(
        //         child: const Text('Authenticate'),
        //         onPressed: _authenticate,
        //       )
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
