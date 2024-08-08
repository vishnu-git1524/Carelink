import 'dart:async';

import 'package:flutter/material.dart';

import '../../api/apis.dart';
import '../home.dart';

class VerificationScreen extends StatefulWidget {
  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  late Timer timer;
  bool isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startEmailVerification();
  }

  void _startEmailVerification() {
    setState(() {
      isVerifying = true;
    });
    APIs.auth.currentUser!.sendEmailVerification();
    timer = Timer.periodic(Duration(seconds: 5), (timer) {
      APIs.auth.currentUser!.reload();
      if (APIs.auth.currentUser!.emailVerified) {
        timer.cancel();
        setState(() {
          isVerifying = false;
        });
        Future.delayed(Duration(seconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => Home()),
            (Route<dynamic> route) => false,
          );
        });
      }
    });
  }

  void _resendVerificationLink() {
    APIs.auth.currentUser!.sendEmailVerification();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Verify Your Email'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.verified_user,
              size: 80,
              color: Colors.lightBlue,
            ),
            SizedBox(height: 30),
            Text(
              'We have sent a verification link to your email. Please click on the link to verify your email address.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 30),
            isVerifying
                ? CircularProgressIndicator(
                    strokeWidth: 2,
                  )
                : Icon(
                    Icons.check_circle_outline,
                    size: 50,
                    color: Colors.green,
                  ),
            SizedBox(height: 30),
            Text(
              "Didn't receive the email?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: _resendVerificationLink,
              child: Text(
                'Resend Verification Link',
                style: TextStyle(color: Colors.blueGrey),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
