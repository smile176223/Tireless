# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Tireless' do
  use_frameworks!

  pod 'GoogleMLKit/PoseDetection', '3.2.0'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Crashlytics'
  pod 'FirebaseFirestoreSwift', '8.14.0-beta'
  pod 'lottie-ios'
  pod 'Kingfisher', '~> 7.7.0'
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'JGProgressHUD'
  
  target 'TirelessTests' do
    pod 'GoogleMLKit/PoseDetection', '3.2.0'
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'Firebase/Crashlytics'
    pod 'FirebaseFirestoreSwift', '8.14.0-beta'
  end
  
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
