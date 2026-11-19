import UIKit

/// Draws the avatar background colour behind the information card as one continuous
/// section: the colour continues the header cover, stays solid while it is hidden behind
/// the header band, and then dissolves into the content background by the bottom of the
/// card. The card itself stays untouched — only the backdrop behind it is coloured.
final class PeerInfoProfileBackdropGradientView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let glowLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.addSublayer(self.gradientLayer)

        self.glowLayer.type = .radial
        self.glowLayer.startPoint = CGPoint(x: 0.5, y: 0.35)
        self.glowLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.addSublayer(self.glowLayer)
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
    ///   - fadeStyle: 0 — linear, 1 — sharp, 2 — soft.
    ///   - strength: 0 — regular, 1 — soft, 2 — saturated.
    ///   - direction: 0 — vertical, 1 — diagonal.
    ///   - centerGlow: adds a subtle radial highlight behind the card.
    func update(size: CGSize, color: UIColor, backgroundColor: UIColor, hold: CGFloat, fadeStyle: Int, strength: Int, direction: Int, centerGlow: Bool) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.gradientLayer.frame = CGRect(origin: .zero, size: size)
        if direction == 1 {
            self.gradientLayer.startPoint = CGPoint(x: 0.2, y: 0.0)
            self.gradientLayer.endPoint = CGPoint(x: 0.8, y: 1.0)
        } else {
            self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        }
        let height = max(size.height, 1.0)
        let topColor = color.withAlphaComponent(1.0)
        let middleMixAlphas: [CGFloat] = [0.55, 0.35, 0.75]
        let middleColor = topColor.mixedWith(backgroundColor, alpha: middleMixAlphas[max(0, min(2, strength))])
        let holdLocation = max(0.0, min(1.0, hold / height))
        let middlePosition: CGFloat = [0.5, 0.3, 0.7][max(0, min(2, fadeStyle))]
        let middleLocation = max(holdLocation, min(1.0, (hold + (height - hold) * middlePosition) / height))
        self.gradientLayer.colors = [topColor.cgColor, topColor.cgColor, middleColor.cgColor, backgroundColor.cgColor]
        self.gradientLayer.locations = [
            NSNumber(value: 0.0),
            NSNumber(value: Double(holdLocation)),
            NSNumber(value: Double(middleLocation)),
            NSNumber(value: 1.0)
        ]

        if centerGlow {
            self.glowLayer.isHidden = false
            self.glowLayer.frame = CGRect(origin: .zero, size: size)
            let glowColor = topColor.withAlphaComponent(0.0).cgColor
            let highlight = UIColor.white.withAlphaComponent(0.10).cgColor
            self.glowLayer.colors = [highlight, glowColor]
        } else {
            self.glowLayer.isHidden = true
        }

        CATransaction.commit()
    }
}
