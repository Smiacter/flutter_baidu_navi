import 'dart:async';
import 'package:flutter/services.dart';
import './enum.dart';

class FlutterBaiduNavi {
  static const MethodChannel _channel = const MethodChannel('baidu_navi');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// 初始化百度地图导航
  /// mapAppKey: 【必传】百度地图AppKey，和地图、定位等一致，到百度开放平台应用管理进行查看
  /// ttsAppId: 【可选】TTS语音相关的一整套key，要传时确保三个参数一起传递，可到百度AI开放平台进行创建查看
  /// ttsApiKey:【可选】默认传空，如果传递的相关key不对或为空，TTS授权失败不影响流程【但是导航会没有声音】
  /// ttsSecretKey:【可选】原生插件代码已默认实现内置TTS导航语音，一般情况下只传mapAppKey即可
  /// 注：实践证明，使用内置的TTS语音，key一定要有，及时使用这些KeyTTS授权失败也会有导航声音，而且给包名完全不一样的Android使用也行！
  static Future<BaiduNaviInitResult> init(String mapAppKey,
      {String ttsAppId = '',
      String ttsApiKey = '',
      String ttsSecretKey = ''}) async {
    final int intResult = await _channel.invokeMethod('init', {
      "mapAppKey": mapAppKey,
      "ttsAppId": ttsAppId,
      "ttsApiKey": ttsApiKey,
      "ttsSecretKey": ttsSecretKey
    });

    final BaiduNaviInitResult result = BaiduNaviInitResult.values[intResult];
    return result;
  }

  /// 开始百度地图导航
  /// startLon: 【必传】起点经度
  /// startLat: 【必传】起点纬度
  /// endLon: 【必传】终点经度
  /// endLat: 【必传】终点纬度
  static Future<BaiduNaviResult> startNavi(
    double startLon,
    double startLat,
    double endLon,
    double endLat,
  ) async {
    final int intResult = await _channel.invokeMethod('startNavi', {
      "startLon": startLon,
      "startLat": startLat,
      "endLon": endLon,
      "endLat": endLat
    });

    final BaiduNaviResult result = BaiduNaviResult.values[intResult];
    return result;
  }
}
