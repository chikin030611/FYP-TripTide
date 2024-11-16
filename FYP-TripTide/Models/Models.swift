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
    var time: String
}

struct Place: Identifiable {
    var id = UUID()
    var image: String
    var name: String
    var tags: [Tag]
    var openHours: [OpenHour]
    var price: String
    var stayingTime: String
    var description: String
    var location: String
}
