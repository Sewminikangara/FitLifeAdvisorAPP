# FitLife Advisor App 🏃‍♀️

## Overview
FitLife Advisor is a comprehensive iOS health and fitness application that leverages advanced iOS features including HealthKit integration, ML Kit for intelligent meal analysis, Face ID/Touch ID authentication, and MapKit for outdoor activity tracking.

## Key Features

### Authentication & Security
- **Biometric Authentication**: Face ID and Touch ID support
- **Secure User Management**: Local data persistence with UserDefaults
- **Improved UI Design**: Premium authentication interface

### Health Integration
- **HealthKit Integration**: Full read/write access to health data
- **Workout Tracking**: Indoor and outdoor activity monitoring
- **Nutrition Logging**: Comprehensive meal and nutrition tracking
- **Health Metrics**: Heart rate, calories, steps, and more

### AI-Powered Features
- **ML Kit Integration**: Intelligent meal photo analysis
- **Food Recognition**: Barcode scanning and nutrition label reading
- **Exercise Detection**: Pose estimation and workout classification
- **Smart Recommendations**: Personalized fitness and nutrition advice

### Advanced iOS Features
- **MapKit Integration**: GPS tracking for outdoor activities
- **Vision Framework**: Image processing and food recognition
- **Core Data**: Persistent data storage
- **Combine Framework**: Reactive programming for data flow
- **SwiftUI**: Modern declarative UI framework

##  Architecture

### MVVM Pattern
```
Views/ (93 files)
├── Authentication/     # Login, signup, biometric setup
├── Dashboard/         # Main app interface
├── Workouts/         # Exercise tracking and planning
├── MealPlanning/     # Nutrition and meal management
├── Profile/          # User settings and preferences
├── Map/             # Location-based features
└── Common/          # Shared UI components

ViewModels/
├── Authentication/   # Auth logic and state management
└── [Other ViewModels integrated in managers]

Core/
├── Managers/ (19 files)    # Business logic and data management
├── ML/                     # Machine learning and AI features
├── Extensions/             # Swift extensions
├── Utilities/              # Helper functions and tools
└── Configuration/          # App settings and constants
```

##  Technical Implementation

### Advanced iOS Features Implemented:
1. **HealthKit Framework**: Complete health data integration
2. **ML Kit & Vision**: AI-powered food and exercise recognition
3. **MapKit & Core Location**: GPS tracking and location services
4. **Local Authentication**: Biometric security implementation
5. **Core Data**: Persistent storage with data modeling
6. **Combine Framework**: Reactive data binding
7. **SwiftUI**: Modern UI development

### Dependencies
- Firebase SDK (Authentication, Analytics)
- HealthKit Framework
- ML Kit Vision APIs
- MapKit & Core Location
- Local Authentication Framework
- Core Data Framework

##  Testing

### Comprehensive Unit Testing (15 test files)
- **AuthenticationManagerTests**: Biometric auth, user management
- **HealthKitManagerTests**: Health data operations
- **MLKitManagerTests**: AI/ML functionality testing
- **MealAnalysisManagerTests**: Food recognition and nutrition
- **75+ individual test methods** with full coverage

### Test Coverage Areas:
- ✅ Authentication flows and biometric integration
- ✅ HealthKit data operations and permissions
- ✅ ML Kit image processing and recognition
- ✅ Meal analysis and nutrition calculations
- ✅ Data persistence and model validation
- ✅ Error handling and edge cases
- ✅ Performance benchmarking

##  Installation & Setup

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Apple Developer Account (for HealthKit and biometric features)

### Installation Steps
1. Clone the repository
   git@github.com:Sewminikangara/FitLifeAdvisorAPP.git
3. Open `FitLifeAdvisorApp.xcodeproj` in Xcode
4. Configure signing certificates and provisioning profiles
5. Add GoogleService-Info.plist for Firebase
6. Build and run on device (required for HealthKit and biometric features)

### Configuration
1. **HealthKit Capabilities**: Enable HealthKit in project capabilities
2. **Biometric Permissions**: Configure Face ID/Touch ID usage descriptions
3. **Location Services**: Add location permission descriptions
4. **Camera Access**: Configure camera usage for meal photo analysis

##  Supported Features by Device

### iPhone Requirements
- **iOS 17.0+**: Core app functionality
- **Face ID/Touch ID**: Biometric authentication
- **Camera**: Meal photo analysis and barcode scanning
- **GPS**: Outdoor activity tracking
- **HealthKit**: iPhone 6s and later

##Configurations
- Enable HealthKit in Capabilities
- Add Face ID / Touch ID usage descriptions
- Add Location usage descriptions
- Add Camera usage descriptions

## Performance Metrics
- **32,359 lines of code** across 160 Swift files
- **Comprehensive unit test coverage** with 75+ test methods
- **Modern SwiftUI architecture** with reactive data binding
- **Professional-grade error handling** and user experience

## Privacy & Security
- **Local data storage**: No sensitive data sent to external servers
- **Biometric security**: Secure local authentication
- **HealthKit privacy**: User-controlled health data permissions
- **Secure networking**: HTTPS-only communications

##  Development Tools & Patterns
- **SwiftUI**: Declarative UI framework
- **MVVM Architecture**: Clean separation of concerns
- **Combine Framework**: Reactive programming
- **XCTest**: Comprehensive unit testing
- **Git Version Control**: Professional development workflow

## Future Development Plans
- **Apple Watch Integration**: Extended health monitoring
- **Social Features**: Community challenges and sharing
- **Advanced AI**: Improved meal recognition accuracy
- **Nutrition Database**: Expanded food database integration
- **Wearable Device Support**: Additional fitness tracker integration

## Developer Information

- **Author**: Sewmini Kangara
- **Student Project**: Advanced iOS Development
- **Architecture**: MVVM with Combine and SwiftUI
- **Testing**: Professional-grade unit testing suite

## License
This project is created for educational purposes as part of an iOS development course.


