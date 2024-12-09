import SwiftUI

let transportTip = Tip(
    id: UUID(),
    images: [],
    author: "TripTide",
    publishDate: Date(),
    title: "Transport in Tokyo",
    content: [
        .image("https://dummyimage.com/600x400/07162e/ffffff"),
        .header("Introduction"),
        .text("Tokyo is a city of contrasts..."),
        .header("1. Secret Garden"),
        .text("Hidden behind the busy streets..."),
        .quote("This place is magical - Local resident"),
        .bulletPoints([
            "Best visited during spring",
            "Open from 9 AM to 5 PM",
            "Free entrance"
        ])
    ],
    reference: "Hong Kong Tourism Board",
    referenceLink: "https://www.disneyland.com.hk"
)

let sampleTips = [
    transportTip,
]

// Get a tip by id
func getTip(by id: UUID) -> Tip? {
    return sampleTips.first { $0.id == id }
}
