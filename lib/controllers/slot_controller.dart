import 'dart:math';

import 'package:bachelor_flutter_crush/controllers/slot_machine_controller.dart';
import 'package:flutter/material.dart';

class SlotController extends StatefulWidget {
  const SlotController({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  SlotState createState() => SlotState();
}

class SlotState extends State<SlotController> {
  late SlotMachineController _controller;

  @override
  void initState() {
    super.initState();
  }

  void onButtonTap({required int index}) {
    _controller.stop(reelIndex: index);
  }

  void onStart() {
    final index = Random().nextInt(20);
    _controller.start(hitRollItemIndex: index < 5 ? index : null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SlotMachine(
              rollItems: [
                RollItem(
                    index: 0,
                    child: Image.asset('assets/images/bombs/blue.png')),
                RollItem(
                    index: 1,
                    child: Image.asset('assets/images/bombs/green.png')),
                RollItem(
                    index: 2,
                    child: Image.asset('assets/images/bombs/orange.png')),
                RollItem(
                    index: 3,
                    child: Image.asset('assets/images/bombs/purple.png')),
                RollItem(
                    index: 4,
                    child: Image.asset('assets/images/bombs/red.png')),
              ],
              onCreated: (controller) {
                _controller = controller;
              },
              onFinished: (resultIndexes) {
                print('Result: $resultIndexes');
              },
            ),
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: TextButton(
                  child: const Text('START'),
                  onPressed: () async {
                    onStart();
                    await Future.delayed(const Duration(seconds: 1));
                    onButtonTap(index: 0);
                    // await Future.delayed(const Duration(milliseconds: 700));
                    onButtonTap(index: 1);
                    // await Future.delayed(const Duration(milliseconds: 700));
                    onButtonTap(index: 2);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
