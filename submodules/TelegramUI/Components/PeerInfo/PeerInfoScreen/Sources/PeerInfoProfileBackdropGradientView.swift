import UIKit

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
        self.gradientLayer.frame = CGRect(origin: .zero, size: size)
        let opaqueColor = color.withAlphaComponent(1.0)
        let middleColor = opaqueColor.mixedWith(backgroundColor, alpha: 0.65)
        self.gradientLayer.colors = [opaqueColor.cgColor, middleColor.cgColor, backgroundColor.cgColor]
        self.gradientLayer.locations = [0.0, 0.45, 1.0]
    }
}
