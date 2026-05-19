//  Copyright © 2026 Nomasystems. All rights reserved.

import UIKit

/// A view with a shimmer (horizontal gradient sweep) animation.
/// Used as the default placeholder if no custom one is provided.
public final class ShimmerPlaceholderView: UIView {

    public static let defaultBaseColor: UIColor = {
        if #available(iOS 13.0, *) { return .systemGray5 }
        return UIColor(red: 0.90, green: 0.90, blue: 0.92, alpha: 1.0)
    }()

    public static let defaultShimmerColor: UIColor = {
        if #available(iOS 13.0, *) { return .systemGray6 }
        return UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
    }()

    private let gradientLayer = CAGradientLayer()

    public var baseColor: UIColor {
        didSet { updateColors() }
    }

    public var shimmerColor: UIColor {
        didSet { updateColors() }
    }

    public var animationDuration: TimeInterval

    public init(baseColor: UIColor = ShimmerPlaceholderView.defaultBaseColor,
                shimmerColor: UIColor = ShimmerPlaceholderView.defaultShimmerColor,
                animationDuration: TimeInterval = 1.5) {
        self.baseColor = baseColor
        self.shimmerColor = shimmerColor
        self.animationDuration = animationDuration
        super.init(frame: .zero)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = baseColor
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        updateColors()
        layer.addSublayer(gradientLayer)
    }

    private func updateColors() {
        gradientLayer.colors = [
            baseColor.cgColor,
            shimmerColor.cgColor,
            baseColor.cgColor
        ]
        gradientLayer.locations = [0.0, 0.5, 1.0]
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    private func startAnimating() {
        guard gradientLayer.animation(forKey: "shimmer") == nil else { return }
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = animationDuration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        gradientLayer.add(animation, forKey: "shimmer")
    }

    private func stopAnimating() {
        gradientLayer.removeAnimation(forKey: "shimmer")
    }
}
