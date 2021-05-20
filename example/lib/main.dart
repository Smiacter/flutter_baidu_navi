import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_baidu_navi/enum.dart';
import 'package:flutter/services.dart';
import 'package:flutter_baidu_navi/flutter_baidu_navi.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  BaiduNaviInitResult _initResult;
  BaiduNaviResult _naviResult;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await FlutterBaiduNavi.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  _initNavi();
                },
                child: Text("初始化导航"),
              ),
              Text('导航初始化结果：$_initResult'),
              TextButton(
                onPressed: () {
                  _startNavi();
                },
                child: Text('百度导航'),
              ),
              Text("导航结果：$_naviResult"),
            ],
          ),
        ),
      ),
    );
  }

  _initNavi() async {
    BaiduNaviInitResult result = await FlutterBaiduNavi.init(
      "2GF3O2BTHxYHlMnoEuSFvyLo6c0xBn1h",
      ttsAppId: "24147217",
      ttsApiKey: "vewI9TV5VQRoOGPypStObVL3",
      ttsSecretKey: "QaFknadW5sPlNEicIcrdFV4VeGG0KZvo",
    );
    setState(() {
      _initResult = result;
    });
  }

  _startNavi() async {
    BaiduNaviResult result = await FlutterBaiduNavi.startNavi(
      104.078063,
      30.66664,
      104.122785,
      30.727933,
    );
    setState(() {
      _naviResult = result;
    });
  }
}
