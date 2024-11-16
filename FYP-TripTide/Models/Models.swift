//
//  Models.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 16/11/2024.
//

import Foundation

struct Tag: Equatable {
    var name: String
}

struct OpenHour {
    var day: String
    var hours: String
}

struct Place: Identifiable {
    var id = UUID()
    var images: [String]
    var name: String
    var rating: Int
    var price: String
    var tags: [Tag]
    var openHours: [OpenHour]
    var stayingTime: String
    var description: String
    var latitude: Double
    var longitude: Double
}
