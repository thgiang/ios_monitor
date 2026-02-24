import Foundation
import ActivityKit

// Attributes for the Order monitoring Live Activity
// Make sure this file is included in the Widget Extension target (and optionally the app target if needed to start activities).
public struct OrderActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state for the Live Activity
        public var totalOrders: Int
        public var lateOrders: Int
        public var totalItems: Int
        public var lastUpdated: Date
        
        public init(totalOrders: Int, lateOrders: Int, totalItems: Int, lastUpdated: Date) {
            self.totalOrders = totalOrders
            self.lateOrders = lateOrders
            self.totalItems = totalItems
            self.lastUpdated = lastUpdated
        }
    }
    
    // Fixed attributes for the activity (if you have any static info, add here)
    public init() {}
}
