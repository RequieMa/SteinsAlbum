import CoreML
import Vision

@available(iOS 15.0, *)
class MLHandler: NSObject {
    private let sceneModel: VNCoreMLModel
    private let selfieModel: VNCoreMLModel
    private let contentModel: VNCoreMLModel
    
    override init() throws {
        // Load compiled Core ML models
        sceneModel = try VNCoreMLModel(for: SceneClassifier().model)
        selfieModel = try VNCoreMLModel(for: SelfieDetector().model)
        contentModel = try VNCoreMLModel(for: ContentClassifier().model)
        super.init()
    }
    
    func classify(_ image: CGImage, modelType: String) throws -> [String: Any] {
        let request: VNCoreMLRequest
        
        switch modelType {
        case "ModelType.scene":
            request = VNCoreMLRequest(model: sceneModel)
        case "ModelType.selfie":
            request = VNCoreMLRequest(model: selfieModel)
        case "ModelType.content":
            request = VNCoreMLRequest(model: contentModel)
        default:
            throw NSError(domain: "MLHandler", code: -1, userInfo: nil)
        }
        
        let handler = VNImageRequestHandler(cgImage: image)
        try handler.perform([request])
        
        guard let results = request.results as? [VNClassificationObservation],
              let topResult = results.first else {
            throw NSError(domain: "MLHandler", code: -2, userInfo: nil)
        }
        
        return [
            "label": topResult.identifier,
            "confidence": topResult.confidence
        ]
    }
} 