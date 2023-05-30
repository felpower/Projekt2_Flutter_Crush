import 'package:bachelor_flutter_crush/bloc/reporting_bloc/reporting_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../bloc/reporting_bloc/reporting_bloc.dart';

class AdvertisementVideoPlayer extends StatefulWidget {
  const AdvertisementVideoPlayer({Key? key}) : super(key: key);

  @override
  _AdvertisementVideoPlayerState createState() =>
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

  @override
  Widget build(BuildContext context) {
    final ReportingBloc reportingBloc = BlocProvider.of<ReportingBloc>(context);

    return FutureBuilder<bool>(
      future: started(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.data == true) {
          return Stack(
            children: [
              VideoPlayer(controller),
              GestureDetector(
                onTapDown: (tapDownEvent) =>
                    _onTapDown(tapDownEvent, reportingBloc),
              ),
              Container(
                  padding: const EdgeInsets.all(5),
                  width: 35,
                  height: 35,
                  margin: const EdgeInsets.only(top: 30),
                  child: FutureBuilder(
                      future:
                          Future.delayed(const Duration(milliseconds: 5000)),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return TextButton(
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              });
                        } else {
                          return const Icon(Icons.update, color: Colors.white);
                        }
                      }))
            ],
          );
        } else {
          return const Text('');
        }
      },
    );
  }

  _onTapDown(var details, ReportingBloc reportingBloc) {
    double x = details.globalPosition.dx;
    double y = details.globalPosition.dy;
    reportingBloc.add(ReportAdvertisementTapEvent(x, y));
  }
}
