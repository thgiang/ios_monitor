import Foundation

struct AppConfig {
    static let monitorAllURLKey = "monitorAllURL"
    static let monitorStoreURLKey = "monitorStoreURL"
    
    static var monitorAllURL: String {
        get { UserDefaults.standard.string(forKey: monitorAllURLKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: monitorAllURLKey) }
    }
    
    static var monitorStoreURL: String {
        get { UserDefaults.standard.string(forKey: monitorStoreURLKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: monitorStoreURLKey) }
    }
    
    static var isConfigured: Bool {
        return !monitorAllURL.isEmpty && !monitorStoreURL.isEmpty
    }
}
