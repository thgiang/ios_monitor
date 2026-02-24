import Foundation
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var stores: [StoreOverview] = []
    @Published var isLoading = false
    @Published var lastUpdated: Date?
    
    private var timer: AnyCancellable?
    private let networkManager = NetworkManager.shared
    
    init() {
        startTimer()
        Task {
            await refreshData()
        }
    }
    
    func refreshData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let fetchedStores = try await networkManager.fetchMonitorAll()
            self.stores = fetchedStores
            self.lastUpdated = Date()
        } catch {
            print("Error refreshing data: \(error)")
        }
    }
    
    private func startTimer() {
        timer = Timer.publish(every: 60, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.refreshData()
                }
            }
    }
    
    deinit {
        timer?.cancel()
    }
}
