# SteinsAlbum

[![CI/CD](https://github.com/RequieMa/SteinsAlbum/actions/workflows/ci.yml/badge.svg)](https://github.com/RequieMa/SteinsAlbum/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/RequieMa/SteinsAlbum/branch/master/graph/badge.svg)](https://codecov.io/gh/RequieMa/SteinsAlbum)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=RequieMa_SteinsAlbum&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=RequieMa_SteinsAlbum)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=RequieMa_SteinsAlbum&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=RequieMa_SteinsAlbum)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=RequieMa_SteinsAlbum&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=RequieMa_SteinsAlbum)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=RequieMa_SteinsAlbum&metric=sqale_index)](https://sonarcloud.io/summary/new_code?id=RequieMa_SteinsAlbum)

A privacy-focused photo album management app that uses CoreML for local inference to categorize photos into scenes, selfies, and more.

## Features

- **Privacy-First Design**: All processing happens locally on your device
- **Smart Categorization**:
  - Scene detection and categorization (nature, urban, indoor, etc.)
  - Selfie detection
  - Content organization (memes, artwork, screenshots, etc.)
- **Location Features**:
  - Map view for geotagged photos
  - Cluster photos by location
- **Review Mode**:
  - Swipe-based photo review
  - Quick delete/keep actions
  - Bulk management options
- **Modern UI**:
  - Material Design 3
  - Dark mode support
  - Smooth animations
  - Responsive layout

## Project Structure

```
SteinsAlbum/
├── lib/
│   ├── main.dart              # App entry point
│   ├── screens/               # App screens
│   │   ├── dashboard_screen.dart
│   │   └── category_view_screen.dart
│   ├── widgets/               # Reusable widgets
│   │   ├── album_stats.dart
│   │   ├── category_grid.dart
│   │   ├── map_view.dart
│   │   └── photo_grid.dart
│   └── models/               # Data models
│       └── ml_inference_model.dart
├── src/
│   ├─── ios/
│       ├── CoreMLModels/     # CoreML model files
│       └── swift/            # Swift bridge code
└── model_conversion/         # Model conversion tools
    ├── convert_model.py
    └── requirements.txt
```

## Setup Instructions

### Prerequisites

- Flutter 3.0 or later
- Xcode 14.0 or later
- iOS 15.0 or later device/simulator
- Python 3.8 or later (for model conversion)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/steins_album.git
cd steins_album
```

2. Install Flutter dependencies:
```bash
flutter pub get
```

3. Install Python dependencies for model conversion:
```bash
cd model_conversion
pip install -r requirements.txt
```

4. Convert ML models:
```bash
python convert_model.py
```

5. Set up iOS permissions:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Verify permissions in Info.plist
   - Set up your development team

6. Run the app:
```bash
flutter run
```

## Usage

### Photo Management
- **Dashboard**: View photo stats and categories
- **Categories**: Browse photos by type (scenes, selfies, etc.)
- **Map View**: See photos on a global map
- **Review Mode**: Swipe left to delete, right to keep

### Adding Photos
- Use the + button to add new photos
- Grant necessary permissions when prompted
- Photos are automatically categorized

### Location Features
- Enable location permissions for map features
- Photos with GPS data are shown on the map
- Filter map markers by category

## Performance Optimization

- Lazy loading for large photo libraries
- Efficient caching of thumbnails
- Optimized CoreML models for mobile
- Background processing for categorization

## Privacy Features

- No cloud uploads
- Local ML inference
- Secure photo access
- No tracking or analytics

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see LICENSE file for details

## Acknowledgments

- CoreML for ML inference
- Flutter for the UI framework
- Google Maps for location features
- Photo Manager for photo access 