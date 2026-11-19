import UIKit

/// Draws the profile colour behind the information card as a smooth transition: it starts
/// with the header cover's main colour right below the header and fades into the content
/// background. The card itself stays untouched — only the backdrop behind it is coloured.
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

    func update(size: CGSize, color: UIColor, backgroundColor: UIColor) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.gradientLayer.frame = CGRect(origin: .zero, size: size)
        let topColor = color.withAlphaComponent(1.0)
        let middleColor = topColor.mixedWith(backgroundColor, alpha: 0.55)
        self.gradientLayer.colors = [topColor.cgColor, middleColor.cgColor, backgroundColor.cgColor]
        self.gradientLayer.locations = [0.0, 0.5, 1.0]

        CATransaction.commit()
    }
}
