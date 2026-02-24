import ActivityKit
import Foundation

struct OrderActivityAttributes: ActivityAttributes {
    // No static content needed — all data is dynamic
    
    struct ContentState: Codable, Hashable {
        var totalOrders: Int
        var lateOrders: Int
        var totalItems: Int
        var lastUpdated: Date
    }
}
