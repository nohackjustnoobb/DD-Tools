import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';

import '../live_view/live_view.dart';
import '../classes.dart';
import '../settings/settings.dart';

Widget avatar(
    {required BuildContext context, required String url, double size = 50}) {
  return GestureDetector(
    onTap: () => showMaterialModalBottomSheet(
        context: context,
        barrierColor: Colors.black.withOpacity(0.8),
        backgroundColor: Colors.transparent,
        builder: (context) => PhotoView(
              imageProvider: NetworkImage(url),
              enableRotation: true,
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration:
                  const BoxDecoration(color: Colors.transparent),
            )),
    child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        child: Image(image: NetworkImage(url), width: size, height: size)),
  );
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  // Customize AppBar
  @override
  Widget build(BuildContext context) {
    _appBar(height) => PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, height + 80),
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: height + 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const Settings())),
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                      icon: const Icon(
                        Icons.tune,
                        color: Colors.white,
                      ),
                      splashRadius: 20,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Transform.translate(
                        offset: const Offset(0, -5),
                        child: const Text(
                          "DD-Tools",
                          style: TextStyle(
                              fontSize: 25.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white),
                        ),
                      ),
                      Container(
                        height: 5,
                        width: MediaQuery.of(context).size.width / 2,
                        margin: const EdgeInsets.only(top: 10),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () => showBarModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) =>
                              Consumer<ChannelList>(
                                  builder: (BuildContext context, channelList,
                                          child) =>
                                      FollowedList(
                                        channelListObject: channelList,
                                        isFav: true,
                                      ))),
                      padding: EdgeInsets.zero,
                      iconSize: 30,
                      icon: const Icon(
                        MdiIcons.heartBox,
                        color: Colors.white,
                      ),
                      splashRadius: 20,
                    ),
                  ),
                ],
              )
            ],
          ),
          height: height + 75,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(15)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 2),
                    blurRadius: 5)
              ]),
        ));

    return Scaffold(
      appBar: _appBar(AppBar().preferredSize.height),
      body: Consumer<ChannelList>(
        builder: (context, channelList, child) {
          return Column(children: [
            FollowedList(
              channelListObject: channelList,
            ),
            StreamList(
              streamList: channelList.streamList,
              channelList: channelList,
            )
          ]);
        },
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: Transform.scale(
          scale: 1.3,
          child: GestureDetector(
            onLongPress: () => showBarModalBottomSheet(
                context: context,
                builder: (BuildContext context) => Consumer<ChannelList>(
                      builder: (context, channelList, child) {
                        return PlayList(channelList: channelList);
                      },
                    )),
            child: FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const LiveView())),
                elevation: 2,
                highlightElevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(
                  MdiIcons.televisionPlay,
                  color: Colors.white,
                  size: 35,
                )),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FollowedList extends StatelessWidget {
  final ChannelList channelListObject;
  final bool isFav;

  const FollowedList(
      {Key? key, required this.channelListObject, this.isFav = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Channel>? channelList = isFav
        ? channelListObject.channelList
            .where((element) =>
                channelListObject.favouriteIDList.contains(element.id))
            .toList()
        : channelListObject.channelList;
    Widget listView = ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.only(top: 5),
        itemCount: channelList.length,
        separatorBuilder: (BuildContext context, int index) => Divider(
              indent: 40,
              endIndent: 40,
              color: Colors.black.withOpacity(0.3),
            ),
        itemBuilder: (BuildContext context, int index) {
          Channel channel = channelList[index];
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  avatar(context: context, url: channel.thumbnail),
                  GestureDetector(
                    onTap: () => showBarModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => ChannelInfo(
                              channelList: channelListObject,
                              channel: channel,
                            )),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      color: Colors.transparent,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              channel.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            channel.subscriberCount ?? '',
                            maxLines: 1,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.8),
                                fontSize: 12),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              IconButton(
                onPressed: () => channelListObject.toggleFavourite(channel.id),
                icon: Icon(
                  channelListObject.favouriteIDList.contains(channel.id)
                      ? MdiIcons.heart
                      : MdiIcons.heartOutline,
                  color: Colors.red[400],
                  size: 28,
                ),
                splashRadius: 20,
              )
            ],
          );
        });
    return isFav
        ? SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (channelListObject.favouriteIDList.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'No Favourite Channel',
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    ),
                  )
                else
                  Container(padding: const EdgeInsets.all(10), child: listView),
                TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor: Colors.red[400],
                        minimumSize: const Size(200, 40)),
                    onPressed: () {
                      channelListObject.clearFavourite();
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Colors.white),
                    )),
              ],
            ),
          )
        : Expanded(
            flex: 1,
            child: Container(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Followed',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 20),
                          ),
                          Container(
                            width: 50,
                            height: 3,
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(1.5))),
                          )
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(
                                  text: jsonEncode(
                                      channelListObject.channelIDList)));
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      CupertinoAlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const <Widget>[
                                            Text("Copied To Clipboard"),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          CupertinoDialogAction(
                                            child: const Text("OK"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      ));
                            },
                            iconSize: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            icon: Icon(
                              MdiIcons.exportVariant,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => showBarModalBottomSheet(
                                context: context,
                                builder: (context) => Share(
                                      channelList: channelListObject,
                                    )),
                            iconSize: 28,
                            padding: const EdgeInsets.all(0),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            icon: Icon(
                              MdiIcons.accountMultiplePlus,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () => showBarModalBottomSheet(
                                context: context,
                                builder: (context) =>
                                    Add(channelList: channelListObject)),
                            iconSize: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            constraints: const BoxConstraints(),
                            splashRadius: 20,
                            icon: Icon(
                              MdiIcons.accountPlus,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  Expanded(flex: 1, child: listView)
                ],
              ),
              padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
            ),
          );
  }
}

