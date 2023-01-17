// swift-tools-version:5.6
import PackageDescription

let package = Package(
	name: "Comier",
	platforms: [.iOS(.v10)],
	products: [
        .library(name: "Comier",
                 type: .static,
                 targets: ["Comier", "FDFullscreenPopGesture"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/baveku/TextureSPM.git", from: "3.1.1"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.8.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.5.0"),
        .package(url: "https://github.com/tristanhimmelman/ObjectMapper", from: "4.2.0"),
        .package(url: "https://github.com/ninjaprox/NVActivityIndicatorView", from: "5.1.1"),
        .package(url: "https://github.com/ra1028/DifferenceKit", from: "1.3.0"),
        .package(url: "https://github.com/google/promises", from: "2.0.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.3"),
        .package(url: "https://github.com/pinterest/PINRemoteImage", .upToNextMajor(from: "3.0.3")),
        .package(url: "https://github.com/pinterest/PINCache.git", .upToNextMajor(from: "3.0.3")),
        .package(url: "https://github.com/pinterest/PINOperation.git", .upToNextMajor(from: "1.2.2"))
    ],
    targets: [
        .target(name: "Comier",
                dependencies: [
                    "Swinject", "NVActivityIndicatorView",
                    "DifferenceKit", "ObjectMapper",
                    "FDFullscreenPopGesture", "PINCache",
                    "PINOperation", "PINRemoteImage",
                    .product(name: "Moya", package: "Moya"),
                    .product(name: "RxMoya", package: "Moya"),
                    .product(name: "AsyncDisplayKit", package: "TextureSPM"),
                    .product(name: "Promises", package: "Promises"),
                    .product(name: "RxCocoa", package: "RxSwift"),
                    .product(name: "RxRelay", package: "RxSwift"),
                    .product(name: "RxSwift", package: "RxSwift"),
                    .product(name: "RxBlocking", package: "RxSwift")
                ],
                path: "Comier"),
        .target(name: "FDFullscreenPopGesture", path: "FDFullscreenPopGesture")
    ]
)
