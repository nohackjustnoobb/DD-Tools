import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' show parse;

import 'Home/home.dart';

void main() async {
  ChannelList channelList = await ChannelList.readFromStorage();

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

  List<Channel> get channelList => _channelList;

  void add(Channel channel) {
    if (!_channelIDList.contains(channel.id)) {
      _channelIDList.add(channel.id);
      _channelList.add(channel);

      notifyListeners();
    }
  }

  void remove(Channel channel) {
    _channelList.remove(channel);

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

  static Future<ChannelList> readFromStorage() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? idList = prefs.getStringList('Channel');
    ChannelList channelList = ChannelList();

    for (String id in idList!) {
      channelList.add(await Channel.getByWebScroper(id));
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
