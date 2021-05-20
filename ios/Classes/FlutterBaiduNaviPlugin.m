#import "FlutterBaiduNaviPlugin.h"
// 百度导航
#import "BNaviService.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
// 自带定位
#import <CoreLocation/CoreLocation.h>

/// 初始化结果，保持和Flutter端的枚举int值一致，传递时传int值
typedef NS_ENUM(NSUInteger, BaiduNaviInitResult) {
    BaiduNaviInitResultSuccess = 0,         // 导航Appkey和TTS授权均成功
    BaiduNaviInitResultFail,                // 导航Appkey和TTS授权均失败
    BaiduNaviInitResultMapSuccessTtsFail,   // 导航AppKey成功，TTS失败
    BaiduNaviInitResultMapFailTtsSuccess    // 导航AppKey失败，TTS成功
};
/// 导航结果，保持和Flutter端的枚举int值一致，传递时传int值
typedef NS_ENUM(NSUInteger, BaiduNaviResult) {
    BaiduNaviResultSuccess = 0,             // 成功开启导航
    BaiduNaviResultLocationUnauthorized,    // 定位权限未开启或受限
    BaiduNaviResultNaviServiceNotInited,    // 导航服务未初始化完成
    BaiduNaviResultNetworkError,            // 网络不可用
    BaiduNaviResultTooNear,                 // 起点与终点距离太近
    BaiduNaviResultOtherError               // 其他原因-导航失败
};

@interface FlutterBaiduNaviPlugin()<BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate, BNNaviSoundDelegate>
@end

static FlutterResult _result;

