#
# Be sure to run `pod lib lint AppServiceKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AppServiceKit"
  s.version          = "0.9.0"
  s.summary          = "An Objective-C library for communicating with the App messaging service."

  s.description      = <<-DESC
An Objective-C library for communicating with the App messaging service.
  DESC

  s.homepage         = "https://github.com/signalapp/AppServiceKit"
  s.license          = 'GPLv3'
  s.author           = { "Frederic Jacobs" => "github@fredericjacobs.com" }
  s.source           = { :git => "https://github.com/STACLE-COMMUNICATIONS/AppServiceKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/FredericJacobs'

  s.platform     = :ios, '11.0'
  s.requires_arc = true
  s.source_files = 'AppServiceKit/src/**/*.{h,m,mm,swift}'

  # We want to use modules to avoid clobbering CocoaLumberjack macros defined
  # by other OWS modules which *also* import CocoaLumberjack. But because we
  # also use Objective-C++, modules are disabled unless we explicitly enable
  # them
  s.compiler_flags = "-fcxx-modules"

  s.prefix_header_file = 'AppServiceKit/src/TSPrefix.h'
  s.xcconfig = { 'OTHER_CFLAGS' => '$(inherited) -DSQLITE_HAS_CODEC',
                 'USER_HEADER_SEARCH_PATHS' => '$(inherited) $(SRCROOT)/libwebp/src'   }

  s.resources = [
    "AppServiceKit/Resources/Certificates/*",
    "AppServiceKit/Resources/schema.sql"
  ]

  s.dependency 'Curve25519Kit'
  s.dependency 'CocoaLumberjack'
  s.dependency 'AFNetworking/NSURLSession'
  s.dependency 'Mantle'
  s.dependency 'Starscream'
  s.dependency 'libPhoneNumber-iOS'
  s.dependency 'GRKOpenSSLFramework'
  s.dependency 'SAMKeychain'
  s.dependency 'Reachability'
  s.dependency 'SwiftProtobuf'
  s.dependency 'SignalClient'
  s.dependency 'SignalCoreKit'
  s.dependency 'SignalMetadataKit'
  s.dependency 'GRDB.swift/SQLCipher'
  s.dependency 'libwebp'
  s.dependency 'PromiseKit', "~> 6.0"
  s.dependency 'YYImage/WebP'
  s.dependency 'blurhash'
  s.dependency 'SignalArgon2'

  s.test_spec 'Tests' do |test_spec|
    test_spec.source_files = 'AppServiceKit/tests/**/*.{h,m,swift}'
    test_spec.resources = 'AppServiceKit/tests/**/*.{json,encrypted,webp}'
  end
end
