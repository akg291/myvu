# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target ‘MyVu’ do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for HelloWorld

pod 'Alamofire'
pod 'AlamofireObjectMapper', '~> 3.0'
pod 'SDWebImage', '~>3.8'
#pod 'SwiftyJSON', '2.0.0'

end


post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '2.3'
        end
    end
end
