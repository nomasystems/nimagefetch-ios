//  Copyright © 2026 Nomasystems. All rights reserved.

import Testing
import UIKit
@testable import NMAImageFetch
@testable import NMAImageFetchSwift

@MainActor @Suite("NImageFetchView Skeleton")
struct NImageFetchViewSkeletonTests {

    @Test("placeholderFadeOutDuration defaults to 0.3")
    func test_fadeOutDuration_defaultValue() {
        let sut = NImageFetchView(frame: .zero)
        #expect(sut.placeholderFadeOutDuration == 0.3)
    }

    @Test("placeholderView is nil by default")
    func test_placeholderView_nilByDefault() {
        let sut = NImageFetchView(frame: .zero)
        #expect(sut.placeholderView == nil)
    }

    @Test("Placeholder is added as subview when showPlaceholderIfNeeded is triggered via setImage")
    func test_placeholder_addedAsSubview_whenSetImageCalled() {
        let sut = NImageFetchView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let placeholder = UIView()
        sut.placeholderView = placeholder

        // Trigger setImage with an invalid request to see placeholder added
        let request = ImageFetchRequest(urlRequest: URLRequest(url: URL(string: "https://invalid.test/image.png")!))
        sut.setImage(request, animated: .never)

        #expect(placeholder.superview === sut)
    }

    @Test("Placeholder is NOT added when placeholderView is nil")
    func test_placeholder_notAdded_whenNil() {
        let sut = NImageFetchView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        // placeholderView is nil by default

        let request = ImageFetchRequest(urlRequest: URLRequest(url: URL(string: "https://invalid.test/image.png")!))
        sut.setImage(request, animated: .never)

        #expect(sut.subviews.isEmpty || sut.subviews.allSatisfy { $0 !== sut.placeholderView })
    }

    @Test("enableShimmerPlaceholder sets placeholderView to ShimmerPlaceholderView")
    func test_enableShimmer_setsPlaceholder() {
        let sut = NImageFetchView(frame: .zero)
        sut.enableShimmerPlaceholder()
        #expect(sut.placeholderView is ShimmerPlaceholderView)
    }

    @Test("enableShimmerPlaceholder sets custom fadeOutDuration")
    func test_enableShimmer_setsFadeOutDuration() {
        let sut = NImageFetchView(frame: .zero)
        sut.enableShimmerPlaceholder(fadeOutDuration: 0.5)
        #expect(sut.placeholderFadeOutDuration == 0.5)
    }

    @Test("disablePlaceholder removes and nils placeholderView")
    func test_disablePlaceholder_removesView() {
        let sut = NImageFetchView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let placeholder = UIView()
        sut.placeholderView = placeholder
        sut.addSubview(placeholder)

        sut.disablePlaceholder()

        #expect(sut.placeholderView == nil)
        #expect(placeholder.superview == nil)
    }

    @Test("configurePlaceholder uses provider to create view")
    func test_configurePlaceholder_usesProvider() {
        struct MockProvider: ImageFetchPlaceholderProvider {
            func makePlaceholderView() -> UIView {
                let view = UIView()
                view.tag = 999
                return view
            }
        }
        let sut = NImageFetchView(frame: .zero)
        sut.configurePlaceholder(provider: MockProvider())
        #expect(sut.placeholderView?.tag == 999)
    }

    @Test("ShimmerPlaceholderView starts animating when added to window")
    func test_shimmer_animatesWhenInWindow() {
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let shimmer = ShimmerPlaceholderView()
        shimmer.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        window.addSubview(shimmer)
        window.makeKeyAndVisible()

        // Give run loop a cycle
        RunLoop.current.run(until: Date().addingTimeInterval(0.1))

        let gradientLayer = shimmer.layer.sublayers?.first as? CAGradientLayer
        #expect(gradientLayer?.animation(forKey: "shimmer") != nil)
    }

    @Test("Repeated setImage cleans previous placeholder")
    func test_repeatedSetImage_cleansPreviousPlaceholder() {
        let sut = NImageFetchView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let placeholder = UIView()
        sut.placeholderView = placeholder

        let request = ImageFetchRequest(urlRequest: URLRequest(url: URL(string: "https://invalid.test/1.png")!))
        sut.setImage(request, animated: .never)
        #expect(placeholder.superview === sut)

        // Second call should still have placeholder (cleaned and re-shown)
        let request2 = ImageFetchRequest(urlRequest: URLRequest(url: URL(string: "https://invalid.test/2.png")!))
        sut.setImage(request2, animated: .never)
        #expect(placeholder.superview === sut)

        // Only one instance of placeholder in subviews
        let placeholderCount = sut.subviews.filter { $0 === placeholder }.count
        #expect(placeholderCount == 1)
    }
}
