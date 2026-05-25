//  Copyright © 2026 Nomasystems. All rights reserved.

import UIKit

/// Protocol for providing placeholder views during image loading.
/// Implement to create custom placeholders (shimmer, blur, solid color, etc.)
public protocol ImageFetchPlaceholderProvider {
    /// Creates a placeholder view instance.
    /// Called once when configuring the placeholder; the view is reused across loads.
    @MainActor func makePlaceholderView() -> UIView
}
