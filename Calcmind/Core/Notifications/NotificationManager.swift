import Foundation
import Observation
import SwiftUI
import UserNotifications

/// Sample attractive notification templates for daily engagement
struct NotificationTemplate {
    let title: String
    let body: String
}

/// Central Notification Manager for CalcMind.
/// Handles requesting permissions, scheduling daily recurring local notifications with attractive messaging,
/// and storing reminder preferences.
@Observable
final class NotificationManager {
    @ObservationIgnored
    @AppStorage("isDailyReminderEnabled") var isEnabled: Bool = false

    @ObservationIgnored
    @AppStorage("reminderHour") var reminderHour: Int = 19 // Default 7:00 PM

    @ObservationIgnored
    @AppStorage("reminderMinute") var reminderMinute: Int = 0

    var isAuthorized: Bool = false

    private let templates: [NotificationTemplate] = [
        NotificationTemplate(
            title: "🧠 Ready for your 2-minute math boost?",
            body: "Snap a photo of any equation or chat with your AI Tutor in CalcMind!"
        ),
        NotificationTemplate(
            title: "✨ Keep your study momentum going!",
            body: "Explore a new math concept or verify steps with AI Tutor today."
        ),
        NotificationTemplate(
            title: "📐 Quick daily brain workout!",
            body: "Open CalcMind to solve, calculate, and sharpen your math skills."
        ),
        NotificationTemplate(
            title: "🎓 Your 24/7 AI Math Tutor is ready!",
            body: "Stuck on a tricky problem? Get instant step-by-step explanations now."
        ),
        NotificationTemplate(
            title: "💡 Daily Math Challenge",
            body: "Test a formula or snap a photo of a problem for instant AI solving."
        )
    ]

    init() {
        checkPermissionStatus()
    }

    var reminderDate: Date {
        get {
            var components = DateComponents()
            components.hour = reminderHour
            components.minute = reminderMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            reminderHour = components.hour ?? 19
            reminderMinute = components.minute ?? 0
            if isEnabled {
                scheduleDailyNotification()
            }
        }
    }

    /// Checks the current system notification permission status
    func checkPermissionStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }

    /// Requests notification authorization from iOS
    @MainActor
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    self.isEnabled = true
                    self.scheduleDailyNotification()
                } else {
                    self.isEnabled = false
                }
                completion(granted)
            }
        }
    }

    /// Schedules a daily recurring local notification with random attractive messaging
    func scheduleDailyNotification() {
        cancelAllNotifications()

        guard isEnabled else { return }

        let template = templates.randomElement() ?? templates[0]

        let content = UNMutableNotificationContent()
        content.title = template.title
        content.body = template.body
        content.sound = .default
        content.badge = 1

        var dateComponents = DateComponents()
        dateComponents.hour = reminderHour
        dateComponents.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "calcmind_daily_reminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    /// Cancels all scheduled local notifications
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["calcmind_daily_reminder"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["calcmind_daily_reminder"])
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
