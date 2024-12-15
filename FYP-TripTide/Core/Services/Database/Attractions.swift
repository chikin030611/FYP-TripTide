import SwiftUI

let disneylandAttraction = Attraction(
    id: "1",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Hong Kong Disneyland",
    rating: 4.2,
    price: "$599+",
    tags: [Tag(name: "Theme Park"), Tag(name: "Entertainment"), Tag(name: "Family")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "10:30", closeTime: "20:30"),
        OpenHour(weekdayIndex: 2, openTime: nil, closeTime: nil),
        OpenHour(weekdayIndex: 3, openTime: "10:30", closeTime: "20:30"),
        OpenHour(weekdayIndex: 4, openTime: "10:30", closeTime: "20:30"),
        OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 6, openTime: "10:00", closeTime: "22:30"),
        OpenHour(weekdayIndex: 7, openTime: "10:00", closeTime: "22:00")
    ],
    stayingTime: "Full Day",
    description: "Hong Kong Disneyland is a theme park located on Lantau Island. It features classic Disney attractions, shows and character meet-and-greets in a magical setting.",
    address: "Lantau Island, Hong Kong",
    latitude: 22.3133203,
    longitude: 114.0417638
)

let oceanParkAttraction = Attraction(
    id: "2",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Ocean Park Hong Kong",
    rating: 1.2,
    price: "$498",
    tags: [Tag(name: "Theme Park"), Tag(name: "Aquarium"), Tag(name: "Wildlife")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "10:00", closeTime: "19:00"),
        OpenHour(weekdayIndex: 2, openTime: "10:00", closeTime: "19:00"),
        OpenHour(weekdayIndex: 3, openTime: "10:00", closeTime: "19:00"),
        OpenHour(weekdayIndex: 4, openTime: "10:00", closeTime: "19:00"),
        OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "19:00"),
        OpenHour(weekdayIndex: 6, openTime: "10:00", closeTime: "19:00"),
        OpenHour(weekdayIndex: 7, openTime: "10:00", closeTime: "19:00")
    ],
    stayingTime: "6-8 hours",
    description: "Ocean Park Hong Kong is a marine life theme park featuring animal exhibits, exciting rides and shows. Known for its cable car ride offering spectacular views.",
    address: "Ocean Park, Hong Kong",
    latitude: 22.2467,
    longitude: 114.1757
)

let victoriaPeakAttraction = Attraction(
    id: "3",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Victoria Peak",
    rating: 3.2,
    price: "$99",
    tags: [Tag(name: "Landmark"), Tag(name: "Viewpoint"), Tag(name: "Nature")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "07:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 2, openTime: "07:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 3, openTime: "07:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 4, openTime: "07:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 5, openTime: "07:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 6, openTime: "07:00", closeTime: "22:00"),
        OpenHour(weekdayIndex: 7, openTime: "07:00", closeTime: "22:00")
    ],
    stayingTime: "2-3 hours",
    description: "The Peak is the highest point on Hong Kong Island, offering breathtaking views of the city skyline, Victoria Harbour, and the surrounding islands.",
    address: "Victoria Peak, Hong Kong",
    latitude: 22.2759,
    longitude: 114.1455
)

let wongTaiSinAttraction = Attraction(
    id: "4",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Wong Tai Sin Temple",
    rating: 2.2,
    price: "Free",
    tags: [Tag(name: "Temple"), Tag(name: "Cultural"), Tag(name: "Historical")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: nil, closeTime: nil),
        OpenHour(weekdayIndex: 2, openTime: "07:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 3, openTime: "07:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 4, openTime: "07:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 5, openTime: "07:00", closeTime: "18:30"),
        OpenHour(weekdayIndex: 6, openTime: "07:00", closeTime: "18:30"),
        OpenHour(weekdayIndex: 7, openTime: "07:00", closeTime: "18:30")
    ],
    stayingTime: "1-2 hours",
    description: "Wong Tai Sin Temple is a famous shrine and major tourist attraction in Hong Kong. The temple is dedicated to Wong Tai Sin, or the Great Immortal Wong.",
    address: "Wong Tai Sin Temple, Hong Kong",
    latitude: 22.3421,
    longitude: 114.1931
)

let tsimShaTsuiAttraction = Attraction(
    id: "5",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Tsim Sha Tsui Promenade",
    rating: 2.2,
    price: "Free",
    tags: [Tag(name: "Waterfront"), Tag(name: "Shopping"), Tag(name: "Entertainment")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "00:00", closeTime: "23:59"),
        OpenHour(weekdayIndex: 2, openTime: "00:00", closeTime: "23:59"),
        OpenHour(weekdayIndex: 3, openTime: "00:00", closeTime: "23:59"),
        OpenHour(weekdayIndex: 4, openTime: "00:00", closeTime: "23:59"),
        OpenHour(weekdayIndex: 5, openTime: "00:00", closeTime: "23:59"),
        OpenHour(weekdayIndex: 6, openTime: "00:00", closeTime: "23:59"),
        OpenHour(weekdayIndex: 7, openTime: "00:00", closeTime: "23:59")
    ],
    stayingTime: "2-3 hours",
    description: "The Tsim Sha Tsui Promenade offers stunning views of Victoria Harbour and Hong Kong Island's skyline. Perfect for the Symphony of Lights show in the evening.",
    address: "Tsim Sha Tsui, Kowloon, Hong Kong",
    latitude: 22.2931,
    longitude: 114.1744
)

