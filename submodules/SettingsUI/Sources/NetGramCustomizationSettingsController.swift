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
        case newMusic
        case newMusicInfo
        case newInfoCard
        case newInfoCardInfo
        case newButtons
        case newButtonsInfo
        case showButtonName
        case showButtonNameInfo
    }

    case profileHeader(String)
    case showUserId(title: String, value: Bool)
    case showUserIdInfo(String)
    case showUserDc(title: String, value: Bool)
    case showUserDcInfo(String)
    case newMusic(title: String, value: Bool)
    case newMusicInfo(String)
    case newInfoCard(title: String, value: Bool)
    case newInfoCardInfo(String)
    case newButtons(title: String, value: Bool)
    case newButtonsInfo(String)
    case showButtonName(title: String, value: Bool)
    case showButtonNameInfo(String)

    var section: ItemListSectionId { CustomizationSection.profile.rawValue }

    var stableId: StableId {
        switch self {
        case .profileHeader: return .profileHeader
        case .showUserId: return .showUserId
        case .showUserIdInfo: return .showUserIdInfo
        case .showUserDc: return .showUserDc
        case .showUserDcInfo: return .showUserDcInfo
        case .newMusic: return .newMusic
        case .newMusicInfo: return .newMusicInfo
        case .newInfoCard: return .newInfoCard
        case .newInfoCardInfo: return .newInfoCardInfo
        case .newButtons: return .newButtons
        case .newButtonsInfo: return .newButtonsInfo
        case .showButtonName: return .showButtonName
        case .showButtonNameInfo: return .showButtonNameInfo
        }
    }

    var sortIndex: Int32 {
        switch self {
        case .profileHeader: return 0
        case .showUserId: return 1
        case .showUserIdInfo: return 2
        case .showUserDc: return 3
        case .showUserDcInfo: return 4
        case .newInfoCard: return 5
        case .newInfoCardInfo: return 6
        case .newMusic: return 7
        case .newMusicInfo: return 8
        case .newButtons: return 9
        case .newButtonsInfo: return 10
        case .showButtonName: return 11
        case .showButtonNameInfo: return 12
        }
    }

    static func ==(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool {
        switch (lhs, rhs) {
        case let (.profileHeader(a), .profileHeader(b)), let (.showUserIdInfo(a), .showUserIdInfo(b)), let (.showUserDcInfo(a), .showUserDcInfo(b)), let (.newMusicInfo(a), .newMusicInfo(b)), let (.newInfoCardInfo(a), .newInfoCardInfo(b)), let (.newButtonsInfo(a), .newButtonsInfo(b)), let (.showButtonNameInfo(a), .showButtonNameInfo(b)):
            return a == b
        case let (.showUserId(a, av), .showUserId(b, bv)), let (.showUserDc(a, av), .showUserDc(b, bv)), let (.newMusic(a, av), .newMusic(b, bv)), let (.newInfoCard(a, av), .newInfoCard(b, bv)), let (.newButtons(a, av), .newButtons(b, bv)), let (.showButtonName(a, av), .showButtonName(b, bv)):
            return a == b && av == bv
        default:
            return false
        }
    }

    static func <(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool { lhs.sortIndex < rhs.sortIndex }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! CustomizationArguments
        switch self {
        case let .profileHeader(text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .showUserId(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleUserId)
        case let .showUserIdInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .showUserDc(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleUserDc)
        case let .showUserDcInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .newMusic(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleNewMusic)
        case let .newMusicInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .newInfoCard(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleNewInfoCard)
        case let .newInfoCardInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .newButtons(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleNewButtons)
        case let .newButtonsInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .showButtonName(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleButtonName)
        case let .showButtonNameInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private struct CustomizationState: Equatable {
    var showUserId: Bool
    var showUserDc: Bool
    var useNewMusic: Bool
    var useNewInfoCard: Bool
    var useNewButtons: Bool
    var showButtonName: Bool
}

private struct CustomizationArguments {
    let toggleUserId: (Bool) -> Void
    let toggleUserDc: (Bool) -> Void
    let toggleNewMusic: (Bool) -> Void
    let toggleNewInfoCard: (Bool) -> Void
    let toggleNewButtons: (Bool) -> Void
    let toggleButtonName: (Bool) -> Void
}

private func customizationSettingsEntries(state: CustomizationState) -> [CustomizationEntry] {
    var entries: [CustomizationEntry] = [.profileHeader("PROFILE")]
    entries.append(.showUserId(title: "Show user ID", value: state.showUserId))
    entries.append(.showUserIdInfo("Displays the unique numeric Telegram account identifier inside the profile information card."))
    entries.append(.showUserDc(title: "Show user DC", value: state.showUserDc))
    entries.append(.showUserDcInfo("Displays the data center (DC) used by this Telegram account inside the profile information card."))
    entries.append(.newInfoCard(title: "Use new info card", value: state.useNewInfoCard))
    entries.append(.newInfoCardInfo("Combines profile details in one card and hides the personal channel heading and subscriber count."))
    entries.append(.newMusic(title: "Use new music player", value: state.useNewMusic))
    entries.append(.newMusicInfo("Uses the new glass-style music card in the profile."))
    entries.append(.newButtons(title: "New buttons", value: state.useNewButtons))
    entries.append(.newButtonsInfo("Displays profile actions as round buttons using the profile colors."))
    if state.useNewButtons {
        entries.append(.showButtonName(title: "Show button name", value: state.showButtonName))
        entries.append(.showButtonNameInfo("Shows action names such as call, video, and mute below the buttons."))
    }
    return entries
}

public func customizationSettingsController(context: AccountContext) -> ViewController {
    let initialState = CustomizationState(
        showUserId: UserDefaults.standard.bool(forKey: "netgramShowUserId"),
        showUserDc: UserDefaults.standard.bool(forKey: "netgramShowUserDc"),
        useNewMusic: UserDefaults.standard.bool(forKey: "netgramUseNewMusicPlayer"),
        useNewInfoCard: UserDefaults.standard.bool(forKey: "netgramUseNewInfoCard"),
        useNewButtons: UserDefaults.standard.bool(forKey: "netgramUseNewButtons"),
        showButtonName: UserDefaults.standard.bool(forKey: "netgramShowButtonName")
    )

    let statePromise = ValuePromise<CustomizationState>(ignoreRepeated: true)
    let stateValue = Atomic<CustomizationState>(value: initialState)
    statePromise.set(initialState)
    let updateState: ((CustomizationState) -> CustomizationState) -> Void = { f in
        statePromise.set(stateValue.modify { f($0) })
    }
    let setValue: (String, (inout CustomizationState, Bool) -> Void, Bool) -> Void = { key, update, value in
        UserDefaults.standard.set(value, forKey: key)
        updateState { state in
            var updated = state
            update(&updated, value)
            return updated
        }
    }
    let arguments = CustomizationArguments(
        toggleUserId: { value in setValue("netgramShowUserId", { state, value in state.showUserId = value }, value) },
        toggleUserDc: { value in setValue("netgramShowUserDc", { state, value in state.showUserDc = value }, value) },
        toggleNewMusic: { value in setValue("netgramUseNewMusicPlayer", { state, value in state.useNewMusic = value }, value) },
        toggleNewInfoCard: { value in setValue("netgramUseNewInfoCard", { state, value in state.useNewInfoCard = value }, value) },
        toggleNewButtons: { value in setValue("netgramUseNewButtons", { state, value in state.useNewButtons = value }, value) },
        toggleButtonName: { value in setValue("netgramShowButtonName", { state, value in state.showButtonName = value }, value) }
    )

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, statePromise.get())
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = customizationSettingsEntries(state: state)
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text("NetGram"), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
        return (controllerState, (listState, arguments))
    }
    return ItemListController(context: context, state: signal)
}
