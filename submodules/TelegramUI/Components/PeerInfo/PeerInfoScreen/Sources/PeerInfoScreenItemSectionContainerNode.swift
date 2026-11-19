import Foundation
import UIKit
import Display
import AsyncDisplayKit
import AccountContext
import TelegramPresentationData
import GlassBackgroundComponent
import ComponentFlow

final class PeerInfoScreenItemSectionContainerNode: ASDisplayNode {
    private let backgroundNode: ASDisplayNode
    private let topSeparatorNode: ASDisplayNode
    private let bottomSeparatorNode: ASDisplayNode
    private let itemContainerNode: ASDisplayNode
    private var glassBackgroundView: GlassBackgroundView?
    private var profileBackdropView: PeerInfoProfileBackdropGradientView?
    
    private var currentItems: [PeerInfoScreenItem] = []
    var itemNodes: [AnyHashable: PeerInfoScreenItemNode] = [:]
    
    override init() {
        self.backgroundNode = ASDisplayNode()
        self.backgroundNode.isLayerBacked = true
        
        self.topSeparatorNode = ASDisplayNode()
        self.topSeparatorNode.isLayerBacked = true
        
        self.bottomSeparatorNode = ASDisplayNode()
        self.bottomSeparatorNode.isLayerBacked = true
        
        self.itemContainerNode = ASDisplayNode()
        self.itemContainerNode.clipsToBounds = true
        
        super.init()
        
        self.addSubnode(self.backgroundNode)
        self.addSubnode(self.itemContainerNode)
        self.addSubnode(self.topSeparatorNode)
        self.addSubnode(self.bottomSeparatorNode)
    }
    
