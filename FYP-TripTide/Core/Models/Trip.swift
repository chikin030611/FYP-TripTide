import Foundation

struct Trip: Identifiable {
    var id: String
    var userId: String
    var name: String
    var description: String
    var touristAttractions: [Place]
    var restaurants: [Place]
    var lodgings: [Place]
    var startDate: Date
    var endDate: Date
    var image: String

    var dailyItineraries: [DailyItinerary]?
    
    static let defaultImages = [
        "trip_default_1",
        "trip_default_2",
        "trip_default_3",
        "trip_default_4",
        "trip_default_5"
    ]

    var numOfDays: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    var savedCount: Int {
        touristAttractions.count + restaurants.count + lodgings.count
    }
    
    init(id: String = UUID().uuidString,
        userId: String,
        name: String,
        description: String,
        touristAttractions: [Place] = [],
        restaurants: [Place] = [],
        lodgings: [Place] = [],
        startDate: Date,
        endDate: Date) {
        
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.touristAttractions = touristAttractions
        self.restaurants = restaurants
        self.lodgings = lodgings
        self.startDate = startDate
        self.endDate = endDate
        self.image = Trip.defaultImages.randomElement() ?? Trip.defaultImages[0]
        self.dailyItineraries = []
    }
}


// Sample Data
extension Trip {
    static let touristAttractions = [
        Place(
            id: "peak_hk",
            images: ["victoria_peak_1", "victoria_peak_2"],
            name: "Victoria Peak",
            type: "tourist_attraction",
            rating: 4.7,
            ratingCount: 115243,
            price: "$",
            tags: [Tag(name: "Viewpoint"), Tag(name: "Nature"), Tag(name: "Photography")],
            openHours: [
                OpenHour(weekdayIndex: 1, openTime: "10:00", closeTime: "23:00"),
                OpenHour(weekdayIndex: 2, openTime: "10:00", closeTime: "23:00"),
                OpenHour(weekdayIndex: 3, openTime: "10:00", closeTime: "23:00"),
                OpenHour(weekdayIndex: 4, openTime: "10:00", closeTime: "23:00"),
                OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "23:30"),
                OpenHour(weekdayIndex: 6, openTime: "10:00", closeTime: "23:30"),
                OpenHour(weekdayIndex: 7, openTime: "10:00", closeTime: "23:00")
            ],
            stayingTime: "2-3 hours",
            description: "Hong Kong's most popular attraction offering spectacular 360-degree views over the city, Victoria Harbour, and the surrounding islands.",
            address: "Peak Tower, 128 Peak Rd, The Peak, Hong Kong",
            latitude: 22.2759,
            longitude: 114.1455
        ),
    
        Place(
            id: "tian_tan",
            images: ["buddha_1", "buddha_2"],
            name: "Tian Tan Buddha",
            type: "tourist_attraction",
            rating: 4.6,
            ratingCount: 75432,
            price: "$$",
            tags: [Tag(name: "Cultural"), Tag(name: "Religious"), Tag(name: "Historical")],
            openHours: [
                OpenHour(weekdayIndex: 1, openTime: "10:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 2, openTime: "10:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 3, openTime: "10:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 4, openTime: "10:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 6, openTime: "10:00", closeTime: "18:00"),
                OpenHour(weekdayIndex: 7, openTime: "10:00", closeTime: "18:00")
            ],
            stayingTime: "3-4 hours",
            description: "Also known as the Big Buddha, this iconic 34-meter-tall bronze statue sits atop Ngong Ping plateau, offering spiritual tranquility and magnificent mountain views.",
            address: "Ngong Ping Rd, Lantau Island, Hong Kong",
            latitude: 22.2540,
            longitude: 113.9052
        ),
        Place(
            id: "wong_tai_sin",
            images: ["temple_1", "temple_2"],
            name: "Wong Tai Sin Temple",
            type: "tourist_attraction",
            rating: 4.4,
            ratingCount: 45678,
            price: "Free",
            tags: [Tag(name: "Temple"), Tag(name: "Cultural"), Tag(name: "Religious")],
            openHours: [
                OpenHour(weekdayIndex: 1, openTime: "07:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 2, openTime: "07:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 3, openTime: "07:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 4, openTime: "07:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 5, openTime: "07:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 6, openTime: "07:00", closeTime: "17:30"),
                OpenHour(weekdayIndex: 7, openTime: "07:00", closeTime: "17:30")
            ],
            stayingTime: "1-2 hours",
            description: "A famous shrine and major tourist attraction in Hong Kong, home to three religions: Taoism, Buddhism and Confucianism.",
            address: "2 Chuk Yuen Village, Wong Tai Sin, Kowloon",
            latitude: 22.3421,
            longitude: 114.1933
        ),

        Place(
            id: "tsim_sha_tsui",
            images: ["promenade_1", "promenade_2"],
            name: "Tsim Sha Tsui Promenade",
            type: "tourist_attraction",
            rating: 4.5,
            ratingCount: 82345,
            price: "Free",
            tags: [Tag(name: "Waterfront"), Tag(name: "Photography"), Tag(name: "Shopping")],
            openHours: Array(repeating: OpenHour(weekdayIndex: 1, openTime: "00:00", closeTime: "24:00", isOpen24Hours: true), count: 7),
            stayingTime: "2-3 hours",
            description: "Iconic waterfront promenade offering stunning views of Victoria Harbour and Hong Kong Island's skyline, perfect for the Symphony of Lights show.",
            address: "Tsim Sha Tsui Promenade, Kowloon",
            latitude: 22.2931,
            longitude: 114.1744
        ),
        Place(
            id: "tai_o",
            images: ["tai_o_1", "tai_o_2"],
            name: "Tai O Fishing Village",
            type: "tourist_attraction",
            rating: 4.3,
            ratingCount: 28976,
            price: "Free",
            tags: [Tag(name: "Cultural"), Tag(name: "Historical"), Tag(name: "Local Life")],
            openHours: Array(repeating: OpenHour(weekdayIndex: 1, openTime: "00:00", closeTime: "24:00", isOpen24Hours: true), count: 7),
            stayingTime: "2-3 hours",
            description: "Traditional fishing village known for its stilt houses and rich cultural heritage, offering a glimpse into Hong Kong's past.",
            address: "Tai O, Lantau Island, Hong Kong",
            latitude: 22.2511,
            longitude: 113.8584
        )
    ]

