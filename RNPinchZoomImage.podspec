require 'json'
package = JSON.parse(File.read(File.join(__dir__, 'package.json')))
Pod::Spec.new do |s|
  s.name         = "RNPinchZoomImage"
  s.version      = package['version']
  s.summary      = package['description']
  s.description  = package['description']
  s.homepage     = package['homepage']
  s.license      = package['license']
  s.author             = package['author']
  s.platform     = :ios, "9.0"
  s.summary       = "Component supports view image with pinch and zoom action"
  s.homepage      = "https://github.com/moonjava2005/react-native-pinch-zoom-image"
  s.source       = { :git => "git://github.com/moonjava2005/react-native-pinch-zoom-image.git", :tag => s.version }
  s.source_files  = "ios/**/*.{h,m}"
  s.requires_arc = true
  s.dependency 'React'

end

  