source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'

target :Swipes do
    pod 'M13BadgeView'
    pod 'youtube-ios-player-helper'
    pod 'Appirater', :inhibit_warnings => true
    pod 'Bolts', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
    pod 'Parse', :inhibit_warnings => true
    pod 'Facebook-iOS-SDK', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'RMStore', :inhibit_warnings => true
    pod 'Base64'
    pod 'APAddressBook'
    pod 'DejalActivityView'
    pod 'NSURL+QueryDictionary'
    pod 'DHCShakeNotifier'
    pod 'Intercom'
    pod 'GoogleAnalytics-iOS-SDK'
    pod 'BobPullToRefresh'
end

target :SwipesKit do
    pod 'Appirater', :inhibit_warnings => true
    pod 'Bolts', :inhibit_warnings => true
    pod 'Parse', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
    pod 'Parse', :inhibit_warnings => true
    pod 'Facebook-iOS-SDK', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'RMStore', :inhibit_warnings => true
    pod 'Base64'
    pod 'APAddressBook'
    pod 'DejalActivityView'
    pod 'NSURL+QueryDictionary'
    pod 'DHCShakeNotifier'
    pod 'Intercom'
    pod 'GoogleAnalytics-iOS-SDK'
end

target :SwipesToday do
    pod 'Parse', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
    pod 'Facebook-iOS-SDK', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'Base64'
    pod 'Intercom'
    pod 'GoogleAnalytics-iOS-SDK'
end

target :SwipesShare do
    pod 'Parse', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
    pod 'Facebook-iOS-SDK', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'Base64'
    pod 'Intercom'
    pod 'GoogleAnalytics-iOS-SDK'
    pod 'UITextView+Placeholder'
end

#link_with 'Swipes', 'Swipes_iOS8', 'SwipesKit'
#link_with 'Swipes', 'SwipesKit'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
    if s==nil then s = [ '$(inherited)' ] end
    s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0');
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
    end
  end
end

