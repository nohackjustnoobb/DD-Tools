import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:html/parser.dart' show parse;
import 'dart:io' show Platform;

class Channel {
  String name, id, thumbnail, description;
  String? subscriberCount, banner;
  Stream? stream;
  String? _apiKey;

  Channel(
      {required this.name,
      required this.id,
      required this.thumbnail,
      required this.description,
      this.subscriberCount,
      this.banner,
      this.stream});

  static dynamic decodeStreamWithRawData(
      Map<String, dynamic> rawData, String owner, String ownerName) {
    try {
      var streamItem = rawData['contents']['twoColumnBrowseResultsRenderer']
                  ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
              ['contents'][0]['itemSectionRenderer']['contents'][0]
          ['channelFeaturedContentRenderer']['items'][0]['videoRenderer'];

      return Stream(
          title: streamItem['title']['runs'][0]['text'],
          id: streamItem['videoId'],
          owner: owner,
          viewCount: int.parse(streamItem['viewCountText']['runs'][0]['text']
              .toString()
              .replaceAll(',', '')),
          ownerName: ownerName);
    } catch (e) {
      return null;
    }
  }

  static Future getByWebScroper(id) async {
    final response = await http.get(
        Uri.parse('https://www.youtube.com/channel/$id'),
        headers: {'Accept-Language': 'en-US'});

    if (response.statusCode == 200) {
      try {
        // Decode
        Map<String, dynamic> initialData = jsonDecode(parse(response.body)
            .getElementsByTagName('Script')
            .where((element) => element.text.contains('var ytInitialData'))
            .toList()[0]
            .text
            .replaceAll('var ytInitialData = ', '')
            .replaceAll(';', ''));

        Map<String, dynamic> channelMetadataRenderer =
            initialData['metadata']['channelMetadataRenderer'];

        Map<String, dynamic> c4TabbedHeaderRenderer =
            initialData['header']['c4TabbedHeaderRenderer'];

        return Channel(
            name: channelMetadataRenderer['title'],
            id: id,
            thumbnail: channelMetadataRenderer['avatar']['thumbnails'][0]
                ['url'],
            description: channelMetadataRenderer['description'],
            stream: decodeStreamWithRawData(
                initialData, id, channelMetadataRenderer['title']),
            subscriberCount: c4TabbedHeaderRenderer['subscriberCountText']
                ['simpleText'],
            banner: c4TabbedHeaderRenderer['mobileBanner']?['thumbnails']
                .last['url']);
      } catch (e) {
        return null;
      }
    } else {
      const AlertDialog(
        title: Text('Fail to fetch channel info.'),
      );

      return null;
    }
  }

  dynamic updateStreamByWebScropper() async {
    final response = await http.get(
        Uri.parse('https://www.youtube.com/channel/$id'),
        headers: {'Accept-Language': 'en-US'});

    if (response.statusCode == 200) {
      // Decode
      Map<String, dynamic> initialData = jsonDecode(parse(response.body)
          .getElementsByTagName('Script')
          .where((element) => element.text.contains('var ytInitialData'))
          .toList()[0]
          .text
          .replaceAll('var ytInitialData = ', '')
          .replaceAll(';', ''));

      stream = decodeStreamWithRawData(
        initialData,
        id,
        name,
      );
      return stream;
    } else {
      const AlertDialog(
        title: Text('Fail to fetch stream info.'),
      );

      return null;
    }
  }
}

class Stream {
  String title, id, owner, ownerName;
  int viewCount;
  String thumbnail;
  YoutubePlayerIFrame? _player;
  YoutubePlayerController? _controller;
  bool isMuted = Platform.isIOS, isPlaying = true;

  Map get info => {
        'title': title,
        'id': id,
        'owner': owner,
        'ownerName': ownerName,
        'viewCount': viewCount,
        'thumbnail': thumbnail
      };

  YoutubePlayerIFrame? get player => _player;

  Stream(
      {required this.title,
      required this.id,
      required this.owner,
      required this.viewCount,
      required this.ownerName})
      : thumbnail = 'https://i.ytimg.com/vi/$id/maxresdefault_live.jpg';

