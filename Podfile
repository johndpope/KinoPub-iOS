source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'

target 'KinoPub' do

  use_frameworks!
  inhibit_all_warnings!
  pod 'Alamofire'
  pod 'AlamofireObjectMapper'
  pod 'AlamofireNetworkActivityLogger'
  pod 'AlamofireImage'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'SwiftyUserDefaults'
  pod 'KeychainSwift'
  pod 'LKAlertController'
  pod 'InteractiveSideMenu'
  pod 'SwifterSwift'
  pod 'DGCollectionViewPaginableBehavior'
  pod 'Atributika'
  pod 'EZPlayer', :git => 'https://github.com/hintoz/EZPlayer.git'
  pod 'Letters'
  pod 'RevealingSplashView'
  pod 'TMDBSwift', :git => 'https://github.com/gkye/TheMovieDatabaseSwiftWrapper.git'
  pod 'SubtleVolume'
  pod 'CustomLoader'
  pod 'NotificationBannerSwift'
  pod 'Eureka'
  pod 'NTDownload', :git => 'https://github.com/hintoz/NTDownload.git'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'Firebase/RemoteConfig'
  pod 'AZSearchView', :git => 'https://github.com/hintoz/AZSearchView.git'
  pod 'NDYoutubePlayer', :git => 'https://github.com/hintoz/NDYoutubePlayer.git'
  pod 'GradientLoadingBar'
  pod 'EasyAbout'
  pod 'CircleProgressView'
  
  pod 'R.swift'
  pod 'Mixpanel'
  pod 'SwiftyBeaver', :configurations => ['Debug']

end

post_install do |installer|
	myTargets = ['CustomLoader', 'DGCollectionViewPaginableBehavior']
	
	installer.pods_project.targets.each do |target|
		if myTargets.include? target.name
			target.build_configurations.each do |config|
				config.build_settings['SWIFT_VERSION'] = '3.2'
			end
		end
	end
end
