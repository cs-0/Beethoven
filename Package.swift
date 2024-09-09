// swift-tools-version:5.10.0

import PackageDescription

let package = Package(
  name: "Beethoven",
  platforms: [
    .iOS(.v15)
  ],
  products: [
    .library(
        name: "Beethoven",
        targets: ["Beethoven"]
    )
  ],
  dependencies: [
    .package(
        url: "https://github.com/cs-0/Pitchy.git",
        branch: "master"
    ),
    .package(
        url: "https://github.com/Quick/Quick",
        from: "7.6.0"
    ),
    .package(
        url: "https://github.com/Quick/Nimble",
        from: "13.0.0"
    )
  ],
  targets: [
    .target(
        name: "Beethoven",
        dependencies: [
            "Pitchy",
        ]
    ),
    .testTarget(
      name: "BeethovenTests",
      dependencies: [
        "Beethoven",
        "Pitchy",
        "Nimble",
        "Quick"
      ]
    )
  ]
)
