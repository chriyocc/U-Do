import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var viewRefreshTrigger = false  // Add this to force view updates
    @AppStorage("selectedLanguage") var selectedLanguage: String = "en" {
        didSet {
            setLanguage(selectedLanguage)
        }
    }
    
    private init() {}
    
    func setLanguage(_ languageCode: String) {
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // Force view refresh
        viewRefreshTrigger.toggle()
        
        // Post notification for any listeners
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
    }
    
    func localizedString(_ key: String) -> String {
        let language = Bundle.main.localizedString(forKey: key, value: nil, table: nil)
        return language
    }
}

struct LocalizedText: View {
    let key: String
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        Text(languageManager.localizedString(key))
            // Force view to update when language changes
            .id(languageManager.viewRefreshTrigger)
    }
}
