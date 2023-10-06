import 'package:flutter/material.dart';

import '../pages/feedback_page.dart';

class FeedbackPageButton extends StatelessWidget {
  const FeedbackPageButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 0),
      child: IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FeedbackPage()));
          },
          icon: const Icon(Icons.feedback)),
    );
  }
}
