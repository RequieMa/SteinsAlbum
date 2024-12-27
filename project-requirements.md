# Project Requirements

## Hardware & Software Requirements
1. **iOS Device** (or Simulator) for testing and deployment.
2. **Flutter**: To develop a cross-platform app (though initial focus on iOS).
3. **CoreML**: For integrating machine learning models into the iOS app.
4. **PyTorch**: For training machine learning models, which will be converted to CoreML.
5. **Python**: To handle model training and conversion processes.
6. **macOS**: For building and deploying iOS apps.

## Libraries and Tools
1. **CoreMLTools**: To convert PyTorch models to CoreML.
   - Install via: `pip install coremltools`
2. **ONNX**: Intermediate format for model conversion.
   - Install via: `pip install onnx`
3. **Flutter**: For mobile app development.
   - Install via: `flutter.dev`
6. **flutter_coreml**: Flutter plugin for CoreML integration on iOS.

## Model Types
- **Scene Categorization**: Model to classify photos into scene types (e.g., nature, urban, indoor).
- **Selfie Detection**: Model to detect selfies vs non-selfies.
- **Content Filtering**: Model to identify memes, 18+ content, etc.
- **Geolocation**: Use GPS data to place photos on a global map (using **Google Maps API** or **Apple Maps**).

## Privacy and Security
1. **Local Inference**: All data processing happens locally on the iOS device.
2. **Data Encryption**: Ensure that no personal data (photos) are sent to the cloud.

## Performance
1. **Model Optimization**: Use techniques like **quantization** to reduce model size and improve inference speed on mobile devices.
2. **Asynchronous Processing**: Ensure that image classification and categorization run in the background, allowing users to interact with the app without delays.
