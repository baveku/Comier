#
# Be sure to run `pod lib lint Comier.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Comier'
  s.version          = '0.8.0'
  s.summary          = 'MVVM-AppBase for Texture + IGListKit + DifferenceKit'
  s.swift_version = '5.4'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
MVVM with TextureGroup + IGListKit + DifferenceKit + Swinject + Reactive Programing
                       DESC

  s.homepage         = 'https://github.com/baveku/Comier'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'baveku' => 'baveku@gmail.com' }
  s.source           = { :git => 'https://github.com/baveku/Comier.git' }
#   s.social_media_url = 'https://twitter.com'

  s.ios.deployment_target = '10.0'
  s.public_header_files = 'Comier/Extensions/**/*.h'
  s.source_files = "Comier/Classes/**/*", "Comier/Extensions/**/*"
  s.frameworks = 'UIKit'
  s.dependency 'RxSwift'
  s.dependency 'RxCocoa'
  s.dependency 'Swinject'
  s.dependency 'Texture'
  s.dependency 'Texture/IGListKit'
  s.dependency 'Moya', '>= 14.0.0'
  s.dependency 'Moya/RxSwift', '>= 14.0.0'
  s.dependency 'ObjectMapper'
  s.dependency 'NVActivityIndicatorView'
  s.dependency 'DifferenceKit'
  s.dependency 'PromisesSwift'
end
