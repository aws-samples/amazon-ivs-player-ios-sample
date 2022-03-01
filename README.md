<a href="https://docs.aws.amazon.com/ivs/"><img align="right" width="128px" src="./ivs-logo.svg"></a>

# Amazon IVS Player iOS SDK Sample Apps

This repository contains sample apps which use the Amazon IVS Player iOS SDK.

## Samples

+ **BasicPlayback**: This is the most basic example of how to get started with the SDK.
+ **CustomUI**: This is a more advanced example that shows how to build a custom UI on top of the SDK.
+ **QuizDemo**: This is a trivia game example in which the questions are sent over timed metadata embedded in the stream.

## More Documentation

+ [Release Notes](https://docs.aws.amazon.com/ivs/latest/userguide/IVSPRN.html)
+ [iOS SDK Guide](https://docs.aws.amazon.com/ivs/latest/userguide/SIPAG.html)

## Setup

1. Clone the repository to your local machine.
1. Ensure you are using a supported version of Ruby, as [the version included with macOS is deprecated](https://developer.apple.com/documentation/macos-release-notes/macos-catalina-10_15-release-notes#Scripting-Language-Runtimes). This repository is tested with the version in [`.ruby-version`](./.ruby-version), which can be used automatically with [rbenv](https://github.com/rbenv/rbenv#installation).
1. Install the SDK dependency using CocoaPods. This can be done by running the following commands from the repository folder:
   * `bundle install`
   * `bundle exec pod install --repo-update`
   * For more information about these commands, see [Bundler](https://bundler.io/) and [CocoaPods](https://guides.cocoapods.org/using/getting-started.html).
1. Open AmazonIVSPlayerSamples.xcworkspace.
1. You can now build and run the projects in the simulator.

## License
This project is licensed under the MIT-0 License. See the LICENSE file.
