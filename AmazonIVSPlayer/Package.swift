// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AmazonIVSPlayer",
    platforms: [
        .iOS("14.0"),
    ],
    products: [
        .library(
            name: "AmazonIVSPlayer",
            targets: ["AmazonIVSPlayer"]),
    ],
    targets: [
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.48.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "49407bad89fd8bf35252d58d13e7c74e0a8547c0efc5e32e6ede7a947c3e3e26"
        ),
    ]
)

