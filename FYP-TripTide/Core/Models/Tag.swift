import Foundation

struct Tag: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    
    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let tagName = try? container.decode(String.self) {
            self.name = tagName
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.name = try container.decode(String.self, forKey: .name)
        }
    }
    
    init(name: String) {
        self.name = name
    }
} 