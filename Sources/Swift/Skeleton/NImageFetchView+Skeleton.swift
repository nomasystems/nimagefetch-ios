//  Copyright © 2026 Nomasystems. All rights reserved.

import UIKit
import NMAImageFetch

extension NImageFetchView {

    /// Configures the placeholder using a provider conforming to ImageFetchPlaceholderProvider.
    /// Must be called BEFORE setImage.
    public func configurePlaceholder(provider: ImageFetchPlaceholderProvider) {
        self.placeholderView = provider.makePlaceholderView()
    }

    /// Configures the placeholder with the built-in shimmer.
    /// Must be called BEFORE setImage.
    public func enableShimmerPlaceholder(
        baseColor: UIColor = ShimmerPlaceholderView.defaultBaseColor,
        shimmerColor: UIColor = ShimmerPlaceholderView.defaultShimmerColor,
        animationDuration: TimeInterval = 1.5,
        fadeOutDuration: TimeInterval = 0.3
    ) {
        let shimmer = ShimmerPlaceholderView(
            baseColor: baseColor,
            shimmerColor: shimmerColor,
            animationDuration: animationDuration
        )
        self.placeholderView = shimmer
        self.placeholderFadeOutDuration = fadeOutDuration
    }

    /// Removes and disables the placeholder for this instance.
    public func disablePlaceholder() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
}
