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
    case profilePrivacy
    case profileStyle
    case chatList
    case chats
    case notifications
    case misc
}

private struct NetGramToggleItem {
    let key: String
    let title: String
    let info: String
}

private struct NetGramCycleItem {
    let key: String
    let title: String
    let info: String
    let options: [String]
}

private let profileToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "ShowUserId", title: "Показывать ID пользователя", info: "Отображает числовой идентификатор аккаунта Telegram в карточке информации профиля."),
    NetGramToggleItem(key: "ShowUserDc", title: "Показывать дата-центр", info: "Отображает дата-центр (DC), который использует этот аккаунт Telegram, в карточке информации профиля."),
    NetGramToggleItem(key: "UseNewInfoCard", title: "Новая карточка информации", info: "Собирает данные профиля в одну карточку и скрывает заголовок личного канала и количество подписчиков."),
    NetGramToggleItem(key: "UseNewMusicPlayer", title: "Новый музыкальный плеер", info: "Компактная стеклянная капсула с музыкой, которая висит в воздухе между шапкой и профилем."),
    NetGramToggleItem(key: "UseNewButtons", title: "Новые кнопки", info: "Отображает действия профиля круглыми кнопками в цветах профиля."),
    NetGramToggleItem(key: "ShowButtonName", title: "Показывать подписи кнопок", info: "Показывает названия действий — звонок, видео и без звука — под кнопками."),
    NetGramToggleItem(key: "ProfileBackdropTransition", title: "Переход цвета из шапки", info: "Цвет фона аватара единой секцией перетекает из шапки за карточку информации и растворяется к её нижнему краю."),
    NetGramToggleItem(key: "ProfileBackdropAvatarColorFallback", title: "Цвет из фотографии аватара", info: "Если у профиля нет цвета, берёт средний цвет из фотографии аватара."),
    NetGramToggleItem(key: "HideWalletPill", title: "Скрыть капсулу баланса", info: "Убирает капсулу «Баланс» из шапки профиля."),
    NetGramToggleItem(key: "AlwaysShowBalance", title: "Всегда показывать баланс", info: "Показывает капсулу баланса даже с минимальной суммой на счету."),
    NetGramToggleItem(key: "HideSavedMusic", title: "Скрыть музыку в профиле", info: "Убирает музыкальную строку из шапки профиля."),
    NetGramToggleItem(key: "HideVerifiedIcon", title: "Скрыть галочку верификации", info: "Убирает значок верификации у имени в шапке профиля."),
    NetGramToggleItem(key: "HidePremiumBadge", title: "Скрыть значок Premium", info: "Убирает значок Premium у имени в шапке профиля."),
    NetGramToggleItem(key: "HideEmojiStatus", title: "Скрыть статус-эмодзи", info: "Убирает эмодзи-статус рядом с именем в шапке профиля."),
    NetGramToggleItem(key: "HideCoverPattern", title: "Скрыть узор фона", info: "Убирает узор с фона шапки профиля, оставляя чистый градиент."),
    NetGramToggleItem(key: "HideProfileTitle", title: "Скрыть имя в шапке", info: "Скрывает имя в шапке профиля."),
    NetGramToggleItem(key: "HideProfileSubtitle", title: "Скрыть строку статуса", info: "Скрывает «в сети» и подобные статусы в шапке профиля."),
    NetGramToggleItem(key: "PhoneCopyOnHold", title: "Копировать телефон удержанием", info: "Удержание на номере телефона копирует его в буфер обмена."),
    NetGramToggleItem(key: "UsernameCopyOnHold", title: "Копировать юзернейм удержанием", info: "Удержание на юзернейме копирует его в буфер обмена.")
]

