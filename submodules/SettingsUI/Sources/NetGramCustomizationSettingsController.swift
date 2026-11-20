import Foundation
import UIKit
import Display
import AsyncDisplayKit
import SwiftSignalKit
import TelegramPresentationData
import AccountContext
import ItemListUI
import PresentationDataUtils

private enum CustomizationScreen: String {
    case root
    case profile
    case notifications
}

private struct NetGramToggleItem {
    let key: String
    let title: String
    let info: String
}

private let profileToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "ShowUserId", title: "Показывать ID пользователя", info: "Отображает числовой идентификатор аккаунта Telegram в карточке информации профиля."),
    NetGramToggleItem(key: "ShowUserDc", title: "Показывать дата-центр", info: "Отображает дата-центр (DC), который использует этот аккаунт Telegram, в карточке информации профиля."),
    NetGramToggleItem(key: "UseNewInfoCard", title: "Новая карточка информации", info: "Собирает данные профиля в одну карточку и скрывает заголовок личного канала и количество подписчиков."),
    NetGramToggleItem(key: "UseNewMusicPlayer", title: "Новый музыкальный плеер", info: "Использует музыкальную карточку-капсулу между шапкой и профилем."),
    NetGramToggleItem(key: "UseNewButtons", title: "Новые кнопки", info: "Отображает действия профиля круглыми кнопками в цветах профиля."),
    NetGramToggleItem(key: "ShowButtonName", title: "Показывать подписи кнопок", info: "Показывает названия действий — звонок, видео и без звука — под кнопками."),
    NetGramToggleItem(key: "ProfileBackdropTransition", title: "Переход цвета из шапки", info: "Цвет фона аватара единой секцией перетекает из шапки за карточку информации и растворяется к её нижнему краю."),
    NetGramToggleItem(key: "ProfileBackdropAvatarColorFallback", title: "Цвет из фотографии аватара", info: "Если у профиля нет цвета, берёт средний цвет из фотографии аватара.")
]

private let notificationToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "BackgroundKeepAlive", title: "Фоновые уведомления (бесшумная дорожка)", info: "Постоянно играет бесшумную дорожку, чтобы приложение не засыпало в фоне. Расходует батарею и не гарантирует доставку уведомлений без push-сертификата."),
    NetGramToggleItem(key: "KeepAliveStopOnHeadphones", title: "Останавливать при подключении наушников", info: "Останавливает бесшумную дорожку, когда подключаются наушники."),
    NetGramToggleItem(key: "KeepAliveStopOnLowBattery", title: "Останавливать при заряде ниже 10%", info: "Останавливает бесшумную дорожку, когда батарея почти разряжена.")
]

private enum CustomizationEntry: ItemListNodeEntry {
    case header(Int32, String)
    case disclosure(Int32, String, CustomizationScreen)
    case toggle(Int32, String, String, Bool)
    case text(Int32, String)

    var section: ItemListSectionId {
        return 0
    }

    var stableId: String {
        switch self {
        case let .header(index, _):
            return "h\(index)"
        case let .disclosure(index, _, screen):
            return "d\(index)\(screen.rawValue)"
        case let .toggle(index, key, _, _):
            return "t\(index)\(key)"
        case let .text(index, _):
            return "x\(index)"
        }
    }

    var sortIndex: Int32 {
        switch self {
        case let .header(index, _), let .disclosure(index, _, _), let .toggle(index, _, _, _), let .text(index, _):
            return index
        }
    }

