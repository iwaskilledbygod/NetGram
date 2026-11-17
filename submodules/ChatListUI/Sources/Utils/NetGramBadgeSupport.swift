import Foundation
import UIKit
import TelegramCore
import AppBundle

let chatListNetBadgeImage: UIImage? = UIImage(bundleImageName: "NetBadge")
let chatListNetBadgeSize = CGSize(width: 15.0, height: 15.0)

func chatListNetBadgeLayout(peerId: EnginePeer.Id?, hasTitle: Bool) -> (image: UIImage?, advancesTitle: Bool) {
    guard hasTitle, let kind = peerId?.netGramBadgeKind, kind.isDeveloper, let image = chatListNetBadgeImage else {
        return (nil, false)
    }
    return (image, true)
}
