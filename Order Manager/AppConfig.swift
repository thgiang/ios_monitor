import Foundation

struct AppConfig {
    static let monitorAllURLKey = "monitorAllURL"
    static let monitorStoreURLKey = "monitorStoreURL"
    static let pushTokenURLKey = "pushTokenURL"
    
    static var monitorAllURL: String {
        get { UserDefaults.standard.string(forKey: monitorAllURLKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: monitorAllURLKey) }
    }
    
    static var monitorStoreURL: String {
        get { UserDefaults.standard.string(forKey: monitorStoreURLKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: monitorStoreURLKey) }
    }
    
    /// URL endpoint trên server Laravel để nhận push token
    /// Ví dụ: https://monitor.zangtee.vn/api/live-activity/register
    static var pushTokenURL: String {
        get { UserDefaults.standard.string(forKey: pushTokenURLKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: pushTokenURLKey) }
    }
    
    static var isConfigured: Bool {
        return !monitorAllURL.isEmpty && !monitorStoreURL.isEmpty
    }
}
