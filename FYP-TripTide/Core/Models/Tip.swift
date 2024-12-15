import Foundation

struct Tip: Identifiable {
    let id: UUID
    let coverImage: String
    let author: String
    let publishDate: Date
    let title: String
    let content: [TipContent]
    let reference: String
    let referenceLink: String

    enum CodingKeys: String, CodingKey {
        case id
        case coverImage
        case author
        case title
        case publishDate
        case content
        case reference
        case referenceLink
    }
}

