// ignore_for_file: avoid_print
import 'package:bachelor_flutter_crush/bloc/user_state_bloc/coins_bloc/coin_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_bloc.dart';
import '../bloc/user_state_bloc/dark_patterns_bloc/dark_patterns_state.dart';
import '../persistence/firebase_store.dart';

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
                  image:
                      AssetImage('assets/images/background/background_new.png'),
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
                      Text('🪙: $coins'),
                      Text('Buntes Jelly: $buntJelly'),
                      Text('Gestreiftes Jelly: $stripeJelly'),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: shopItems.length,
                    itemBuilder: (context, index) {
                      if (shopItems[index].type == 'xp') {
                        return Container(); // Return an empty container if the item is XP and dark patterns are not activated or in competition state
                      }
                      return Container(
                        color: Colors.black.withOpacity(0.1),
                        // Semi-transparent background
                        child: ListTile(
                          title: Text(shopItems[index].name,
                              style: const TextStyle(color: Colors.black)),
                          subtitle: Text(
                              '${shopItems[index].description} - ${shopItems[index].cost}🪙',
                              style: const TextStyle(color: Colors.black)),
                          trailing: ElevatedButton(
                            child: const Text('Kaufen'),
                            onPressed: () {
                              if (shopItems[index].cost > coins) {
                                Fluttertoast.showToast(
                                    msg:
                                        "Du hast nur $coins🪙, für dieses Item brauchst du aber "
                                        "${shopItems[index].cost}🪙",
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

    // Get the CoinBloc
    CoinBloc coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
    // Subtract the cost from the user's coins and emit a new state
    coinBloc.add(RemoveCoinsEvent(shopItems[index].cost));

    setState(() {
      coins -= shopItems[index].cost; // Subtract the cost from the user's coins
    });
    FirebaseStore.addItemBought(shopItems[index].description);
    _showDarkPatternsInfo(index);
  }

  void showToastItemBought(int index) {
    Fluttertoast.showToast(
        msg:
            "Du hast ${shopItems[index].description} gekauft. Du hast noch $coins🪙.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void _showDarkPatternsInfo(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    var dpInfoShown = prefs.getBool('darkPatternsInfoShop');

    if (dpInfoShown == null || dpInfoShown == false) {
      return showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                scrollable: true,
                title: const Text('Das war gerade ein Dark Pattern!'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isExpanded)
                      const Text(
                        'Der In-Game-Shop, den du gerade besucht hast, ist ein weiteres Beispiel für einen Dark Pattern, der in vielen Smartphone-Spielen vorkommt. Hier werden die Gegenstände oft in einer Art präsentiert, die dich dazu verleiten soll, mehr zu kaufen, als du ursprünglich vorhattest. Häufig siehst du "begrenzte Zeit"-Angebote, Bündelpreise oder besondere Rabatte, die dir das Gefühl geben, ein Schnäppchen zu machen. Manchmal wird sogar dein Spielfortschritt durch den Erwerb dieser Items direkt beeinflusst, was den Druck erhöht, Geld auszugeben. Hast du bemerkt, wie oft du durch den Shop stöberst, auf der Suche nach dem nächsten „Deal“? Oder dass du dich motiviert fühlst, einen Kauf zu tätigen, um schneller voranzukommen oder besondere Vorteile zu erhalten? Das ist kein Zufall: Die Entwickler möchten, dass du das Gefühl hast, etwas zu verpassen, wenn du diese Angebote nicht wahrnimmst, und hoffen, dass du echtes Geld investierst, um im Spiel erfolgreicher zu sein.',
                      ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(isExpanded ? "" : 'Mehr erfahren'),
                          isExpanded
                              ? const Icon(Icons.expand_less)
                              : const Icon(Icons.expand_more),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      prefs.setBool('darkPatternsInfoShop', true);
                      Navigator.of(context).pop();
                      showToastItemBought(index);
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      showToastItemBought(index);
    }
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