class Share extends StatefulWidget {
  final ChannelList channelList;

  const Share({Key? key, required this.channelList}) : super(key: key);

  @override
  ShareState createState() => ShareState();
}

class ShareState extends State<Share> {
  final TextEditingController _controller = TextEditingController();

  void addChannelList() {
    try {
      String text = _controller.text;
      if (text != '') {
        widget.channelList.fetchChannelList(
            idList: jsonDecode(text).cast<String>(), isSave: true);
      }
      Navigator.of(context).pop();
    } catch (e) {
      _controller.clear();
      showDialog(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Icon(
                      MdiIcons.alertCircle,
                      color: Colors.red,
                      size: 20,
                    ),
                    Text("String Value is not valid"),
                  ],
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Material(
            child: TextFormField(
              controller: _controller,
              cursorColor: Theme.of(context).primaryColor,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => addChannelList(),
              decoration: InputDecoration(
                icon: Icon(
                  MdiIcons.clipboardText,
                  color: Theme.of(context).primaryColor,
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                labelText: 'Channel List',
                suffixIcon: IconButton(
                  onPressed: () => addChannelList(),
                  icon: Icon(
                    MdiIcons.magnify,
                    color: Theme.of(context).primaryColor,
                  ),
                  splashRadius: 20,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 10),
            child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    primary: Colors.white,
                    minimumSize: const Size(150, 40)),
                onPressed: () => addChannelList(),
                child: const Text(
                  'Add Channel List',
                  style: TextStyle(color: Colors.white),
                )),
          ),
          TweenAnimationBuilder(
              tween: Tween<double>(
                  begin: 0, end: MediaQuery.of(context).viewInsets.bottom),
              duration: const Duration(milliseconds: 200),
              builder: (BuildContext context, double size, Widget? child) =>
                  SizedBox(
                    height: size,
                  ))
        ],
      ),
    ));
  }
}

class ChannelInfo extends StatelessWidget {
  final ChannelList channelList;
  final Channel channel;

  const ChannelInfo(
      {Key? key, required this.channelList, required this.channel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: SingleChildScrollView(
      child: Container(
        padding:
            const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(7)),
              child: Column(
                children: [
                  if (channel.banner != null)
                    Image(image: NetworkImage('${channel.banner}')),
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: [
                            avatar(context: context, url: channel.thumbnail),
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.59,
                                      child: Text(
                                        channel.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Text(
                                    channel.subscriberCount ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 12),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.only(left: 10),
                            )
                          ],
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: IconButton(
                            onPressed: () => launch(
                                'https://www.youtube.com/channel/${channel.id}',
                                forceSafariVC: false),
                            iconSize: 40,
                            padding: const EdgeInsets.all(0),
                            icon: const Icon(
                              MdiIcons.youtube,
                              color: Colors.red,
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 10,
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  channelList.remove(channel);
                },
                style: TextButton.styleFrom(
                    primary: Colors.white, backgroundColor: Colors.red[400]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      MdiIcons.accountMinus,
                      size: 30,
                      color: Colors.white,
                    ),
                    Container(
                      width: 5,
                    ),
                    const Text(
                      'Unfollow',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  ],
                ))
          ],
        ),
      ),
    ));
  }
}

