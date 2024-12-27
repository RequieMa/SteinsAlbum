# Project Instructions

## Purpose
The goal of this project is to develop a photo album management app for iOS using Flutter and CoreML for local inference. The app should help users categorize and manage their photo albums, providing functionalities such as:
- Grouping photos into categories (e.g., Scenes, Selfies, Memes, 18+).
- Organizing scenes on a global map using geolocation.
- Categorizing photos into selfies vs. non-selfies.
- Providing an intuitive and privacy-focused UI for photo management.

## Requirements
1. **CoreML Integration**: The app will use **CoreML** for running inference locally on the iOS device.
2. **Model Conversion**: Use **PyTorch** to train models and convert them to **ONNX**, and finally to **CoreML** using `coremltools`.
3. **Flutter**: Use Flutter for cross-platform development. Focus on building for iOS first.
4. **Privacy**: All inference and processing must occur locally, without uploading images to the cloud.
5. **Performance**: Optimize models for mobile using quantization and other techniques.
6. **Categorization Models**: Develop or utilize pretrained models for:
   - Scene categorization.
   - Selfie vs. non-selfie classification.
   - Content filtering (e.g., 18+ detection, meme classification).
7. **User Interface**: The app should provide a smooth, intuitive user experience, with easy navigation, quick categorization, and management of photos.

## Workflow
- **Step 1**: Pretrain models for photo categorization (using PyTorch).
- **Step 2**: Convert models to **ONNX** and then to **CoreML** for iOS compatibility.
- **Step 3**: Integrate the CoreML model into the Flutter app using a native Swift bridge.
- **Step 4**: Optimize the app for performance, ensure a clean UI/UX, and validate privacy-first design principles.

## Expected Outcomes
- **Functional iOS app** with a Flutter frontend.
- **Local image classification** via CoreML for all inference tasks.
- **Seamless user experience** for categorizing, tagging, and reviewing photos.
- **App performance** optimized for mobile devices.

## Notes
- Privacy and performance are top priorities.
- All models should be optimized for inference on mobile hardware.
