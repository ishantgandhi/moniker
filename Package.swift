// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Moniker",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(name: "Moniker", path: "Sources/Moniker")
    ]
)
