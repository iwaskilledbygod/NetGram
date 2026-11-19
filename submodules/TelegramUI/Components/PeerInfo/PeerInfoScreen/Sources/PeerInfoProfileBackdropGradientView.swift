import UIKit

/// Draws the profile colour *behind* the information card: a soft coloured glow that
/// spreads around the card edges, plus an optional vertical fade that blends it into the
/// profile header. The card itself stays untouched, so the tint never recolours it.
final class PeerInfoProfileBackdropGradientView: UIView {
    private let glowLayer = CALayer()
    private let fadeLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        self.backgroundColor = .clear

        self.glowLayer.shadowOffset = CGSize()
        self.layer.addSublayer(self.glowLayer)

        self.fadeLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        self.fadeLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        self.layer.addSublayer(self.fadeLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// - Parameters:
    ///   - cardFrame: the card rect inside this view.
    ///   - color: blended profile colour.
    ///   - cornerRadius: card corner radius.
    ///   - spread: how far the glow reaches past the card edges.
    ///   - intensity: glow strength, 0...1.
    ///   - fadeHeight: height of the colour patch above the card that fades into the header (0 disables it).
    func update(cardFrame: CGRect, color: UIColor, cornerRadius: CGFloat, spread: CGFloat, intensity: CGFloat, fadeHeight: CGFloat) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        let opaqueColor = color.withAlphaComponent(1.0)

        self.glowLayer.frame = cardFrame
        self.glowLayer.cornerRadius = cornerRadius
        self.glowLayer.backgroundColor = opaqueColor.withAlphaComponent(0.55).cgColor
        self.glowLayer.shadowColor = opaqueColor.cgColor
        self.glowLayer.shadowOpacity = Float(max(0.0, min(1.0, intensity)))
        self.glowLayer.shadowRadius = max(0.0, spread)
        self.glowLayer.shadowPath = UIBezierPath(roundedRect: CGRect(origin: .zero, size: cardFrame.size), cornerRadius: cornerRadius).cgPath

        if fadeHeight > 0.5 {
            self.fadeLayer.isHidden = false
            let fadeFrame = CGRect(x: cardFrame.minX, y: cardFrame.minY - fadeHeight, width: cardFrame.width, height: fadeHeight)
            self.fadeLayer.frame = fadeFrame
            let clearColor = opaqueColor.withAlphaComponent(0.0).cgColor
            self.fadeLayer.colors = [clearColor, opaqueColor.withAlphaComponent(0.75).cgColor]
            self.fadeLayer.cornerRadius = cornerRadius
            self.fadeLayer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            self.fadeLayer.isHidden = true
        }

        CATransaction.commit()
    }
}
