import Foundation

actor PlaceCache {
    static let shared = PlaceCache()
    
    private var cache: [String: (data: PlaceDetailResponse, timestamp: Date)] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    
    private init() {}
    
    func get(_ id: String) -> PlaceDetailResponse? {
        guard let entry = cache[id] else { return nil }
        
        // Check if cache entry has expired
        if Date().timeIntervalSince(entry.timestamp) > cacheTimeout {
            cache.removeValue(forKey: id)
            return nil
        }
        
        return entry.data
    }
    
    func set(_ response: PlaceDetailResponse, for id: String) {
        cache[id] = (response, Date())
        
        // Clean up old entries
        cleanCache()
    }
    
    func clear() {
        cache.removeAll()
    }
    
    private func cleanCache() {
        let now = Date()
        cache = cache.filter { now.timeIntervalSince($0.value.timestamp) <= cacheTimeout }
    }
}

actor PlaceBasicCache {
    static let shared = PlaceBasicCache()
    
    private var cache: [String: (data: PlaceBasicData, timestamp: Date)] = [:]
    private let cacheDuration: TimeInterval = 3600 // 1 hour
    
    func get(_ id: String) -> PlaceBasicData? {
        guard let cached = cache[id],
              Date().timeIntervalSince(cached.timestamp) < cacheDuration else {
            return nil
        }
        return cached.data
    }
    
    func set(_ data: PlaceBasicData, for id: String) {
        cache[id] = (data: data, timestamp: Date())
    }
    
    func clear() {
        cache.removeAll()
    }
}