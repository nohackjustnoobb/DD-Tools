import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'classes.dart';
import 'home/home.dart';

void main() async {
  ChannelList channelList = ChannelList();
  await channelList.readFromStorage(fetchBackground: true);
  ThemeModel themeModel = await ThemeModel.getFromStorage();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(
        value: channelList,
      ),
      ChangeNotifierProvider.value(value: themeModel)
    ],
    child: const App(),
  ));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeModel>(
        builder: (BuildContext context, themeColor, child) => MaterialApp(
              title: 'Flutter Demo',
              theme: ThemeData(
                  primaryColor: Color(themeColor.themeColor),
                  scaffoldBackgroundColor: const Color(0xFFF5F5F5)),
              home: const Home(),
            ));
  }
}
