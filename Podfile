platform :ios, '12.0'

workspace 'AmazonIVSPlayerSamples'

# All of the following projects consume the AmazonIVSPlayer framework as clients
abstract_target 'IVSClients' do
    pod 'AmazonIVSPlayer', '1.21.0'

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
