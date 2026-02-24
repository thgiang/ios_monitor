import ActivityKit
import Foundation

@MainActor
class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    private var currentActivity: Activity<OrderActivityAttributes>?
    
    private init() {}
    
    /// End all existing activities and start a fresh one.
    /// Call this every time the app becomes active to "renew" the 8-hour limit.
    func restartActivity(stores: [StoreOverview]) {
        endAllActivities()
        
        let state = buildContentState(from: stores)
        startActivity(state: state)
    }
    
    /// Start a new Live Activity with the given state.
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
                pushType: nil
            )
            currentActivity = activity
            print("[LiveActivity] Started activity: \(activity.id)")
        } catch {
            print("[LiveActivity] Error starting activity: \(error)")
        }
    }
    
    /// Update the currently running Live Activity with new data.
    func updateActivity(stores: [StoreOverview]) {
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
