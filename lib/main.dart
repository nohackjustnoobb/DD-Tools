import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;

import 'Home/home.dart';

void main() async {
  ChannelList channelList =
      await ChannelList.readFromStorage(fetchBackground: true);

  runApp(App(
    channelList: channelList,
  ));
}

class App extends StatelessWidget {
  final ChannelList? channelList;

  const App({Key? key, this.channelList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Colors.indigo[400],
          scaffoldBackgroundColor: const Color(0xFFF5F5F5)),
      home: ChangeNotifierProvider.value(
        value: channelList,
        child: const Home(),
      ),
    );
  }
}

class Channel {
  final String name, id, thumbnail, description;
  final String? subscriberCount, banner;
  Map<String, dynamic>? stream;

  Channel(
      {required this.name,
      required this.id,
      required this.thumbnail,
      required this.description,
      this.subscriberCount,
      this.banner,
      this.stream});

  static dynamic decodeStreamWithRawData(
      Map<String, dynamic> rawData, String owner) {
    try {
      var streamItem = rawData['contents']['twoColumnBrowseResultsRenderer']
                  ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']
              ['contents'][0]['itemSectionRenderer']['contents'][0]
          ['channelFeaturedContentRenderer']['items'][0]['videoRenderer'];

      return {
        'id': streamItem['videoId'],
        'thumbnail': streamItem['thumbnail']['thumbnails'].last['url'],
        'title': streamItem['title']['runs'][0]['text'],
        'viewCount': int.parse(streamItem['viewCountText']['runs'][0]['text']
            .toString()
            .replaceAll(',', '')),
        'owner': owner
      };
    } catch (e) {
      return null;
    }
  }

  static Future getByWebScroper(id) async {
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

      Map<String, dynamic> channelMetadataRenderer =
          initialData['metadata']['channelMetadataRenderer'];

      Map<String, dynamic> c4TabbedHeaderRenderer =
          initialData['header']['c4TabbedHeaderRenderer'];

      return Channel(
          name: channelMetadataRenderer['title'],
          id: id,
          thumbnail: channelMetadataRenderer['avatar']['thumbnails'][0]['url'],
          description: channelMetadataRenderer['description'],
          stream: decodeStreamWithRawData(
              initialData, channelMetadataRenderer['title']),
          subscriberCount: c4TabbedHeaderRenderer['subscriberCountText']
              ['simpleText'],
          banner: c4TabbedHeaderRenderer['mobileBanner']?['thumbnails']
              .last['url']);
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

      stream = decodeStreamWithRawData(initialData, name);
      return stream;
    } else {
      const AlertDialog(
        title: Text('Fail to fetch stream info.'),
      );

      return null;
    }
  }
}

class ChannelList extends ChangeNotifier {
  final _channelList = <Channel>[];
  final _channelIDList = <String>[];
  String? apiKey;

  List<Channel> get channelList => _channelList;

  ChannelList({this.apiKey});

  void add(Channel channel) {
    if (!_channelIDList.contains(channel.id)) {
      _channelIDList.add(channel.id);
      _channelList.add(channel);

      notifyListeners();
    }
  }

  void remove(Channel channel) {
    _channelList.remove(channel);
    _channelIDList.remove(channel.id);

    notifyListeners();
  }

  void removeAll() {
    _channelList.clear();

    notifyListeners();
  }

  void save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('Channel', _channelIDList);
  }

  void fetchInBackground({required List<String> idList}) async {
    for (String id in idList) {
      await addChannelWithWebScropper(id: id);
    }
  }

  //TODO: change to Prefer way
  Future<bool> addChannelWithWebScropper({required String id}) async {
    Channel? channel = await Channel.getByWebScroper(id);
    if (channel != null) add(channel);
    return channel != null;
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

  List<Map?> getStreamList() {
    return _channelList
        .where((element) => element.stream != null)
        .map((e) => e.stream)
        .toList();
  }
}
