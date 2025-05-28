// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WWJWTAuthenticationToken",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "WWJWTAuthenticationToken", targets: ["WWJWTAuthenticationToken"]),
    ],
    targets: [
        .target(name: "WWJWTAuthenticationToken", resources: [.copy("Privacy")]),
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
