# Project Architecture

## High-Level Overview
The architecture follows a **Model-View-Presenter (MVP)** pattern:
- **Model**: CoreML models for image categorization and other machine learning tasks.
- **View**: The Flutter frontend, responsible for presenting the UI and receiving user input.
- **Presenter**: Handles the logic between the Model and View, including invoking machine learning models and updating the UI accordingly.

### **Core Components**
1. **CoreML Model**: Responsible for running image classification, scene categorization, and selfie detection locally on the iOS device.
2. **Flutter Frontend**: The user interface, built with Flutter, will display categorized images, provide options for image deletion, and offer interactive views such as maps for scene categorization.
3. **Native iOS Code**: Swift code will handle CoreML model loading and inference. This will be integrated with Flutter through platform channels.

### **Model Integration Flow**
1. **Image Capture/Selection**: User selects an image from the gallery.
2. **Preprocessing**: Image is preprocessed (e.g., resizing, normalization) before feeding it into the CoreML model.
3. **Inference**: The preprocessed image is passed to CoreML for classification (e.g., Scene classification, Selfie detection).
4. **Results**: The app displays the category (e.g., Nature, Selfie) and any additional information (e.g., GPS location on a global map).
5. **Postprocessing**: The results are displayed on the frontend, allowing the user to categorize, delete, or move the photo.

### **Architecture Flow**
[Flutter Frontend] <---> [Swift Code (Platform Channel)] <---> [CoreML Model (Inference)]

### **File Structure**
/src /ios /CoreMLModels - model.mlmodel # CoreML Model files /swift - inference.swift # Swift code to handle inference /lib /screens - home_screen.dart # Main UI screen - image_category_screen.dart # Category-specific UI /models - image_model.dart # Flutter model to handle results /utils - image_preprocessing.dart # Image preprocessing logic