import Foundation
import Combine
import SwiftUI

@MainActor
class EditItineraryViewModel: ObservableObject {
    private let itineraryManager = ItineraryManager.shared
    private let placesService = PlacesService.shared
    private let tripId: String
    
    // Inputs
    @Published var day: Int {
        didSet {
            if oldValue != day {
                // Save current places for the old day
                if oldValue > 0 {
                    scheduledPlacesByDay[oldValue] = scheduledPlaces
                }
                
                // Update with places for the new day (or empty array if none exist)
                scheduledPlaces = scheduledPlacesByDay[day] ?? []
                
                // Update existingItineraryId based on the current day
                if let itinerary = allItineraries.first(where: { $0.dayNumber == day }) {
                    existingItineraryId = itinerary.id
                } else {
                    existingItineraryId = nil
                }
                
                // If we don't already have data for this day and allItineraries is already loaded,
                // try to fetch the itinerary for this day
                if !allItineraries.isEmpty && !scheduledPlacesByDay.keys.contains(day) {
                    Task {
                        await fetchExistingItinerary()
                    }
                }
                
                // Update UI state
                showDropArea = scheduledPlaces.isEmpty
            }
        }
    }
    @Published var numberOfDays: Int
    @Published var scheduledPlaces: [ScheduledPlaceInput] = []
    
    // Dictionary to store scheduled places for each day
    @Published var scheduledPlacesByDay: [Int: [ScheduledPlaceInput]] = [:]
    
    // Status
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var isSuccess = false
    @Published var showDropArea = true
    private var _isEditing: Bool = false // Internal backing storage
    var isEditing: Bool {
        get {
            // Dynamic determination: we're editing if there's an existing itinerary for the current day
            return existingItineraryId != nil
        }
        set {
            // We still need to be able to set this initially, but it'll be overridden
            // when existingItineraryId changes
            _isEditing = newValue
        }
    }
    @Published var existingItineraryId: String? = nil
    
    // Available places
    @Published var availablePlaces: [Place] = []
    @Published var touristAttractions: [Place] = []
    @Published var restaurants: [Place] = []
    @Published var lodgings: [Place] = []
    @Published var isLoadingPlaces = false
    
    // Add a property to store all fetched itineraries
    @Published var allItineraries: [DailyItinerary] = []
    
    // Add these properties to track tasks
    private var fetchTask: Task<Void, Never>? = nil
    private var loadPlacesTask: Task<Void, Never>? = nil
    
    // Add these properties near the top of the class with other @Published properties
    @Published var timeOverlapWarnings: [String] = []
    @Published var invalidTimeRangeWarnings: [String] = []
    
    // Add this property near the top with other properties
    @Published var isPreviewMode = false
    
    // Add state tracking for undo functionality
    private var undoStack: [[ScheduledPlaceInput]] = []
    @Published var canUndo: Bool = false
    
    // Add a computed property to get the date for the selected day
    var selectedDate: Date? {
        // Find the itinerary for the current day to get its date
        if let itinerary = allItineraries.first(where: { $0.dayNumber == day }) {
            return itinerary.date
        }
        
        // If no itinerary exists yet but we have a cached trip, calculate date from trip start date
        if let trip = cachedTrip {
            let calendar = Calendar.current
            return calendar.date(byAdding: .day, value: day - 1, to: trip.startDate)
        }
        
        return nil
    }
    
    // Add a property to store the cached trip
    private var cachedTrip: Trip? = nil
    
    init(tripId: String, day: Int, numberOfDays: Int, isEditing: Bool = false) {
        self.tripId = tripId
        self.day = day
        self.numberOfDays = numberOfDays
        // We'll still initialize _isEditing, but it will be overridden as needed
        self._isEditing = isEditing
        
        // Load the trip to get its start date
        Task {
            do {
                let tripsManager = TripsManager.shared
                self.cachedTrip = try await tripsManager.fetchTrip(id: tripId)
            } catch {
                print("Error loading trip: \(error.localizedDescription)")
            }
        }
        
        // Start loading places immediately using tracked tasks
        loadPlacesTask = Task { 
            await self.loadAvailablePlaces() 
        }
        
        // Always fetch all itineraries
        fetchTask = Task {
            await self.fetchAllItineraries()
        }
    }
    
    // Add a deinit method to cancel tasks
    deinit {
        fetchTask?.cancel()
        loadPlacesTask?.cancel()
        print("EditItineraryViewModel deinit")
    }
    
