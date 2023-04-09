// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Redux",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "Redux", targets: ["Redux"]),
        .library(name: "Redux-Logger", targets: ["Redux-Logger"]),
        .library(name: "Redux-Thunk", targets: ["Redux-Thunk"]),
        .library(name: "SwiftUI-Redux", targets: ["SwiftUI-Redux"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "Redux", dependencies: []),
        .target(name: "Redux-Logger", dependencies: ["Redux"]),
        .target(name: "Redux-Thunk", dependencies: ["Redux"]),
        .target(name: "SwiftUI-Redux", dependencies: ["Redux"]),
        
        .testTarget(name: "ReduxTests", dependencies: ["Redux"]),
    ]
)
