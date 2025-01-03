import Flutter
import UIKit
import CoreML
import Vision

@objc public class MLModelBridge: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "steins_album/ml_inference",
            binaryMessenger: registrar.messenger()
        )
        let instance = MLModelBridge()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "classifyImage":
            if let args = call.arguments as? [String: Any],
               let imagePath = args["imagePath"] as? String,
               let modelType = args["modelType"] as? String {
                classifyImage(imagePath: imagePath, modelType: modelType, result: result)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Invalid arguments for image classification",
                    details: nil
                ))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func classifyImage(imagePath: String, modelType: String, result: @escaping FlutterResult) {
        guard let image = UIImage(contentsOfFile: imagePath)?.cgImage else {
            result(FlutterError(
                code: "INVALID_IMAGE",
                message: "Could not load image from path",
                details: nil
            ))
            return
        }
        
        // Select appropriate model based on type
        let modelURL: URL
        switch modelType {
        case "scene":
            modelURL = Bundle.main.url(forResource: "scene_classifier", withExtension: "mlmodelc")!
        case "selfie":
            modelURL = Bundle.main.url(forResource: "selfie_classifier", withExtension: "mlmodelc")!
        case "content":
            modelURL = Bundle.main.url(forResource: "content_filter", withExtension: "mlmodelc")!
        default:
            result(FlutterError(
                code: "INVALID_MODEL",
                message: "Invalid model type specified",
                details: nil
            ))
            return
        }
        
        do {
            // Create ML model configuration
            let config = MLModelConfiguration()
            config.computeUnits = .all
            
            // Create Vision request
            let model = try MLModel(contentsOf: modelURL, configuration: config)
            let vnModel = try VNCoreMLModel(for: model)
            let request = VNCoreMLRequest(model: vnModel) { request, error in
                if let error = error {
                    result(FlutterError(
                        code: "INFERENCE_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                    return
                }
                
                guard let observations = request.results as? [VNClassificationObservation],
                      let topResult = observations.first else {
                    result(FlutterError(
                        code: "NO_RESULTS",
                        message: "No classification results",
                        details: nil
                    ))
                    return
                }
                
                // Return results
                let response: [String: Any] = [
                    "label": topResult.identifier,
                    "confidence": topResult.confidence
                ]
                result(response)
            }
            
            // Perform inference
            let handler = VNImageRequestHandler(cgImage: image)
            try handler.perform([request])
        } catch {
            result(FlutterError(
                code: "MODEL_ERROR",
                message: error.localizedDescription,
                details: nil
            ))
        }
    }
} 