    static func ==(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool {
        switch (lhs, rhs) {
        case let (.header(i, a), .header(j, b)):
            return i == j && a == b
        case let (.disclosure(i, a, s), .disclosure(j, b, t)):
            return i == j && a == b && s == t
        case let (.toggle(i, ka, ta, va), .toggle(j, kb, tb, vb)):
            return i == j && ka == kb && ta == tb && va == vb
        case let (.text(i, a), .text(j, b)):
            return i == j && a == b
        default:
            return false
        }
    }

    static func <(lhs: CustomizationEntry, rhs: CustomizationEntry) -> Bool {
        return lhs.sortIndex < rhs.sortIndex
    }

    func item(presentationData: ItemListPresentationData, arguments: Any) -> ListViewItem {
        let arguments = arguments as! CustomizationArguments
        switch self {
        case let .header(_, text):
            return ItemListSectionHeaderItem(presentationData: presentationData, text: text, sectionId: self.section)
        case let .disclosure(_, title, screen):
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: nil, title: title, label: "", labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .arrow, action: {
                arguments.openScreen(screen)
            })
        case let .toggle(_, title, key, value):
            return ItemListSwitchItem(presentationData: presentationData, systemStyle: .glass, title: title, value: value, sectionId: self.section, style: .blocks, updated: { value in
                arguments.toggle(key, value)
            })
        case let .text(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private struct CustomizationArguments {
    let openScreen: (CustomizationScreen) -> Void
    let toggle: (String, Bool) -> Void
}

private func appendTable(_ entries: inout [CustomizationEntry], table: [NetGramToggleItem]) {
    var index = entries.count
    for item in table {
        let value = UserDefaults.standard.bool(forKey: "netgram" + item.key)
        entries.append(.toggle(Int32(index), item.title, item.key, value))
        index += 1
        entries.append(.text(Int32(index), item.info))
        index += 1
    }
}

private func customizationEntries(screen: CustomizationScreen) -> [CustomizationEntry] {
    var entries: [CustomizationEntry] = []
    var index: Int32 = 0

    switch screen {
    case .root:
        entries.append(.header(index, "NETGRAM"))
        index += 1
        entries.append(.disclosure(index, "Профиль", .profile))
        index += 1
        entries.append(.disclosure(index, "Уведомления", .notifications))
    case .profile:
        entries.append(.header(index, "ПРОФИЛЬ"))
        appendTable(&entries, table: profileToggles.filter { $0.key != "ShowButtonName" || UserDefaults.standard.bool(forKey: "netgramUseNewButtons") })
    case .notifications:
        entries.append(.header(index, "УВЕДОМЛЕНИЯ"))
        appendTable(&entries, table: notificationToggles)
        let playing = UserDefaults.standard.bool(forKey: "netgramKeepAlivePlaying")
        entries.append(.text(Int32(entries.count), "Статус бесшумной дорожки: \(playing ? "играет" : "остановлена")"))
    }

    return entries
}

private func customizationScreenTitle(_ screen: CustomizationScreen) -> String {
    switch screen {
    case .root:
        return "NetGram"
    case .profile:
        return "Профиль"
    case .notifications:
        return "Уведомления"
    }
}

public func customizationSettingsController(context: AccountContext) -> ViewController {
    return makeCustomizationSettingsController(context: context, screen: .root)
}

private func makeCustomizationSettingsController(context: AccountContext, screen: CustomizationScreen) -> ItemListController {
    let statePromise = ValuePromise<Int>(ignoreRepeated: true)
    let stateValue = Atomic<Int>(value: 0)
    statePromise.set(0)
    let bumpState: () -> Void = {
        let _ = stateValue.modify { $0 + 1 }
        statePromise.set(stateValue.with { $0 })
    }

    var openScreenImpl: ((CustomizationScreen) -> Void)?
    let arguments = CustomizationArguments(
        openScreen: { screen in
            openScreenImpl?(screen)
        },
        toggle: { key, value in
            UserDefaults.standard.set(value, forKey: "netgram" + key)
            bumpState()
        }
    )

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, statePromise.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = customizationEntries(screen: screen)
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(customizationScreenTitle(screen)), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: .blocks)
        return (controllerState, (listState, arguments))
    }
    let controller = ItemListController(context: context, state: signal)
    if screen == .root {
        openScreenImpl = { [weak controller] screen in
            controller?.push(makeCustomizationSettingsController(context: context, screen: screen))
        }
    }
    return controller
}
