Pod::Spec.new do |spec|

  spec.name         = 'YouboraJWPlayer4Adapter'
  spec.version      = '6.6.0'
  
  spec.summary      = 'Adapter to use YouboraLib on JWPlayer.'
  spec.description  = <<-DESC
                         YouboraJWPlayer4Adapter is an adapter used for JWPlayer.
                         DESC

  spec.homepage     = 'https://bitbucket.org/npaw/jwplayer4-adapter-ios#readme'


  # Spec License
  spec.license      = { :type => 'MIT', :file => 'LICENSE.md' }


  # Author Metadata
  spec.author             = { 'NPAW' => 'support@nicepeopleatwork.com' }
  
  # Platform
  spec.ios.deployment_target = '10.0'

  spec.swift_version = '5.0', '5.1', '5.2', '5.3'


  # Source Location
  spec.source       = { :git => 'https://bitbucket.org/npaw/jwplayer4-adapter-ios.git', :tag => spec.version }


  # Source Code
  spec.source_files  = 'YouboraJWPlayerAdapter/**/*.{h,m,swift}'


  # Project Settings
  spec.pod_target_xcconfig = { 'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) YOUBORAJWPLAYERADAPTER_VERSION=' + spec.version.to_s }

  spec.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  # Dependency
  spec.dependency 'YouboraLib', '~> 6.5'
  spec.dependency 'JWPlayerKit', '~> 4.0'

end
