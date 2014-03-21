platform :ios, '6.0'
pod 'Appirater', '~> 2.0.2'
pod 'Facebook-iOS-SDK', :inhibit_warnings => true
pod 'Parse', :inhibit_warnings => true
pod 'MagicalRecord', '~> 2.2', :inhibit_warnings => true
pod 'Reachability', '~> 3.1.1'
pod 'Underscore.m', '~> 0.2.1'
pod 'RMStore', '~> 0.4.2'
pod 'Base64', '~> 1.0.1'
pod 'Evernote-SDK-iOS', '~> 1.3.1'
pod 'APAddressBook', '~> 0.0.6'
#pod 'Localytics-AMP', '~> 2.23'
pod 'KeenClient', '~> 3.2'

#pod 'Analytics', '~> 0.10.2'
#pod 'Dropbox-iOS-SDK', '~> 1.3.9'
#pod 'ASCScreenBrightnessDetector'
#pod 'TWStatus', '~> 0.0.1'

post_install do |installer|
  installer.project.targets.each do |target|
    target.build_configurations.each do |config|
      target.build_settings(config.name)['ARCHS'] = '$(ARCHS_STANDARD_32_BIT)'
      s = config.build_settings['GCC_PREPROCESSOR_DEFINITIONS']
    if s==nil then s = [ '$(inherited)' ] end
    s.push('MR_ENABLE_ACTIVE_RECORD_LOGGING=0');
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] = s
    end
  end
end


#