import Foundation
import UserNotifications
import Combine

class NotificationManager: NSObject, ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    private var lastStepNotification = 0
    private var lastHeartRateAlert: Date?
    
    private override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                if granted {
                    print("✅ Notification permission granted")
                } else {
                    print("❌ Notification permission denied")
                }
            }
        }
    }
    
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Step Notifications
    
    func checkStepMilestones(currentSteps: Int) {
        let milestones = [500, 1000, 2500, 5000, 7500, 10000, 15000, 20000]
        
        for milestone in milestones {
            if currentSteps >= milestone && lastStepNotification < milestone {
                sendStepMilestoneNotification(steps: milestone)
                lastStepNotification = milestone
                break
            }
        }
    }
    
    private func sendStepMilestoneNotification(steps: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Step Milestone!"
        content.body = "Congratulations! You've walked \(steps) steps today!"
        content.sound = .default
        
        let motivationalMessages = [
            "Keep it up! 💪",
            "You're doing great! 🌟",
            "Amazing progress! 🚀",
            "Stay active! 🏃‍♂️"
        ]
        content.subtitle = motivationalMessages.randomElement() ?? ""
        
        let request = UNNotificationRequest(
            identifier: "step-milestone-\(steps)",
            content: content,
            trigger: nil // Deliver immediately
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send step notification: \(error)")
            } else {
                print("✅ Step milestone notification sent: \(steps) steps")
            }
        }
    }
    
    // MARK: - Heart Rate Notifications
    
    func checkHeartRate(bpm: Double, status: HeartRateStatus) {
        // Prevent notification spam - only notify once every 5 minutes
        if let lastAlert = lastHeartRateAlert,
           Date().timeIntervalSince(lastAlert) < 300 {
            return
        }
        
        switch status {
        case .low:
            sendHeartRateAlert(
                title: "⚠️ Low Heart Rate",
                body: "Your heart rate is \(Int(bpm)) BPM. Consider checking if you're feeling okay.",
                isUrgent: true
            )
            lastHeartRateAlert = Date()
            
        case .high:
            sendHeartRateAlert(
                title: "🔥 High Heart Rate",
                body: "Your heart rate is \(Int(bpm)) BPM. Consider taking a break and slowing down.",
                isUrgent: true
            )
            lastHeartRateAlert = Date()
            
        case .normal:
            // No notification needed for normal heart rate
            break
        }
    }
    
    private func sendHeartRateAlert(title: String, body: String, isUrgent: Bool) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = isUrgent ? .defaultCritical : .default
        
        let request = UNNotificationRequest(
            identifier: "heart-rate-alert-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send heart rate notification: \(error)")
            } else {
                print("✅ Heart rate alert sent")
            }
        }
    }
    
    // MARK: - Media Capture Notifications
    
    func sendPhotoSavedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "📸 Photo Saved!"
        content.body = "Your photo has been saved successfully to your library."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "photo-saved-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send photo notification: \(error)")
            } else {
                print("✅ Photo saved notification sent")
            }
        }
    }
    
    func sendVideoSavedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎥 Video Saved!"
        content.body = "Your video has been saved successfully to your library."
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "video-saved-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send video notification: \(error)")
            } else {
                print("✅ Video saved notification sent")
            }
        }
    }
    
    // MARK: - Motivational Notifications
    
    func sendMotivationalMessage() {
        let messages = [
            ("💪 Stay Active!", "You're doing great! Keep moving throughout the day."),
            ("🌟 Amazing Work!", "Your dedication to health is inspiring!"),
            ("🏃‍♂️ Keep Going!", "Every step counts towards a healthier you!"),
            ("❤️ Health First!", "Taking care of your health is the best investment."),
            ("🎯 Goal Crusher!", "You're making excellent progress towards your goals!")
        ]
        
        let randomMessage = messages.randomElement()!
        
        let content = UNMutableNotificationContent()
        content.title = randomMessage.0
        content.body = randomMessage.1
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "motivational-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to send motivational notification: \(error)")
            } else {
                print("✅ Motivational notification sent")
            }
        }
    }
    
    // MARK: - Reset Methods
    
    func resetStepNotifications() {
        lastStepNotification = 0
    }
    
    func resetHeartRateAlert() {
        lastHeartRateAlert = nil
    }
}
