import SwiftUI

class TabController: ObservableObject {
    @Published var selectedTab: Int = 0
    
    func switchToTab(_ tab: Int) {
        // If we're already on the target tab, briefly set to nil (invalid tab)
        if selectedTab == tab {
            // Temporarily set to an invalid index that won't trigger a visible tab change
            selectedTab = -1
            // Switch back to desired tab immediately
            DispatchQueue.main.async {
                self.selectedTab = tab
            }
        } else {
            selectedTab = tab
        }
    }
} 