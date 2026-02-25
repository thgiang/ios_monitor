import ActivityKit
import UIKit
import Foundation

@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<OrderActivityAttributes>?
    
    /// Danh sách store_id đang được theo dõi — gửi kèm push token lên server
    private var monitoredStoreIds: [Int] = []
    
    /// Device UUID để server phân biệt các thiết bị
    private var deviceId: String {
        UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
    }
    
    private init() {}
    
    /// End all existing activities and start a fresh one.
    /// Call this every time the app becomes active to "renew" the 8-hour limit.
    func restartActivity(stores: [StoreOverview]) {
        endAllActivities()
        
        // Lưu lại danh sách store đang theo dõi
        self.monitoredStoreIds = stores.map { $0.id }
        
        let state = buildContentState(from: stores)
        startActivity(state: state)
    }
    
    /// Start a new Live Activity with push notification support.
    func startActivity(state: OrderActivityAttributes.ContentState) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[LiveActivity] Activities are not enabled")
            return
        }
        
        let attributes = OrderActivityAttributes()
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(5 * 60))
        
        do {
            let activity = try Activity<OrderActivityAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: .token   // ← Cho phép nhận push từ APNs
            )
            currentActivity = activity
            print("[LiveActivity] Started activity: \(activity.id)")
            
            // Lắng nghe push token và gửi lên server
            observePushToken(for: activity)
            
        } catch {
            print("[LiveActivity] Error starting activity: \(error)")
        }
    }
    
    /// Update the currently running Live Activity with new data (foreground only).
    func updateActivity(stores: [StoreOverview]) {
        // Cập nhật danh sách store đang theo dõi
        self.monitoredStoreIds = stores.map { $0.id }
        
        let state = buildContentState(from: stores)
        
        guard let activity = currentActivity else {
            // No active activity — start one
            startActivity(state: state)
            return
        }
        
        let content = ActivityContent(state: state, staleDate: Date().addingTimeInterval(5 * 60))
        
        Task {
            await activity.update(content)
            print("[LiveActivity] Updated activity: \(activity.id)")
        }
    }
    
    /// End all Live Activities for this app.
    func endAllActivities() {
        let activities = Activity<OrderActivityAttributes>.activities
        
        for activity in activities {
            Task {
                await activity.end(nil, dismissalPolicy: .immediate)
                print("[LiveActivity] Ended activity: \(activity.id)")
            }
        }
        
        currentActivity = nil
    }
    
    // MARK: - Push Token
    
    /// Lắng nghe push token updates và gửi lên server Laravel.
    /// Token có thể thay đổi bất cứ lúc nào, vì vậy cần lắng nghe liên tục.
    private func observePushToken(for activity: Activity<OrderActivityAttributes>) {
        Task {
            for await pushToken in activity.pushTokenUpdates {
                let tokenString = pushToken.map { String(format: "%02x", $0) }.joined()
                print("[LiveActivity] Push token: \(tokenString)")
                
                await sendTokenToServer(token: tokenString)
            }
        }
    }
    
    /// Gửi push token + thông tin device + danh sách store lên server Laravel.
    ///
    /// Payload gửi lên server:
    /// ```json
    /// {
    ///   "push_token": "a1b2c3d4...",
    ///   "device_id": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
    ///   "store_ids": [1, 2, 5, 8]
    /// }
    /// ```
    private func sendTokenToServer(token: String) async {
        let urlString = AppConfig.pushTokenURL
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            print("[LiveActivity] Push token URL not configured, skipping registration")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "push_token": token,
            "device_id": deviceId,
            "store_ids": monitoredStoreIds
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("[LiveActivity] Token registered (status: \(statusCode)) for stores: \(monitoredStoreIds)")
        } catch {
            print("[LiveActivity] Failed to send token: \(error)")
        }
    }
    
    // MARK: - Helpers
    
    private func buildContentState(from stores: [StoreOverview]) -> OrderActivityAttributes.ContentState {
        let totalOrders = stores.reduce(0) { $0 + $1.pendingOrders }
        let lateOrders = stores.reduce(0) { $0 + $1.lateOrders }
        let totalItems = stores.reduce(0) { $0 + $1.pendingItems }
        
        return OrderActivityAttributes.ContentState(
            totalOrders: totalOrders,
            lateOrders: lateOrders,
            totalItems: totalItems,
            lastUpdated: Date()
        )
    }
}
