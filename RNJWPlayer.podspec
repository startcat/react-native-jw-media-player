require 'json'

package = JSON.parse(File.read('./package.json'))

# folly_version must match the version used in React Native
# See folly_version in react-native/React/FBReactNativeSpec/FBReactNativeSpec.podspec
folly_compiler_flags = '-DFOLLY_NO_CONFIG -DFOLLY_MOBILE=1 -DFOLLY_USE_LIBCPP=1 -Wno-comma -Wno-shorten-64-to-32'
folly_version = '2021.06.28.00-v2'

Pod::Spec.new do |s|
  s.name         = 'RNJWPlayer'
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']
  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "12.0"
  s.source       = { :git => "https://github.com/startcat/react-native-jw-media-player.git", :tag => "v#{s.version}" }
  s.source_files  = "RNJWPlayer/*.{h,m}"
  s.dependency   'JWPlayerKit', '~> 4.6.2'
  s.dependency   'google-cast-sdk', '~> 4.7.0'
  s.dependency   'React'
  s.dependency "React-Core"
  s.dependency "React-Codegen"
  s.dependency "RCT-Folly", folly_version
  s.dependency "RCTRequired"
  s.dependency "RCTTypeSafety"
  s.dependency "ReactCommon/turbomodule/core"
  s.compiler_flags  = folly_compiler_flags
  s.pod_target_xcconfig    = {
    "HEADER_SEARCH_PATHS" => "\"$(PODS_ROOT)/boost\""
  }
  # s.static_framework = true
  s.info_plist = {
    'NSBluetoothAlwaysUsageDescription' => 'We will use your Bluetooth for media casting.',
    'NSBluetoothPeripheralUsageDescription' => 'We will use your Bluetooth for media casting.',
    'NSLocalNetworkUsageDescription' => 'We will use the local network to discover Cast-enabled devices on your WiFi network.',
    'Privacy - Local Network Usage Description' => 'We will use the local network to discover Cast-enabled devices on your WiFi network.',
    'NSMicrophoneUsageDescription' => 'We will use your Microphone for media casting.'
  }
  
end
