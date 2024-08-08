import 'package:flutter/material.dart';

import '../api/apis.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(APIs.me.name),
      ),
    );
  }
}
