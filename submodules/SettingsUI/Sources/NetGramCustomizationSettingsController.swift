import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramPresentationData
import AccountContext
import ItemListUI
import PresentationDataUtils

private enum CustomizationSection: Int32 {
    case profile = 0
}

private enum CustomizationEntry: ItemListNodeEntry {
    enum StableId: Hashable {
        case profileHeader
        case showUserId
        case showUserIdInfo
        case showUserDc
        case showUserDcInfo
    }

    case profileHeader(String)
    case showUserId(title: String, value: Bool)
    case showUserIdInfo(String)
    case showUserDc(title: String, value: Bool)
    case showUserDcInfo(String)

    var section: ItemListSectionId {
        return CustomizationSection.profile.rawValue
    }

    var stableId: StableId {
        switch self {
        case .profileHeader:
            return .profileHeader
        case .showUserId:
            return .showUserId
        case .showUserIdInfo:
            return .showUserIdInfo
        case .showUserDc:
            return .showUserDc
        case .showUserDcInfo:
            return .showUserDcInfo
        }
    }

    var sortIndex: Int32 {
        switch self {
        case .profileHeader:
            return 0
        case .showUserId:
            return 1
        case .showUserIdInfo:
            return 2
        case .showUserDc:
            return 3
        case .showUserDcInfo:
            return 4
        }
    }

    static func ==(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool {
        switch lhs {
        case let .profileHeader(lhsText):
            if case let .profileHeader(rhsText) = rhs, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .showUserId(lhsTitle, lhsValue):
            if case .showUserId(lhsTitle, lhsValue) = rhs {
                return true
            } else {
                return false
            }
        case let .showUserIdInfo(lhsText):
            if case let .showUserIdInfo(rhsText) = rhs, lhsText == rhsText {
                return true
            } else {
                return false
            }
        case let .showUserDc(lhsTitle, lhsValue):
            if case .showUserDc(lhsTitle, lhsValue) = rhs {
                return true
            } else {
                return false
            }
        case let .showUserDcInfo(lhsText):
            if case let .showUserDcInfo(rhsText) = rhs, lhsText == rhsText {
                return true
            } else {
                return false
            }
        }
    }

    static func <(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! CustomizationArguments
        switch self {
        case let .profileHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .showUserId(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleUserId(value)
            })
        case let .showUserIdInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .showUserDc(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggleUserDc(value)
            })
        case let .showUserDcInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private struct CustomizationState: Equatable {
    let showUserId: Bool
    let showUserDc: Bool
}

private struct CustomizationArguments {
    let toggleUserId: (Bool) -> Void
    let toggleUserDc: (Bool) -> Void
}

private func customizationSettingsEntries(state: CustomizationState) -> [CustomizationEntry] {
    var entries: [CustomizationEntry] = []
    entries.append(.profileHeader("PROFILE"))
    entries.append(.showUserId(title: "Show user ID", value: state.showUserId))
    entries.append(.showUserIdInfo("Displays the unique numeric Telegram account identifier in the profile card, above the phone number."))
    entries.append(.showUserDc(title: "Show user DC", value: state.showUserDc))
    entries.append(.showUserDcInfo("Displays the data center (DC) the account's media is stored on, in the profile card."))
    return entries
}

public func customizationSettingsController(context: AccountContext) -> ViewController {
    let initialState = CustomizationState(
        showUserId: UserDefaults.standard.bool(forKey: "netgramShowUserId"),
        showUserDc: UserDefaults.standard.bool(forKey: "netgramShowUserDc")
    )

    let statePromise = ValuePromise<CustomizationState>(ignoreRepeated: true)
    let stateValue = Atomic<CustomizationState>(value: initialState)
    statePromise.set(initialState)

    let updateState: ((CustomizationState) -> CustomizationState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }

    let arguments = CustomizationArguments(
        toggleUserId: { value in
            UserDefaults.standard.set(value, forKey: "netgramShowUserId")
            updateState { $0.with { $0.showUserId = value } }
        },
        toggleUserDc: { value in
            UserDefaults.standard.set(value, forKey: "netgramShowUserDc")
            updateState { $0.with { $0.showUserDc = value } }
        }
    )

    let signal = combineLatest(queue: .mainQueue(),
        context.sharedContext.presentationData,
        statePromise.get()
    )
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = customizationSettingsEntries(state: state)

        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("Customization"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)

        return (controllerState, (listState, arguments))
    }

    return ItemListController(context: context, state: signal)
}
