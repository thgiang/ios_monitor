import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchMonitorAll() async throws -> [StoreOverview] {
        guard let url = URL(string: "https://monitor.zangtee.vn/api-monitor-all") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let response = try JSONDecoder().decode(MonitorAllResponse.self, from: data)
        return response.stores
    }
    
    func fetchStoreDetail(storeId: Int) async throws -> StoreDetailResponse {
        guard let url = URL(string: "https://monitor.zangtee.vn/api-monitor?store_id=\(storeId)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        return try JSONDecoder().decode(StoreDetailResponse.self, from: data)
    }
}

