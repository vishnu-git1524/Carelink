import 'package:flutter/material.dart';

class Dialogs {
  static void showSnackBar(
    BuildContext context,
    String msg,
  ) {
    // final snackBar = SnackBar(
    //   content: Text(
    //     msg,
    //     style: TextStyle(color: Colors.black), // Change text color to black
    //   ),
    //   backgroundColor:
    //       Colors.lightBlue[200], // Change background color to light blue
    //   behavior: SnackBarBehavior.floating,
    //   margin: EdgeInsets.all(16),
    //   showCloseIcon: true,
    //   closeIconColor: Colors.black, // Change close icon color to black
    //   duration: Duration(seconds: 3),
    // );

    // ScaffoldMessenger.of(context).showSnackBar(snackBar);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.info, color: Colors.white),
          SizedBox(width: 8),
          Expanded(child: Text(msg)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.blue[200],
      margin: EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showProgressBar(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
                child: CircularProgressIndicator(
              strokeWidth: 2,
            )));
  }
}
