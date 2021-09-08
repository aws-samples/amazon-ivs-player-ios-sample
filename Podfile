platform :ios, '10.0'

workspace 'AmazonIVSPlayerSamples'

# All of the following projects consume the AmazonIVSPlayer framework as clients
abstract_target 'IVSClients' do
    pod 'AmazonIVSPlayer', '~> 1.4.1'

    target 'BasicPlayback' do
        project 'BasicPlayback/BasicPlayback.xcodeproj'
    end

    target 'CustomUI' do
        project 'CustomUI/CustomUI.xcodeproj'
    end

    target 'QuizDemo' do
        project 'QuizDemo/QuizDemo.xcodeproj'
    end
end

# Allow building for arm64e architecture, which AmazonIVSPlayer supports.
# See https://developer.apple.com/documentation/security/preparing_your_app_to_work_with_pointer_authentication
post_install do |installer|
    installer.pods_project.build_configurations.each do |configuration|
        configuration.build_settings['ARCHS[sdk=iphoneos*]'] = ['$(ARCHS_STANDARD)','arm64e']
    end
end
