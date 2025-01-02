import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    
    @Published var viewRefreshTrigger = false
    private let selectedLanguageKey = "selectedLanguage"
    
    var selectedLanguage: String {
        didSet {
            Bundle.main.setLanguage(selectedLanguage)
            viewRefreshTrigger.toggle()
            NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
            UserDefaults.standard.set([selectedLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.set(selectedLanguage, forKey: selectedLanguageKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        self.selectedLanguage = UserDefaults.standard.string(forKey: selectedLanguageKey) ?? "en"
        
        
    }
    
    func setLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
    }
}

// Extension to help Bundle find the correct language
extension Bundle {
    static var bundle: Bundle?
    
    func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, LanguageBundle.self)
        }
        
        if let path = self.path(forResource: language, ofType: "lproj") {
            Bundle.bundle = Bundle(path: path)
        } else {
            // Handle the case where the language resource file is not found
            print("Language resource file for \(language) not found.")
            Bundle.bundle = nil // or set it to a default bundle
        }
    }
}

// Custom Bundle class to override the language bundle
class LanguageBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = Bundle.bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

struct LocalizedText: View {
    let key: String
    @ObservedObject private var languageManager = LanguageManager.shared
    
    var body: some View {
        Text(NSLocalizedString(key, comment: ""))
            .id(languageManager.viewRefreshTrigger)
    }
}