private let profilePrivacyToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "HideCallList", title: "Скрыть журнал звонков", info: "Убирает недавние звонки из профиля."),
    NetGramToggleItem(key: "HidePersonalChannel", title: "Скрыть личный канал", info: "Убирает строку личного канала из профиля."),
    NetGramToggleItem(key: "HideCommunityRow", title: "Скрыть сообщество", info: "Убирает привязанное сообщество из профиля."),
    NetGramToggleItem(key: "HideBirthdayRow", title: "Скрыть дату рождения", info: "Убирает дату рождения из карточки информации."),
    NetGramToggleItem(key: "HideAboutRow", title: "Скрыть «о себе»", info: "Убирает блок «о себе» из карточки информации."),
    NetGramToggleItem(key: "HideNoteRow", title: "Скрыть заметки", info: "Убирает заметки о пользователе из профиля."),
    NetGramToggleItem(key: "HideAppFooterRow", title: "Скрыть нижний блок приложения", info: "Убирает строку-подвал под данными профиля."),
    NetGramToggleItem(key: "HideAffiliateRow", title: "Скрыть партнёрскую программу", info: "Убирает строку партнёрской программы из профиля."),
    NetGramToggleItem(key: "HideBusinessHoursRow", title: "Скрыть часы работы", info: "Убирает часы работы из карточки информации."),
    NetGramToggleItem(key: "HideLocationRow", title: "Скрыть адрес", info: "Убирает адрес и карту из карточки информации."),
    NetGramToggleItem(key: "HideAddToContactsRow", title: "Скрыть «добавить в контакты»", info: "Убирает кнопку добавления в контакты."),
    NetGramToggleItem(key: "HideBlockRow", title: "Скрыть блокировку", info: "Убирает кнопку блокировки пользователя."),
    NetGramToggleItem(key: "HideReportRow", title: "Скрыть «пожаловаться»", info: "Убирает кнопку жалобы из профиля."),
    NetGramToggleItem(key: "HideEncryptionKeyRow", title: "Скрыть ключ шифрования", info: "Убирает строку ключа шифрования секретного чата."),
    NetGramToggleItem(key: "HideBotPermissions", title: "Скрыть разрешения бота", info: "Убирает секцию разрешений бота."),
    NetGramToggleItem(key: "HideBotSettingsRow", title: "Скрыть настройки бота", info: "Убирает кнопку настроек бота."),
    NetGramToggleItem(key: "HideBotReportRow", title: "Скрыть жалобу на бота", info: "Убирает кнопку жалобы на бота."),
    NetGramToggleItem(key: "HideVerificationRow", title: "Скрыть строку верификации", info: "Убирает описание верификации из профиля."),
    NetGramToggleItem(key: "HideBotAddToChatRow", title: "Скрыть «добавить бота в группу»", info: "Убирает кнопку добавления бота в группу."),
    NetGramToggleItem(key: "HideBotBalanceRows", title: "Скрыть баланс бота", info: "Убирает секцию баланса бота."),
    NetGramToggleItem(key: "HideDeleteReactionRow", title: "Скрыть «удалить реакцию»", info: "Убирает кнопку удаления своей реакции из профиля.")
]

private let profileStyleCycles: [NetGramCycleItem] = [
    NetGramCycleItem(key: "GlassDensity", title: "Насыщенность стекла", info: "Насколько плотно стекло заливает карточку информации.", options: ["Обычное", "Плотное", "Насыщенное"]),
    NetGramCycleItem(key: "GlassTintStyle", title: "Оттенок стекла", info: "Цвет заливки стекла карточки.", options: ["Белое", "Тёмное", "В цвет профиля"]),
    NetGramCycleItem(key: "CardRadius", title: "Скругление карточек", info: "Радиус углов стеклянных карточек.", options: ["Обычное", "Крупное", "Максимальное"]),
    NetGramCycleItem(key: "CardInnerPadding", title: "Внутренний контур стекла", info: "Толщина внутреннего контура стекла карточки.", options: ["Тонкий", "Средний", "Широкий"]),
    NetGramCycleItem(key: "BackdropLength", title: "Длина перехода", info: "Как далеко за карточку тянется цветовой переход.", options: ["До низа карточки", "Длинный", "Короткий"]),
    NetGramCycleItem(key: "BackdropFadeStyle", title: "Форма перехода", info: "Как быстро цвет растворяется в фоне.", options: ["Линейный", "Резкий", "Мягкий"]),
    NetGramCycleItem(key: "BackdropStrength", title: "Контраст перехода", info: "Насколько заметен цвет в середине перехода.", options: ["Обычный", "Мягкий", "Насыщенный"]),
    NetGramCycleItem(key: "BackdropColorSource", title: "Источник цвета перехода", info: "Какой цвет обложки берётся за основу перехода. Авто — как в шапке.", options: ["Авто", "Основной", "Второй"]),
    NetGramCycleItem(key: "BackdropTopGap", title: "Отступ перехода от шапки", info: "Сколько места оставить между шапкой и началом перехода.", options: ["Обычный", "Широкий", "Максимальный"]),
    NetGramCycleItem(key: "BackdropWidth", title: "Ширина перехода", info: "Занимает ли переход весь экран или только зону карточки.", options: ["Вся ширина", "Ширина карточки"]),
    NetGramCycleItem(key: "BackdropDirection", title: "Направление перехода", info: "Геометрия цветового перехода за карточкой.", options: ["Вертикальный", "Диагональный"]),
    NetGramCycleItem(key: "ButtonSizeStyle", title: "Размер кнопок", info: "Размер круглых кнопок действий в шапке профиля.", options: ["Обычный", "Крупный", "Максимальный"]),
    NetGramCycleItem(key: "ButtonsSpacing", title: "Расстояние между кнопками", info: "Промежуток между круглыми кнопками профиля.", options: ["Обычный", "Широкий", "Плотный"]),
    NetGramCycleItem(key: "MusicCapsuleSize", title: "Размер музыкальной капсулы", info: "Высота висящей музыкальной капсулы.", options: ["Обычный", "Крупный", "Максимальный"]),
    NetGramCycleItem(key: "MusicCapsuleOffset", title: "Позиция музыкальной капсулы", info: "На какой высоте капсула висит над краем шапки.", options: ["Обычная", "Выше", "Ниже"])
]

