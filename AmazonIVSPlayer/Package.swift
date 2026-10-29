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
            url: "https://player.live-video.net/1.58.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "a090bfca97a02667e0d1ef4e2e97df3366ecbc8add8461ca7bf13dc5460e7cc4"
        ),
    ]
)

