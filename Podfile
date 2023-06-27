# Uncomment the next line to define a global platform for your project
# platform :ios, '13.0'

target 'Tireless' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Tireless

  pod 'SwiftLint'
  pod 'GoogleMLKit/PoseDetection'
  pod 'lottie-ios'
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Storage'
  pod 'Firebase/Crashlytics'
  pod 'FirebaseFirestoreSwift', '8.14.0-beta'
  pod 'Kingfisher', '~> 7.8.1'
  pod 'IQKeyboardManagerSwift', '6.3.0'
  pod 'JGProgressHUD'
  
  target 'TirelessTests' do
    inherit! :search_paths
    pod 'Firebase/Auth'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'Firebase/Crashlytics'
    pod 'GoogleMLKit/PoseDetection'
  end

end

post_install do |pi|
  pi.pods_project.targets.each do |t|
    t.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
