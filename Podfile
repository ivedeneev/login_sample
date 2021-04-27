platform :ios, '12.0'

def rx_pods
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
end

target 'LoginSample' do
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'SnapKit'
  rx_pods

end

target 'LoginSampleTests' do
  use_frameworks!
  inhibit_all_warnings!
  
  rx_pods
  pod 'RxTest'
  pod 'RxBlocking'

end



post_install do |installer|
  # Xcode 12 fixes
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
        config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'arm64'
      end
    end
end

