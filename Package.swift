// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WalletStorage",
    defaultLocalization: "en",
	platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library( 
            name: "WalletStorage",
            targets: ["WalletStorage"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
		.package(url: "https://github.com/eu-digital-identity-wallet/eudi-lib-ios-iso18013-data-model.git", from: "0.7.1"),
		],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "WalletStorage", 
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
								.product(name: "MdocDataModel18013", package: "eudi-lib-ios-iso18013-data-model"),
            ]),
        .testTarget(
            name: "WalletStorageTests",
            dependencies: ["WalletStorage"]),
    ]
)
