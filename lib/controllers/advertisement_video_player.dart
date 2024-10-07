import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../bloc/user_state_bloc/coins_bloc/coin_bloc.dart';
import '../bloc/user_state_bloc/coins_bloc/coin_event.dart';
import '../persistence/firebase_store.dart';

class AdvertisementVideoPlayer extends StatefulWidget {
  final bool isForcedAd;

  const AdvertisementVideoPlayer({Key? key, required this.isForcedAd})
      : super(key: key);

  @override
  State<AdvertisementVideoPlayer> createState() =>
      _AdvertisementVideoPlayerState();
}

class _AdvertisementVideoPlayerState extends State<AdvertisementVideoPlayer> {
  late VideoPlayerController controller;
  bool startedPlaying = false;

  @override
  void initState() {
    super.initState();
    bool popped = false;
    controller =
        VideoPlayerController.asset('assets/videos/spinning_earth.mp4');
    controller.addListener(() async {
      if (startedPlaying && !controller.value.isPlaying && !popped) {
        popped = true;
        if (!widget.isForcedAd) {
          _showDarkPatternsInfo();
          rewardUserWithCoins();
        }
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<bool> started() async {
    controller.setLooping(false);
    await controller.initialize();
    await controller.play();
    startedPlaying = true;
    return true;
  }

  void rewardUserWithCoins() {
    FirebaseStore.watchedAdd(DateTime.now());
    flutter_bloc.BlocProvider.of<CoinBloc>(context).add(AddCoinsEvent(100));
    Fluttertoast.showToast(
      msg: "You have been rewarded with 100 🪙",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: FutureBuilder<bool>(
          future: started(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (snapshot.data == true) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: SizedBox(
                        width: controller.value.size.width,
                        height: controller.value.size.height,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (tapDownEvent) => _onTapDown(tapDownEvent),
                  ),
                  Positioned(
                    top: 30,
                    right: 10,
                    child: FutureBuilder(
                      future:
                          Future.delayed(const Duration(milliseconds: 1000)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return TextButton(
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (!widget.isForcedAd) {
                                _showDarkPatternsInfo();
                                rewardUserWithCoins();
                              } else {
                                Navigator.of(context).pop();
                                _showRemoveAdsDialog();
                              }
                            },
                          );
                        } else {
                          return const Icon(Icons.update, color: Colors.white);
                        }
                      },
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  void _showRemoveAdsDialog() {
    if (context == null || !mounted) return; // Ensure context is valid and widget is mounted
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Werbung ausschalten'),
          content: const Text('Möchtest du die Werbung ausschalten für 500 🪙?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Nein'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Ja'),
              onPressed: () {
                Navigator.of(context).pop();
                // Get the CoinBloc
                CoinBloc coinBloc = flutter_bloc.BlocProvider.of<CoinBloc>(context);
                int amount = coinBloc.state.amount;
                if (amount >= 500) {
                  coinBloc.add(RemoveCoinsEvent(500));
                  Fluttertoast.showToast(
                      msg: "Werbung wurde entfernt",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 5,
                      backgroundColor: Colors.green,
                      textColor: Colors.white,
                      fontSize: 16.0);
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setBool('isAdsRemoved', true);
                  });
                } else {
                  Fluttertoast.showToast(
                      msg: "Du hast nur $amount 🪙, für das entfernen der Werbung benötigst du 500🪙",
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 5,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _onTapDown(var details) {
    // double x = details.globalPosition.dx;
    // double y = details.globalPosition.dy;
  }

  void _showDarkPatternsInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isExpanded = false;
    var dpInfoShown = prefs.getBool('darkPatternsInfoAdds');

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
                    const Text(
                        'Das Werbevideo, das du gerade gesehen hast, ist ein Dark Pattern, das gezielt in vielen Smartphone-Spielen verwendet wird. '),
                    if (isExpanded)
                      const Text(
                        'Es nutzt emotionale Manipulation, um dich dazu zu bringen, häufiger zu spielen und möglicherweise In-Game-Käufe zu tätigen. Das Video zeigt dir verlockende Angebote, die oft nur für kurze Zeit verfügbar sind, was ein Gefühl von Dringlichkeit und Verknappung erzeugt. Dies sorgt dafür, dass du das Gefühl hast, schnell handeln zu müssen, bevor das Angebot verschwindet. Ist dir aufgefallen, dass du dich dazu gedrängt fühlst, auf das Angebot einzugehen, bevor es abläuft? Vielleicht hast du sogar darüber nachgedacht, echtes Geld auszugeben, um das exklusive Item oder Bonuspaket zu bekommen? Genau das ist das Ziel dieser Taktik: Sie soll dich emotional ansprechen und dich davon überzeugen, dass du eine einzigartige Chance verpasst, wenn du nicht sofort handelst.',
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
                      prefs.setBool('darkPatternsInfoAdds', true);
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
}