class StreamList extends StatefulWidget {
  final List<Stream?> streamList;
  final ChannelList channelList;

  const StreamList(
      {Key? key, required this.streamList, required this.channelList})
      : super(key: key);

  @override
  StreamListState createState() => StreamListState();
}

class StreamListState extends State<StreamList> {
  bool isLoading = false;

  update() async {
    await widget.channelList.updateStream();
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Container(
          child: Stack(
            children: [
              Column(
                children: <Widget>[
                  Container(
                    height: 5,
                    width: 60,
                    margin: const EdgeInsets.only(top: 15, bottom: 5),
                    decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(1.5)),
                        color: Colors.black.withOpacity(0.1)),
                  ),
                  Expanded(
                    child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollUpdateNotification &&
                              !isLoading) {
                            // ignore: unnecessary_null_comparison
                            if (scrollNotification.metrics.pixels != null &&
                                scrollNotification.metrics.pixels <= -80) {
                              setState(() {
                                isLoading = true;
                              });
                              update();
                            }
                          }
                          return true;
                        },
                        child: ListView.separated(
                            padding: const EdgeInsets.only(left: 10, right: 5),
                            itemCount: widget.streamList.length + 1,
                            separatorBuilder:
                                (BuildContext context, int index) {
                              if (index != 0) {
                                return Divider(
                                  indent: 40,
                                  endIndent: 40,
                                  color: Colors.black.withOpacity(0.3),
                                );
                              } else {
                                return Container();
                              }
                            },
                            itemBuilder: (BuildContext context, int index) {
                              if (index == 0) {
                                return isLoading
                                    ? Container(
                                        padding: const EdgeInsets.all(10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container();
                              } else {
                                Map streamInfo =
                                    widget.streamList[index - 1]!.info;
                                bool inPlaylist = widget.channelList.playlistID
                                    .contains(widget.streamList[index - 1]!.id);
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => showBarModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              StreamInfo(
                                                  channelList:
                                                      widget.channelList,
                                                  stream: widget
                                                      .streamList[index - 1])),
                                      child: Row(
                                        children: <Widget>[
                                          Image(
                                            image: NetworkImage(
                                                streamInfo['thumbnail']),
                                            width: 100,
                                            height: 56.25,
                                          ),
                                          Container(
                                            margin:
                                                const EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.55,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  streamInfo['title'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor),
                                                ),
                                                Text(
                                                  streamInfo['ownerName'],
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                    ),
                                    Material(
                                      color: Colors.transparent,
                                      child: IconButton(
                                        onPressed: () {
                                          if (inPlaylist) {
                                            widget.channelList.removePlayList(
                                                widget
                                                    .streamList[index - 1]!.id);
                                          } else {
                                            widget.channelList.addPlayList(
                                                widget.streamList[index - 1]);
                                          }
                                        },
                                        iconSize: 30,
                                        icon: Icon(
                                          inPlaylist
                                              ? MdiIcons.playlistMinus
                                              : MdiIcons.playlistPlus,
                                          color: inPlaylist
                                              ? Colors.red[400]
                                              : Theme.of(context).primaryColor,
                                        ),
                                        splashRadius: 20,
                                      ),
                                    )
                                  ],
                                );
                              }
                            })),
                  )
                ],
              ),
              if (Platform.isAndroid)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(25)),
                    child: Material(
                      color: Theme.of(context).primaryColor,
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                          });
                          update();
                        },
                        iconSize: 30,
                        icon: const Icon(
                          MdiIcons.reload,
                          color: Colors.white,
                        ),
                        splashRadius: 20,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, -2),
                    blurRadius: 5)
              ]),
        ));
  }
}

class StreamInfo extends StatelessWidget {
  final ChannelList channelList;
  final Stream? stream;

