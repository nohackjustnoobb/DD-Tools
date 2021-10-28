import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../classes.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  bool isShowingAdvanced = false;
  static List<int> defaultColor = [
    0xffF26868,
    0xffF2BCD1,
    0xff6dc2c9,
    0xff6873F2,
    0xffc28ef9,
  ];
  int pickerColor = Colors.white.hashCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          shadowColor: Colors.black.withOpacity(0.5),
          title: const Text('Settings'),
        ),
        body: Consumer<ChannelList>(builder: (context, channelList, child) {
          return SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.only(top: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 5,
                            ),
                            child: Icon(
                              MdiIcons.downloadNetwork,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Fetch Method',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.7)),
                              ),
                              Text(
                                'Currently Fetching With ${channelList.isUsingAPI ? 'API' : 'WebScraper'}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5)),
                              ),
                            ],
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: TextButton(
                          onPressed: () => channelList.isUsingAPI
                              ? channelList.removeKey()
                              : showBarModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AddAPI(channelList: channelList)),
                          style: TextButton.styleFrom(
                              primary: Colors.white,
                              backgroundColor: channelList.isUsingAPI
                                  ? Colors.red[400]
                                  : Theme.of(context).primaryColor),
                          child: Text(channelList.isUsingAPI
                              ? 'Remove Key'
                              : 'Use API'),
                        ),
                      )
                    ],
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 5,
                              ),
                              child: Icon(
                                MdiIcons.compare,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              'Theme Color',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.7)),
                            ),
                          ],
                        ),
                        Consumer<ThemeModel>(
                            builder: (BuildContext context, themeMdoel,
                                    child) =>
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          content: SingleChildScrollView(
                                            child: ColorPicker(
                                              pickerColor: Color(pickerColor),
                                              onColorChanged: (color) =>
                                                  setState(() => pickerColor =
                                                      color.hashCode),
                                              showLabel: true,
                                              pickerAreaHeightPercent: 0.8,
                                            ),
                                          ),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () {
                                                themeMdoel.changeThemeColor(
                                                    pickerColor);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 2.5),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10)),
                                          child: Container(
                                            child: const Icon(
                                              MdiIcons.palette,
                                              color: Colors.white,
                                              size: 25,
                                            ),
                                            width: 30,
                                            height: 30,
                                            color: Color(themeMdoel.themeColor),
                                          ),
                                        ),
                                      ),
                                    ),
                                    ...defaultColor
                                        .map(
                                          (e) => GestureDetector(
                                            onTap: () =>
                                                e == themeMdoel.themeColor
                                                    ? null
                                                    : themeMdoel
                                                        .changeThemeColor(e),
                                            child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 2.5),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10)),
                                                  child: Container(
                                                    color: Color(e),
                                                    width: 30,
                                                    height: 30,
                                                    child: e ==
                                                            themeMdoel
                                                                .themeColor
                                                        ? const Icon(
                                                            MdiIcons.checkBold,
                                                            color: Colors.white,
                                                          )
                                                        : null,
                                                  ),
                                                )),
                                          ),
                                        )
                                        .toList()
                                  ],
                                ))
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => setState(
                              () => isShowingAdvanced = !isShowingAdvanced),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Icon(
                                    MdiIcons.cog,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Advanced Settings',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.7)),
                                  )
                                ],
                              ),
                              Icon(
                                isShowingAdvanced
                                    ? MdiIcons.chevronDown
                                    : MdiIcons.chevronLeft,
                                color: Theme.of(context).primaryColor,
                                size: 30,
                              )
                            ],
                          ),
                        ),
                        if (isShowingAdvanced)
                          Column(
                            children: <Widget>[
                              Text(
                                'Not recommended to change the options here because it may cause some bugs.',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.5)),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Hybrid Fetch Mode',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.8)),
                                  ),
                                  Switch(
                                    value: channelList.isHybridMode,
                                    onChanged: channelList.isUsingAPI
                                        ? (_) => setState(() => channelList
                                            .toggleHybridMode(enable: _))
                                        : null,
                                    activeTrackColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.6),
                                    activeColor: Theme.of(context).primaryColor,
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Force Play Sound',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.8)),
                                  ),
                                  Switch(
                                    value: channelList.forcePlaySound,
                                    onChanged: (_) => setState(() => channelList
                                        .toggleForcePlaySound(enable: _)),
                                    activeTrackColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.6),
                                    activeColor: Theme.of(context).primaryColor,
                                  )
                                ],
                              ),
                              Consumer<ThemeModel>(
                                builder: (BuildContext context, themeModel,
                                        child) =>
                                    TextButton(
                                        style: TextButton.styleFrom(
                                            primary: Colors.white,
                                            backgroundColor: Colors.red[400],
                                            minimumSize: const Size(140, 30)),
                                        onPressed: () {
                                          channelList.clearAllData();
                                          themeModel.resetTheme();
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text(
                                          'Clear All Data',
                                          style: TextStyle(color: Colors.white),
                                        )),
                              )
                            ],
                          )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'DD-Tools  Ver ${channelList.packageInfo.version}',
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.3)),
                          ),
                          Text(
                            'nohackjustnoobb@github',
                            style:
                                TextStyle(color: Colors.black.withOpacity(0.3)),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        }));
  }
}

class AddAPI extends StatefulWidget {
  final ChannelList channelList;

  const AddAPI({Key? key, required this.channelList}) : super(key: key);

  @override
  AddAPIState createState() => AddAPIState();
}

class AddAPIState extends State<AddAPI> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller.value = TextEditingValue(
        text: widget.channelList.isUsingAPI ? widget.channelList.apiKey : '');
  }

  void saveAPIKey() async {
    bool isValid = _controller.value.text == ''
        ? false
        : await widget.channelList.setAPIKey(_controller.value.text);

    _controller.clear();
    if (isValid) {
      Navigator.of(context).pop();
    } else {
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
                    Text("API Key is not valid"),
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
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Material(
              color: Colors.transparent,
              child: TextFormField(
                controller: _controller,
                cursorColor: Theme.of(context).primaryColor,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => saveAPIKey(),
                maxLength: 50,
                readOnly: widget.channelList.isUsingAPI,
                decoration: InputDecoration(
                  icon: Icon(
                    MdiIcons.key,
                    color: Theme.of(context).primaryColor,
                  ),
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  labelText: 'API Key',
                  suffixIcon: IconButton(
                    onPressed: () => _controller.clear(),
                    icon: Icon(
                      MdiIcons.close,
                      color: Theme.of(context).primaryColor,
                    ),
                    splashRadius: 20,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
          ),
          TextButton(
              style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  primary: Colors.white,
                  minimumSize: const Size(150, 40)),
              onPressed: () => saveAPIKey(),
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.white),
              )),
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
