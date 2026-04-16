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
            url: "https://player.live-video.net/1.51.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "2313493e25b1c1d60edfdcce1aed24faf3263030a52509e64d862141b6877246"
        ),
    ]
)