    func update(context: AccountContext, width: CGFloat, safeInsets: UIEdgeInsets, hasCorners: Bool, presentationData: PresentationData, items: [PeerInfoScreenItem], transition: ContainedViewLayoutTransition, glassTintColor: UIColor? = nil, profileBackdropColor: UIColor? = nil, profileBackdropMode: Int = 0, profileBackdropTopExtension: CGFloat = 0.0) -> CGFloat {
        self.backgroundNode.backgroundColor = presentationData.theme.list.itemBlocksBackgroundColor
        self.topSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor
        self.bottomSeparatorNode.backgroundColor = presentationData.theme.list.itemBlocksSeparatorColor

        self.topSeparatorNode.isHidden = hasCorners
        self.bottomSeparatorNode.isHidden = hasCorners

        if profileBackdropColor != nil {
            let backdropView: PeerInfoProfileBackdropGradientView
            if let current = self.profileBackdropView {
                backdropView = current
            } else {
                backdropView = PeerInfoProfileBackdropGradientView(frame: CGRect())
                self.profileBackdropView = backdropView
                self.view.insertSubview(backdropView, belowSubview: self.itemContainerNode.view)
            }
            self.view.sendSubviewToBack(backdropView)
            backdropView.isHidden = false
        } else if let profileBackdropView = self.profileBackdropView {
            profileBackdropView.removeFromSuperview()
            self.profileBackdropView = nil
        }

        if glassTintColor != nil {
            self.backgroundNode.backgroundColor = profileBackdropMode == 1 ? (profileBackdropColor ?? .clear) : .clear
            self.topSeparatorNode.backgroundColor = .clear
            self.bottomSeparatorNode.backgroundColor = .clear

            let glassBackgroundView: GlassBackgroundView
            if let current = self.glassBackgroundView {
                glassBackgroundView = current
            } else {
                glassBackgroundView = GlassBackgroundView(frame: CGRect())
                self.glassBackgroundView = glassBackgroundView
                self.view.insertSubview(glassBackgroundView, belowSubview: self.itemContainerNode.view)
            }
            glassBackgroundView.clipsToBounds = true
        } else if let glassBackgroundView = self.glassBackgroundView {
            glassBackgroundView.removeFromSuperview()
            self.glassBackgroundView = nil
        }
        
        var contentHeight: CGFloat = 0.0
        var contentWithBackgroundHeight: CGFloat = 0.0
        var contentWithBackgroundOffset: CGFloat = 0.0
        
        for i in 0 ..< items.count {
            let item = items[i]
            
            let itemNode: PeerInfoScreenItemNode
            var wasAdded = false
            if let current = self.itemNodes[item.id] {
                itemNode = current
            } else {
                wasAdded = true
                itemNode = item.node()
                self.itemNodes[item.id] = itemNode
                self.itemContainerNode.addSubnode(itemNode)
                itemNode.bringToFrontForHighlight = { [weak self, weak itemNode] in
                    guard let strongSelf = self, let itemNode = itemNode else {
                        return
                    }
                    strongSelf.view.bringSubviewToFront(itemNode.view)
                }
            }
            
            let itemTransition: ContainedViewLayoutTransition = wasAdded ? .immediate : transition
            
            let topItem: PeerInfoScreenItem?
            if i == 0 {
                topItem = nil
            } else if items[i - 1] is PeerInfoScreenHeaderItem {
                topItem = nil
            } else {
                topItem = items[i - 1]
            }
            
            let bottomItem: PeerInfoScreenItem?
            if i == items.count - 1 {
                bottomItem = nil
            } else if items[i + 1] is PeerInfoScreenCommentItem {
                bottomItem = nil
            } else {
                bottomItem = items[i + 1]
            }
            
            let itemHeight = itemNode.update(context: context, width: width, safeInsets: safeInsets, presentationData: presentationData, item: item, topItem: topItem, bottomItem: bottomItem, hasCorners: hasCorners, transition: itemTransition)
            let itemFrame = CGRect(origin: CGPoint(x: 0.0, y: contentHeight), size: CGSize(width: width, height: itemHeight))
            itemTransition.updateFrame(node: itemNode, frame: itemFrame)
            if wasAdded {
                itemNode.alpha = 0.0
                let alphaTransition: ContainedViewLayoutTransition = transition.isAnimated ? .animated(duration: 0.35, curve: .linear) : .immediate
                alphaTransition.updateAlpha(node: itemNode, alpha: 1.0)
            }
            
            if item is PeerInfoScreenCommentItem {
            } else {
                contentWithBackgroundHeight += itemHeight
            }
            contentHeight += itemHeight
            
            if item is PeerInfoScreenHeaderItem {
                contentWithBackgroundOffset = contentHeight
            }
        }
        
        var removeIds: [AnyHashable] = []
        for (id, _) in self.itemNodes {
            if !items.contains(where: { $0.id == id }) {
                removeIds.append(id)
            }
        }
        for id in removeIds {
            if let itemNode = self.itemNodes.removeValue(forKey: id) {
                itemNode.view.superview?.sendSubviewToBack(itemNode.view)
                transition.updateAlpha(node: itemNode, alpha: 0.0, completion: { [weak itemNode] _ in
                    itemNode?.removeFromSupernode()
                })
            }
        }
        
        transition.updateFrame(node: self.itemContainerNode, frame: CGRect(origin: CGPoint(), size: CGSize(width: width, height: contentHeight)))
        let sectionBackgroundColor: UIColor
        if profileBackdropMode == 1, let profileBackdropColor {
            sectionBackgroundColor = profileBackdropColor
        } else {
            sectionBackgroundColor = presentationData.theme.list.itemBlocksBackgroundColor
        }
        self.backgroundNode.backgroundColor = sectionBackgroundColor
        transition.updateFrame(node: self.backgroundNode, frame: CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundOffset), size: CGSize(width: width, height: max(0.0, contentWithBackgroundHeight - contentWithBackgroundOffset))))
        transition.updateFrame(node: self.topSeparatorNode, frame: CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundOffset - UIScreenPixel), size: CGSize(width: width, height: UIScreenPixel)))
        transition.updateFrame(node: self.bottomSeparatorNode, frame: CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundHeight), size: CGSize(width: width, height: UIScreenPixel)))

        if let glassBackgroundView = self.glassBackgroundView {
            let glassFrame = CGRect(origin: CGPoint(x: 0.0, y: contentWithBackgroundOffset), size: CGSize(width: width, height: max(0.0, contentWithBackgroundHeight - contentWithBackgroundOffset)))
            glassBackgroundView.frame = glassFrame
            let componentTransition = ComponentTransition(transition)
            componentTransition.setCornerRadius(layer: glassBackgroundView.layer, cornerRadius: 20.0)
            let dark = presentationData.theme.overallDarkAppearance
            glassBackgroundView.update(size: glassFrame.size, cornerRadius: 20.0, isDark: dark, tintColor: GlassBackgroundView.TintColor(kind: .custom(style: .default, color: glassTintColor ?? UIColor(white: 0.5, alpha: 1.0)), innerColor: nil, innerInset: 3.0), transition: componentTransition)
        }
        if let profileBackdropColor, let profileBackdropView = self.profileBackdropView {
            let backdropFrame: CGRect
            switch profileBackdropMode {
            case 0:
                backdropFrame = CGRect(x: 0.0, y: contentWithBackgroundOffset, width: width, height: max(0.0, contentWithBackgroundHeight - contentWithBackgroundOffset))
            case 1:
                backdropFrame = CGRect(x: 0.0, y: contentWithBackgroundOffset, width: width, height: max(0.0, contentWithBackgroundHeight - contentWithBackgroundOffset))
            default:
                let topExtension = min(profileBackdropTopExtension, contentWithBackgroundOffset)
                backdropFrame = CGRect(x: 0.0, y: contentWithBackgroundOffset - topExtension, width: width, height: max(0.0, contentWithBackgroundHeight - contentWithBackgroundOffset) + topExtension)
            }
            profileBackdropView.frame = backdropFrame
            profileBackdropView.update(size: backdropFrame.size, color: profileBackdropColor, backgroundColor: presentationData.theme.list.itemBlocksBackgroundColor)
            if profileBackdropMode == 2 {
                profileBackdropView.layer.mask = nil
                let mask = CAGradientLayer()
                mask.frame = profileBackdropView.bounds
                mask.startPoint = CGPoint(x: 0.5, y: 0.0)
                mask.endPoint = CGPoint(x: 0.5, y: 1.0)
                mask.colors = [UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor]
                mask.locations = [0.0, 0.4, 1.0]
                profileBackdropView.layer.mask = mask
            } else {
                profileBackdropView.layer.mask = nil
            }
        }
        
        if contentHeight.isZero {
            transition.updateAlpha(node: self.topSeparatorNode, alpha: 0.0)
            transition.updateAlpha(node: self.bottomSeparatorNode, alpha: 0.0)
        } else {
            transition.updateAlpha(node: self.topSeparatorNode, alpha: 1.0)
            transition.updateAlpha(node: self.bottomSeparatorNode, alpha: 1.0)
        }
        
        return contentHeight
    }
    
    func animateErrorIfNeeded() {
        for (_, itemNode) in self.itemNodes {
            if let itemNode = itemNode as? PeerInfoScreenMultilineInputItemNode {
                itemNode.animateErrorIfNeeded()
            }
        }
    }
}
