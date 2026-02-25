import SwiftUI

struct ConfigView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var tempMonitorAllURL: String = AppConfig.monitorAllURL
    @State private var tempMonitorStoreURL: String = AppConfig.monitorStoreURL
    @State private var tempPushTokenURL: String = AppConfig.pushTokenURL
    
    @State private var showingError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Cấu hình API"), footer: Text("Vui lòng nhập đầy đủ các đường dẫn URL để ứng dụng có thể lấy dữ liệu.")) {
                    TextField("URL Monitor All", text: $tempMonitorAllURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("URL Monitor Store (prefix)", text: $tempMonitorStoreURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section(header: Text("Live Activity Push"), footer: Text("URL để đăng ký push token cho Live Activity. Để trống nếu không sử dụng.")) {
                    TextField("URL đăng ký Push Token", text: $tempPushTokenURL)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            .navigationTitle("Cấu hình")
            .navigationBarItems(
                trailing: Button("Lưu") {
                    save()
                }
            )
            .alert(isPresented: $showingError) {
                Alert(title: Text("Lỗi"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            .interactiveDismissDisabled(AppConfig.monitorAllURL.isEmpty || AppConfig.monitorStoreURL.isEmpty)
        }
    }
    
    private func save() {
        guard !tempMonitorAllURL.isEmpty, !tempMonitorStoreURL.isEmpty else {
            errorMessage = "Vui lòng nhập đầy đủ cả hai URL."
            showingError = true
            return
        }
        
        guard URL(string: tempMonitorAllURL) != nil, URL(string: tempMonitorStoreURL) != nil else {
            errorMessage = "URL không hợp lệ."
            showingError = true
            return
        }
        
        AppConfig.monitorAllURL = tempMonitorAllURL
        AppConfig.monitorStoreURL = tempMonitorStoreURL
        AppConfig.pushTokenURL = tempPushTokenURL
        
        dismiss()
    }
}

#Preview {
    ConfigView()
}
