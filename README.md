# SteinsAlbum

[![CI/CD](https://github.com/RequieMa/SteinsAlbum/actions/workflows/ci.yml/badge.svg)](https://github.com/RequieMa/SteinsAlbum/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/RequieMa/SteinsAlbum/branch/master/graph/badge.svg)](https://codecov.io/gh/RequieMa/SteinsAlbum)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=RequieMa_SteinsAlbum&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=RequieMa_SteinsAlbum)

A privacy-focused photo album management app that uses CoreML for local inference to categorize photos.

## Project Structure

```
.
├── README.md
└── steins_album/          # Main Flutter project directory
    ├── lib/               # Flutter source code
    │   ├── models/        # Data models
    │   ├── screens/       # App screens
    │   ├── services/      # Business logic
    │   └── widgets/       # Reusable widgets
    ├── ios/               # iOS specific code
    │   └── Runner/
    ├── src/
    │   └── ios/
    │       ├── CoreMLModels/  # ML model files
    │       └── swift/         # Swift bridge code
    ├── model_conversion/  # ML model conversion tools
    └── test/             # Unit and widget tests
```

## Prerequisites

- Flutter 3.0 or later
- Xcode 14.0 or later (for iOS)
- iOS 15.0 or later device/simulator
- Python 3.8-3.11 (for ML model conversion)
- CocoaPods (for iOS)

## Build Instructions

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/steins_album.git
cd steins_album
```

2. **Install Flutter dependencies**
```bash
cd steins_album
flutter pub get
```

3. **Set up ML models**

First install Python dependencies:
```bash
cd model_conversion

# First install setuptools
pip3 install --upgrade pip setuptools wheel

# First install base requirements
pip3 install -r requirements.txt

# If you're on MacOS with Intel processor:
pip3 install torch==1.13.1 torchvision==0.14.1

# If you're on MacOS with M1/M2:
pip3 install torch==2.0.0 torchvision==0.15.0

# If you're on Windows/Linux without NVIDIA GPU:
pip3 install torch==2.0.0+cpu torchvision==0.15.0+cpu -f https://download.pytorch.org/whl/torch_stable.html

# If you have NVIDIA GPU:
pip3 install torch==2.0.0+cu118 torchvision==0.15.0+cu118 -f https://download.pytorch.org/whl/torch_stable.html

python convert_model.py
cd ..
```

4. **iOS Setup**

First, install CocoaPods:
```bash
# Remove any existing CocoaPods installation
sudo gem uninstall cocoapods
sudo gem uninstall ffi
sudo gem uninstall ethon
sudo gem uninstall typhoeus

# Clean gem cache
sudo gem clean

# Install specific version of ffi for Intel Mac
sudo gem install ffi -v 1.15.5 --platform x86_64-darwin

# Install specific version of CocoaPods for Intel Mac
sudo gem install cocoapods -v 1.12.1 --platform x86_64-darwin

# If you encounter CDN issues, run:
pod repo remove trunk
pod setup
```

Then install pod dependencies:
```bash
cd ios
pod install
# If pod install fails, try:
pod install --verbose --no-repo-update
cd ..
```

Open Xcode workspace:
```bash
open ios/Runner.xcworkspace
```

In Xcode:
- Select your development team
- Set Bundle Identifier
- Verify build settings
- Ensure CoreML models are included in the target

5. **Run the app**
```bash
flutter run
```

## Development

### Running Tests
```bash
flutter test
```

### Generate Coverage Report
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Code Style
```bash
flutter analyze
dart format .
```

## Troubleshooting

### Common Issues

1. **ML Model Conversion Fails**
   - Verify Python environment
   - Check model_conversion/requirements.txt versions
   - Ensure source models exist

2. **iOS Build Fails**
   - Clean build:
     ```bash
     flutter clean
     cd ios && pod install && cd ..
     ```
   - Verify CoreML models are in correct location
   - Check Xcode signing settings

3. **Runtime Errors**
   - Check iOS permissions in Info.plist
   - Verify photo library access
   - Check ML model paths

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License - see LICENSE file

## Support

- File issues on GitHub
- Check documentation in /docs
- Join discussions in Discussions tab 