  static Future getByWebScroper(id) async {
    final response = await http.get(
        Uri.parse('https://www.youtube.com/channel/$id'),
        headers: {'Accept-Language': 'en-US'});

    if (response.statusCode == 200) {
      // Decode
      Map<String, dynamic> initialPlayerResponse = jsonDecode(
          parse(response.body)
              .getElementsByTagName('Script')
              .where((element) =>
                  element.text.contains('var ytInitialPlayerResponse'))
              .toList()[0]
              .text
              .replaceAll('var ytInitialPlayerResponse = ', '')
              .replaceAll(';', ''));

      try {
        Map playerMicroformatRenderer =
            initialPlayerResponse['microformat']['playerMicroformatRenderer'];

        return Stream(
            title: playerMicroformatRenderer['title'],
            id: id,
            owner: playerMicroformatRenderer['externalChannelId'],
            ownerName: playerMicroformatRenderer['ownerChannelName'],
            viewCount: int.parse(playerMicroformatRenderer['viewCount']));
      } catch (e) {
        return null;
      }
    } else {
      const AlertDialog(
        title: Text('Fail to fetch live info.'),
      );

      return null;
    }
  }

  createPlayer() {
    _controller = YoutubePlayerController(
        initialVideoId: id,
        params: YoutubePlayerParams(
            showControls: false,
            mute: Platform.isIOS,
            autoPlay: true,
            desktopMode: true));

    _player = YoutubePlayerIFrame(
      controller: _controller,
      aspectRatio: 16 / 9,
    );

    return _player;
  }

  // control player
  mute() {
    _controller!.mute();
    isMuted = true;
  }

  unMute() {
    _controller!.unMute();
    isMuted = false;
  }

  play() {
    _controller!.play();
    isPlaying = true;
  }

  pause() {
    _controller!.pause();
    isPlaying = false;
  }
}

class ChannelList extends ChangeNotifier {
  final _channelList = <Channel>[];
  final _channelIDList = <String>[];
  final _playList = <Stream>[];
  final String? _apiKey;

  List<Channel> get channelList => _channelList;
  List<Stream> get playList => _playList;
  List<Stream?> get streamList => _channelList
      .where((element) => element.stream != null)
      .map((e) => e.stream)
      .toList();

  ChannelList({apiKey}) : _apiKey = apiKey;

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('Channel', _channelIDList);
  }

  // Channel
  void add(Channel channel) {
    if (!_channelIDList.contains(channel.id)) {
      _channelIDList.add(channel.id);
      _channelList.add(channel);

      notifyListeners();
    }
  }

  void remove(Channel channel) {
    _channelList.remove(channel);
    if (channel.stream != null && _playList.contains(channel.stream)) {
      removePlayList(channel.stream!.id);
    }
    _channelIDList.remove(channel.id);

    notifyListeners();
  }

  void removeAll() {
    _channelList.clear();
    _channelIDList.clear();
    _playList.clear();

    notifyListeners();
  }

  //TODO: change to Prefer way
  Future<bool> addChannelWithWebScropper({required String id}) async {
    Channel? channel = await Channel.getByWebScroper(id);
    if (channel != null) add(channel);
    return channel != null;
  }

  void fetchInBackground({required List<String> idList}) async {
    for (String id in idList) {
      await addChannelWithWebScropper(id: id);
    }
  }

  static Future<ChannelList> readFromStorage(
      {bool fetchBackground = false}) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? idList = prefs.getStringList('Channel');
    ChannelList channelList = ChannelList();

    if (idList == null) return channelList;

    if (fetchBackground) {
      channelList.fetchInBackground(idList: idList);
    } else {
      for (String id in idList) {
        await channelList.addChannelWithWebScropper(id: id);
      }
    }
    return channelList;
  }

  // Playlist
  void addPlayList(Stream? stream) {
    if (stream != null) {
      _playList.add(stream);
      stream.createPlayer();
    }
    notifyListeners();
  }

  void addPlayListWithID(String id) async {
    Stream? stream = await Stream.getByWebScroper(id);

    if (stream != null) {
      addPlayList(stream);
      notifyListeners();
    }
  }

  void removePlayList(String id) {
    Stream? stream = _playList.firstWhere((element) => element.id == id);
    _playList.remove(stream);
    notifyListeners();
  }

  Channel? getChannelWithStream(Stream stream) {
    try {
      return _channelList.firstWhere((element) => element.id == stream.owner);
    } catch (e) {
      return null;
    }
  }

  // controller
  muteAll() {
    for (Stream stream in _playList) {
      stream.mute();
    }
  }

  unMuteAll() {
    for (Stream stream in _playList) {
      stream.unMute();
    }
  }

  playAll() {
    for (Stream stream in _playList) {
      stream.play();
    }
  }

  pauseAll() {
    for (Stream stream in _playList) {
      stream.pause();
    }
  }
}
