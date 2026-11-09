// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "AmazonIVSPlayer",
    platforms: [
        .iOS("15.0"),
    ],
    products: [
        .library(
            name: "AmazonIVSPlayer",
            targets: ["AmazonIVSPlayer"]),
    ],
    targets: [
        .binaryTarget(
            name: "AmazonIVSPlayer",
            url: "https://player.live-video.net/1.58.1/AmazonIVSPlayer.xcframework.zip",
            checksum: "1ff3bbd493341800430a31b4006d84e771bb98c715cd559522b2c6473b461455"
        ),
    ]
)

