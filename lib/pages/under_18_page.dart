import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Under18Page extends StatelessWidget {
  const Under18Page({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    checkSharedPreferences();
    return PopScope(
        canPop: false,
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text('Information'),
            ),
            body: const Text(
                "Vielen Dank für Ihr Interesse an unserer Studie. Leider dürfen aus rechtlichen "
                "Gründen nur Personen mit einem Mindestalter von 18 Jahren an unsere Studie "
                "teilnehmen.")));
  }

  void checkSharedPreferences() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("isUnder18", true);
  }
}