    func fetchAllItineraries() async {
        // Skip fetching if in preview mode
        if isPreviewMode {
            print("🔍 Skipping fetch in preview mode")
            return
        }
        
        guard !isLoading else { return } // Prevent concurrent fetches
        
        self.isLoading = true
        self.error = nil
        
        do {
            let itineraries = try await itineraryManager.fetchAllItineraries(tripId: tripId)
            
            // Check if task was cancelled before updating UI
            guard !Task.isCancelled else { return }
            
            await MainActor.run {
                self.allItineraries = itineraries
                
                // Populate scheduledPlacesByDay dictionary for all days
                for itinerary in itineraries {
                    let inputs = itinerary.places.map { place in
                        let input = ScheduledPlaceInput()
                        input.placeId = place.placeId
                        input.startTime = place.startTime
                        input.endTime = place.endTime
                        input.notes = place.notes
                        
                        // Set up notification callback
                        input.notifyParent = { [weak self] in
                            self?.updateDictionaryForCurrentDay()
                        }
                        
                        return input
                    }
                    
                    self.scheduledPlacesByDay[itinerary.dayNumber] = inputs
                    
                    // If this is the current day, update scheduledPlaces
                    if itinerary.dayNumber == self.day {
                        self.existingItineraryId = itinerary.id
                        self.scheduledPlaces = inputs
                        self.showDropArea = inputs.isEmpty
                    }
                }
                
                // If there's no data for the current day, initialize it as empty
                if !self.scheduledPlacesByDay.keys.contains(self.day) {
                    self.scheduledPlaces = []
                    self.scheduledPlacesByDay[self.day] = []
                    self.showDropArea = true
                    self.existingItineraryId = nil
                }
                
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load itineraries: \(error.localizedDescription)"
                self.isLoading = false
                // Reset state on error
                self.allItineraries = []
                self.scheduledPlaces = []
                self.scheduledPlacesByDay = [:]
                self.showDropArea = true
                self.existingItineraryId = nil
            }
        }
    }
    
    func fetchExistingItinerary() async {
        // Skip fetching if in preview mode
        if isPreviewMode {
            print("🔍 Skipping fetch in preview mode")
            return
        }
        
        // If we've already fetched all itineraries, use the cached data
        if !allItineraries.isEmpty {
            await MainActor.run {
                if let itinerary = allItineraries.first(where: { $0.dayNumber == day }) {
                    self.existingItineraryId = itinerary.id
                    
                    // Convert scheduled places to input model if not already in dictionary
                    if !scheduledPlacesByDay.keys.contains(day) {
                        let inputs = itinerary.places.map { place in
                            let input = ScheduledPlaceInput()
                            input.placeId = place.placeId
                            input.startTime = place.startTime
                            input.endTime = place.endTime
                            input.notes = place.notes
                            return input
                        }
                        
                        self.scheduledPlaces = inputs
                        self.scheduledPlacesByDay[day] = inputs
                    } else {
                        self.scheduledPlaces = scheduledPlacesByDay[day] ?? []
                    }
                    
                    self.showDropArea = self.scheduledPlaces.isEmpty
                } else {
                    // No itinerary for this day
                    self.scheduledPlaces = []
                    self.scheduledPlacesByDay[day] = []
                    self.showDropArea = true
                }
            }
            return
        }
        
        // Otherwise, fetch all itineraries
        await fetchAllItineraries()
    }
    
