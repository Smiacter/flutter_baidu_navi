# flutter_baidu_navi

Flutter baidu map navigation - Flutter百度地图导航

## 更新

### 2021.05.21

移除手动添加的TTS静态库和资源包，避免文件过大无法上传的问题，可用git source的方式使用插件

> 再次看了下百度导航官方的文档，发现TTS是支持pod依赖的，因为是注释掉了所以不起眼当时没有看到😂，还是自己不够仔细啊，走了那么多的弯路

## 使用

**添加依赖**

因为Android端的功能尚未开发，固还未发布到pub，目前可使用git source依赖的方式，在`pubspec.yaml`中配置：

```
flutter_baidu_navi:
    git:
      url: https://github.com/Smiacter/flutter_baidu_navi.git
```

或下载源码到本地，使用本地依赖插件的方式，在`pubspec.yaml`中配置插件目录路径

```
flutter_baidu_navi:
	path: ../plugin/flutter_baidu_navi	# 路劲根据自己的存放目录而定
```

**初始化百度地图定位**

```
/// 在适当位置调用初始化，由于使用内置TTS，返回mapSuccess即可
/// 参数依次为百度地图AppKey，TTS的AppId、ApiKey、SecretKey
/// TTS相关的Key为可选参数，如果不传默认为空，导航没声音
FlutterBaiduNavi.init(
  "2GF3O2BTHxYHlMnoEuSFvyLo6c0xBn1h",
  ttsAppId: "24147217",
  ttsApiKey: "vewI9TV5VQRoOGPypStObVL3",
  ttsSecretKey: "QaFknadW5sPlNEicIcrdFV4VeGG0KZvo",
);
```

初始化返回结果为`BaiduNaviInitResult`, 具体可查看源码

```
/// 百度导航初始化结果
enum BaiduNaviInitResult {
  /// 导航Appkey和TTS授权均成功
  success,
  /// 导航Appkey和TTS授权均失败【导航AppKey失败导航一定会失败，且会弹出未授权提示框，所以请确保地图应用的AppKey准确无误】
  fail,
  /// 导航AppKey成功，TTS失败
  /// 注：实践证明，使用内置的TTS语音，有TTS相关Key，及时使用这些KeyTTS授权失败也会有导航声音，而且给包名完全不一样的Android使用也行！
  /// 如果TTS相关的Key为空或者不是AI平台申请的Key，导航就很有可能没有声音
  mapSuccessTtsFail,
  /// 导航AppKey失败，TTS成功【导航AppKey失败导航一定会失败，且会弹出未授权提示框，所以请确保地图应用的AppKey准确无误】
  mapFailTtsSuccess,
}
```

**开始导航**

```
/// 开始导航，参数依次为起点经度、起点纬度、终点经度、终点纬度
FlutterBaiduNavi.startNavi(
  104.078063,
  30.66664,
  104.122785,
  30.727933,
);
```

发起导航返回结果为`BaiduNaviResult`, 具体可查看源码

```
/// 百度导航结果
/// 注：选取了一些常见的错误，如需其他错误类型，需更改插件代码返回相应的值
enum BaiduNaviResult {
  /// 成功开启导航
  success,
  /// 定位权限未开启或受限
  locationUnauthorized,
  /// 导航服务未初始化完成
  naviServiceNotInited,
  /// 网络不可用
  networkError,
  /// 起点与终点距离太近
  tooNear,
  /// 其他原因-导航失败
  otherError,
}
```

### TODO: 

- [ ] Android端功能开发
- [ ] 最终完善，发布到pub

## 更多

其他更多开发细节和说明可以查看博客[百度地图导航Flutter插件(iOS端)](https://www.jianshu.com/p/7c92f35cd765)
