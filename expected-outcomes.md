# Expected Outcomes

## 1. iOS App with CoreML Integration
- **Photo Categorization**: The app should categorize photos into predefined categories such as "Scenes," "Selfies," and "Memes," with high accuracy.
- **Selfie Detection**: It should correctly classify selfies vs. non-selfies using a trained model (e.g., BlazeFace).
- **Global Map**: Photos categorized as "Scenes" should be displayed on a global map using GPS metadata, showing the locations where they were taken.
- **Content Filtering**: The app should be able to filter photos that fall under certain categories like 18+, memes, etc.

## 2. Model Performance
- The model should be optimized for **low latency** and **efficient performance** on mobile hardware (iPhone).
- **Inference Time**: Inference should occur in less than 2-3 seconds per image
