import Foundation

enum TipContent: Codable {
    case text(String)
    case image(String) // URL of the image
    case header(String)
    case quote(String)
    case bulletPoints([String])
    case link(String, String)
    enum CodingKeys: String, CodingKey {
        case type
        case content
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let text):
            try container.encode("text", forKey: .type)
            try container.encode(text, forKey: .content)
        case .image(let url):
            try container.encode("image", forKey: .type)
            try container.encode(url, forKey: .content)
        case .header(let text):
            try container.encode("header", forKey: .type)
            try container.encode(text, forKey: .content)
        case .quote(let text):
            try container.encode("quote", forKey: .type)
            try container.encode(text, forKey: .content)
        case .bulletPoints(let points):
            try container.encode("bulletPoints", forKey: .type)
            try container.encode(points, forKey: .content)
        case .link(let url, _):
            try container.encode("link", forKey: .type)
            try container.encode(url, forKey: .content)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "text":
            let text = try container.decode(String.self, forKey: .content)
            self = .text(text)
        case "image":
            let url = try container.decode(String.self, forKey: .content)
            self = .image(url)
        case "header":
            let text = try container.decode(String.self, forKey: .content)
            self = .header(text)
        case "quote":
            let text = try container.decode(String.self, forKey: .content)
            self = .quote(text)
        case "bulletPoints":
            let points = try container.decode([String].self, forKey: .content)
            self = .bulletPoints(points)
        case "link":
            let url = try container.decode(String.self, forKey: .content)
            let text = try container.decode(String.self, forKey: .content)
            self = .link(url, text)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type")
        }
    }
}