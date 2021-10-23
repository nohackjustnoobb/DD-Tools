import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';

import '../classes.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
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
