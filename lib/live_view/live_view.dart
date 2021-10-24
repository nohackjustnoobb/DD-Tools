import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../home/home.dart' show PlayList;

import '../classes.dart';

class LiveView extends StatelessWidget {
  const LiveView({Key? key}) : super(key: key);

  double getFitPlayerWidth(screenWidth, screenHeight, listLength) {
    int itemPerRow = 1;
    double originalWidth = screenWidth;
    if (screenWidth > screenHeight) originalWidth -= 90;
    while ((screenWidth / 16 * 9) * (listLength / itemPerRow).ceil() >
        screenHeight) {
      itemPerRow += 1;
      screenWidth = originalWidth / itemPerRow;
    }
    return screenWidth - 20;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          bottom: false,
          child: Consumer<ChannelList>(
            builder: (context, channelList, child) {
              double playerWidth = getFitPlayerWidth(
                  MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height,
                  channelList.playList.length);
              return Stack(
                children: [
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 5,
                      runSpacing: 5,
                      runAlignment: WrapAlignment.spaceBetween,
                      children: channelList.playList
                          .map(
                            (e) => ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: Container(
                                  padding: const EdgeInsets.all(5),
                                  color: Theme.of(context).primaryColor,
                                  child: SizedBox(
                                      width: playerWidth,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        child: e.getPlayer(
                                            !channelList.forcePlaySound),
                                      ))),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  Controller(
                    channelList: channelList,
                  ),
                ],
              );
            },
          )),
    );
  }
}

class Controller extends StatefulWidget {
  final ChannelList channelList;

  const Controller({Key? key, required this.channelList}) : super(key: key);

  @override
  ControllerState createState() => ControllerState();
}

class ControllerState extends State<Controller>
    with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController animationController;
  double volume = 100;
  bool isOpen = true;
  bool isMuted = true;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    animation = Tween(begin: 10.0, end: -165.0).animate(animationController)
      ..addListener(() {
        setState(() {});
      });

    animationController.addStatusListener((status) {
      isOpen = status == AnimationStatus.dismissed;
    });

    isMuted = !widget.channelList.forcePlaySound;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        top: 10,
        left: animation.value,
        child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: Container(
              color: Colors.white,
              child: Container(
                color: Theme.of(context).primaryColor.withOpacity(0.15),
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      iconSize: 28,
                      icon: const Icon(MdiIcons.home),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: widget.channelList.playList.isEmpty
                          ? null
                          : () {
                              isPlaying
                                  ? widget.channelList.pauseAll()
                                  : widget.channelList.playAll();
                              setState(() => isPlaying = !isPlaying);
                            },
                      iconSize: 28,
                      icon: Icon(isPlaying ? MdiIcons.pause : MdiIcons.play),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: !widget.channelList.forcePlaySound ||
                              widget.channelList.playList.isEmpty
                          ? null
                          : () => setState(() {
                                isMuted
                                    ? widget.channelList.unMuteAll()
                                    : widget.channelList.muteAll();
                                isMuted = !isMuted;
                              }),
                      iconSize: 28,
                      icon: Icon(
                          isMuted ? MdiIcons.volumeMute : MdiIcons.volumeHigh),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: widget.channelList.playList.isEmpty
                          ? null
                          : () => showBarModalBottomSheet(
                              context: context,
                              builder: (context) => ControllerList(
                                  channelList: widget.channelList)),
                      iconSize: 28,
                      icon: const Icon(MdiIcons.dotsHorizontal),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: () => showBarModalBottomSheet(
                          context: context,
                          builder: (context) => PlayList(
                                channelList: widget.channelList,
                                isInPlaylist: false,
                              )),
                      iconSize: 28,
                      icon: const Icon(MdiIcons.plus),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: () => isOpen
                          ? animationController.forward()
                          : animationController.reverse(),
                      iconSize: 28,
                      icon: Icon(isOpen
                          ? MdiIcons.chevronLeft
                          : MdiIcons.chevronRight),
                      padding: EdgeInsets.zero,
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    )
                  ],
                ),
              ),
            )));
  }
}

class ControllerList extends StatefulWidget {
  final ChannelList channelList;
  const ControllerList({Key? key, required this.channelList}) : super(key: key);

  @override
  ControllerListState createState() => ControllerListState();
}

class ControllerListState extends State<ControllerList> {
  Map<String, double> streamVolume = {};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: ListView.separated(
            padding: const EdgeInsets.all(10),
            shrinkWrap: true,
            itemCount: widget.channelList.playList.length,
            separatorBuilder: (BuildContext context, int index) => Divider(
                  indent: 40,
                  endIndent: 40,
                  color: Colors.black.withOpacity(0.3),
                ),
            itemBuilder: (BuildContext context, int index) {
              Map streamInfo = widget.channelList.playList[index].info;
              Stream stream = widget.channelList.playList[index];
              streamVolume[stream.id] = 100.0;
              return Column(children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: NetworkImage(streamInfo['thumbnail']),
                      width: 100,
                      height: 56.25,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            streamInfo['title'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor),
                          ),
                          Text(
                            streamInfo['ownerName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.7)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      onPressed: () => setState(() =>
                          stream.isPlaying ? stream.pause() : stream.play()),
                      iconSize: 28,
                      icon: Icon(
                          stream.isPlaying ? MdiIcons.pause : MdiIcons.play),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        if (stream.isMuted) {
                          if (!widget.channelList.forcePlaySound) {
                            widget.channelList.muteAll();
                          }
                          stream.unMute();
                        } else {
                          stream.mute();
                        }
                      }),
                      iconSize: 28,
                      icon: Icon(stream.isMuted
                          ? MdiIcons.volumeMute
                          : MdiIcons.volumeHigh),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Theme.of(context).primaryColor,
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        if (widget.channelList.playList.length == 1) {
                          Navigator.of(context).pop();
                        }
                        widget.channelList.removePlayList(stream.id);
                      }),
                      iconSize: 28,
                      icon: const Icon(MdiIcons.playlistMinus),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      color: Colors.red[400],
                      constraints: const BoxConstraints(),
                      splashRadius: 18,
                    ),
                  ],
                )
              ]);
            }));
  }
}
