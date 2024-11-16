//
//  StringToUrlConverter.swift
//  FYP-TripTide
//
//  Created by Chi Kin Tang on 17/11/2024.
//

import Foundation

/// Converts a string to a URL, returning nil if the string is not a valid URL.
func stringToURL(_ string: String) -> URL? {
    guard let url = URL(string: string) else {
        print("Invalid URL string: \(string)")
        return nil
    }
    return url
}
