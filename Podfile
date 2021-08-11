platform :ios, '12.0'

#def shared
#
#end

target 'faceIdTest' do
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'SnapKit'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'IVCollectionKit'
  pod 'SwiftGen'
  pod 'Resolver'

end

target 'faceIdTestTests' do
  use_frameworks!
  inhibit_all_warnings!
  
#  pod 'SnapKit'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'RxTest'
  pod 'RxBlocking'
  pod 'Resolver'

end

target 'faceIdTestUITests' do
  use_frameworks!
  inhibit_all_warnings!
  
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'RxTest'
  pod 'RxBlocking'
  pod 'Resolver'
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
