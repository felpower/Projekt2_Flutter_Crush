import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../persistence/reporting_service.dart';

void main() => runApp(const RatingPage());

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<RatingPage> {
  late double _rating;

  final int _ratingBarMode = 1;
  final double _initialRating = 3;

  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _rating = _initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Image.asset('assets/images/background/background2.jpg',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover),
      WillPopScope(
          onWillPop: () async => false,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Builder(
              builder: (context) => Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Please Rate the Game'),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.white,
                      onPressed: () {
                        ReportingService.addRating(_rating);
                        print("Rating: "+ _rating.toString());
                        if (_rating > 3) {
                          setRatingState();
                          var duration = const Duration(milliseconds: 500);
                          sleep(duration);
                          Navigator.pop(this.context);
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                    title: const Text('Error'),
                                    content: const Text(
                                        'Please try rating the game later, or try to change your rating'),
                                    elevation: 24,
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(16))),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () => {
                                                Navigator.pop(context, 'Cancel')
                                              },
                                          child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () =>
                                            {Navigator.pop(context, 'OK')},
                                        child: const Text('OK'),
                                      )
                                    ],
                                  ));
                        }
                      },
                    ),
                  ],
                ),
                body: Directionality(
                  textDirection: TextDirection.ltr,
                  child: ListView(children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        const SizedBox(
                          height: 200.0,
                        ),
                        _heading('Please Rate the Game'),
                        _ratingBar(),
                        const SizedBox(height: 20.0),
                        //FixMe: ReAdd when setState works Text(
                        //   'Rating: $_rating',
                        //   style: const TextStyle(
                        //       fontWeight: FontWeight.bold, color: Colors.amber),
                        // ),
                      ],
                    ),
                    IconButton(
                        onPressed: () {
                          ReportingService.addRating(_rating);
                          print("Rating: "+ _rating.toString());
                          if (_rating > 3) {
                            setRatingState();
                            var duration = const Duration(milliseconds: 500);
                            sleep(duration);
                            Navigator.pop(this.context);
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text(
                                          'Please try rating the game later, or try to change your rating'),
                                      elevation: 24,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16))),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () => {
                                                  Navigator.pop(
                                                      context, 'Cancel')
                                                },
                                            child: const Text('Cancel')),
                                        TextButton(
                                          onPressed: () =>
                                              {Navigator.pop(context, 'OK')},
                                          child: const Text('OK'),
                                        )
                                      ],
                                    ));
                          }
                        },
                        iconSize: 100,
                        icon: const Icon(Icons.check, color: Colors.amber))
                  ]),
                ),
              ),
            ),
          ))
    ]);
  }

  Widget _ratingBar() {
    return RatingBar.builder(
      initialRating: _initialRating,
      minRating: 1,
      unratedColor: Colors.amber.withAlpha(400),
      itemCount: 5,
      itemSize: 50.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        _rating = rating;
      },
      updateOnDrag: true,
    );
  }

  Widget _heading(String text) => Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.amber,
              fontSize: 24.0,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      );

  void setRatingState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("hasRated", true);
  }
}
