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
            url: "https://player.live-video.net/1.54.1/AmazonIVSPlayer.xcframework.zip",
            checksum: "6572968f41e31b4a52e5d970be39e366924eaf586ee8a89cf9709b86fc93510d"
        ),
    ]
)

