import Foundation

struct Tag: Identifiable, Hashable {
    let id = UUID()
    let name: String
    
    init(name: String) {
        self.name = name
    }
} 