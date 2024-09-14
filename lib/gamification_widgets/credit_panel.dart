import 'package:flutter/material.dart';

class CreditPanel extends StatelessWidget {
  const CreditPanel(this.text, this.paddingTop, this.width, {Key? key})
      : super(key: key);
  final String text;
  final double paddingTop;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        var snackBar = text.contains("XP")
            ? const SnackBar(
                content: Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        'XP werden genutzt um im HighScore(siehe',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 5), // Add this line
                      Icon(Icons.emoji_events, color: Colors.blue),
                      Text(
                        ' oben rechts)',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        ' voranzukommen!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              )
            : const SnackBar(
                content: Text(
                    'Die 🪙 können benutzt werden um im Shop Items zu kaufen oder um Levels '
                    'freizuschalten!',
                    textAlign: TextAlign.center));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      },
      child: Padding(
        padding:
            EdgeInsets.only(top: paddingTop, left: 10, right: 10, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300]?.withOpacity(0.7),
            borderRadius: BorderRadius.circular(30.0),
            border:
                Border.all(width: 5.0, color: Colors.black.withOpacity(0.5)),
          ),
          height: 80,
          width: width,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
