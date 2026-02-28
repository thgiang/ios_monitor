import Foundation
import ActivityKit

// Attributes for the Order monitoring Live Activity
// This file is included in the Widget Extension target.
public struct OrderActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state for the Live Activity
        public var totalOrders: Int
        public var lateOrders: Int
        public var totalItems: Int
        public var lastUpdated: Date
        
        enum CodingKeys: String, CodingKey {
            case totalOrders, lateOrders, totalItems, lastUpdated
        }
        
        public init(totalOrders: Int, lateOrders: Int, totalItems: Int, lastUpdated: Date) {
            self.totalOrders = totalOrders
            self.lateOrders = lateOrders
            self.totalItems = totalItems
            self.lastUpdated = lastUpdated
        }
        
        // Custom decode: APNs gửi Date dưới dạng Unix timestamp (seconds since 1970)
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            totalOrders = try container.decode(Int.self, forKey: .totalOrders)
            lateOrders = try container.decode(Int.self, forKey: .lateOrders)
            totalItems = try container.decode(Int.self, forKey: .totalItems)
            
            let timestamp = try container.decode(Double.self, forKey: .lastUpdated)
            lastUpdated = Date(timeIntervalSince1970: timestamp)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(totalOrders, forKey: .totalOrders)
            try container.encode(lateOrders, forKey: .lateOrders)
            try container.encode(totalItems, forKey: .totalItems)
            try container.encode(lastUpdated.timeIntervalSince1970, forKey: .lastUpdated)
        }
    }
    
    // Fixed attributes for the activity
    public init() {}
}
