// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PathTimeShared",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "PathTimeShared", targets: ["PathTimeShared"])
    ],
    targets: [
        .target(
            name: "PathTimeShared",
            path: "Sources/PathTimeShared"
        )
    ]
)