private let profileStyleToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "CardShadow", title: "Тень карточки", info: "Добавляет мягкую тень под стеклянной карточкой."),
    NetGramToggleItem(key: "CardBorder", title: "Контур карточки", info: "Тонкая рамка по краю стеклянной карточки."),
    NetGramToggleItem(key: "GlassInnerGlow", title: "Свечение внутри стекла", info: "Светлый внутренний контур по краю стекла."),
    NetGramToggleItem(key: "BackdropCenterGlow", title: "Свечение в центре перехода", info: "Лёгкий радиальный блик в центре цветового перехода."),
    NetGramToggleItem(key: "TransparentButtons", title: "Прозрачные кнопки", info: "Делает стеклянные кнопки действий заметно прозрачнее."),
    NetGramToggleItem(key: "MusicCapsuleShadow", title: "Тень музыкальной капсулы", info: "Добавляет мягкую тень под висящей музыкальной капсулой."),
    NetGramToggleItem(key: "MusicCapsuleGlass", title: "Стекло капсулы на любом профиле", info: "Показывает музыкальную капсулу со стеклом даже у профилей без обложки."),
    NetGramToggleItem(key: "DimProfileHeader", title: "Приглушить шапку профиля", info: "Слегка снижает яркость шапки профиля.")
]

