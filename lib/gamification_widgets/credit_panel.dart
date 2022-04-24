import 'package:flutter/material.dart';

class CreditPanel extends StatelessWidget {
  const CreditPanel(this.text,  this.paddingTop, this.width, {Key? key}) : super(key: key);
  final String text;
  final double paddingTop;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: paddingTop, left: 10, right: 10, bottom: 10)
      ,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300]?.withOpacity(0.7),
          borderRadius: BorderRadius.circular(30.0),
          border: Border.all(width: 5.0, color: Colors.black.withOpacity(0.5)),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(color: Colors.black, fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        height: 80,
        width: width,
      ),
    );
  }
}
