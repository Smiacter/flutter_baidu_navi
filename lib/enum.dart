/// 定义百度地图导航相关的返回值枚举
///
///

/// 百度导航初始化结果
/// 导航(地图)AppKey初始化成功即可使用导航功能，当传入了TTS相关Key导航会有声音，否则会没有声音
enum BaiduNaviInitResult {
  /// 导航Appkey和TTS授权均成功【0】
  success,

  /// 导航Appkey和TTS授权均失败【导航AppKey失败导航一定会失败，且会弹出未授权提示框，所以请确保地图应用的AppKey准确无误】【1】
  fail,

  /// 导航AppKey成功，TTS失败【2】
  /// 注：实践证明，使用内置的TTS语音，有TTS相关Key，及时使用这些KeyTTS授权失败也会有导航声音，而且给包名完全不一样的Android使用也行！
  /// 如果TTS相关的Key为空或者不是AI平台申请的Key，导航就很有可能没有声音
  mapSuccessTtsFail,

  /// 导航AppKey失败，TTS成功【导航AppKey失败导航一定会失败，且会弹出未授权提示框，所以请确保地图应用的AppKey准确无误】【3】
  mapFailTtsSuccess,
}

/// 百度导航结果
/// 注：选取了一些常见的错误，如需其他错误类型，需更改插件代码返回相应的值
enum BaiduNaviResult {
  /// 成功开启导航【0】
  success,

  /// 定位权限未开启或受限【1】
  locationUnauthorized,

  /// 导航服务未初始化完成【2】
  naviServiceNotInited,

  /// 网络不可用【3】
  networkError,

  /// 起点与终点距离太近【4】
  tooNear,

  /// 其他原因-导航失败【5】
  otherError,
}
