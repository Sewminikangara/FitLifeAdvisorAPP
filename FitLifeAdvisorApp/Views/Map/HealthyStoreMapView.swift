//
//  HealthyStoreMapView.swift
//  FitLifeAdvisorApp
//

// MapKit integration for finding healthy food stores and gyms


import SwiftUI
import MapKit
import CoreLocation

struct HealthyStoreMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 7.8731, longitude: 80.7718), // Central Sri Lanka (Kandy area)
        span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 2.0) // Covers most of Sri Lanka
    )
    @State private var selectedCategory: PlaceCategory = .both
    @State private var places: [HealthyPlace] = []
    @State private var selectedPlace: HealthyPlace?
    @State private var isLoading = false
    @State private var showingPlaceDetail = false
    @Environment(\.dismiss) private var dismiss
    
    // Add computed property for filtered places
    var filteredPlaces: [HealthyPlace] {
        switch selectedCategory {
        case .healthyFood:
            return places.filter { $0.category == .healthyFood }
        case .gym:
            return places.filter { $0.category == .gym }
        case .both:
            return places
        }
    }
    
    enum PlaceCategory: String, CaseIterable {
        case healthyFood = "Healthy Food"
        case gym = "Gyms"
        case both = "All Places"
        
        var searchTerms: [String] {
            switch self {
            case .healthyFood:
                return ["organic food store", "health food store", "Keells Super", "Arpico Supercentre", "Cargills Food City", "fruit shop", "vegetable market", "Ayurvedic shop", "juice bar", "salad bar", "healthy restaurant", "organic market"]
            case .gym:
                return ["gym", "fitness center", "Gold's Gym", "Fitness First", "Body Line Fitness", "yoga studio", "pilates studio", "martial arts", "swimming pool", "sports club"]
            case .both:
                return ["organic food store", "health food store", "Keells Super", "gym", "fitness center", "Gold's Gym", "yoga studio", "juice bar", "Ayurvedic shop"]
            }
        }
        
        var icon: String {
            switch self {
            case .healthyFood: return "leaf.fill"
            case .gym: return "dumbbell.fill"
            case .both: return "map.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .healthyFood: return Constants.Colors.successGreen
            case .gym: return Constants.Colors.primaryBlue
            case .both: return Constants.Colors.warningOrange
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Map Background
                Map(coordinateRegion: $region, annotationItems: filteredPlaces) { place in
                    MapAnnotation(coordinate: place.coordinate) {
                        PlaceAnnotationView(place: place) {
                            selectedPlace = place
                            showingPlaceDetail = true
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Top Controls
                VStack {
                    // Category Selector
                    CategorySelectorView(selectedCategory: $selectedCategory) {
                        // No need to search when changing categories - we use filtered data
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // Bottom Controls
                    VStack(spacing: Constants.Spacing.medium) {
                        if isLoading {
                            LoadingView()
                        }
                        
                        // Sri Lankan Cities Quick Access
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: Constants.Spacing.small) {
                                CityButton(name: "Colombo", coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)) {
                                    centerOnCity(coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612))
                                }
                                CityButton(name: "Kandy", coordinate: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337)) {
                                    centerOnCity(coordinate: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337))
                                }
                                CityButton(name: "Galle", coordinate: CLLocationCoordinate2D(latitude: 6.0535, longitude: 80.2210)) {
                                    centerOnCity(coordinate: CLLocationCoordinate2D(latitude: 6.0535, longitude: 80.2210))
                                }
                                CityButton(name: "Negombo", coordinate: CLLocationCoordinate2D(latitude: 7.2084, longitude: 79.8358)) {
                                    centerOnCity(coordinate: CLLocationCoordinate2D(latitude: 7.2084, longitude: 79.8358))
                                }
                            }
                            .padding(.horizontal, Constants.Spacing.medium)
                        }
                        
                        // Location & Search Button
                        HStack(spacing: Constants.Spacing.medium) {
                            // Current Location Button
                            Button(action: centerOnUserLocation) {
                                Image(systemName: "location.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Constants.Colors.primaryBlue)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            
                            // Search Area Button
                            Button(action: searchPlaces) {
                                HStack(spacing: Constants.Spacing.small) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.title2)
                                    Text("Search This Area")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, Constants.Spacing.large)
                                .padding(.vertical, Constants.Spacing.medium)
                                .background(Constants.Colors.successGreen)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .disabled(isLoading)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Find Healthy Places")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text("\(places.count) places")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.textLight)
                }
            }
        }
        .sheet(isPresented: $showingPlaceDetail) {
            if let place = selectedPlace {
                PlaceDetailView(place: place)
            }
        }
        .onAppear {
            setupLocation()
            loadSampleSriLankanPlaces()
        }
        .onChange(of: locationManager.location) { location in
            if let location = location {
                region.center = location.coordinate
                // Recalculate distances when user location changes
                updateDistances(userLocation: location)
            }
        }
    }
    
    private func setupLocation() {
        locationManager.requestLocation()
        // Don't call searchPlaces() - we use sample data instead
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation(.easeInOut(duration: 1)) {
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            }
        } else {
            locationManager.requestLocation()
            // Default to Colombo if location not available
            withAnimation(.easeInOut(duration: 1)) {
                region.center = CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8612)
                region.span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            }
        }
    }
    
    private func centerOnCity(coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 1)) {
            region.center = coordinate
            region.span = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        }
        // Don't search for places - we use sample data
    }
    
    // Helper function to calculate distance from user location
    private func calculateDistance(from userLocation: CLLocation, to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let targetLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return userLocation.distance(from: targetLocation)
    }
    
    // Function to update distances when user location changes
    private func updateDistances(userLocation: CLLocation) {
        places = places.map { place in
            var updatedPlace = place
            updatedPlace.distance = calculateDistance(from: userLocation, to: place.coordinate)
            return updatedPlace
        }
    }
    
    private func searchPlaces() {
        isLoading = true
        places.removeAll()
        
        let searchTerms = selectedCategory.searchTerms
        let group = DispatchGroup()
        var foundPlaces: [HealthyPlace] = []
        
        for term in searchTerms.prefix(3) { // Limit to 3 searches to avoid rate limiting
            group.enter()
            searchForPlaces(term: term) { results in
                foundPlaces.append(contentsOf: results)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            // Remove duplicates and limit results
            let uniquePlaces = Dictionary(grouping: foundPlaces) { $0.name }
                .compactMapValues { $0.first }
                .values
            
            places = Array(uniquePlaces.prefix(20))
            isLoading = false
        }
    }
    
    private func searchForPlaces(term: String, completion: @escaping ([HealthyPlace]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = term
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response, error == nil else {
                completion([])
                return
            }
            
            let places = response.mapItems.compactMap { item -> HealthyPlace? in
                guard let name = item.name,
                      let location = item.placemark.location else { return nil }
                
                let category: PlaceCategory = {
                    let lowercaseName = name.lowercased()
                    if lowercaseName.contains("gym") || 
                       lowercaseName.contains("fitness") || 
                       lowercaseName.contains("yoga") ||
                       lowercaseName.contains("crossfit") {
                        return .gym
                    }
                    return .healthyFood
                }()
                
                return HealthyPlace(
                    id: UUID(),
                    name: name,
                    address: item.placemark.title ?? "",
                    coordinate: location.coordinate,
                    category: category,
                    rating: Double.random(in: 3.5...5.0), // Simulated rating
                    distance: location.distance(from: CLLocation(latitude: region.center.latitude, longitude: region.center.longitude)),
                    phoneNumber: item.phoneNumber,
                    website: item.url?.absoluteString
                )
            }
            
            completion(places)
        }
    }
    
    private func loadSampleSriLankanPlaces() {
        // Get user location for distance calculations
        let userLocation = locationManager.location ?? CLLocation(latitude: 6.9271, longitude: 79.8612) // Default to Colombo
        
        // Sample healthy food places in Sri Lanka
        let samplePlaces = [
            // Colombo - Healthy Food
            HealthyPlace(
                id: UUID(),
                name: "Keells Super - Union Place",
                address: "371 R A De Mel Mawatha, Union Place, Colombo 02",
                coordinate: CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.8613),
                category: .healthyFood,
                rating: 4.2,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.8613)),
                phoneNumber: "+94117123456",
                website: "https://keellssuper.com"
            ),
            HealthyPlace(
                id: UUID(),
                name: "Organic World - Bambalapitiya",
                address: "65 Galle Road, Bambalapitiya, Colombo 04",
                coordinate: CLLocationCoordinate2D(latitude: 6.8845, longitude: 79.8565),
                category: .healthyFood,
                rating: 4.5,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.8845, longitude: 79.8565)),
                phoneNumber: "+94112582147",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Ayurveda Authentic Products",
                address: "125 Kandy Road, Colombo 07",
                coordinate: CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.8740),
                category: .healthyFood,
                rating: 4.3,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.9147, longitude: 79.8740)),
                phoneNumber: "+94115678901",
                website: nil
            ),
            
            // Colombo - Gyms
            HealthyPlace(
                id: UUID(),
                name: "Gold's Gym Colombo",
                address: "55 Independence Avenue, Colombo 07",
                coordinate: CLLocationCoordinate2D(latitude: 6.9034, longitude: 79.8617),
                category: .gym,
                rating: 4.6,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.9034, longitude: 79.8617)),
                phoneNumber: "+94112685555",
                website: "https://goldsgym.lk"
            ),
            HealthyPlace(
                id: UUID(),
                name: "Fitness First - Crescat",
                address: "Level 4, Crescat Boulevard, 89 Galle Road, Colombo 03",
                coordinate: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8456),
                category: .gym,
                rating: 4.4,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.9271, longitude: 79.8456)),
                phoneNumber: "+94112575757",
                website: "https://fitnessfirst.lk"
            ),
            HealthyPlace(
                id: UUID(),
                name: "Power Zone Gym - Rajagiriya",
                address: "789 Nawala Road, Rajagiriya",
                coordinate: CLLocationCoordinate2D(latitude: 6.9063, longitude: 79.8910),
                category: .gym,
                rating: 4.3,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.9063, longitude: 79.8910)),
                phoneNumber: "+94112789123",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Iron Paradise - Mount Lavinia",
                address: "456 Galle Road, Mount Lavinia",
                coordinate: CLLocationCoordinate2D(latitude: 6.8356, longitude: 79.8647),
                category: .gym,
                rating: 4.5,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.8356, longitude: 79.8647)),
                phoneNumber: "+94112778899",
                website: nil
            ),
            
            // Kandy
            HealthyPlace(
                id: UUID(),
                name: "Kandy City Centre - Healthy Market",
                address: "5 Dalada Veediya, Kandy 20000",
                coordinate: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337),
                category: .healthyFood,
                rating: 4.1,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2906, longitude: 80.6337)),
                phoneNumber: "+94812234567",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Body Line Fitness Kandy",
                address: "212 Peradeniya Road, Kandy 20000",
                coordinate: CLLocationCoordinate2D(latitude: 7.2935, longitude: 80.6305),
                category: .gym,
                rating: 4.3,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2935, longitude: 80.6305)),
                phoneNumber: "+94812345678",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Elite Fitness - Kandy",
                address: "89 Kotugodella Veediya, Kandy 20000",
                coordinate: CLLocationCoordinate2D(latitude: 7.2948, longitude: 80.6350),
                category: .gym,
                rating: 4.2,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2948, longitude: 80.6350)),
                phoneNumber: "+94812445566",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Kandy Sports Club Gym",
                address: "3 Lady Gordon's Drive, Kandy 20000",
                coordinate: CLLocationCoordinate2D(latitude: 7.2958, longitude: 80.6380),
                category: .gym,
                rating: 4.4,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2958, longitude: 80.6380)),
                phoneNumber: "+94812667788",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Lucion Fitness Club",
                address: "67 Temple Street, Kandy 20000",
                coordinate: CLLocationCoordinate2D(latitude: 7.2970, longitude: 80.6390),
                category: .gym,
                rating: 4.5,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2970, longitude: 80.6390)),
                phoneNumber: "+94812889900",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Metro Fitness",
                address: "45 Yatinuwara Street, Kandy 20000",
                coordinate: CLLocationCoordinate2D(latitude: 7.2920, longitude: 80.6360),
                category: .gym,
                rating: 4.3,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2920, longitude: 80.6360)),
                phoneNumber: "+94812775544",
                website: nil
            ),
            
            // Galle
            HealthyPlace(
                id: UUID(),
                name: "Galle Fort Organic Store",
                address: "15 Church Street, Galle Fort, Galle 80000",
                coordinate: CLLocationCoordinate2D(latitude: 6.0329, longitude: 80.2168),
                category: .healthyFood,
                rating: 4.7,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.0329, longitude: 80.2168)),
                phoneNumber: "+94912234567",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Galle Fitness Center",
                address: "234 Matara Road, Galle 80000",
                coordinate: CLLocationCoordinate2D(latitude: 6.0535, longitude: 80.2210),
                category: .gym,
                rating: 4.3,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.0535, longitude: 80.2210)),
                phoneNumber: "+94916547890",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Southern Fitness - Galle",
                address: "78 Wakwella Road, Galle 80000",
                coordinate: CLLocationCoordinate2D(latitude: 6.0367, longitude: 80.2205),
                category: .gym,
                rating: 4.1,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.0367, longitude: 80.2205)),
                phoneNumber: "+94912334455",
                website: nil
            ),
            
            // Negombo
            HealthyPlace(
                id: UUID(),
                name: "Negombo Health Club",
                address: "23 Lewis Place, Negombo 11500",
                coordinate: CLLocationCoordinate2D(latitude: 7.2084, longitude: 79.8380),
                category: .gym,
                rating: 4.2,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2084, longitude: 79.8380)),
                phoneNumber: "+94314587692",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Beach Fitness - Negombo",
                address: "56 St. Joseph Street, Negombo 11500",
                coordinate: CLLocationCoordinate2D(latitude: 7.2098, longitude: 79.8420),
                category: .gym,
                rating: 4.0,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2098, longitude: 79.8420)),
                phoneNumber: "+94312445566",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Negombo Sports Complex",
                address: "91 Kurana Road, Negombo 11500",
                coordinate: CLLocationCoordinate2D(latitude: 7.2050, longitude: 79.8350),
                category: .gym,
                rating: 4.3,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 7.2050, longitude: 79.8350)),
                phoneNumber: "+94312778899",
                website: nil
            ),
            
            // More Gyms across Sri Lanka (Suburbs)
            HealthyPlace(
                id: UUID(),
                name: "Power World Gym - Nugegoda",
                address: "123 High Level Road, Nugegoda 10250",
                coordinate: CLLocationCoordinate2D(latitude: 6.8649, longitude: 79.8997),
                category: .gym,
                rating: 4.2,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.8649, longitude: 79.8997)),
                phoneNumber: "+94112789456",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Flex Gym - Battaramulla",
                address: "456 Parliament Road, Battaramulla 10120",
                coordinate: CLLocationCoordinate2D(latitude: 6.8985, longitude: 79.9185),
                category: .gym,
                rating: 4.1,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.8985, longitude: 79.9185)),
                phoneNumber: "+94113654789",
                website: nil
            ),
            HealthyPlace(
                id: UUID(),
                name: "Fitness Zone - Maharagama",
                address: "789 Maharagama Main Road, Maharagama 10280",
                coordinate: CLLocationCoordinate2D(latitude: 6.8417, longitude: 79.9267),
                category: .gym,
                rating: 4.0,
                distance: calculateDistance(from: userLocation, to: CLLocationCoordinate2D(latitude: 6.8417, longitude: 79.9267)),
                phoneNumber: "+94112987321",
                website: nil
            )
        ]
        
        self.places = samplePlaces
    }
}

