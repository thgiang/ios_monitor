import SwiftUI

struct StoreDetailView: View {
    let storeId: Int
    let storeName: String
    
    @State private var orders: [Order] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        List {
            if !orders.isEmpty {
                Section {
                    HStack {
                        VStack {
                            Text("Đã muộn")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(orders.filter { $0.lateMinutes <= 0 }.count)")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                        
                        VStack {
                            Text("Chưa muộn")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(orders.filter { $0.lateMinutes > 0 }.count)")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.blue)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section(header: Text("Chi tiết đơn hàng")) {
                if orders.isEmpty && !isLoading {
                    Text("Không có đơn hàng chờ")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(orders) { order in
                        OrderRow(order: order)
                    }
                }
            }
        }
        .navigationTitle(storeName)
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            Task {
                await fetchDetails()
            }
        }
        .refreshable {
            await fetchDetails()
        }
    }
    
    private func fetchDetails() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await NetworkManager.shared.fetchStoreDetail(storeId: storeId)
            self.orders = response.lateOrders
        } catch {
            self.errorMessage = "Lỗi khi tải dữ liệu"
            print("Error: \(error)")
        }
        isLoading = false
    }
}

struct OrderRow: View {
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(order.displayCode)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                StatusBadge(status: String(describing: order.status))
            }
            
            HStack {
                Label("\(order.itemCount) món", systemImage: "cube.box")
                Spacer()
                if order.lateMinutes <= 0 {
                    Text("Trễ \(order.lateMinutes) phút")
                        .foregroundColor(.red)
                        .bold()
                } else {
                    Text("Còn \(order.lateMinutes) phút")
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            
            Text("Deadline: \(order.timeDeadline)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .cornerRadius(4)
    }
    
    private var backgroundColor: Color {
        switch status.uppercased() {
        case "CONFIRMED": return .blue
        case "ACCEPTED": return .orange
        case "PREPARING": return .green
        default: return .gray
        }
    }
}
