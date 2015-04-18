#
#  Be sure to run `pod spec lint JsonObject.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|


  s.name = "JsonSerializer"
  s.version = "0.8.0"
  s.summary = "Swift JSON Serialization Made Easy"
  s.homepage = "https://github.com/Skyvive/JsonSerializer"
  s.license = { :type => "MIT", :file => "LICENSE" }
  s.author = { "Brad Hilton" => "brad.hilton.nw@gmail.com" }
  s.ios.deployment_target = "8.3"
  s.osx.deployment_target = "10.9"
  s.source = { :git => "https://github.com/Skyvive/JsonSerializer.git", :tag => "0.8.0" }
  s.source_files  = "JsonSerializer", "JsonSerializer/**/*.{swift,h,m}"
  s.requires_arc = true

end
