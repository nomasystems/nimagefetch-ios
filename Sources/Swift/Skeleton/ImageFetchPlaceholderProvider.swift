//  Copyright © 2026 Nomasystems. All rights reserved.

import UIKit

/// Protocol for providing placeholder views during image loading.
/// Implement to create custom placeholders (shimmer, blur, solid color, etc.)
public protocol ImageFetchPlaceholderProvider {
    /// Creates a new placeholder view instance.
    /// Called once per image load.
    func makePlaceholderView() -> UIView
}
