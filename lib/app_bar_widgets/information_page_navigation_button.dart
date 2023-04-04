import 'package:bachelor_flutter_crush/pages/information_page.dart';
import 'package:flutter/material.dart';

class InformationPageNavigationButton extends StatelessWidget {
  const InformationPageNavigationButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const InformationPage()));
          },
          icon: const Icon(Icons.info_outlined)),
    );
  }
}
