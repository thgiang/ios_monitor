import Foundation

struct StoreOverview: Codable, Identifiable {
    let id: Int
    let name: String
    let pendingOrders: Int
    let pendingItems: Int
    let lateOrders: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "store_id"
        case name = "store_name"
        case pendingOrders = "pending_orders"
        case pendingItems = "pending_items"
        case lateOrders = "late_orders"
    }
}

struct MonitorAllResponse: Codable {
    let success: Bool
    let stores: [StoreOverview]
}

struct Order: Codable, Identifiable {
    let id: String
    let displayCode: String
    let itemCount: Int
    let timeDeadline: String
    let lateMinutes: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case displayCode = "display_code"
        case itemCount = "item_count"
        case timeDeadline = "time_deadline"
        case lateMinutes = "late_minutes"
        case status
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let displayCode = try container.decode(String.self, forKey: .displayCode)
        self.displayCode = displayCode
        self.id = displayCode
        self.itemCount = try container.decode(Int.self, forKey: .itemCount)
        self.timeDeadline = try container.decode(String.self, forKey: .timeDeadline)
        self.lateMinutes = try container.decode(Int.self, forKey: .lateMinutes)
        self.status = try container.decode(String.self, forKey: .status)
    }
}

struct StoreDetailResponse: Codable {
    let success: Bool
    let storeId: String
    let storeName: String
    let pendingOrders: Int
    let pendingItems: Int
    let lateOrders: [Order]
    
    enum CodingKeys: String, CodingKey {
        case success
        case storeId = "store_id"
        case storeName = "store_name"
        case pendingOrders = "pending_orders"
        case pendingItems = "pending_items"
        case lateOrders = "late_orders"
    }
}

