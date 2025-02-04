import Foundation

extension String {
    func formatTagName() -> String {
        self.split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }
} 