// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Penguin",
  products: [
    .executable(name: "penguini", targets: ["penguini"])
  ],
  dependencies: [
    .package(url: "https://github.com/kyouko-taiga/Diesel", from: "1.0.0"),
  ],
  targets: [
    .target(name: "penguini", dependencies: ["Penguin"]),
    .target(name: "Penguin", dependencies: ["Diesel"]),
    .testTarget(name: "PenguinTests", dependencies: ["Penguin"]),
  ])
