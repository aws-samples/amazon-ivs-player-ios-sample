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
            url: "https://player.live-video.net/1.52.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "c836cc04d8c5ec85a5720a7803092706266a65224a46130188314f4a972da700"
        ),
    ]
)