private let chatListToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "HideStoriesPanel", title: "Скрыть панель сторис", info: "Убирает панель сторис из шапки списка чатов."),
    NetGramToggleItem(key: "HideListDate", title: "Скрыть время сообщения", info: "Убирает время последнего сообщения из строк списка чатов."),
    NetGramToggleItem(key: "HideListDateDisclosure", title: "Скрыть стрелку у времени", info: "Убирает стрелку рядом со временем в списке чатов."),
    NetGramToggleItem(key: "HideListStatusIcons", title: "Скрыть значки закрепления", info: "Убирает значки закрепления и секретных чатов у названия."),
    NetGramToggleItem(key: "HideListBadges", title: "Скрыть счётчики непрочитанных", info: "Убирает счётчики непрочитанных сообщений из списка чатов."),
    NetGramToggleItem(key: "HideListMentionBadges", title: "Скрыть бейджи упоминаний", info: "Убирает бейджи «@» и реакций из списка чатов."),
    NetGramToggleItem(key: "HideListOnlineDots", title: "Скрыть точки «в сети»", info: "Убирает зелёные индикаторы онлайна с аватаров."),
    NetGramToggleItem(key: "HideListVerifiedIcons", title: "Скрыть значки верификации", info: "Убирает галочки верификации из списка чатов."),
    NetGramToggleItem(key: "HideListCredibilityIcons", title: "Скрыть значки Premium и «скам»", info: "Убирает значки Premium и предупреждений из списка чатов."),
    NetGramToggleItem(key: "HideListStatusEmoji", title: "Скрыть статус-эмодзи в списке", info: "Убирает эмодзи-статусы из списка чатов."),
    NetGramToggleItem(key: "HideListMuteIcons", title: "Скрыть значки «без звука»", info: "Убирает значки выключенных уведомлений из списка чатов."),
    NetGramToggleItem(key: "HideListNetBadges", title: "Скрыть бейджи NetGram", info: "Убирает служебные бейджи NetGram из списка чатов."),
    NetGramToggleItem(key: "HideListTimerBadges", title: "Скрыть значки таймера", info: "Убирает значки самоуничтожения с аватаров."),
    NetGramToggleItem(key: "HideListLiveBadges", title: "Скрыть значки прямых эфиров", info: "Убирает значки live-трансляций с аватаров."),
    NetGramToggleItem(key: "HideListMediaPreviews", title: "Скрыть превью медиа", info: "Убирает миниатюры медиа из строк списка чатов."),
    NetGramToggleItem(key: "HideListItemTags", title: "Скрыть теги чатов", info: "Убирает теги папок из строк списка чатов."),
    NetGramToggleItem(key: "HideListAvatars", title: "Скрыть аватары", info: "Текстовый список чатов без аватаров."),
    NetGramToggleItem(key: "HideListTyping", title: "Скрыть «печатает…» в списке", info: "Убирает индикаторы набора текста из списка чатов."),
    NetGramToggleItem(key: "HideListDustEffect", title: "Скрыть эффект пыли", info: "Отключает эффект исчезающих сообщений в списке чатов."),
    NetGramToggleItem(key: "DimMutedChats", title: "Приглушить чаты без звука", info: "Слегка снижает яркость строк чатов с выключенными уведомлениями."),
    NetGramToggleItem(key: "HideListSeparators", title: "Скрыть разделители строк", info: "Убирает разделительные линии между строками списка чатов."),
    NetGramToggleItem(key: "HideListStars", title: "Скрыть звёзды на аватарах", info: "Убирает звёздочные отметки с аватаров в списке чатов."),
    NetGramToggleItem(key: "HideListOpenAppButton", title: "Скрыть кнопку «Открыть приложение»", info: "Убирает кнопку открытия мини-приложения из строк списка чатов.")
]

private let chatsToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "HideChatHeaderContents", title: "Скрыть содержимое шапки чата", info: "Оставляет в шапке чата только стеклянную капсулу без имени и статусов."),
    NetGramToggleItem(key: "HideChatSubtitle", title: "Скрыть статус в шапке чата", info: "Убирает строку «в сети», «печатает…» и подобные статусы в шапке чата."),
    NetGramToggleItem(key: "HideChatTitle", title: "Скрыть имя собеседника", info: "Скрывает имя в шапке чата."),
    NetGramToggleItem(key: "HideChatVerifiedIcon", title: "Скрыть галочку верификации в шапке", info: "Убирает значок верификации из шапки чата."),
    NetGramToggleItem(key: "HideChatCredibilityIcon", title: "Скрыть значок Premium в шапке", info: "Убирает значок Premium из шапки чата."),
    NetGramToggleItem(key: "HideChatStatusEmoji", title: "Скрыть статус-эмодзи в шапке", info: "Убирает эмодзи-статус из шапки чата."),
    NetGramToggleItem(key: "HideChatNetBadge", title: "Скрыть бейдж NetGram в шапке", info: "Убирает служебный бейдж NetGram из шапки чата."),
    NetGramToggleItem(key: "HideChatLockIcon", title: "Скрыть значок секретного чата", info: "Убирает значок замка из шапки секретного чата.")
]

private let notificationsToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "BackgroundKeepAlive", title: "Фоновые уведомления (бесшумная дорожка)", info: "Постоянно играет бесшумную дорожку, чтобы приложение не засыпало в фоне и получало уведомления без сертификата. Расходует батарею."),
    NetGramToggleItem(key: "KeepAliveStopOnHeadphones", title: "Останавливать при подключении наушников", info: "Останавливает бесшумную дорожку, когда подключаются наушники."),
    NetGramToggleItem(key: "KeepAliveStopOnLowBattery", title: "Останавливать при заряде ниже 10%", info: "Останавливает бесшумную дорожку, когда батарея почти разряжена.")
]

