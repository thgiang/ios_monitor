import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var viewModel: DashboardViewModel
    @State private var showingConfig = false
    @AppStorage(AppConfig.monitorAllURLKey) private var monitorAllURL: String = ""
    @AppStorage(AppConfig.monitorStoreURLKey) private var monitorStoreURL: String = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Tổng quan hệ thống")) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Tổng số đơn hàng")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            let totalOrders = viewModel.stores.reduce(0) { $0 + $1.pendingOrders }
                            let totalLate = viewModel.stores.reduce(0) { $0 + $1.lateOrders }
                            
                            HStack(spacing: 4) {
                                Text("\(totalOrders) đơn")
                                Text("(\(totalLate) muộn)")
                                    .foregroundColor(totalLate > 0 ? .red : .secondary)
                            }
                            .font(.title2)
                            .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Tổng số món")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(viewModel.stores.reduce(0) { $0 + $1.pendingItems })")
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Danh sách cửa hàng")) {
                    if viewModel.stores.isEmpty && !viewModel.isLoading {
                        Text("Không có dữ liệu")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(viewModel.stores) { store in
                            NavigationLink(destination: StoreDetailView(storeId: store.id, storeName: store.name)) {
                                StoreRow(store: store)
                            }
                        }
                    }
                }
                
                if let lastUpdated = viewModel.lastUpdated {
                    Section {
                        Text("Cập nhật cuối: \(lastUpdated.formatted(date: .omitted, time: .standard))")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle("ZangTee Monitor")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingConfig = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .overlay {
                if viewModel.isLoading && viewModel.stores.isEmpty {
                    ProgressView("Đang tải...")
                }
            }
            .onAppear {
                if monitorAllURL.isEmpty || monitorStoreURL.isEmpty {
                    showingConfig = true
                }
            }
            .sheet(isPresented: $showingConfig) {
                ConfigView()
                    .onDisappear {
                        Task {
                            await viewModel.refreshData()
                        }
                    }
            }
        }
    }
}

struct StoreRow: View {
    let store: StoreOverview
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.name)
                    .font(.headline)
                Text("ID: \(store.id)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                HStack {
                    Image(systemName: "cart")
                        .foregroundColor(.blue)
                    
                    HStack(spacing: 2) {
                        Text("\(store.pendingOrders) đơn")
                        Text("(\(store.lateOrders) muộn)")
                            .foregroundColor(store.lateOrders > 0 ? .red : .secondary)
                    }
                    .bold()
                }
                HStack {
                    Image(systemName: "list.bullet")
                        .foregroundColor(.green)
                    Text("\(store.pendingItems)")
                        .bold()
                }
                .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
}