// MARK: - Supporting Views

struct CityButton: View {
    let name: String
    let coordinate: CLLocationCoordinate2D
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(Constants.Colors.primaryBlue)
                .padding(.horizontal, Constants.Spacing.medium)
                .padding(.vertical, Constants.Spacing.small)
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}

struct CategorySelectorView: View {
    @Binding var selectedCategory: HealthyStoreMapView.PlaceCategory
    let onSelectionChanged: () -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Constants.Spacing.medium) {
                ForEach(HealthyStoreMapView.PlaceCategory.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                        onSelectionChanged()
                    }) {
                        HStack(spacing: Constants.Spacing.small) {
                            Image(systemName: category.icon)
                                .font(.system(size: 16, weight: .semibold))
                            
                            Text(category.rawValue)
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(selectedCategory == category ? .white : category.color)
                        .padding(.horizontal, Constants.Spacing.medium)
                        .padding(.vertical, Constants.Spacing.small)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(selectedCategory == category ? category.color : .white)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        )
                    }
                }
            }
            .padding(.horizontal, Constants.Spacing.medium)
        }
    }
}

struct PlaceAnnotationView: View {
    let place: HealthyPlace
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                Circle()
                    .fill(place.category.color)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
                
                Image(systemName: place.category.icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .scaleEffect(1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: place.id)
    }
}

