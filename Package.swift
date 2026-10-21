// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "idkPlus",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .executable(name: "idkPlus", targets: ["idkPlus"])
    ],
    targets: [
        .executableTarget(
            name: "idkPlus",
            path: "App",
            resources: [
                .process("Lokgojo.png"),
                .process("Logo.png")
            ]
        )
    ]
)