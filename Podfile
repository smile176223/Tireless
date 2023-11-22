# Uncomment the next line to define a global platform for your project
platform :ios, '15.0'

target 'Tireless' do
  use_frameworks!

  pod 'GoogleMLKit/PoseDetection'
  pod 'FirebaseCore'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'FirebaseCrashlytics'
  pod 'FirebaseFirestoreSwift'
  pod 'lottie-ios'
  pod 'Kingfisher'
  pod 'IQKeyboardManagerSwift'
  pod 'JGProgressHUD'
  
  target 'TirelessTests' do
    pod 'GoogleMLKit/PoseDetection'
    pod 'FirebaseAuth'
    pod 'FirebaseFirestore'
    pod 'FirebaseStorage'
    pod 'FirebaseCrashlytics'
    pod 'FirebaseFirestoreSwift'
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
