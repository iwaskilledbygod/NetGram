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

private enum CustomizationScreen: Equatable {
    case root
    case profile
}

private enum CustomizationEntry: ItemListNodeEntry {
    enum StableId: Hashable {
        case profileHeader
        case profileDisclosure
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
        case profileBackdropUnderCard
        case profileBackdropUnderCardInfo
        case profileBackdropWholeSection
        case profileBackdropWholeSectionInfo
        case profileBackdropTransition
        case profileBackdropTransitionInfo
        case profileBackdropAvatarColorFallback
        case profileBackdropAvatarColorFallbackInfo
    }

    case profileHeader(String)
    case profileDisclosure(String)
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
    case profileBackdropUnderCard(title: String, value: Bool)
    case profileBackdropUnderCardInfo(String)
    case profileBackdropWholeSection(title: String, value: Bool)
    case profileBackdropWholeSectionInfo(String)
    case profileBackdropTransition(title: String, value: Bool)
    case profileBackdropTransitionInfo(String)
    case profileBackdropAvatarColorFallback(title: String, value: Bool)
    case profileBackdropAvatarColorFallbackInfo(String)

    var section: ItemListSectionId { CustomizationSection.profile.rawValue }

    var stableId: StableId {
        switch self {
        case .profileHeader: return .profileHeader
        case .profileDisclosure: return .profileDisclosure
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
        case .profileBackdropUnderCard: return .profileBackdropUnderCard
        case .profileBackdropUnderCardInfo: return .profileBackdropUnderCardInfo
        case .profileBackdropWholeSection: return .profileBackdropWholeSection
        case .profileBackdropWholeSectionInfo: return .profileBackdropWholeSectionInfo
        case .profileBackdropTransition: return .profileBackdropTransition
        case .profileBackdropTransitionInfo: return .profileBackdropTransitionInfo
        case .profileBackdropAvatarColorFallback: return .profileBackdropAvatarColorFallback
        case .profileBackdropAvatarColorFallbackInfo: return .profileBackdropAvatarColorFallbackInfo
        }
    }

    var sortIndex: Int32 {
        switch self {
        case .profileHeader, .profileDisclosure: return 0
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
        case .profileBackdropUnderCard: return 13
        case .profileBackdropUnderCardInfo: return 14
        case .profileBackdropWholeSection: return 15
        case .profileBackdropWholeSectionInfo: return 16
        case .profileBackdropTransition: return 17
        case .profileBackdropTransitionInfo: return 18
        case .profileBackdropAvatarColorFallback: return 19
        case .profileBackdropAvatarColorFallbackInfo: return 20
        }
    }

