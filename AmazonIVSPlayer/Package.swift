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
            url: "https://player.live-video.net/1.54.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "77a9cac0470037166adbc80290db5cf038b26835c31b9e0ddd2b6d810ac873c3"
        ),
    ]
)