  const StreamInfo({Key? key, required this.channelList, required this.stream})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Channel? channel = channelList.getChannelWithStream(stream!);
    Map streamInfo = stream!.info;
    bool inPlaylist = channelList.playlist.contains(stream);
    return SafeArea(
        child: Container(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                avatar(
                                    context: context, url: channel!.thumbnail),
                                Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.59,
                                          child: Text(
                                            channel.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      Text(
                                        channel.subscriberCount ?? '',
                                        maxLines: 1,
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.8),
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.only(left: 10),
                                )
                              ],
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: IconButton(
                                onPressed: () => launch(
                                    'https://www.youtube.com/watch?v=${streamInfo['id']}',
                                    forceSafariVC: false),
                                iconSize: 35,
                                padding: const EdgeInsets.all(0),
                                icon: const Icon(
                                  MdiIcons.youtubeTv,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  child: Row(
                    children: <Widget>[
                      if (streamInfo['thumbnail'] != null)
                        Image(
                          image: NetworkImage(streamInfo['thumbnail']),
                          width: 100,
                          height: 56.25,
                        ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        width: MediaQuery.of(context).size.width - 235,
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
                                      .withOpacity(0.8)),
                            ),
                            if (streamInfo['viewCount'] != null)
                              Text(
                                '${streamInfo['viewCount']} watching',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.6)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 5,
                ),
                TextButton(
                    onPressed: () {
                      if (inPlaylist) {
                        channelList.removePlayList(stream!.id);
                      } else {
                        channelList.addPlayList(stream);
                      }
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      primary: Colors.grey,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          inPlaylist
                              ? MdiIcons.playlistMinus
                              : MdiIcons.playlistPlus,
                          size: 30,
                          color: inPlaylist
                              ? Colors.red[400]
                              : Theme.of(context).primaryColor,
                        ),
                        Container(
                          width: 5,
                        ),
                        Text(
                          inPlaylist
                              ? 'Remove From Playlist'
                              : 'Add To Playlist',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: inPlaylist
                                  ? Colors.red[400]
                                  : Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold),
                        )
                      ],
                    )),
              ],
            )));
  }
}

class Add extends StatefulWidget {
  final ChannelList channelList;
  final bool isChannel;

  const Add({Key? key, required this.channelList, this.isChannel = true})
      : super(key: key);

  @override
  AddState createState() => AddState();
}

class AddState extends State<Add> {
  Channel? channel;
  Stream? stream;

  final TextEditingController _controller = TextEditingController();
  void searchChannel() async {
    String id = _controller.value.text;
    if (id != '') {
      if (id.contains('channel')) {
        id = id.substring(id.indexOf('channel') + 8);
        if (id.length > 24) {
          id.substring(0, id.indexOf('/'));
        }
      }

      dynamic addChannel;
      if (widget.channelList.isUsingAPI && !widget.channelList.keyReachLimit) {
        addChannel =
            await Channel.getByAPI(id: id, api: widget.channelList.apiKey);

        if (addChannel is Exception) {
          addChannel = await Channel.getByWebScroper(id);
        }
      } else {
        addChannel = await Channel.getByWebScroper(id);
      }

      _controller.clear();
      setState(() {
        channel = addChannel;
      });
    }
  }

  void searchStream() async {
    String id = _controller.value.text;
    if (id != '') {
      if (id.contains('watch')) {
        id = id.substring(id.indexOf('watch') + 8);
      }
      if (id.contains('youtu.be')) {
        id = id.substring(id.lastIndexOf('/') + 1);
      }
      Stream? createdStream = await Stream.getByWebScroper(id);
      _controller.clear();
      setState(() {
        stream = createdStream;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Material(
            child: TextFormField(
              controller: _controller,
              cursorColor: Theme.of(context).primaryColor,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) =>
                  widget.isChannel ? searchChannel() : searchStream(),
              maxLength: 100,
              decoration: InputDecoration(
                icon: Icon(
                  MdiIcons.account,
                  color: Theme.of(context).primaryColor,
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                labelText:
                    widget.isChannel ? 'Channel Link / ID' : 'Strean Link / ID',
                suffixIcon: IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    widget.isChannel ? searchChannel() : searchStream();
                  },
                  icon: Icon(
                    MdiIcons.magnify,
                    color: Theme.of(context).primaryColor,
                  ),
                  splashRadius: 20,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ),
          Expanded(
              child: ListView(
            children: [
              if (channel != null)
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Column(
                    children: <Widget>[
                      if (channel!.banner != null)
                        Image(image: NetworkImage('${channel!.banner}')),
                      Container(
                        width: MediaQuery.of(context).size.width - 30,
                        color: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            avatar(
                                context: context,
                                url: channel!.thumbnail,
                                size: 60),
                            Container(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 125,
                                    child: Text(
                                      channel!.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (channel!.subscriberCount != null)
                                    Text(
                                      '${channel!.subscriberCount}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 12),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (channel!.description != '')
                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.8),
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            channel!.description,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        )
                    ],
                  ),
                )
              else if (stream != null)
                Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        avatar(context: context, url: stream!.ownerThumbnail),
                        Container(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 100,
                              child: Text(
                                stream!.ownerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            Text(
                              stream!.owner,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.8)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      height: 10,
                    ),
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: Container(
                        color: Theme.of(context).primaryColor,
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Image(
                              image: NetworkImage(stream!.thumbnail),
                            ),
                            Container(
                              height: 5,
                            ),
                            Text(
                              stream!.title,
                              style: const TextStyle(color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      child: TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.7),
                              primary: Colors.white,
                              minimumSize: const Size(140, 40)),
                          onPressed: () {
                            widget.channelList
                                .addChannelWithPreferWay(id: stream!.owner);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Add Channel',
                            style: TextStyle(color: Colors.white),
                          )),
                    )
                  ],
                )
              else
                Center(
                  child: Text(
                    'No Result',
                    style: TextStyle(
                        fontSize: 18, color: Colors.black.withOpacity(0.4)),
                  ),
                )
            ],
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              TextButton(
                  style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Colors.red[400],
                      minimumSize: const Size(140, 40)),
                  onPressed: () => setState(() {
                        channel = null;
                        stream = null;
                      }),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: channel == null && stream == null
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      primary: Colors.white,
                      minimumSize: const Size(140, 40)),
                  onPressed: channel != null || stream != null
                      ? () {
                          if (channel != null) {
                            widget.channelList.add(channel!);
                            widget.channelList.save();
                          } else if (stream != null) {
                            widget.channelList.addPlayList(stream);
                          }
                          Navigator.of(context).pop(context);
                        }
                      : null,
                  child: Text(
                    'Add ${widget.isChannel ? 'Channel' : 'Stream'}',
                    style: const TextStyle(color: Colors.white),
                  ))
            ],
          ),
        ],
      ),
    );
  }
}

