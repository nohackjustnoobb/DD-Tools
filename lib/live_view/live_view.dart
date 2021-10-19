import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'dart:io' show Platform;

import '../classes.dart';

class LiveView extends StatelessWidget {
  final ChannelList channelList;

  const LiveView({Key? key, required this.channelList}) : super(key: key);

  double getFitPlayerWidth(screenWidth, screenHeight, listLength) {
    int itemPerRow = 1;
    double originalWidth = screenWidth;
    while ((screenWidth / 16 * 9) * (listLength / itemPerRow).ceil() >
        screenHeight) {
      itemPerRow += 1;
      screenWidth = originalWidth / itemPerRow;
    }
    return screenWidth - 10;
  }

  @override
  Widget build(BuildContext context) {
    double playerWidth = getFitPlayerWidth(MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height, channelList.playList.length);

    return Scaffold(
        body: SafeArea(
      bottom: false,
      child: Stack(
        children: [
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              runAlignment: WrapAlignment.spaceBetween,
              children: channelList.playList
                  .map((e) => SizedBox(
                        width: playerWidth,
                        child: YoutubePlayerIFrame(
                          controller: YoutubePlayerController(
                              initialVideoId: e.id,
                              params: YoutubePlayerParams(
                                  showControls: false,
                                  mute: Platform.isIOS,
                                  autoPlay: true,
                                  desktopMode: true)),
                          aspectRatio: 16 / 9,
                        ),
                      ))
                  .toList(),
            ),
          ),
          Positioned(
              top: 0,
              left: 5,
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(24))),
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () => Navigator.of(context).pop(),
                  iconSize: 40,
                  icon: Icon(
                    MdiIcons.arrowLeftCircle,
                    color: Theme.of(context).primaryColor,
                  ),
                  splashRadius: 25,
                ),
              )),
        ],
      ),
    ));
  }
}
