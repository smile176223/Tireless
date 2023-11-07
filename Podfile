# Uncomment the next line to define a global platform for your project
# platform :ios, '14.0'

target 'Tireless' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Tireless

  pod 'SwiftLint'
  pod 'GoogleMLKit/PoseDetection', '3.2.0'
  pod 'lottie-ios'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Crashlytics'
  pod 'FirebaseFirestoreSwift', '8.14.0-beta'
  pod 'Kingfisher', '~> 7.7.0'
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'JGProgressHUD'
  
end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
      end
    end
  end
end