@implementation FlutterBaiduNaviPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_baidu_navi"
            binaryMessenger:[registrar messenger]];
  FlutterBaiduNaviPlugin* instance = [[FlutterBaiduNaviPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  _result = result;
    
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
      result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else if ([@"init" isEqualToString:call.method]) {
      NSString *mapAppKey = call.arguments[@"mapAppKey"];
      NSString *ttsAppId = call.arguments[@"ttsAppId"];
      NSString *ttsApiKey = call.arguments[@"ttsApiKey"];
      NSString *ttsSecretKey = call.arguments[@"ttsSecretKey"];
      [self initNaviWithMapAppKey:mapAppKey ttsAppId:ttsAppId ttsApiKey:ttsApiKey ttsSecretKey:ttsSecretKey];
  } else if ([@"startNavi" isEqualToString:call.method]) {
      double startLon = [call.arguments[@"startLon"] doubleValue];
      double startLat = [call.arguments[@"startLat"] doubleValue];
      double endLon = [call.arguments[@"endLon"] doubleValue];
      double endLat = [call.arguments[@"endLat"] doubleValue];
      [self startNaviWithStartLon:startLon startLat:startLat endLon:endLon endLat:endLat];
  } else {
      result(FlutterMethodNotImplemented);
  }
}

/// 初始化百度导航，含地图导航授权，TTS授权 - 启动时调用
- (void)initNaviWithMapAppKey: (NSString *)mapAppKey ttsAppId: (NSString *)ttsAppId ttsApiKey: (NSString *)ttsApiKey ttsSecretKey: (NSString *)ttsSecretKey  {
    [[BNaviService getInstance] initNaviService:nil success:^{
        [[BNaviService getInstance] authorizeNaviAppKey:mapAppKey completion:^(BOOL navResult) {
            NSLog(@"authorizeNaviAppKey ret = %d",navResult);
            
            [[BNaviService getInstance] authorizeTTSAppId:ttsAppId apiKey:ttsApiKey secretKey:ttsSecretKey completion:^(BOOL ttsResult) {
                NSLog(@"authorizeTTS ret = %d",ttsResult);
                if (navResult && ttsResult) {
                    _result(@(BaiduNaviInitResultSuccess));
                } else if (navResult && !ttsResult) {
                    _result(@(BaiduNaviInitResultMapSuccessTtsFail));
                } else if (!navResult && ttsResult) {
                    _result(@(BaiduNaviInitResultMapFailTtsSuccess));
                } else {
                    _result(@(BaiduNaviInitResultFail));
                }
            }];
        }];
        [[[BNaviService getInstance] soundManager] setSoundDelegate:self];
    } fail:^{
        NSLog(@"百度导航初始化失败");
        _result(@(BaiduNaviInitResultFail));
    }];
}

- (void)startNaviWithStartLon: (double)startLon startLat: (double)startLat endLon: (double)endLon endLat: (double)endLat {
    // 判断定位权限是否开启
    if (![CLLocationManager locationServicesEnabled] ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        _result(@(BaiduNaviResultLocationUnauthorized));
        return;
    }
    // 导航引擎尚未初始化完成，请稍后重试
    if (![[BNaviService getInstance] isServicesInited]) {
        _result(@(BaiduNaviResultNaviServiceNotInited));
        return;
    }
    // TODO: 可添加Loading框
    // [[ISTHUDManager defaultManager] showHUDWithInfo:@"导航启动中..."];
    
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    // 起点 经纬度坐标
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = startLon;
    startNode.pos.y = startLat;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    
    // 终点 经纬度坐标
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = endLon;
    endNode.pos.y = endLat;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    // 关闭openURL,不想跳转百度地图可以设为YES
    [BNaviService_RoutePlan setDisableOpenUrl:YES];
    // 开始算路，算路成功后正式拉起导航，详见BNNaviRoutePlanDelegate实现
    [BNaviService_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Recommend naviNodes:nodesArray time:nil delegete:self userInfo:nil];
}

#pragma mark - BNNaviRoutePlanDelegate

/// 算路成功
- (void)routePlanDidFinished:(NSDictionary *)userInfo {
    // TODO: 如果设置了Loading，此处隐藏
    // [[ISTHUDManager defaultManager] hideAllHUDs];
    _result(@(BaiduNaviResultSuccess));
    // 路径规划成功，开始导航
    [BNaviService_UI showPage:BNaviUI_NormalNavi delegate:self extParams:nil];
}

/// 算路失败
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo {
    // TODO: 如果设置了Loading，此处隐藏
    // [[ISTHUDManager defaultManager] hideAllHUDs];
    switch ([error code]%10000)
    {
        case BNAVI_ROUTEPLAN_ERROR_NONETWORK:       // 网络异常/网络不可用
        case BNAVI_ROUTEPLAN_ERROR_NETWORKABNORMAL:
            _result(@(BaiduNaviResultNetworkError));
            break;
        case BNAVI_ROUTEPLAN_ERROR_NODESTOONEAR:    // 起终点距离起终点太近
            _result(@(BaiduNaviResultTooNear));
            break;
        default:                                    // 其他的错误【如有其他需求的错误判断，此处增加】
            _result(@(BaiduNaviResultOtherError));
            break;
    }
}

/// 算路取消
- (void)routePlanDidUserCanceled:(NSDictionary *)userInfo {
    _result(@(BaiduNaviResultOtherError));
}

#pragma mark - BNNaviUIManagerDelegate

/// 退出导航
- (void)onExitPage:(BNaviUIType)pageType extraInfo:(NSDictionary *)extraInfo {
    if (pageType == BNaviUI_NormalNavi) {
        // NSLog(@"退出导航");
    } else if (pageType == BNaviUI_Declaration) {
        // NSLog(@"退出导航声明页面");
    }
}

#pragma mark - BNNaviSoundDelegate

- (void)onPlayTTS:(NSString *)text {
    // NSLog(@"播放语音：%@", text);
}

- (void)onPlayVoiceSound:(BNVoiceSoundType)type filePath:(NSString *)filePath {
    // NSLog(@"语音filePath：%@", filePath);
}

- (void)onTTSAuthorized:(BOOL)success {
    // NSLog(@"TTS授权：%s", success ? "true" : "false");
}

@end
