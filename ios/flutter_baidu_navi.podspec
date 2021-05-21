#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_baidu_navi.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_baidu_navi'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'BaiduNaviKit', '6.2.0'
  s.dependency 'BaiduNaviKit/TTS', '6.2.0'
  s.platform = :ios, '8.0'
  s.static_framework = true
  # 以下注释的两行为走的弯路，如上直接pod添加TTS依赖即可，之前没仔细看官方的集成文档啊😂
  # s.vendored_libraries  = 'Libs/*.a'
  # s.resource = ['Resources/*.bundle']

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end