private let miscToggles: [NetGramToggleItem] = [
    NetGramToggleItem(key: "HideInfoDescriptions", title: "Скрыть описания функций", info: "Убирает пояснения под переключателями в настройках NetGram."),
    NetGramToggleItem(key: "SettingsListStyle", title: "Простые списки настроек", info: "Переключает настройки NetGram на простой стиль без карточек."),
    NetGramToggleItem(key: "ShowFeatureCounter", title: "Показывать счётчик функций", info: "Показывает внизу главного экрана, сколько функций включено."),
    NetGramToggleItem(key: "SettingsShowKeys", title: "Показывать ключи функций", info: "Добавляет к описаниям технический ключ функции.")
]

private func allToggleKeys() -> [String] {
    var keys: [String] = []
    for table in [profileToggles, profilePrivacyToggles, profileStyleToggles, chatListToggles, chatsToggles, notificationsToggles, miscToggles] {
        for item in table {
            keys.append(item.key)
        }
    }
    return keys
}

private func enabledFeatureCount() -> Int {
    let defaults = UserDefaults.standard
    var count = 0
    for key in allToggleKeys() {
        if defaults.bool(forKey: "netgram" + key) {
            count += 1
        }
    }
    return count
}

private func allCycles() -> [NetGramCycleItem] {
    return profileStyleCycles
}

private enum CustomizationEntry: ItemListNodeEntry {
    case header(Int32, String)
    case disclosure(Int32, String, CustomizationScreen)
    case toggle(Int32, String, String, Bool)
    case cycle(Int32, String, Int, [String])
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
        case let .cycle(index, key, _, _):
            return "c\(index)\(key)"
        case let .text(index, _):
            return "x\(index)"
        }
    }

    var sortIndex: Int32 {
        switch self {
        case let .header(index, _), let .disclosure(index, _, _), let .toggle(index, _, _, _), let .cycle(index, _, _, _), let .text(index, _):
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
        case let (.cycle(i, ka, ia, oa), .cycle(j, kb, ib, ob)):
            return i == j && ka == kb && ia == ib && oa == ob
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
        case let .cycle(_, title, index, options):
            let optionTitle = options[max(0, min(options.count - 1, index))]
            return ItemListDisclosureItem(presentationData: presentationData, systemStyle: .glass, icon: nil, title: "\(title): \(optionTitle)", label: "", labelStyle: .text, sectionId: self.section, style: .blocks, disclosureStyle: .none, action: {
                arguments.cycle(cycleKey(title, options: options), options.count)
            })
        case let .text(_, text):
            return ItemListTextItem(presentationData: presentationData, text: .plain(text), sectionId: self.section)
        }
    }
}

private func cycleKey(_ title: String, options: [String]) -> String {
    for cycle in allCycles() {
        if cycle.title == title {
            return cycle.key
        }
    }
    return title
}

private struct CustomizationArguments {
    let openScreen: (CustomizationScreen) -> Void
    let toggle: (String, Bool) -> Void
    let cycle: (String, Int) -> Void
}

private func appendTable(_ entries: inout [CustomizationEntry], table: [NetGramToggleItem], showInfo: Bool, showKeys: Bool) {
    var index = entries.count
    for item in table {
        let value = UserDefaults.standard.bool(forKey: "netgram" + item.key)
        entries.append(.toggle(Int32(index), item.title, item.key, value))
        index += 1
        if showInfo {
            let infoText: String
            if showKeys {
                infoText = "\(item.info) (netgram\(item.key))"
            } else {
                infoText = item.info
            }
            entries.append(.text(Int32(index), infoText))
            index += 1
        }
    }
}

