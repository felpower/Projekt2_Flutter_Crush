import 'dart:math';

import 'package:flutter/material.dart';

import 'board_view.dart';
import 'model.dart';

class FortuneWheel extends StatefulWidget {
  const FortuneWheel({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FortuneWheelState();
  }
}

class _FortuneWheelState extends State<FortuneWheel> with SingleTickerProviderStateMixin {
  double _angle = 0;
  double _current = 0;
  late AnimationController _ctrl;
  late Animation _ani;

  final List<Luck> _items = [
    Luck("fireball", Colors.accents[0]),
    Luck("multi_color", Colors.accents[2]),
    Luck("mine", Colors.accents[4]),
    Luck("tnt", Colors.accents[6]),
    Luck("rocket", Colors.accents[8]),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var duration = const Duration(milliseconds: 5000);
    _ctrl = AnimationController(vsync: this, duration: duration);
    _ani = CurvedAnimation(parent: _ctrl, curve: Curves.fastLinearToSlowEaseIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fortune Wheel'),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.green, Colors.blue.withOpacity(0.2)])),
        child: AnimatedBuilder(
            animation: _ani,
            builder: (context, child) {
              final value = _ani.value;
              final angle = value * _angle;
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  BoardView(items: _items, current: _current, angle: angle),
                  _buildGo(),
                  _buildResult(value),
                ],
              );
            }),
      ),
    );
  }

  _buildGo() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _animation,
        child: Container(
          alignment: Alignment.center,
          height: 72,
          width: 72,
          child: const Text(
            "GO",
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  _animation() {
    if (!_ctrl.isAnimating) {
      var random = Random().nextDouble();
      _angle = 20 + Random().nextInt(5) + random;
      _ctrl.forward(from: 0.0).then((_) {
        _current = (_current + random);
        _current = _current - _current ~/ 1;
        _ctrl.reset();
      });
    }
  }

  int _calIndex(value) {
    var base = (2 * pi / _items.length / 2) / (2 * pi);
    return (((base + value) % 1) * _items.length).floor();
  }

  _buildResult(value) {
    var index = _calIndex(value * _angle + _current);
    var item = _items[index];
    String asset = item.asset;
    if (_ctrl.isCompleted) {
      print(item.image); //Print win message
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Image.asset(asset, height: 80, width: 80),
      ),
    );
  }
}
