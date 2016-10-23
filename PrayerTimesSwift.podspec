#
# Be sure to run `pod lib lint PrayerTimesSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PrayerTimesSwift"
  s.version          = "1.1.0"
  s.summary          = "Prayer Times provides a set of handy functions to calculate prayer times for any location around the world"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Prayer Times provides a set of handy functions to calculate prayer times for any location around the world, based on a variety of calculation methods currently used in Muslim communities
                       DESC

  s.homepage         = "https://github.com/alhazmy13/PrayerTimesSwift"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Abdullah Alhazmy" => "me@alhazmy13.net" }
  s.source           = { :git => "https://github.com/alhazmy13/PrayerTimesSwift.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/alhazmy13'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'PrayerTimesSwift' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
