# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Tireless' do
  use_frameworks!

  pod 'GoogleMLKit/PoseDetection'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore', :git => 'https://github.com/invertase/firestore-ios-sdk-frameworks.git', :tag => '10.18.0'
  pod 'FirebaseStorage'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseFirestoreSwift'
  pod 'lottie-ios'
  pod 'Kingfisher'
  pod 'IQKeyboardManagerSwift'
  pod 'JGProgressHUD'
  
  target 'TirelessTests' do
    pod 'GoogleMLKit/PoseDetection'
    pod 'FirebaseCore'
  end
  
end

pre_install do |installer|
  Pod::Installer::Xcode::TargetValidator.send(:define_method, :verify_no_static_framework_transitive_dependencies) {}
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      end
    end
  end
end
