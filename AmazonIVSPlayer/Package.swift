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
            url: "https://player.live-video.net/1.55.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "25b0bb8af9e77a809726f66bb0c8a1545fb89fe2a552a09aedd9c0871dbe2c0d"
        ),
    ]
)

