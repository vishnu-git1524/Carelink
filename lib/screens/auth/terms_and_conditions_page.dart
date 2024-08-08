import 'package:flutter/material.dart';

class TermsAndConditionsPage extends StatelessWidget {
  final String appName;

  TermsAndConditionsPage({required this.appName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Terms and Conditions"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Terms and Conditions for $appName",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "By using this $appName, you agree to be bound by these terms and conditions. Please read them carefully before using the $appName.",
              ),
              SizedBox(height: 16),
              Text(
                "1. Acceptance of Terms\n\n"
                "By accessing or using the $appName, you agree to be legally bound by these terms and conditions. If you do not agree with any of these terms, you are prohibited from using or accessing the $appName.",
              ),
              SizedBox(height: 16),
              Text(
                "2. Use of the $appName\n\n"
                "The $appName is provided for personal use only. You may not use it for any commercial purposes without the express written consent of the developer.",
              ),
              SizedBox(height: 16),
              Text(
                "3. User Content\n\n"
                "You are solely responsible for any content you post or share on the $appName. By posting or sharing content, you grant the $appName non-exclusive, worldwide, royalty-free, and sublicensable rights to use, modify, reproduce, display, and distribute the content.",
              ),
              SizedBox(height: 16),
              Text(
                "4. Privacy\n\n"
                "Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and disclose information.",
              ),
              SizedBox(height: 16),
              Text(
                "5. Changes to Terms\n\n"
                "We reserve the right to modify or replace these terms and conditions at any time. It is your responsibility to review this page periodically for changes. Your continued use of the $appName after any changes constitutes acceptance of those changes.",
              ),
              SizedBox(height: 16),
              Text(
                "6. Contact Us\n\n"
                "If you have any questions or suggestions about these terms and conditions, please contact us at vishnuvenkat1524@gmail.com.",
              ),
              SizedBox(height: 16),
              Text(
                "Last Updated: ${DateTime.now().toString().substring(0, 10)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
