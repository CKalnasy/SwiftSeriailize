#
# Be sure to run `pod lib lint SwiftSerialize.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwiftSerialize"
  s.version          = "0.2.0"
  s.summary          = "Library to serialize and deserialze Swift objects."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
Serialize Swift objects to JSON and unserialize them to custom classes.
                       DESC

  s.homepage         = "https://github.com/ckalnasy/SwiftSerialize"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "CKalnasy" => "kalnasy.6@osu.edu" }
  s.source           = { :git => "https://github.com/ckalnasy/SwiftSerialize.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'SwiftSerialize/*'
  s.resource_bundles = {
    'SwiftSerialize' => ['Pod/Assets/*.png']
  }

  s.dependency 'swift-serialize', '~> 1.0'
end