private func customizationEntries(screen: CustomizationScreen) -> [CustomizationEntry] {
    let showInfo = !NetGramFeatures.enabled("HideInfoDescriptions")
    let showKeys = NetGramFeatures.enabled("SettingsShowKeys")
    var entries: [CustomizationEntry] = []
    var index: Int32 = 0

    switch screen {
    case .root:
        entries.append(.header(index, "NETGRAM"))
        index += 1
        entries.append(.disclosure(index, "Профиль", .profile))
        index += 1
        entries.append(.disclosure(index, "Оформление профиля", .profileStyle))
        index += 1
        entries.append(.disclosure(index, "Приватность профиля", .profilePrivacy))
        index += 1
        entries.append(.disclosure(index, "Список чатов", .chatList))
        index += 1
        entries.append(.disclosure(index, "Чаты", .chats))
        index += 1
        entries.append(.disclosure(index, "Уведомления", .notifications))
        index += 1
        entries.append(.disclosure(index, "Разное", .misc))
        index += 1
        if NetGramFeatures.enabled("ShowFeatureCounter") {
            entries.append(.text(index, "Включено функций: \(enabledFeatureCount()) из \(allToggleKeys().count)"))
            index += 1
        }
    case .profile:
        entries.append(.header(index, "ПРОФИЛЬ"))
        index += 1
        appendTable(&entries, table: profileToggles, showInfo: showInfo, showKeys: showKeys)
    case .profilePrivacy:
        entries.append(.header(index, "ПРИВАТНОСТЬ ПРОФИЛЯ"))
        index += 1
        appendTable(&entries, table: profilePrivacyToggles, showInfo: showInfo, showKeys: showKeys)
    case .profileStyle:
        entries.append(.header(index, "ОФОРМЛЕНИЕ ПРОФИЛЯ"))
        index += 1
        appendTable(&entries, table: profileStyleToggles, showInfo: showInfo, showKeys: showKeys)
        for cycle in profileStyleCycles {
            let value = NetGramFeatures.integer(cycle.key)
            entries.append(.cycle(index, cycle.title, value, cycle.options))
            index += 1
            if showInfo {
                entries.append(.text(index, showKeys ? "\(cycle.info) (netgram\(cycle.key))" : cycle.info))
                index += 1
            }
        }
    case .chatList:
        entries.append(.header(index, "СПИСОК ЧАТОВ"))
        index += 1
        appendTable(&entries, table: chatListToggles, showInfo: showInfo, showKeys: showKeys)
    case .chats:
        entries.append(.header(index, "ЧАТЫ"))
        index += 1
        appendTable(&entries, table: chatsToggles, showInfo: showInfo, showKeys: showKeys)
    case .notifications:
        entries.append(.header(index, "УВЕДОМЛЕНИЯ"))
        index += 1
        appendTable(&entries, table: notificationsToggles, showInfo: showInfo, showKeys: showKeys)
        let playing = UserDefaults.standard.bool(forKey: "netgramKeepAlivePlaying")
        entries.append(.text(index, "Статус бесшумной дорожки: \(playing ? "играет" : "остановлена")"))
        index += 1
    case .misc:
        entries.append(.header(index, "РАЗНОЕ"))
        index += 1
        appendTable(&entries, table: miscToggles, showInfo: showInfo, showKeys: showKeys)
    }

    return entries
}

private func customizationScreenTitle(_ screen: CustomizationScreen) -> String {
    switch screen {
    case .root:
        return "NetGram"
    case .profile:
        return "Профиль"
    case .profilePrivacy:
        return "Приватность профиля"
    case .profileStyle:
        return "Оформление профиля"
    case .chatList:
        return "Список чатов"
    case .chats:
        return "Чаты"
    case .notifications:
        return "Уведомления"
    case .misc:
        return "Разное"
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
        },
        cycle: { key, optionsCount in
            let current = UserDefaults.standard.integer(forKey: "netgram" + key)
            UserDefaults.standard.set((current + 1) % max(1, optionsCount), forKey: "netgram" + key)
            bumpState()
        }
    )

    let signal = combineLatest(queue: .mainQueue(), context.sharedContext.presentationData, statePromise.get())
    |> map { presentationData, _ -> (ItemListControllerState, (ItemListNodeState, Any)) in
        let entries = customizationEntries(screen: screen)
        let controllerState = ItemListControllerState(presentationData: ItemListPresentationData(presentationData), title: .text(customizationScreenTitle(screen)), leftNavigationButton: nil, rightNavigationButton: nil, backNavigationButton: ItemListBackButton(title: presentationData.strings.Common_Back))
        let listState = ItemListNodeState(presentationData: ItemListPresentationData(presentationData), entries: entries, style: NetGramFeatures.enabled("SettingsListStyle") ? .plain : .blocks)
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
