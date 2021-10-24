import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:html/parser.dart' show parse;

class Channel {
  String name, id, thumbnail, description;
  String? subscriberCount, banner;
  Stream? stream;

  Channel(
      {required this.name,
      required this.id,
      required this.thumbnail,
      required this.description,
      this.subscriberCount,
      this.banner,
      this.stream});

  static Future getByAPI(
      {required id,
      required api,
      ChannelList? channelList,
      bool isHybridMode = true}) async {
    try {
      final response = await http.get(Uri.parse(
          'https://youtube.googleapis.com/youtube/v3/channels?part=statistics&part=snippet&part=brandingSettings&id=$id&key=$api'));
      if (response.statusCode == 200) {
        Map channelData = jsonDecode(response.body)['items'][0];

        int subscriberCount =
            int.parse(channelData['statistics']['subscriberCount']);

        String toString(int value) {
          const units = <int, String>{
            1000000000: 'B',
            1000000: 'M',
            1000: 'K',
          };
          return units.entries
              .map((e) => '${value ~/ e.key}${e.value}')
              .firstWhere((e) => !e.startsWith('0'), orElse: () => '$value');
        }

        Channel channel = Channel(
            name: channelData['snippet']['title'],
            id: id,
            thumbnail: channelData['snippet']['thumbnails']['high']['url'],
            description: channelData['snippet']['description'],
            subscriberCount: '${toString(subscriberCount)} subscribers',
            banner: channelData['brandingSettings']['image']
                ['bannerExternalUrl']);

        if (isHybridMode) {
          channel.updateStreamByWebScropper(channelList: channelList);
        } else {
          dynamic result = await channel.updateStreamByAPI(api: api);
          if (result is Exception) {
            return Exception('reachQuotaLimit');
          }
        }

        return channel;
      } else if (response.statusCode == 403) {
        return Exception('reachQuotaLimit');
      } else {
        throw Exception();
      }
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

        Stream? stream;
        try {
          var streamItem = initialData['contents']
                          ['twoColumnBrowseResultsRenderer']['tabs'][0]
                      ['tabRenderer']['content']['sectionListRenderer']
                  ['contents'][0]['itemSectionRenderer']['contents'][0]
              ['channelFeaturedContentRenderer']['items'][0]['videoRenderer'];

          stream = Stream(
              title: streamItem['title']['runs'][0]['text'],
              id: streamItem['videoId'],
              owner: id,
              viewCount: int.parse(streamItem['viewCountText']['runs'][0]
                      ['text']
                  .toString()
                  .replaceAll(',', '')),
              ownerName: channelMetadataRenderer['title'],
              ownerThumbnail: channelMetadataRenderer['avatar']['thumbnails'][0]
                  ['url']);
        } catch (e) {
          stream = null;
        }

        return Channel(
            name: channelMetadataRenderer['title'],
            id: id,
            thumbnail: channelMetadataRenderer['avatar']['thumbnails'][0]
                ['url'],
            description: channelMetadataRenderer['description'],
            stream: stream,
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

  Future updateStreamByWebScropper({ChannelList? channelList}) async {
    try {
      final response = await http.get(
          Uri.parse('https://www.youtube.com/embed/live_stream?channel=$id'),
          headers: {'Accept-Language': 'en-US'});

      if (response.statusCode == 200) {
        // Decode
        Map<String, dynamic> playerVars = jsonDecode(response.body
            .substring(response.body.indexOf('embedded_player_response') + 27,
                response.body.lastIndexOf('video_id') - 3)
            .replaceAll('\\"', '"'));

        if (playerVars['previewPlayabilityStatus']['status'] != 'OK') {
          throw Exception('');
        }

        stream = Stream(
            title: playerVars['embedPreview']['thumbnailPreviewRenderer']
                ['title']['runs'][0]['text'],
            id: playerVars['embedPreview']['thumbnailPreviewRenderer']
                    ['playButton']['buttonRenderer']['navigationEndpoint']
                ['watchEndpoint']['videoId'],
            owner: id,
            ownerName: name,
            ownerThumbnail: thumbnail);

        if (channelList != null) {
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          channelList.notifyListeners();
        }

        return stream;
      } else {
        throw Exception();
      }
    } catch (e) {
      const AlertDialog(
        title: Text('Fail to fetch stream info.'),
      );

      if (stream != null && channelList != null) {
        channelList.removePlayList(stream!.id);
      }

      stream = null;
      return null;
    }
  }

  Future updateStreamByAPI({
    required String api,
    ChannelList? channelList,
  }) async {
    try {
      final response = await http.get(Uri.parse(
          'https://youtube.googleapis.com/youtube/v3/search?part=snippet&channelId=$id&eventType=live&type=video&key=$api'));
      if (response.statusCode == 200) {
        Map streamData = jsonDecode(response.body)['items'][0];

        if (stream != null && stream!.id == streamData['id']['videoId']) {
          stream = Stream(
            title: streamData['snippet']['title'],
            id: streamData['id']['videoId'],
            owner: id,
            ownerName: name,
            ownerThumbnail: thumbnail,
          );
        }

        if (channelList != null) {
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          channelList.notifyListeners();
        }

        return stream;
      } else if (response.statusCode == 403) {
        return Exception('reachQuotaLimit');
      } else {
        throw Exception();
      }
    } catch (e) {
      if (stream != null && channelList != null) {
        channelList.removePlayList(stream!.id);
      }

      stream = null;
      return null;
    }
  }
}

class Stream {
  String title, id, owner, ownerName, ownerThumbnail;
  int? viewCount;
  String thumbnail;
  YoutubePlayerIFrame? _player;
  YoutubePlayerController? _controller;
  bool isMuted = true, isPlaying = true;

  Map get info => {
        'title': title,
        'id': id,
        'owner': owner,
        'ownerName': ownerName,
        'viewCount': viewCount,
        'thumbnail': thumbnail,
        'ownerThumbnail': ownerThumbnail
      };

  YoutubePlayerIFrame? getPlayer(bool? muted) {
    if (muted != null && muted != isMuted) {
      createPlayer(muted: muted);
    }

    return _player;
  }

  Stream(
      {required this.title,
      required this.id,
      required this.owner,
      this.viewCount,
      required this.ownerName,
      required this.ownerThumbnail})
      : thumbnail = 'https://i.ytimg.com/vi/$id/maxresdefault_live.jpg';

  static Future getByWebScroper(id) async {
    final response = await http.get(
        Uri.parse('https://www.youtube.com/watch?v=$id'),
        headers: {'Accept-Language': 'en-US'});

    if (response.statusCode == 200) {
      try {
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

        Map playerMicroformatRenderer =
            initialPlayerResponse['microformat']['playerMicroformatRenderer'];

        Map<String, dynamic> initialData = jsonDecode(parse(response.body)
            .getElementsByTagName('Script')
            .where((element) => element.text.contains('var ytInitialData'))
            .toList()[0]
            .text
            .replaceAll('var ytInitialData = ', '')
            .replaceAll(';', ''));

        return Stream(
            title: playerMicroformatRenderer['title']['simpleText'],
            id: id,
            owner: playerMicroformatRenderer['externalChannelId'],
            ownerName: playerMicroformatRenderer['ownerChannelName'],
            viewCount: int.parse(playerMicroformatRenderer['viewCount']),
            ownerThumbnail: initialData['contents']['twoColumnWatchNextResults']
                    ['results']['results']['contents']
                .last['videoSecondaryInfoRenderer']['owner']
                    ['videoOwnerRenderer']['thumbnail']['thumbnails']
                .last['url']);
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

  createPlayer({bool? muted}) {
    isMuted = muted ?? true;
    _controller = YoutubePlayerController(
        initialVideoId: id,
        params: YoutubePlayerParams(
            showControls: false,
            mute: isMuted,
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

  syncStatus() {
    isMuted ? mute() : unMute();
    isPlaying ? play() : pause();
  }
}

class ChannelList extends ChangeNotifier {
  final _channelList = <Channel>[];
  final _channelIDList = <String>[];
  final _playList = <Stream>[];
  final _playIDList = <String>[];
  String? _apiKey;
  bool keyReachLimit = false, isHybridMode = true, forcePlaySound = false;

  List<Channel> get channelList => _channelList;
  List<Stream> get playList => _playList;
  List<String> get playIDList => _playIDList;
  List<Stream?> get streamList => _channelList
      .where((element) => element.stream != null)
      .map((e) => e.stream)
      .toList();

  bool get isUsingAPI => _apiKey != null;
  String get apiKey => _apiKey.toString();

  ChannelList({apiKey}) : _apiKey = apiKey;

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('Channel', _channelIDList);
    prefs.setBool('hybridMode', isHybridMode);
    prefs.setString('API', _apiKey.toString());
    prefs.setBool('forcePlaySound', forcePlaySound);
  }

  void toggleHybridMode({bool? enable}) {
    isHybridMode = enable ?? !isHybridMode;
    save();
  }

  void toggleForcePlaySound({bool? enable}) {
    forcePlaySound = enable ?? !forcePlaySound;
    save();
  }

  Future updateStreamWithPreferWay({required Channel channel}) async {
    dynamic stream;

    if (_apiKey != null && !keyReachLimit) {
      stream = await channel.updateStreamByAPI(
          api: _apiKey.toString(), channelList: this);
      if (stream is Exception) {
        keyReachLimit = true;
        updateStreamWithPreferWay(channel: channel);
      }
    } else {
      stream = channel.updateStreamByWebScropper(channelList: this);
    }
    return stream;
  }

  Future updateStream() async {
    for (Channel channel in _channelList) {
      await updateStreamWithPreferWay(channel: channel);
    }
    return null;
  }

  // API
  Future<bool> setAPIKey(String key) async {
    try {
      final response = await http.get(Uri.parse(
          'https://youtube.googleapis.com/youtube/v3/activities?part=id&channelId=UC_x5XG1OV2P6uZZ5FSM9Ttw&key=$key'));
      if (response.statusCode == 200) {
        _apiKey = key;
        save();
        notifyListeners();
        return true;
      } else {
        throw Exception('API Key is not valid');
      }
    } catch (e) {
      return false;
    }
  }

  void removeKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('API');
    _apiKey = null;
    keyReachLimit = false;
    notifyListeners();
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

  Future<bool> addChannelWithPreferWay({required String id}) async {
    dynamic channel;
    if (_apiKey != null && !keyReachLimit) {
      channel = await Channel.getByAPI(
          id: id, api: _apiKey, channelList: this, isHybridMode: isHybridMode);
      if (channel is Exception) {
        keyReachLimit = true;
        addChannelWithPreferWay(id: id);
      }
    } else {
      channel = await Channel.getByWebScroper(id);
    }
    if (channel != null && channel is! Exception) add(channel);
    return channel != null;
  }

  void fetchInBackground({required List<String> idList}) async {
    for (String id in idList) {
      await addChannelWithPreferWay(id: id);
    }
  }

  Future<void> readFromStorage({bool fetchBackground = false}) async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? idList = prefs.getStringList('Channel');
    _apiKey = prefs.getString('API');
    isHybridMode = prefs.getBool('hybridMode') ?? true;
    forcePlaySound = prefs.getBool('forcePlaySound') ?? false;

    if (idList == null) return;

    if (fetchBackground) {
      fetchInBackground(idList: idList);
    } else {
      for (String id in idList) {
        await addChannelWithPreferWay(id: id);
      }
    }
    return;
  }

  // Playlist
  void addPlayList(Stream? stream) {
    if (stream != null && !_playList.contains(stream)) {
      _playList.add(stream);
      _playIDList.add(stream.id);
      stream.createPlayer(muted: !forcePlaySound);
    }
    notifyListeners();
  }

  void addMultiplePlayList(List<Stream?> streamList) {
    List<Stream> streamListFiltered = streamList.whereType<Stream>().toList();
    if (streamListFiltered.isNotEmpty) {
      _playList.addAll(streamListFiltered);
      _playIDList.addAll(streamListFiltered.map((e) => e.id).toList());
      for (var stream in streamListFiltered) {
        stream.createPlayer();
      }
      notifyListeners();
    }
  }

  void removePlayList(String id) {
    Stream? stream = _playList.firstWhere((element) => element.id == id);
    _playList.remove(stream);
    _playIDList.remove(stream.id);
    notifyListeners();
  }

  void clearPlayList() {
    _playList.clear();
    _playIDList.clear();
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

  syncAll() {
    for (Stream stream in _playList) {
      stream.syncStatus();
    }
  }
}