    static let restaurants = [
    Place(
        id: "tim_ho_wan",
        images: ["dim_sum_1", "dim_sum_2"],
        name: "Tim Ho Wan",
        type: "restaurant",
        rating: 4.6,
        ratingCount: 52341,
        price: "$$",
        tags: [Tag(name: "Dim Sum"), Tag(name: "Cantonese"), Tag(name: "Michelin-starred")],
        openHours: [
            OpenHour(weekdayIndex: 1, openTime: "10:00", closeTime: "22:00"),
            OpenHour(weekdayIndex: 2, openTime: "10:00", closeTime: "22:00"),
            OpenHour(weekdayIndex: 3, openTime: "10:00", closeTime: "22:00"),
            OpenHour(weekdayIndex: 4, openTime: "10:00", closeTime: "22:00"),
            OpenHour(weekdayIndex: 5, openTime: "10:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 6, openTime: "09:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 7, openTime: "09:00", closeTime: "22:00")
        ],
        stayingTime: "1-2 hours",
        description: "World's most affordable Michelin-starred restaurant, famous for its BBQ pork buns and dim sum.",
        address: "Shop 72, G/F, Nam Cheong Station, Nam Cheong Station, Kowloon",
        latitude: 22.3276,
        longitude: 114.1516
    ),

    Place(
        id: "yung_kee",
        images: ["restaurant_1", "restaurant_2"],
        name: "Yung Kee Restaurant",
        type: "restaurant",
        rating: 4.4,
        ratingCount: 31245,
        price: "$$$",
        tags: [Tag(name: "Cantonese"), Tag(name: "Traditional"), Tag(name: "Roast Goose")],
        openHours: [
            OpenHour(weekdayIndex: 1, openTime: "11:00", closeTime: "23:30"),
            OpenHour(weekdayIndex: 2, openTime: "11:00", closeTime: "23:30"),
            OpenHour(weekdayIndex: 3, openTime: "11:00", closeTime: "23:30"),
            OpenHour(weekdayIndex: 4, openTime: "11:00", closeTime: "23:30"),
            OpenHour(weekdayIndex: 5, openTime: "11:00", closeTime: "23:30"),
            OpenHour(weekdayIndex: 6, openTime: "11:00", closeTime: "23:30"),
            OpenHour(weekdayIndex: 7, openTime: "11:00", closeTime: "23:30")
        ],
        stayingTime: "1-2 hours",
        description: "Established in 1942, famous for its roast goose and traditional Cantonese cuisine.",
        address: "32-40 Wellington Street, Central, Hong Kong",
        latitude: 22.2816,
        longitude: 114.1557
    ),
    Place(
        id: "mak_noodle",
        images: ["noodles_1", "noodles_2"],
        name: "Mak's Noodle",
        type: "restaurant",
        rating: 4.3,
        ratingCount: 28654,
        price: "$",
        tags: [Tag(name: "Noodles"), Tag(name: "Local"), Tag(name: "Quick Meal")],
        openHours: [
            OpenHour(weekdayIndex: 1, openTime: "11:30", closeTime: "21:00"),
            OpenHour(weekdayIndex: 2, openTime: "11:30", closeTime: "21:00"),
            OpenHour(weekdayIndex: 3, openTime: "11:30", closeTime: "21:00"),
            OpenHour(weekdayIndex: 4, openTime: "11:30", closeTime: "21:00"),
            OpenHour(weekdayIndex: 5, openTime: "11:30", closeTime: "21:30"),
            OpenHour(weekdayIndex: 6, openTime: "11:30", closeTime: "21:30"),
            OpenHour(weekdayIndex: 7, openTime: "11:30", closeTime: "21:00")
        ],
        stayingTime: "30-60 minutes",
        description: "Famous for its wonton noodles, this traditional noodle shop has been serving Hong Kong for generations.",
        address: "77 Wellington Street, Central, Hong Kong",
        latitude: 22.2820,
        longitude: 114.1554
    ),

    Place(
        id: "lung_king_heen",
        images: ["restaurant_3", "restaurant_4"],
        name: "Lung King Heen",
        type: "restaurant",
        rating: 4.8,
        ratingCount: 15678,
        price: "$$$$",
        tags: [Tag(name: "Fine Dining"), Tag(name: "Cantonese"), Tag(name: "Michelin-starred")],
        openHours: [
            OpenHour(weekdayIndex: 1, openTime: "12:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 2, openTime: "12:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 3, openTime: "12:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 4, openTime: "12:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 5, openTime: "12:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 6, openTime: "12:00", closeTime: "22:30"),
            OpenHour(weekdayIndex: 7, openTime: "12:00", closeTime: "22:30")
        ],
        stayingTime: "2-3 hours",
        description: "The world's first Chinese restaurant to receive three Michelin stars, offering spectacular harbor views and exceptional Cantonese cuisine.",
        address: "Four Seasons Hotel, 8 Finance Street, Central, Hong Kong",
        latitude: 22.2867,
        longitude: 114.1581
    )
    ]

    static let lodgings = [
    Place(
        id: "ritz_carlton",
        images: ["hotel_1", "hotel_2"],
        name: "The Ritz-Carlton Hong Kong",
        type: "lodging",
        rating: 4.9,
        ratingCount: 12543,
        price: "$$$$",
        tags: [Tag(name: "Luxury"), Tag(name: "Sky-high"), Tag(name: "5-star")],
        openHours: Array(repeating: OpenHour(weekdayIndex: 1, openTime: "00:00", closeTime: "24:00", isOpen24Hours: true), count: 7),
        stayingTime: "Overnight",
        description: "Occupying floors 102-118 of the ICC, this luxury hotel offers spectacular views and world-class amenities including the highest bar in the world.",
        address: "International Commerce Centre, 1 Austin Road West, Kowloon",
        latitude: 22.3031,
        longitude: 114.1603
    ),

    Place(
        id: "peninsula_hk",
        images: ["hotel_3", "hotel_4"],
        name: "The Peninsula Hong Kong",
        type: "lodging",
        rating: 4.8,
        ratingCount: 18765,
        price: "$$$$",
        tags: [Tag(name: "Historic"), Tag(name: "Luxury"), Tag(name: "5-star")],
        openHours: Array(repeating: OpenHour(weekdayIndex: 1, openTime: "00:00", closeTime: "24:00", isOpen24Hours: true), count: 7),
        stayingTime: "Overnight",
        description: "Known as the 'Grande Dame of the Far East', this historic luxury hotel has been serving guests since 1928 with the finest hospitality.",
        address: "Salisbury Road, Tsim Sha Tsui, Kowloon",
        latitude: 22.2951,
        longitude: 114.1722
    )
    ]
    
    static let sampleTrip = Trip(
        id: "1",
        userId: "1",
        name: "Trip to Hong Kong",
        description: "Experience the dynamic energy of Hong Kong over 3 unforgettable days. Start in Central, where gleaming skyscrapers meet traditional temples. Take the iconic Star Ferry across Victoria Harbour for breathtaking city views, then ride the historic Peak Tram to Victoria Peak for panoramic vistas of the city and surrounding islands. \nExplore the bustling streets of Mong Kok, where neon signs illuminate night markets selling everything from street food to electronics. Don't miss local favorites like dim sum at Tim Ho Wan and egg waffles from street vendors. \nEnd your journey with a visit to Lantau Island to see the majestic Tian Tan Buddha, followed by a peaceful escape to the fishing village of Tai O, where traditional stilt houses offer a glimpse into Hong Kong's past.",
        touristAttractions: Trip.touristAttractions,
        restaurants: Trip.restaurants,
        lodgings: Trip.lodgings,
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    )
}

extension Trip {
    func printTrip() {
        print("\n\n\n=======================")
        print("Trip: \(name)")
        print("Description: \(description)")
        print("Start Date: \(startDate)")
        print("End Date: \(endDate)")
        print("Tourist Attractions: \(touristAttractions.map { $0.id })")
        print("Restaurants: \(restaurants.map { $0.id })")
        print("Lodgings: \(lodgings.map { $0.id })")
    }
}