    static func ==(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool {
        switch (lhs, rhs) {
        case let (.profileHeader(a), .profileHeader(b)), let (.profileDisclosure(a), .profileDisclosure(b)), let (.showUserIdInfo(a), .showUserIdInfo(b)), let (.showUserDcInfo(a), .showUserDcInfo(b)), let (.newMusicInfo(a), .newMusicInfo(b)), let (.newInfoCardInfo(a), .newInfoCardInfo(b)), let (.newButtonsInfo(a), .newButtonsInfo(b)), let (.showButtonNameInfo(a), .showButtonNameInfo(b)), let (.profileBackdropUnderCardInfo(a), .profileBackdropUnderCardInfo(b)), let (.profileBackdropWholeSectionInfo(a), .profileBackdropWholeSectionInfo(b)), let (.profileBackdropTransitionInfo(a), .profileBackdropTransitionInfo(b)), let (.profileBackdropAvatarColorFallbackInfo(a), .profileBackdropAvatarColorFallbackInfo(b)):
            return a == b
        case let (.showUserId(a, av), .showUserId(b, bv)), let (.showUserDc(a, av), .showUserDc(b, bv)), let (.newMusic(a, av), .newMusic(b, bv)), let (.newInfoCard(a, av), .newInfoCard(b, bv)), let (.newButtons(a, av), .newButtons(b, bv)), let (.showButtonName(a, av), .showButtonName(b, bv)), let (.profileBackdropUnderCard(a, av), .profileBackdropUnderCard(b, bv)), let (.profileBackdropWholeSection(a, av), .profileBackdropWholeSection(b, bv)), let (.profileBackdropTransition(a, av), .profileBackdropTransition(b, bv)), let (.profileBackdropAvatarColorFallback(a, av), .profileBackdropAvatarColorFallback(b, bv)):
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
        case let .profileDisclosure(text):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: nil, title: text, label: "", labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: arguments.openProfile)
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
        case let .profileBackdropUnderCard(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleProfileBackdropUnderCard)
        case let .profileBackdropUnderCardInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .profileBackdropWholeSection(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleProfileBackdropWholeSection)
        case let .profileBackdropWholeSectionInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .profileBackdropTransition(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleProfileBackdropTransition)
        case let .profileBackdropTransitionInfo(text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        case let .profileBackdropAvatarColorFallback(title, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: arguments.toggleProfileBackdropAvatarColorFallback)
        case let .profileBackdropAvatarColorFallbackInfo(text):
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
    var profileBackdropUnderCard: Bool
    var profileBackdropWholeSection: Bool
    var profileBackdropTransition: Bool
    var profileBackdropAvatarColorFallback: Bool
}

private struct CustomizationArguments {
    let openProfile: () -> Void
    let toggleUserId: (Bool) -> Void
    let toggleUserDc: (Bool) -> Void
    let toggleNewMusic: (Bool) -> Void
    let toggleNewInfoCard: (Bool) -> Void
    let toggleNewButtons: (Bool) -> Void
    let toggleButtonName: (Bool) -> Void
    let toggleProfileBackdropUnderCard: (Bool) -> Void
    let toggleProfileBackdropWholeSection: (Bool) -> Void
    let toggleProfileBackdropTransition: (Bool) -> Void
    let toggleProfileBackdropAvatarColorFallback: (Bool) -> Void
}

private func customizationSettingsEntries(state: CustomizationState, screen: CustomizationScreen) -> [CustomizationEntry] {
    guard screen == .profile else {
        return [.profileDisclosure("Профиль")]
    }
    var entries: [CustomizationEntry] = [.profileHeader("ПРОФИЛЬ")]
    entries.append(.showUserId(title: "Показывать ID пользователя", value: state.showUserId))
    entries.append(.showUserIdInfo("Отображает числовой идентификатор аккаунта Telegram в карточке информации профиля."))
    entries.append(.showUserDc(title: "Показывать дата-центр", value: state.showUserDc))
    entries.append(.showUserDcInfo("Отображает дата-центр (DC), который использует этот аккаунт Telegram, в карточке информации профиля."))
    entries.append(.newInfoCard(title: "Новая карточка информации", value: state.useNewInfoCard))
    entries.append(.newInfoCardInfo("Собирает данные профиля в одну карточку и скрывает заголовок личного канала и количество подписчиков."))
    entries.append(.newMusic(title: "Новый музыкальный плеер", value: state.useNewMusic))
    entries.append(.newMusicInfo("Использует новую музыкальную карточку-капсулу, которая висит в воздухе между шапкой и профилем."))
    entries.append(.newButtons(title: "Новые кнопки", value: state.useNewButtons))
    entries.append(.newButtonsInfo("Отображает действия профиля круглыми кнопками в цветах профиля."))
    if state.useNewButtons {
        entries.append(.showButtonName(title: "Показывать подписи кнопок", value: state.showButtonName))
        entries.append(.showButtonNameInfo("Показывает названия действий — звонок, видео и без звука — под кнопками."))
    }
    entries.append(.profileBackdropUnderCard(title: "Переход цвета за карточку", value: state.profileBackdropUnderCard))
    entries.append(.profileBackdropUnderCardInfo("Цвет профиля плавно переходит из шапки за карточку информации и растворяется к её нижнему краю."))
    entries.append(.profileBackdropWholeSection(title: "Переход за всю секцию", value: state.profileBackdropWholeSection))
    entries.append(.profileBackdropWholeSectionInfo("Продлевает переход цвета профиля за нижний край карточки."))
    entries.append(.profileBackdropTransition(title: "Растворение в фоне", value: state.profileBackdropTransition))
    entries.append(.profileBackdropTransitionInfo("Цвет профиля переходит из шапки и растворяется в фоне уже над серединой карточки."))
    entries.append(.profileBackdropAvatarColorFallback(title: "Цвет из фотографии аватара", value: state.profileBackdropAvatarColorFallback))
    entries.append(.profileBackdropAvatarColorFallbackInfo("Если у профиля нет цвета, берёт средний цвет из фотографии аватара."))
    return entries
}

private func customizationState() -> CustomizationState {
    let defaults = UserDefaults.standard
    return CustomizationState(
        showUserId: defaults.bool(forKey: "netgramShowUserId"),
        showUserDc: defaults.bool(forKey: "netgramShowUserDc"),
        useNewMusic: defaults.bool(forKey: "netgramUseNewMusicPlayer"),
        useNewInfoCard: defaults.bool(forKey: "netgramUseNewInfoCard"),
        useNewButtons: defaults.bool(forKey: "netgramUseNewButtons"),
        showButtonName: defaults.bool(forKey: "netgramShowButtonName"),
        profileBackdropUnderCard: defaults.bool(forKey: "netgramProfileBackdropUnderCard"),
        profileBackdropWholeSection: defaults.bool(forKey: "netgramProfileBackdropWholeSection"),
        profileBackdropTransition: defaults.bool(forKey: "netgramProfileBackdropTransition"),
        profileBackdropAvatarColorFallback: defaults.bool(forKey: "netgramProfileBackdropAvatarColorFallback")
    )
}

public func customizationSettingsController(context: AccountContext) -> ViewController {
    return makeCustomizationSettingsController(context: context, screen: .root)
}

private func makeCustomizationSettingsController(context: AccountContext, screen: CustomizationScreen) -> ItemListController {
    let initialState = customizationState()
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
    var openProfileImpl: (() -> Void)?
    let arguments = CustomizationArguments(
        openProfile: { openProfileImpl?() },
        toggleUserId: { value in setValue("netgramShowUserId", { state, value in state.showUserId = value }, value) },
        toggleUserDc: { value in setValue("netgramShowUserDc", { state, value in state.showUserDc = value }, value) },
        toggleNewMusic: { value in setValue("netgramUseNewMusicPlayer", { state, value in state.useNewMusic = value }, value) },
        toggleNewInfoCard: { value in setValue("netgramUseNewInfoCard", { state, value in state.useNewInfoCard = value }, value) },
        toggleNewButtons: { value in setValue("netgramUseNewButtons", { state, value in state.useNewButtons = value }, value) },
        toggleButtonName: { value in setValue("netgramShowButtonName", { state, value in state.showButtonName = value }, value) },
        toggleProfileBackdropUnderCard: { value in
            let nextState = stateValue.modify { state -> CustomizationState in
                var updated = state
                updated.profileBackdropUnderCard = value
                if value {
                    updated.profileBackdropWholeSection = false
                    updated.profileBackdropTransition = false
                }
                return updated
            }
            let defaults = UserDefaults.standard
            defaults.set(nextState.profileBackdropUnderCard, forKey: "netgramProfileBackdropUnderCard")
            defaults.set(nextState.profileBackdropWholeSection, forKey: "netgramProfileBackdropWholeSection")
            defaults.set(nextState.profileBackdropTransition, forKey: "netgramProfileBackdropTransition")
            statePromise.set(nextState)
        },
        toggleProfileBackdropWholeSection: { value in
            let nextState = stateValue.modify { state -> CustomizationState in
                var updated = state
                updated.profileBackdropWholeSection = value
                if value {
                    updated.profileBackdropUnderCard = false
                    updated.profileBackdropTransition = false
                }
                return updated
            }
            let defaults = UserDefaults.standard
            defaults.set(nextState.profileBackdropUnderCard, forKey: "netgramProfileBackdropUnderCard")
            defaults.set(nextState.profileBackdropWholeSection, forKey: "netgramProfileBackdropWholeSection")
            defaults.set(nextState.profileBackdropTransition, forKey: "netgramProfileBackdropTransition")
            statePromise.set(nextState)
        },
        toggleProfileBackdropTransition: { value in
            let nextState = stateValue.modify { state -> CustomizationState in
                var updated = state
                updated.profileBackdropTransition = value
                if value {
                    updated.profileBackdropUnderCard = false
                    updated.profileBackdropWholeSection = false
                }
                return updated
            }
            let defaults = UserDefaults.standard
            defaults.set(nextState.profileBackdropUnderCard, forKey: "netgramProfileBackdropUnderCard")
            defaults.set(nextState.profileBackdropWholeSection, forKey: "netgramProfileBackdropWholeSection")
            defaults.set(nextState.profileBackdropTransition, forKey: "netgramProfileBackdropTransition")
            statePromise.set(nextState)
        },
        toggleProfileBackdropAvatarColorFallback: { value in setValue("netgramProfileBackdropAvatarColorFallback", { state, value in state.profileBackdropAvatarColorFallback = value }, value) }
    )

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, statePromise.get())
    |> map { presentationData, state -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = customizationSettingsEntries(state: state, screen: screen)
        let title = screen == .root ? "NetGram" : "Профиль"
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(title), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
        return (controllerState, (listState, arguments))
    }
    let controller = ItemListController(context: context, state: signal)
    if screen == .root {
        openProfileImpl = { [weak controller] in
            controller?.push(makeCustomizationSettingsController(context: context, screen: .profile))
        }
    }
    return controller
}
