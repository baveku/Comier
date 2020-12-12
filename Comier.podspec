#
# Be sure to run `pod lib lint Comier.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Comier'
  s.version          = '0.1.1'
  s.summary          = 'AppBase for TextureLib'
  s.swift_version = '5.3'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
BaseApp use TextureGroup
                       DESC

  s.homepage         = 'https://github.com/baveku/Comier'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'baveku' => 'baveku@gmail.com' }
  s.source           = { :git => 'https://github.com/baveku/Comier.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'

  s.source_files = 'Comier/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Comier' => ['Comier/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'Swinject'
  s.dependency 'Texture'
  s.dependency 'Texture/IGListKit'
end
