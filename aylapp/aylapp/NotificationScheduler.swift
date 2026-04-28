//
//  NotificationScheduler.swift
//  aylapp
//
//  Created by Codex on 28.04.2026.
//

import Foundation
import UserNotifications

struct AppNotificationPlan: Identifiable {
    let id: String
    let title: String
    let body: String
    let schedule: AppNotificationSchedule
    var sound: UNNotificationSound? = .default
    var badge: NSNumber? = nil
    var userInfo: [String: String] = [:]
}

enum AppNotificationSchedule {
    case calendar(DateComponents, repeats: Bool)
    case timeInterval(TimeInterval, repeats: Bool)

    var trigger: UNNotificationTrigger? {
        switch self {
        case let .calendar(dateComponents, repeats):
            return UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: repeats)
        case let .timeInterval(seconds, repeats):
            guard seconds > 0 else { return nil }
            return UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: repeats)
        }
    }
}

enum AppNotificationCatalog {
    static let all: [AppNotificationPlan] = [
        // Buraya daha sonra bildirimlerini ekleyebilirsin.
        // Ornek:
        // AppNotificationPlan(
        //     id: "morning-reminder",
        //     title: "Gunaydin",
        //     body: "Bugun icin minik bir hatirlatici.",
        //     schedule: .calendar(
        //         DateComponents(hour: 9, minute: 0),
        //         repeats: true
        //     )
        // )
        AppNotificationPlan(id: "birthday1", title: "🎂 Hepi bebişko deeey", body: "İyi ki dooğduun böbüşkoooo", schedule: .calendar(DateComponents(month: 4, day: 28, hour: 12, minute: 45, second: 0), repeats: true)),
        AppNotificationPlan(id: "birthday2", title: "🎂 Hepi bebişko dey devam ediyooor", body: "İyi ki dooğduun böbüşkoooo", schedule: .calendar(DateComponents(month: 4, day: 28, hour: 14, minute: 30, second: 0), repeats: true)),
        AppNotificationPlan(id: "birthday3", title: "Yeni görev", body: "Koş ve sarıl 🤭", schedule: .calendar(DateComponents(month: 4, day: 28, hour: 15, minute: 0, second: 0), repeats: true)),
        AppNotificationPlan(id: "birthday4", title: "🎂 Hepi bebişko deeey", body: "Tamam, yeter, çok çalıştın. Biraz da ...", schedule: .calendar(DateComponents(month: 4, day: 28, hour: 16, minute: 45, second: 0), repeats: true)),
        AppNotificationPlan(id: "birthday5", title: "🎂 Hepi bebişko deeey", body: "Hala", schedule: .calendar(DateComponents(month: 4, day: 28, hour: 23, minute: 0, second: 0), repeats: true))
    ]
}

final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let requestPrefix = "aylapp.notification."

    private init() {}

    func configureOnLaunch() {
        center.getNotificationSettings { [weak self] settings in
            guard let self else { return }

            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.syncPendingNotifications()
            case .notDetermined:
                self.requestAuthorizationAndSync()
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    func requestAuthorizationAndSync() {
        center.requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, _ in
            guard granted else { return }
            self?.syncPendingNotifications()
        }
    }

    func syncPendingNotifications() {
        let identifiers = AppNotificationCatalog.all.map(\.requestIdentifier)

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        center.removeDeliveredNotifications(withIdentifiers: identifiers)

        for plan in AppNotificationCatalog.all {
            guard let trigger = plan.schedule.trigger else { continue }

            let content = UNMutableNotificationContent()
            content.title = plan.title
            content.body = plan.body
            content.sound = plan.sound
            content.userInfo = plan.userInfo

            if let badge = plan.badge {
                content.badge = badge
            }

            let request = UNNotificationRequest(
                identifier: plan.requestIdentifier,
                content: content,
                trigger: trigger
            )

            center.add(request)
        }
    }
}

private extension AppNotificationPlan {
    var requestIdentifier: String {
        "aylapp.notification.\(id)"
    }
}
