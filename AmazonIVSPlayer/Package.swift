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
            url: "https://player.live-video.net/1.56.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "3e997ba6d61957a9c469e7360d326ce34d70f2f2dbb4c696a90a551b9b84491d"
        ),
    ]
)

