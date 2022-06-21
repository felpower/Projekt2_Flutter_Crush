import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() => runApp(const RatingPage());

class RatingPage extends StatefulWidget {
  const RatingPage({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<RatingPage> {
  late double _rating;

  final int _ratingBarMode = 1;
  final double _initialRating = 4;

  IconData? _selectedIcon;

  @override
  void initState() {
    super.initState();
    _rating = _initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Builder(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: const Text('Please Rate the Game'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    color: Colors.white,
                    onPressed: () {
                      if (_rating > 3) Navigator.pop(this.context);
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
                        height: 40.0,
                      ),
                      _heading('Please Rate the Game'),
                      _ratingBar(_ratingBarMode),
                      const SizedBox(height: 20.0),
                      Text(
                        'Rating: $_rating',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {
                        if (_rating > 3) Navigator.pop(this.context);
                      },
                      iconSize: 100,
                      icon: const Icon(Icons.check))
                ]),
              ),
            ),
          ),
        ));
  }

  Widget _ratingBar(int mode) {
    return RatingBar.builder(
      initialRating: _initialRating,
      minRating: 1,
      unratedColor: Colors.amber.withAlpha(50),
      itemCount: 5,
      itemSize: 50.0,
      itemPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      itemBuilder: (context, _) => Icon(
        _selectedIcon ?? Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
      },
      updateOnDrag: true,
    );
  }

  Widget _heading(String text) => Column(
        children: [
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24.0,
            ),
          ),
          const SizedBox(
            height: 20.0,
          ),
        ],
      );
}
