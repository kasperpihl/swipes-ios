platform :ios, '6.0'
pod 'Appirater', :inhibit_warnings => true
pod 'Bolts', :inhibit_warnings => true
pod 'Facebook-iOS-SDK', :inhibit_warnings => true
pod 'Parse', :inhibit_warnings => true
pod 'MagicalRecord', :inhibit_warnings => true
pod 'Reachability'
pod 'Underscore.m'
pod 'RMStore', '~> 0.4.2', :inhibit_warnings => true
pod 'Base64'
pod 'Evernote-SDK-iOS', :inhibit_warnings => true
pod 'APAddressBook'
# there is a problem with version 3.2.10 that breaks Facebook build
pod 'KeenClient', '<= 3.2.9'
#pod 'MMDrawerController', '~> 0.5.3' - now part of libs as it was modified

#pod 'Localytics-AMP', '~> 2.23'
#pod 'Analytics', '~> 0.10.2'
#pod 'Dropbox-iOS-SDK', '~> 1.3.9'
#pod 'ASCScreenBrightnessDetector'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
        #      target.build_settings(config.name)['ARCHS'] = '$(ARCHS_STANDARD_32_BIT)'
      s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
    if s==nil then s = [ '$(inherited)' ] end
    s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0');
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
    end
  end
end


#
