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
            url: "https://player.live-video.net/1.53.0/AmazonIVSPlayer.xcframework.zip",
            checksum: "91d2832894014efdcc77f476ea59842fce789ccabf989bf9afd06da88b21d8ae"
        ),
    ]
)

