source 'https://github.com/CocoaPods/Specs.git'

platform :ios, "7.1"

inhibit_all_warnings!

pod 'HockeySDK', '~> 3.8.5'
pod 'Reachability', '~> 3.2'
pod 'AFNetworking', '~> 1.3.4'
pod 'DKHelper', '~> 0.9.6'
pod 'MarqueeLabel', '~> 2.3.5'
pod 'MBXMapKit', '~> 0.8.0'
pod 'Appirater', '~> 2.0'


post_install do | installer |
	require 'fileutils'
	FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.plist', 'Resources/Settings.bundle/Pods-acknowledgements.plist', :remove_destination => true)
end