class PlayList extends StatefulWidget {
  final ChannelList channelList;
  final bool isInPlaylist;

  const PlayList(
      {Key? key, required this.channelList, this.isInPlaylist = true})
      : super(key: key);

  @override
  PlayListState createState() => PlayListState();
}

class PlayListState extends State<PlayList> {
  @override
  Widget build(BuildContext context) {
    List<Stream?> playlist = widget.isInPlaylist
        ? widget.channelList.playlist
        : widget.channelList.streamList
            .where((element) =>
                !widget.channelList.playlistID.contains(element!.id))
            .toList();

    return SafeArea(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListView.separated(
          padding:
              const EdgeInsets.only(left: 10, right: 5, bottom: 10, top: 10),
          shrinkWrap: true,
          itemCount: playlist.length,
          separatorBuilder: (BuildContext context, int index) => Divider(
            indent: 40,
            endIndent: 40,
            color: Colors.black.withOpacity(0.3),
          ),
          itemBuilder: (BuildContext context, int index) {
            Map streamInfo = playlist[index]!.info;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Image(
                      image: NetworkImage(streamInfo['thumbnail']),
                      width: 100,
                      height: 56.25,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10),
                      width: MediaQuery.of(context).size.width * 0.55,
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
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      widget.isInPlaylist
                          ? widget.channelList
                              .removePlayList(playlist[index]!.id)
                          : widget.channelList.addPlayList(playlist[index]);
                      setState(() {});
                    },
                    iconSize: 30,
                    icon: widget.isInPlaylist
                        ? Icon(MdiIcons.playlistMinus, color: Colors.red[400])
                        : Icon(
                            MdiIcons.playlistPlus,
                            color: Theme.of(context).primaryColor,
                          ),
                    splashRadius: 20,
                  ),
                )
              ],
            );
          },
        ),
        Row(
          children: <Widget>[
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                    style: TextButton.styleFrom(
                        primary: Colors.white,
                        backgroundColor:
                            playlist.isEmpty ? Colors.grey : Colors.red[400],
                        minimumSize: const Size(150, 0)),
                    onPressed: playlist.isEmpty
                        ? null
                        : () => setState(() {
                              widget.isInPlaylist
                                  ? widget.channelList.clearPlayList()
                                  : widget.channelList
                                      .addMultiplePlayList(playlist);
                            }),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          widget.isInPlaylist ? MdiIcons.minus : MdiIcons.plus,
                          color: Colors.white,
                        ),
                        Text(
                          '${widget.isInPlaylist ? 'Remove' : 'Add'} Listed',
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    )),
                TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: const Size(150, 0),
                    ),
                    onPressed: () => showBarModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) => Add(
                              channelList: widget.channelList,
                              isChannel: false,
                            )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const <Widget>[
                        Icon(MdiIcons.plus),
                        Text(
                          'Add Stream',
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )),
              ],
            ))
          ],
        )
      ],
    ));
  }
}
