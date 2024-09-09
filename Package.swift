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
    )
  ],
  targets: [
    .target(
        name: "Beethoven",
        dependencies: [
            "Pitchy",
        ],
        path: "Source"
    ),
    .testTarget(
      name: "BeethovenTests",
      dependencies: [
        "Pitchy",
      ]
    )
  ]
)