struct LoadingView: View {
    var body: some View {
        HStack(spacing: Constants.Spacing.small) {
            ProgressView()
                .scaleEffect(0.8)
            Text("Finding healthy places...")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Constants.Colors.textLight)
        }
        .padding(.horizontal, Constants.Spacing.large)
        .padding(.vertical, Constants.Spacing.small)
        .background(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct PlaceDetailView: View {
    let place: HealthyPlace
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Constants.Spacing.large) {
                    // Header
                    VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                        HStack {
                            Image(systemName: place.category.icon)
                                .font(.title2)
                                .foregroundColor(place.category.color)
                            
                            Text(place.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.textDark)
                        }
                        
                        HStack {
                            StarsView(rating: place.rating)
                            Text(String(format: "%.1f", place.rating))
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Constants.Colors.textLight)
                        }
                    }
                    
                    // Details
                    VStack(alignment: .leading, spacing: Constants.Spacing.medium) {
                        DetailRow(icon: "location.fill", title: "Address", value: place.address, color: Constants.Colors.errorRed)
                        
                        DetailRow(icon: "ruler", title: "Distance", value: String(format: "%.1f km", place.distance / 1000), color: Constants.Colors.warningOrange)
                        
                        if let phone = place.phoneNumber {
                            DetailRow(icon: "phone.fill", title: "Phone", value: phone, color: Constants.Colors.successGreen)
                        }
                        
                        if let website = place.website {
                            DetailRow(icon: "globe", title: "Website", value: website, color: Constants.Colors.primaryBlue)
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: Constants.Spacing.medium) {
                        Button(action: openInMaps) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Open in Maps")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Constants.Spacing.medium)
                            .background(Constants.Colors.primaryBlue)
                            .cornerRadius(12)
                        }
                        
                        if let phone = place.phoneNumber {
                            Button(action: { callPlace(phone: phone) }) {
                                HStack {
                                    Image(systemName: "phone.fill")
                                    Text("Call Now")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Constants.Spacing.medium)
                                .background(Constants.Colors.successGreen)
                                .cornerRadius(12)
                            }
                        }
                    }
                    
                    Spacer(minLength: 50)
                }
                .padding(Constants.Spacing.large)
            }
            .navigationTitle(place.category.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(Constants.Colors.primaryBlue)
                }
            }
        }
    }
    
    private func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: place.coordinate))
        mapItem.name = place.name
        mapItem.openInMaps()
    }
    
    private func callPlace(phone: String) {
        if let url = URL(string: "tel://\(phone)") {
            UIApplication.shared.open(url)
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: Constants.Spacing.medium) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Constants.Colors.textLight)
                
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Constants.Colors.textDark)
            }
            
            Spacer()
        }
        .padding(.vertical, Constants.Spacing.small)
    }
}

struct StarsView: View {
    let rating: Double
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
    }
}

// MARK: - Data Models

struct HealthyPlace: Identifiable, Equatable {
    let id: UUID
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let category: HealthyStoreMapView.PlaceCategory
    let rating: Double
    var distance: CLLocationDistance
    let phoneNumber: String?
    let website: String?
    
    static func == (lhs: HealthyPlace, rhs: HealthyPlace) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Location Manager

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    
    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed with error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        }
    }
}

#Preview {
    HealthyStoreMapView()
}
