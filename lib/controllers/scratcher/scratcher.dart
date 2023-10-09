import 'package:flutter/material.dart';

import 'advanced.dart';
import 'basic.dart';

class Scratcher extends StatelessWidget {
  const Scratcher({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DefaultTabController(
        length: 2,
        child: Scaffold(
          bottomNavigationBar: SafeArea(
            child: TabBar(
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.blueGrey,
              indicatorColor: Colors.blueAccent,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(icon: Icon(Icons.looks_one)),
                Tab(icon: Icon(Icons.looks_two)),
              ],
            ),
          ),
          body: TabBarView(
            physics: NeverScrollableScrollPhysics(),
            children: [
              AdvancedScreen(),
              BasicScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
