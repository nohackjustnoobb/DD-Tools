import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:photo_view/photo_view.dart';

import '../live_view/live_view.dart';
import '../classes.dart';

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
                  const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 30,
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
                  const Icon(
                    MdiIcons.heartBox,
                    color: Colors.white,
                    size: 30,
                  )
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
      floatingActionButton: Transform.scale(
          scale: 1.3,
          child: Consumer<ChannelList>(
            builder: (context, channelList, child) {
              return GestureDetector(
                onLongPress: () => showBarModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) =>
                        PlayList(channelList: channelList)),
                child: FloatingActionButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                LiveView(channelList: channelList))),
                    elevation: 2,
                    highlightElevation: 0,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(
                      MdiIcons.televisionPlay,
                      color: Colors.white,
                      size: 35,
                    )),
              );
            },
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class FollowedList extends StatelessWidget {
  final ChannelList channelListObject;

  const FollowedList({Key? key, required this.channelListObject})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Channel>? channelList = channelListObject.channelList;
    return Expanded(
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
                          color: Theme.of(context).primaryColor, fontSize: 20),
                    ),
                    Container(
                      width: 50,
                      height: 3,
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(1.5))),
                    )
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(right: 5),
                  child: GestureDetector(
                    onTap: () => showBarModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            AddChannel(channelList: channelListObject)),
                    child: Icon(
                      MdiIcons.accountPlus,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )
              ],
            ),
            Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.only(top: 5),
                    itemCount: channelList.length,
                    separatorBuilder: (BuildContext context, int index) =>
                        Divider(
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
                                    builder: (BuildContext context) =>
                                        ChannelInfo(
                                          channelList: channelListObject,
                                          channel: channel,
                                        )),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.6,
                                        child: Text(
                                          channel.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
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
                                  padding: const EdgeInsets.only(left: 10),
                                ),
                              )
                            ],
                          ),
                          //TODO: add favourite to automatic add to playlist
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              MdiIcons.heartOutline,
                              color: Colors.red[400],
                              size: 28,
                            ),
                            splashRadius: 20,
                          )
                        ],
                      );
                    }))
          ],
        ),
        padding: const EdgeInsets.fromLTRB(15, 20, 10, 0),
      ),
    );
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
        child: Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 15, bottom: 10),
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
                                    width:
                                        MediaQuery.of(context).size.width - 160,
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
                          onPressed: () async {
                            String url =
                                'https://www.youtube.com/channel/${channel.id}';
                            if (await canLaunch(url)) {
                              launch(url, forceSafariVC: false);
                            }
                          },
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
    ));
  }
}

class StreamList extends StatelessWidget {
  final List<Stream?> streamList;
  final ChannelList channelList;

  const StreamList(
      {Key? key, required this.streamList, required this.channelList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
        flex: 1,
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: 5,
                width: 60,
                margin: const EdgeInsets.only(top: 15, bottom: 5),
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(1.5)),
                    color: Colors.black.withOpacity(0.1)),
              ),
              Expanded(
                  child: ListView.separated(
                      padding: const EdgeInsets.only(left: 10, right: 5),
                      itemCount: streamList.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          Divider(
                            indent: 40,
                            endIndent: 40,
                            color: Colors.black.withOpacity(0.3),
                          ),
                      itemBuilder: (BuildContext context, int index) {
                        Map streamInfo = streamList[index]!.info;
                        bool inPlaylist =
                            channelList.playList.contains(streamList[index]);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => showBarModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) => StreamInfo(
                                      channelList: channelList,
                                      stream: streamList[index])),
                              child: Row(
                                children: <Widget>[
                                  Image(
                                    image:
                                        NetworkImage(streamInfo['thumbnail']),
                                    width: 100,
                                    height: 56.25,
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    width: MediaQuery.of(context).size.width *
                                        0.55,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          streamInfo['title'],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor),
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
                            ),
                            Material(
                              color: Colors.transparent,
                              child: IconButton(
                                onPressed: () {
                                  if (inPlaylist) {
                                    channelList
                                        .removePlayList(streamList[index]!.id);
                                  } else {
                                    channelList.addPlayList(streamList[index]);
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
                      }))
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
    bool inPlaylist = channelList.playList.contains(stream);
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
                                                  .width -
                                              160,
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
                                onPressed: () async {
                                  String url =
                                      'https://www.youtube.com/watch?v=${streamInfo['id']}';
                                  if (await canLaunch(url)) {
                                    launch(url, forceSafariVC: false);
                                  }
                                },
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
                        width: MediaQuery.of(context).size.width * 0.60,
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

class AddChannel extends StatefulWidget {
  final ChannelList channelList;

  const AddChannel({Key? key, required this.channelList}) : super(key: key);

  @override
  AddChannelState createState() => AddChannelState();
}

class AddChannelState extends State<AddChannel> {
  Channel? channel;

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    void search() async {
      String id = _controller.value.text;
      if (id != '') {
        if (id.contains('channel')) {
          id = id.substring(id.indexOf('channel') + 8);
          if (id.length > 24) {
            id.substring(0, id.indexOf('/'));
          }
        }
        Channel? createdChannel = await Channel.getByWebScroper(id);
        setState(() {
          channel = createdChannel;
        });
      }
    }

    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: <Widget>[
          Material(
            child: TextFormField(
              controller: _controller,
              cursorColor: Theme.of(context).primaryColor,
              textInputAction: TextInputAction.search,
              onFieldSubmitted: (_) => search(),
              maxLength: 100,
              decoration: InputDecoration(
                icon: Icon(
                  MdiIcons.account,
                  color: Theme.of(context).primaryColor,
                ),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                labelText: 'Channel Link / ID',
                suffixIcon: IconButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    search();
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
                      }),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.white),
                  )),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: channel == null
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                      primary: Colors.white,
                      minimumSize: const Size(140, 40)),
                  onPressed: channel != null
                      ? () {
                          if (channel != null) {
                            Navigator.of(context).pop(context);
                            widget.channelList.add(channel!);
                            widget.channelList.save();
                          }
                        }
                      : null,
                  child: const Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
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

  const PlayList({Key? key, required this.channelList}) : super(key: key);

  @override
  PlayListState createState() => PlayListState();
}

class PlayListState extends State<PlayList> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListView.separated(
          padding:
              const EdgeInsets.only(left: 10, right: 5, bottom: 10, top: 10),
          shrinkWrap: true,
          itemCount: widget.channelList.playList.length,
          separatorBuilder: (BuildContext context, int index) => Divider(
            indent: 40,
            endIndent: 40,
            color: Colors.black.withOpacity(0.3),
          ),
          itemBuilder: (BuildContext context, int index) {
            Map streamInfo = widget.channelList.playList[index].info;

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
                      widget.channelList.removePlayList(
                          widget.channelList.playList[index].id);
                      setState(() {});
                    },
                    iconSize: 30,
                    icon: Icon(MdiIcons.playlistMinus, color: Colors.red[400]),
                    splashRadius: 20,
                  ),
                )
              ],
            );
          },
        ),
      ],
    ));
  }
}
