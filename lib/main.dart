import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'classes.dart';
import 'Home/home.dart';

void main() async {
  ChannelList channelList =
      await ChannelList.readFromStorage(fetchBackground: true);

  runApp(
    ChangeNotifierProvider.value(value: channelList, child: const App()),
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primaryColor: Colors.indigo[400],
          scaffoldBackgroundColor: const Color(0xFFF5F5F5)),
      home: const Home(),
    );
  }
}
