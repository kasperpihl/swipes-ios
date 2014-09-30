platform :ios, '7.0'
target :Swipes do
    pod 'Appirater', :inhibit_warnings => true
    pod 'Bolts', :inhibit_warnings => true
#    pod 'Facebook-iOS-SDK', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
    pod 'Parse', :inhibit_warnings => true
#    pod 'MagicalRecord', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'RMStore', :inhibit_warnings => true
    pod 'Base64'
    #pod 'Evernote-SDK-iOS', :inhibit_warnings => true
    pod 'APAddressBook'
    pod 'DejalActivityView'
    pod 'KeenClient', :inhibit_warnings => true
    pod 'NSURL+QueryDictionary'
    pod 'DHCShakeNotifier'
end

#target :Swipes_iOS8 do
#    pod 'Appirater', :inhibit_warnings => true
#    pod 'Bolts', :inhibit_warnings => true
#    pod 'Facebook-iOS-SDK', :inhibit_warnings => true
#    pod 'Parse-iOS', :inhibit_warnings => true
#    pod 'ParseFacebookUtils'
#    pod 'MagicalRecord', :inhibit_warnings => true
#    pod 'Reachability'
#    pod 'Underscore.m'
#    pod 'RMStore', '~> 0.4.2', :inhibit_warnings => true
#    pod 'Base64'
#    pod 'Evernote-SDK-iOS', :inhibit_warnings => true
#    pod 'APAddressBook'
#    pod 'DejalActivityView'
#    pod 'KeenClient', :inhibit_warnings => true
#    pod 'NSURL+QueryDictionary'
#    pod 'DHCShakeNotifier'
#end

target :SwipesKit do
    pod 'Appirater', :inhibit_warnings => true
    pod 'Bolts', :inhibit_warnings => true
    pod 'Parse', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
    pod 'Parse', :inhibit_warnings => true
#    pod 'MagicalRecord', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'RMStore', :inhibit_warnings => true
    pod 'Base64'
    pod 'Evernote-SDK-iOS', :inhibit_warnings => true
    pod 'APAddressBook'
    pod 'DejalActivityView'
    pod 'KeenClient', :inhibit_warnings => true
    pod 'NSURL+QueryDictionary'
    pod 'DHCShakeNotifier'
end

target :SwipesToday do
    pod 'Appirater', :inhibit_warnings => true
    pod 'Bolts', :inhibit_warnings => true
    pod 'Parse', :inhibit_warnings => true
    pod 'ParseFacebookUtils'
#    pod 'MagicalRecord', :inhibit_warnings => true
    pod 'Reachability'
    pod 'Underscore.m'
    pod 'RMStore', :inhibit_warnings => true
    pod 'Base64'
    pod 'Evernote-SDK-iOS', :inhibit_warnings => true
    pod 'APAddressBook'
    pod 'DejalActivityView'
    pod 'KeenClient', :inhibit_warnings => true
    pod 'NSURL+QueryDictionary'
    pod 'DHCShakeNotifier'
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