let tianTanBuddhaAttraction = Attraction(
    id: "6",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Tian Tan Buddha",
    rating: 3.2,
    price: "$199",
    tags: [Tag(name: "Religious"), Tag(name: "Cultural"), Tag(name: "Historical")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "10:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 2, openTime: "10:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 3, openTime: "10:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 4, openTime: "10:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 6, openTime: "10:00", closeTime: "17:30"),
        OpenHour(weekdayIndex: 7, openTime: "10:00", closeTime: "17:30")
    ],
    stayingTime: "3-4 hours",
    description: "The Tian Tan Buddha is a large bronze statue of Buddha Shakyamuni, completed in 1993, and located at Ngong Ping, Lantau Island.",
    address: "Ngong Ping, Lantau Island, Hong Kong",
    latitude: 22.2543,
    longitude: 113.9055
)

let ladiesMarketAttraction = Attraction(
    id: "7",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Ladies' Market",
    rating: 2.7,
    price: "Free",
    tags: [Tag(name: "Shopping"), Tag(name: "Street Market"), Tag(name: "Local Culture")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "13:00", closeTime: "23:30"),
        OpenHour(weekdayIndex: 2, openTime: "13:00", closeTime: "23:30"),
        OpenHour(weekdayIndex: 3, openTime: "13:00", closeTime: "23:30"),
        OpenHour(weekdayIndex: 4, openTime: "13:00", closeTime: "23:30"),
        OpenHour(weekdayIndex: 5, openTime: "12:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 6, openTime: "12:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 7, openTime: nil, closeTime: nil)
    ],
    stayingTime: "2-3 hours",
    description: "The Ladies' Market is a street market with over 100 stalls selling bargain clothing, accessories and souvenirs. Popular for its bargaining culture.",
    address: "Ladies' Market, Mong Kok, Kowloon, Hong Kong",
    latitude: 22.3186,
    longitude: 114.1707
)

let midLevelsEscalatorsAttraction = Attraction(
    id: "8",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Central and Mid-Levels Escalators",
    rating: 3.8,
    price: "Free", 
    tags: [Tag(name: "Urban Attraction"), Tag(name: "Transportation"), Tag(name: "Unique")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "06:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 2, openTime: "06:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 3, openTime: "06:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 4, openTime: "06:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 5, openTime: "06:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 6, openTime: "06:00", closeTime: "00:00"),
        OpenHour(weekdayIndex: 7, openTime: "06:00", closeTime: "00:00")
    ],
    stayingTime: "1-2 hours",
    description: "The Central-Mid-Levels escalator system is the longest outdoor covered escalator system in the world, offering a unique way to explore Hong Kong's urban areas.",
    address: "Central, Hong Kong",
    latitude: 22.2837,
    longitude: 114.1548
)

let hongKongParkAttraction = Attraction(
    id: "9",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Hong Kong Park",
    rating: 3.6,
    price: "Free",
    tags: [Tag(name: "Park"), Tag(name: "Nature"), Tag(name: "Family")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "06:00", closeTime: "23:00"),
        OpenHour(weekdayIndex: 2, openTime: "06:00", closeTime: "23:00"),
        OpenHour(weekdayIndex: 3, openTime: "06:00", closeTime: "23:00"),
        OpenHour(weekdayIndex: 4, openTime: "06:00", closeTime: "23:00"),
        OpenHour(weekdayIndex: 5, openTime: "06:00", closeTime: "23:00"),
        OpenHour(weekdayIndex: 6, openTime: "06:00", closeTime: "23:00"),
        OpenHour(weekdayIndex: 7, openTime: "06:00", closeTime: "23:00")
    ],
    stayingTime: "1-2 hours",
    description: "Hong Kong Park is an urban park featuring a greenhouse, an aviary, a squash centre, and tai chi garden. A peaceful oasis in the heart of the city.",
    address: "Hong Kong Park, Hong Kong",
    latitude: 22.2771,
    longitude: 114.1608
)

let starFerryAttraction = Attraction(
    id: "10",
    images: ["https://dummyimage.com/600x400/ffc14f/ffffff", "https://dummyimage.com/600x400/07162e/ffffff"],
    name: "Star Ferry",
    rating: 3.9,
    price: "$2.7",
    tags: [Tag(name: "Transportation"), Tag(name: "Historical"), Tag(name: "Views")],
    openHours: [
        OpenHour(weekdayIndex: 1, openTime: "06:30", closeTime: "23:30"),
        OpenHour(weekdayIndex: 2, openTime: "06:30", closeTime: "23:30"),
        OpenHour(weekdayIndex: 3, openTime: "06:30", closeTime: "23:30"),
        OpenHour(weekdayIndex: 4, openTime: "06:30", closeTime: "23:30"),
        OpenHour(weekdayIndex: 5, openTime: "06:30", closeTime: "23:30"),
        OpenHour(weekdayIndex: 6, openTime: "06:30", closeTime: "23:30"),
        OpenHour(weekdayIndex: 7, openTime: "06:30", closeTime: "23:30")
    ],
    stayingTime: "30 minutes",
    description: "The Star Ferry is a passenger ferry service operator and tourist attraction. Crossing Victoria Harbour, it offers spectacular views of Hong Kong's skyline.",
    address: "Star Ferry, Hong Kong",
    latitude: 22.2932,
    longitude: 114.1692
)

let sampleAttractions = [
    disneylandAttraction,
    oceanParkAttraction, 
    victoriaPeakAttraction,
    wongTaiSinAttraction,
    tsimShaTsuiAttraction,
    tianTanBuddhaAttraction,
    ladiesMarketAttraction,
    midLevelsEscalatorsAttraction,
    hongKongParkAttraction,
    starFerryAttraction
]

// Get a attraction by id
func getAttraction(by id: String) -> Attraction? {
    return sampleAttractions.first { $0.id == id }
}
