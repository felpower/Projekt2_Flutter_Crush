import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class SlotMachine extends StatefulWidget {
  const SlotMachine({Key? key}) : super(key: key);

  @override
  State<SlotMachine> createState() => _SlotMachineState();
}

class _SlotMachineState extends State<SlotMachine> {
  final List<String> items = ["🍎", "🍋", "🍇", "🍉", "🍒"];

  final List<ScrollController> controllers = [
    ScrollController(),
    ScrollController(),
    ScrollController()
  ];
  List<String> result = ["", "", ""];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Slot Machine")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: controllers.map((controller) {
                return SizedBox(
                  height: 60,
                  width: 60,
                  child: ListView.builder(
                    controller: controller,
                    itemExtent: 60,
                    itemBuilder: (context, index) {
                      return Center(child: Text(items[index % items.length], style: const TextStyle(fontSize: 50)));
                    },
                  ),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: spin,
              child: const Text("Spin"),
            )
          ],
        ),
      ),
    );
  }

  void spin() {
    final random = Random();

    Future.delayed(Duration(seconds: 2), () {
      // After spinning, retrieve the result
      retrieveResult();
    });

    for (var controller in controllers) {
      final position = controller.position;
      final offset = position.pixels + (500 + random.nextInt(1500));
      controller.animateTo(offset, duration: Duration(seconds: 2), curve: Curves.easeOutCubic);
    }
  }

  void retrieveResult() {
    List<String> results = [];
    for (var controller in controllers) {
      int resultIndex = (controller.offset / 60).round() % items.length;
      results.add(items[resultIndex]);
    }

    // This will print the result. You can do anything with this result.
    print(results);

    // Example: show a dialog with the result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Result'),
        content: Text(results.join(' - ')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

}
