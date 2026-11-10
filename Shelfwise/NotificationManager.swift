import Foundation
import Combine
import UserNotifications

@MainActor
public final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    public static let shared = NotificationManager()
    
    @Published public var isAuthorized: Bool = false
    @Published public var dailyReminderEnabled: Bool = true
    @Published public var dailyReminderTime: Date = {
        var components = DateComponents()
        components.hour = 20
        components.minute = 30
        return Calendar.current.date(from: components) ?? Date()
    }()
    
    @Published public var weeklyReportReminderEnabled: Bool = true
    @Published public var weeklyReminderDay: Int = 1 // 1 = Sunday
    @Published public var weeklyReminderHour: Int = 19
    @Published public var lastNotificationStatusMessage: String?
    
    private let dailyReminderIdentifier = "darkpsych.daily.study.reminder"
    private let weeklyReportIdentifier = "darkpsych.weekly.report.digest"
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }
    
    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            self.isAuthorized = granted
            if granted {
                scheduleAllReminders()
            }
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            self.isAuthorized = false
            return false
        }
    }
    
    public func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            Task { @MainActor in
                self.isAuthorized = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }
    
    public func scheduleAllReminders() {
        if dailyReminderEnabled {
            scheduleDailyStudyReminder()
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        }
        
        if weeklyReportReminderEnabled {
            scheduleWeeklyReportReminder()
        } else {
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [weeklyReportIdentifier])
        }
    }
    
    public func scheduleDailyStudyReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyReminderIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Dark Psychology Curriculum • Level 1"
        let prompts = [
            "Time for your daily session: decode cognitive biases & subconscious reflexes.",
            "Study habit reminder: 20 pages tonight keeps you on track for Level 1 mastery.",
            "Understand the human mind: Thinking, Fast and Slow is waiting for you.",
            "Unravel heuristics and behavioural conditioning. Log your daily pages now."
        ]
        content.body = prompts.randomElement() ?? prompts[0]
        content.sound = .default
        
        let cal = Calendar.current
        let hour = cal.component(.hour, from: dailyReminderTime)
        let minute = cal.component(.minute, from: dailyReminderTime)
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: dailyReminderIdentifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            Task { @MainActor in
                if let error = error {
                    self.lastNotificationStatusMessage = "Failed: \(error.localizedDescription)"
                } else {
                    self.lastNotificationStatusMessage = "Daily reminder active for \(String(format: "%02d:%02d", hour, minute))"
                }
            }
        }
    }
    
    public func scheduleWeeklyReportReminder() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [weeklyReportIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "Weekly Dark Psychology Digest 📊"
        content.body = "Your weekly reading report is ready. Inspect your pages read, cognitive topics mastered, and streak!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weeklyReminderDay
        dateComponents.hour = weeklyReminderHour
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: weeklyReportIdentifier, content: content, trigger: trigger)
        
        center.add(request) { error in
            Task { @MainActor in
                if let error = error {
                    self.lastNotificationStatusMessage = "Weekly report scheduling failed"
                } else {
                    self.lastNotificationStatusMessage = "Weekly report scheduled every Sunday at 7:00 PM"
                }
            }
        }
    }
    
    public func sendImmediateTestNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Dark Psychology Study Reminder"
        content.body = "Mastery in Level 1: Understanding the human mind. Log your progress and take a quick photo note!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
        let request = UNNotificationRequest(identifier: "test.immediate.notification", content: content, trigger: trigger)
        
        center.add(request) { error in
            Task { @MainActor in
                if error == nil {
                    self.lastNotificationStatusMessage = "Test notification sent! Check in 2 seconds."
                }
            }
        }
    }
    
    public nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
