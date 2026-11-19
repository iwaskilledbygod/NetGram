import UIKit

/// Draws the avatar background colour behind the information card as one continuous
/// section: the colour continues the header cover, stays solid while it is hidden behind
/// the header band, and then dissolves into the content background by the bottom of the
/// card. The card itself stays untouched — only the backdrop behind it is coloured.
final class PeerInfoProfileBackdropGradientView: UIView {
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.addSublayer(self.gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// - Parameters:
    ///   - size: size of the whole backdrop view.
    ///   - color: the colour at the header band's bottom edge.
    ///   - backgroundColor: the content background the colour dissolves into.
    ///   - hold: how much of the top of the backdrop is hidden behind the header band; the
    ///     colour stays solid there so the transition seam never leaves the band.
    func update(size: CGSize, color: UIColor, backgroundColor: UIColor, hold: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.gradientLayer.frame = CGRect(origin: .zero, size: size)
        let height = max(size.height, 1.0)
        let topColor = color.withAlphaComponent(1.0)
        let middleColor = topColor.mixedWith(backgroundColor, alpha: 0.55)
        let holdLocation = max(0.0, min(1.0, hold / height))
        let middleLocation = max(holdLocation, min(1.0, (hold + (height - hold) * 0.5) / height))
        self.gradientLayer.colors = [topColor.cgColor, topColor.cgColor, middleColor.cgColor, backgroundColor.cgColor]
        self.gradientLayer.locations = [0.0, holdLocation, middleLocation, 1.0]

        CATransaction.commit()
    }
}
