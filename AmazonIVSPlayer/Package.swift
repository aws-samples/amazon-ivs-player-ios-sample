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
            url: "https://player.live-video.net/1.57.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "a848cb36f59d5d19f11456913d7a8c035fb118a7f3a0a4e12230e2e534970430"
        ),
    ]
)

