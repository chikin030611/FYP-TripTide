# TripTide Client App

TripTide is a travel planning iOS application built with SwiftUI. This client app integrates with a backend server and utilizes Google Maps APIs for location-based features.

## 🚀 Features

- User-friendly interface with BottomBar navigation
- Secure token storage using Keychain
- Interactive maps and place suggestions powered by Google Maps
- Support for development, staging, and release environments

## 📋 Prerequisites

Before setting up the client app, make sure you have the following:

- macOS with **Xcode 13.0** or later
- Device or simulator running **iOS 15.0** or later
- **Swift 5.5** or later
- A valid **Google Maps API key**  
  ↳ [Places API Overview](https://developers.google.com/maps/documentation/places/web-service/overview)  
  ↳ [Cloud Project Setup](https://developers.google.com/maps/documentation/elevation/cloud-setup)

## 🔧 Project Setup

### 1. Install Dependencies

Dependencies should be resolved automatically by Xcode. If not:

1. Open the project in Xcode
2. Navigate to `File` → `Add Package Dependencies…`
3. Add the following packages:

- [`BottomBar-SwiftUI`](https://github.com/smartvipere75/bottombar-swiftui)
- [`JWTDecode.swift`](https://github.com/auth0/JWTDecode.swift.git)
- [`KeychainSwift`](https://github.com/evgenyneu/keychain-swift)
- [`Inject`](https://github.com/krzysztofzablocki/Inject.git)

### 2. Environment Configuration

Create three configuration files under the `Configurations` directory:

- `DEBUG.xcconfig` (development)
- `STAGING.xcconfig` (staging)
- `RELEASE.xcconfig` (release)

Each file should include:

```plaintext
BASE_URL = http:/$()/localhost:8080/api
GOOGLE_MAPS_API_KEY = YOUR_API_KEY
```
Replace YOUR_API_KEY with your actual Google Maps API key
Ensure the BASE_URL points to your backend (including /api) with special formatting using $() to escape

## ▶️ Running the App
1. Select the appropriate scheme (e.g., Debug, Staging, Release)
2. Choose your target device or simulator
3. Hit the Run button in Xcode
