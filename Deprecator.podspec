#
#  Be sure to run `pod spec lint Deprecator.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Deprecator"
  s.version      = "0.10.0"
  s.summary      = "Deprecator automatically handles version checking against a hosted JSON file."
  s.homepage     = "http://red.to"

  s.license      = "MIT"
  s.author             = { "Red Davis" => "me@red.to" }
  s.social_media_url   = "http://twitter.com/reddavis"

  s.ios.deployment_target = "10.0"

  s.source       = { :git => "https://github.com/togethera/Deprecator-iOS.git", :tag => "#{s.version}" }
  s.source_files = ['Deprecator/Source/*.swift']
end
