source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "7.1"

inhibit_all_warnings!

def corePods
	pod 'HockeySDK', '~> 4.1.0'
	pod 'Reachability', '~> 3.2'
	pod 'AFNetworking', '~> 1.3.4'
	pod 'DKHelper', '~> 2.2.3'
	pod 'MarqueeLabel', '~> 2.3.5'
	pod 'Appirater', '~> 2.0'
	pod 'Google/Analytics' #No specific version allowed
end

target 'Wheelmap-Alpha' do
    corePods
end

target 'Wheelmap-Beta' do
    corePods
end

target 'Wheelmap-Live' do
    corePods
end

post_install do |installer|

    installer.pods_project.targets.each do |target|
        if target.name.include?("Pods-")
            require 'fileutils'
            FileUtils.cp_r('Pods/Target Support Files/' + target.name + '/' + target.name + '-acknowledgements.plist',
            'Resources/Settings.bundle/Pods-acknowledgements.plist', :remove_destination => true)
        end
        
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
        end
    end
end