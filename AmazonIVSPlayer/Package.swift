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
            url: "https://player.live-video.net/1.49.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "19a63fb1942e2c75abd9633e7d7b5e9a8d0f0b51e25ede1f2d3225a18f7ef12c"
        ),
    ]
)

