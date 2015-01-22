#
# Be sure to run `pod lib lint OpenInGoogleMaps.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "OpenInGoogleMaps"
  s.version          = "0.1.0"
  s.summary          = "A helper class to simplify the task of opening a map directly in Google Maps on iOS"
  s.description      = <<-DESC
                       The `OpenInGoogleMapsController` class is designed to make it easy for an iOS
developer to open a map, show a Street View location, or show a set of directions directly in Google
Maps. The class supports using the `x-callback-URL` standard so that you can add a "Back to my app"
button directly within Google Maps, and supports a number of fallback strategies, so that you can
automatically open the map in another application if the user does not have Google Maps installed.
                       DESC
  s.homepage         = "https://github.com/googlemaps/OpenInGoogleMaps-iOS"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { "Todd Kerpelman" => "kerp@google.com" }
  s.source           = { :git => "https://github.com/googlemaps/OpenInGoogleMaps-iOS.git", :tag => s.version.to_s }
  s.platform     = :ios, '7.0'
  s.requires_arc = true
  s.source_files = 'OpenInGoogleMapsController.{h,m}'
  s.frameworks = 'CoreLocation'
end