    func loadAvailablePlaces() async {
        await MainActor.run {
            self.isLoadingPlaces = true
        }
        
        do {
            // Load places saved in this trip
            let tripsManager = TripsManager.shared
            if let trip = try await tripsManager.fetchTrip(id: tripId) {
                // Combine all place IDs
                let placeIds = trip.touristAttractionsIds + trip.restaurantsIds + trip.lodgingsIds
                
                let places = try await fetchPlacesById(ids: placeIds)
                
                await MainActor.run {
                    // Convert to Place objects
                    let allPlaces = places.map { $0.toPlace() }
                    self.availablePlaces = allPlaces
                    
                    // Sort places by type
                    self.touristAttractions = allPlaces.filter { $0.type == "tourist_attraction" }
                    self.restaurants = allPlaces.filter { $0.type == "restaurant" }
                    self.lodgings = allPlaces.filter { $0.type == "lodging" }
                    
                    print("📊 Places loaded - Tourist Attractions: \(self.touristAttractions.count), Restaurants: \(self.restaurants.count), Lodgings: \(self.lodgings.count)")
                    
                    self.isLoadingPlaces = false
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to load places: \(error.localizedDescription)"
                self.isLoadingPlaces = false
            }
        }
    }

    func addPlace() {
        let newPlace = ScheduledPlaceInput()
        
        // Set default times
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        startComponents.hour = 9
        startComponents.minute = 0
        newPlace.startTime = calendar.date(from: startComponents)
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        endComponents.hour = 11
        endComponents.minute = 0
        newPlace.endTime = calendar.date(from: endComponents)
        
        // Set up notification callback
        newPlace.notifyParent = { [weak self] in
            self?.updateDictionaryForCurrentDay()
        }
        
        scheduledPlaces.append(newPlace)
        
        // Also update our dictionary
        scheduledPlacesByDay[day] = scheduledPlaces
    }
    
    func removePlaceAt(index: Int) {
        guard index < scheduledPlaces.count else { return }
        
        // Save current state to undo stack
        saveStateForUndo()
        
        scheduledPlaces.remove(at: index)
        
        // Update our dictionary
        scheduledPlacesByDay[day] = scheduledPlaces

        // Check for overlaps after removing a place
        checkForTimeOverlaps()

        if scheduledPlaces.isEmpty {
            showDropArea = true
        }
    }
    
    // Add this method to check for time overlaps
    func checkForTimeOverlaps() {
        timeOverlapWarnings.removeAll()
        
        guard scheduledPlaces.count > 1 else { 
            // Even if there's only one place, we should check its time range
            checkForInvalidTimeRanges()
            return 
        }
        
        // Original overlap checking logic
        for i in 0..<scheduledPlaces.count {
            for j in (i + 1)..<scheduledPlaces.count {
                let place1 = scheduledPlaces[i]
                let place2 = scheduledPlaces[j]
                
                guard let start1 = place1.startTime,
                      let end1 = place1.endTime,
                      let start2 = place2.startTime,
                      let end2 = place2.endTime else {
                    continue
                }
                
                // Check if the time periods overlap
                if start1 < end2 && start2 < end1 {
                    // Get place names for better warning messages
                    let place1Name = availablePlaces.first(where: { $0.id == place1.placeId })?.name ?? "Unknown Place"
                    let place2Name = availablePlaces.first(where: { $0.id == place2.placeId })?.name ?? "Unknown Place"
                    
                    let warning = "Time overlap detected between '\(place1Name)' and '\(place2Name)'"
                    timeOverlapWarnings.append(warning)
                }
            }
        }
        
        // Also check for invalid time ranges
        checkForInvalidTimeRanges()
    }
    
    // Add this method to check for invalid time ranges
    func checkForInvalidTimeRanges() {
        invalidTimeRangeWarnings.removeAll()
        
        for place in scheduledPlaces {
            guard let startTime = place.startTime,
                  let endTime = place.endTime else {
                continue
            }
            
            // Check if end time is before start time
            if endTime < startTime {
                // Get place name for better warning messages
                let placeName = availablePlaces.first(where: { $0.id == place.placeId })?.name ?? "Unknown Place"
                
                let warning = "Invalid time range for '\(placeName)': End time cannot be before start time"
                invalidTimeRangeWarnings.append(warning)
            }
        }
    }
    
    // Modify the addPlaceWithId method to save state before adding a place
    func addPlaceWithId(_ placeId: String) {
        // Save current state to undo stack
        saveStateForUndo()
        
        let newPlace = ScheduledPlaceInput()
        newPlace.placeId = placeId
        
        // Set default times
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        startComponents.hour = 9
        startComponents.minute = 0
        newPlace.startTime = calendar.date(from: startComponents)
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        endComponents.hour = 11
        endComponents.minute = 0
        newPlace.endTime = calendar.date(from: endComponents)
        
        // Set up notification callback
        newPlace.notifyParent = { [weak self] in
            self?.updateDictionaryForCurrentDay()
        }
        
        scheduledPlaces.append(newPlace)
        
        // Update our dictionary
        scheduledPlacesByDay[day] = scheduledPlaces
        
        // Check for time overlaps and invalid time ranges
        checkForTimeOverlaps()
        
        // Hide drop area
        if !scheduledPlaces.isEmpty {
            showDropArea = false
        }
    }
    
    // Add a method to update the dictionary whenever a scheduled place is modified
    private func updateDictionaryForCurrentDay() {
        print("📝 updateDictionaryForCurrentDay called for day \(day)")
        scheduledPlacesByDay[day] = scheduledPlaces
        
        // Debug the current places in the dictionary
        if let places = scheduledPlacesByDay[day] {
            print("�� Dictionary updated for day \(day) with \(places.count) places")
            
            for (index, place) in places.enumerated() {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                let startTimeStr = place.startTime.map { formatter.string(from: $0) } ?? "nil"
                let endTimeStr = place.endTime.map { formatter.string(from: $0) } ?? "nil"
                
                print("�� Place \(index): ID=\(place.placeId ?? "nil"), Start=\(startTimeStr), End=\(endTimeStr)")
            }
        } else {
            print("⚠️ Dictionary entry for day \(day) is nil after update")
        }
        
        checkForTimeOverlaps()
    }
    
    func saveItinerary() async {
        await MainActor.run {
            self.isLoading = true
            self.error = nil
        }
        
        do {
            // Make sure we're working with the current places
            let currentPlaces = scheduledPlaces
            
            let dtos = currentPlaces.compactMap { place -> ScheduledPlaceDto? in
                guard let placeId = place.placeId, !placeId.isEmpty else { return nil }
                
                // Format time strings safely
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                
                let startTime = place.startTime.map { formatter.string(from: $0) } ?? "00:00:00"
                let endTime = place.endTime.map { formatter.string(from: $0) } ?? "00:00:00"
                
                return ScheduledPlaceDto(
                    placeId: placeId,
                    startTime: startTime,
                    endTime: endTime,
                    notes: place.notes
                )
            }
            
            // Simplify logic: we're editing if there's an existing ID, otherwise creating
            if let existingId = existingItineraryId {
                if dtos.isEmpty {
                    // If all places were removed, delete the itinerary
                    try await itineraryManager.deleteItinerary(tripId: tripId, day: day)
                    
                    await MainActor.run {
                        self.isSuccess = true
                        self.isLoading = false
                        // Make sure our local state reflects the deletion
                        self.existingItineraryId = nil
                        
                        // Update our allItineraries array too
                        self.allItineraries.removeAll(where: { $0.dayNumber == self.day })
                    }
                } else {
                    // Otherwise update with the places we have
                    let dailyItinerary = try await itineraryManager.updateItinerary(
                        tripId: tripId,
                        day: day,
                        scheduledPlaces: dtos
                    )
                    
                    await MainActor.run {
                        self.isSuccess = true
                        self.isLoading = false
                    }
                }
            } else {
                // Creating a new itinerary
                if !dtos.isEmpty {
                    let dailyItinerary = try await itineraryManager.createItinerary(
                        tripId: tripId, 
                        day: day,
                        scheduledPlaces: dtos
                    )
                    
                    await MainActor.run {
                        self.existingItineraryId = dailyItinerary.id
                        self.isSuccess = true
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.error = "Please add at least one place with a valid ID"
                        self.isLoading = false
                    }
                }
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to save itinerary: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    private func fetchPlacesById(ids: [String]) async throws -> [PlaceBasicData] {
        return try await withThrowingTaskGroup(of: PlaceBasicData.self) { group in
            // Create a task for each place ID
            for id in ids {
                group.addTask {
                    try await self.placesService.fetchPlaceBasicById(id: id)
                }
            }
            
            // Collect results
            var places: [PlaceBasicData] = []
            for try await place in group {
                places.append(place)
            }
            
            return places
        }
    }
    
    // Convenience method to delete itinerary if all places were removed
    func deleteItineraryIfEmpty() async {
        // Only relevant if we're editing an existing itinerary
        if isEditing, let existingId = existingItineraryId, scheduledPlaces.isEmpty {
            await MainActor.run {
                self.isLoading = true
                self.error = nil
            }
            
            do {
                try await itineraryManager.deleteItinerary(tripId: tripId, day: day)
                
                await MainActor.run {
                    self.isSuccess = true
                    self.isLoading = false
                    self.existingItineraryId = nil
                    
                    // Update our allItineraries array too
                    self.allItineraries.removeAll(where: { $0.dayNumber == self.day })
                    
                    // Update our dictionary
                    self.scheduledPlacesByDay[self.day] = []
                }
            } catch {
                await MainActor.run {
                    self.error = "Failed to delete empty itinerary: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
    
    // Add a public method for updating the dictionary
    func forceUpdateDictionaryForCurrentDay() {
        print("🔨 forceUpdateDictionaryForCurrentDay called for day \(day)")
        
        // Make a deep copy of the scheduled places
        let placesCopy = scheduledPlaces.map { place -> ScheduledPlaceInput in
            let newPlace = ScheduledPlaceInput()
            newPlace.placeId = place.placeId
            newPlace.startTime = place.startTime
            newPlace.endTime = place.endTime
            newPlace.notes = place.notes
            
            // Set up notification callback
            newPlace.notifyParent = { [weak self] in
                self?.updateDictionaryForCurrentDay()
            }
            
            return newPlace
        }
        
        scheduledPlacesByDay[day] = placesCopy
        
        // Debug output
        if let storedPlaces = scheduledPlacesByDay[day] {
            print("🔨 Dictionary updated with \(storedPlaces.count) places for day \(day)")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            
            for (index, place) in storedPlaces.enumerated() {
                let placeName = availablePlaces.first(where: { $0.id == place.placeId })?.name ?? "Unknown"
                let startTimeStr = place.startTime.map { formatter.string(from: $0) } ?? "nil"
                let endTimeStr = place.endTime.map { formatter.string(from: $0) } ?? "nil"
                
                print("🔨 Updated place \(index): \(placeName), Start=\(startTimeStr), End=\(endTimeStr)")
            }
        } else {
            print("⚠️ Dictionary entry for day \(day) is still nil after forced update")
        }
    }
    
    // Add this method to create a preview copy
    func createPreviewCopy() -> EditItineraryViewModel {
        let previewModel = EditItineraryViewModel(
            tripId: self.tripId,
            day: self.day,
            numberOfDays: self.numberOfDays,
            isEditing: self.isEditing
        )
        
        // Mark as preview mode to prevent fetching
        previewModel.isPreviewMode = true
        
        // Copy current state
        previewModel.scheduledPlaces = self.scheduledPlaces
        previewModel.scheduledPlacesByDay = self.scheduledPlacesByDay
        previewModel.availablePlaces = self.availablePlaces
        previewModel.existingItineraryId = self.existingItineraryId
        previewModel.allItineraries = self.allItineraries
        previewModel.touristAttractions = self.touristAttractions
        previewModel.restaurants = self.restaurants
        previewModel.lodgings = self.lodgings
        previewModel.timeOverlapWarnings = self.timeOverlapWarnings
        previewModel.invalidTimeRangeWarnings = self.invalidTimeRangeWarnings
        
        return previewModel
    }
    
    // Add these methods for undo functionality
    private func saveStateForUndo() {
        // Create deep copy of current scheduled places
        let copy = scheduledPlaces.map { place -> ScheduledPlaceInput in
            let newPlace = ScheduledPlaceInput()
            newPlace.placeId = place.placeId
            newPlace.startTime = place.startTime
            newPlace.endTime = place.endTime
            newPlace.notes = place.notes
            
            // Set up notification callback
            newPlace.notifyParent = { [weak self] in
                self?.updateDictionaryForCurrentDay()
            }
            
            return newPlace
        }
        
        // Add current state to undo stack
        undoStack.append(copy)
        canUndo = true
        
        // Limit undo stack size
        if undoStack.count > 10 {
            undoStack.removeFirst()
        }
    }
    
    // Public method for components to save state before edits
    func saveStateBeforeEdit() {
        saveStateForUndo()
    }
    
    func undo() {
        guard !undoStack.isEmpty else { return }
        
        // Get previous state
        let previousState = undoStack.removeLast()
        
        // Update UI
        scheduledPlaces = previousState
        scheduledPlacesByDay[day] = previousState
        
        // Update undo button state
        canUndo = !undoStack.isEmpty
        
        // Check for overlaps
        checkForTimeOverlaps()
        
        // Update drop area visibility
        showDropArea = scheduledPlaces.isEmpty
    }
}

// Input model for the form
class ScheduledPlaceInput: Identifiable, ObservableObject {
    let id = UUID()
    @Published var placeId: String? = nil {
        didSet {
            print("🔄 ScheduledPlaceInput: placeId changed to \(String(describing: placeId))")
            notifyParent?()
        }
    }
    @Published var startTime: Date? = nil {
        didSet {
            if let time = startTime {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                print("🔄 ScheduledPlaceInput: startTime changed to \(formatter.string(from: time))")
            } else {
                print("🔄 ScheduledPlaceInput: startTime changed to nil")
            }
            notifyParent?()
        }
    }
    @Published var endTime: Date? = nil {
        didSet {
            if let time = endTime {
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm:ss"
                print("🔄 ScheduledPlaceInput: endTime changed to \(formatter.string(from: time))")
            } else {
                print("🔄 ScheduledPlaceInput: endTime changed to nil")
            }
            notifyParent?()
        }
    }
    @Published var notes: String? = nil {
        didSet {
            print("🔄 ScheduledPlaceInput: notes changed to \(String(describing: notes))")
            notifyParent?()
        }
    }
    
    // Callback to notify parent view model of changes
    var notifyParent: (() -> Void)? = nil
} 