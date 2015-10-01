source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '7.0'
inhibit_all_warnings!

def shared_pods
    pod 'Parse'
    pod 'ParseFacebookUtils'
    pod 'evernote-cloud-sdk-ios'
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'Base64'
    pod 'Intercom'
    pod 'GoogleAnalytics'
end

target :'Swipes for Teams' do
    shared_pods
    pod 'M13BadgeView'
    pod 'youtube-ios-player-helper'
    pod 'Appirater'
    pod 'RMStore'
    pod 'APAddressBook'
    pod 'DejalActivityView'
    pod 'NSURL+QueryDictionary'
    pod 'DHCShakeNotifier'
    pod 'BobPullToRefresh'
    pod 'Fabric'
    pod 'Crashlytics'
end

target :'Swipes for Teams Today' do
    shared_pods
end

target :'Swipes for Teams Share' do
    shared_pods
    pod 'UITextView+Placeholder'
end

#target :SwipesKit do
#    shared_pods
#    pod 'Appirater'
#    pod 'RMStore'
#    pod 'APAddressBook'
#    pod 'DejalActivityView'
#    pod 'NSURL+QueryDictionary'
#    pod 'DHCShakeNotifier'
#end

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

