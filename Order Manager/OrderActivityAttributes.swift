import ActivityKit
import Foundation

struct OrderActivityAttributes: ActivityAttributes {
    // No static content needed — all data is dynamic
    
    struct ContentState: Codable, Hashable {
        var totalOrders: Int
        var lateOrders: Int
        var totalItems: Int
        var lastUpdated: Date
        
        enum CodingKeys: String, CodingKey {
            case totalOrders, lateOrders, totalItems, lastUpdated
        }
        
        init(totalOrders: Int, lateOrders: Int, totalItems: Int, lastUpdated: Date) {
            self.totalOrders = totalOrders
            self.lateOrders = lateOrders
            self.totalItems = totalItems
            self.lastUpdated = lastUpdated
        }
        
        // Custom decode: APNs gửi Date dưới dạng Unix timestamp (seconds since 1970)
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            totalOrders = try container.decode(Int.self, forKey: .totalOrders)
            lateOrders = try container.decode(Int.self, forKey: .lateOrders)
            totalItems = try container.decode(Int.self, forKey: .totalItems)
            
            let timestamp = try container.decode(Double.self, forKey: .lastUpdated)
            lastUpdated = Date(timeIntervalSince1970: timestamp)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(totalOrders, forKey: .totalOrders)
            try container.encode(lateOrders, forKey: .lateOrders)
            try container.encode(totalItems, forKey: .totalItems)
            try container.encode(lastUpdated.timeIntervalSince1970, forKey: .lastUpdated)
        }
    }
}
