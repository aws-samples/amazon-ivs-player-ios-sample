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
            url: "https://player.live-video.net/1.50.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "fac2eb41f61b090a2744402b60c934cfef8411b46033370f4a2a017ba598d268"
        ),
    ]
)

