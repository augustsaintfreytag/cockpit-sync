// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "CockpitSync",
	platforms: [
		// .linux — Support implicitly provided by default.
		.macOS(.v10_13)
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		.package(url: "https://github.com/apple/swift-argument-parser", from: "0.2.0")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages which this package depends on.
		.target(
			name: "CockpitSync",
			dependencies: [
				.productItem(name: "ArgumentParser", package: "swift-argument-parser", condition: nil)
			],
			swiftSettings: [
				.define("DEBUG", BuildSettingCondition.when(configuration: BuildConfiguration.debug))
			]
		)
	]
)
