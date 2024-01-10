// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  ShopState createState() => ShopState();
}

class ShopState extends State<ShopPage> {
  int coins = 0;
  int buntJelly = 0;
  int stripeJelly = 0;
  int xp = 0;
  List<ShopItem> shopItems = [
    ShopItem(
      name: 'XP',
      description: '50 Erfahrungspunkte',
      cost: 100,
      type: 'xp',
    ),
    ShopItem(
      name: 'Sonderjelly',
      description: '1 Buntes Sonderjelly',
      cost: 200,
      type: 'buntJelly',
    ),
    ShopItem(
      name: 'Sonderjelly',
      description: '1 Gestreiftes Sonderjelly',
      cost: 150,
      type: 'stripeJelly',
    ),
  ];

  DarkPatternsState darkPatterns = DarkPatternsDeactivatedState();

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Shop'),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/background/background_new.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  color: Colors.black.withOpacity(0.2),
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('\$: $coins'),
                      if (darkPatterns is! DarkPatternsDeactivatedState) Text('XP: $xp'),
                      Text('Buntes Jelly: $buntJelly'),
                      Text('Gestreiftes Jelly: $stripeJelly'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: shopItems.length,
                    itemBuilder: (context, index) {
                      if (shopItems[index].type == 'xp' &&
                          darkPatterns is DarkPatternsDeactivatedState) {
                        return Container(); // Return an empty container if the item is XP and dark patterns are deactivated
                      }
                      return Container(
                        color: Colors.black.withOpacity(0.1), // Semi-transparent background
                        child: ListTile(
                          title: Text(shopItems[index].name,
                              style: const TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${shopItems[index].description} - ${shopItems[index].cost} coins',
                              style: const TextStyle(color: Colors.black)),
                          trailing: ElevatedButton(
                            child: const Text('Kaufen'),
                            onPressed: () {
                              if (shopItems[index].cost > coins) {
                                Fluttertoast.showToast(
                                    msg: "Du hast nur $coins\$, für dieses Item brauchst du aber "
                                        "${shopItems[index].cost}\$",
                                    toastLength: Toast.LENGTH_LONG,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 5,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                buyItem(index, context);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> buyItem(int index, BuildContext context) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    if (shopItems[index].type.contains('bunt')) {
      sp.setInt("buntJelly", buntJelly + 1);
      setState(() {
        buntJelly = buntJelly + 1;
      });
    } else if (shopItems[index].type.contains('stripe')) {
      sp.setInt("stripeJelly", stripeJelly + 1);
      setState(() {
        stripeJelly = stripeJelly + 1;
      });
    } else if (shopItems[index].type.contains("xp")) {
      sp.setInt("xp", xp + 50);
      setState(() {
        xp = xp + 50;
      });
    }
    setState(() {
      coins -= shopItems[index].cost; // Subtract the cost from the user's coins
    });
    sp.setInt('coin', coins); // Update the user's coins in SharedPreferences

    // Show a toast message with the name of the item bought and the new amount of coins
    Fluttertoast.showToast(
        msg: "Du hast ${shopItems[index].description} gekauft. Du hast noch $coins\$.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  void loadSharedPreferences() async {
    DarkPatternsState darkPatternsState =
        flutter_bloc.BlocProvider.of<DarkPatternsBloc>(context).state;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      darkPatterns = darkPatternsState;
      coins = prefs.getInt('coin') ?? 150;
      buntJelly = prefs.getInt("buntJelly") ?? 0;
      stripeJelly = prefs.getInt("stripeJelly") ?? 0;
      xp = prefs.getInt("xp") ?? 0;
    });
  }
}

class ShopItem {
  final String name;
  final String description;
  final int cost;
  final String type;

  ShopItem({
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
  });
}
