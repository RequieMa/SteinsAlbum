import Flutter
import UIKit

@UIApplicationMain
@available(iOS 15.0, *)
class AppDelegate: FlutterAppDelegate {
  private var mlHandler: MLHandler?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(
      name: "com.steinsalbum.ml",
      binaryMessenger: controller.binaryMessenger
    )
    
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      
      switch call.method {
      case "classifyImage":
        guard let args = call.arguments as? [String: Any],
              let imagePath = args["imagePath"] as? String,
              let modelType = args["modelType"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
          return
        }
        
        do {
          if mlHandler == nil {
            mlHandler = try MLHandler()
          }
          
          guard let image = UIImage(contentsOfFile: imagePath)?.cgImage else {
            throw NSError(domain: "MLHandler", code: -3, userInfo: nil)
          }
          
          let classification = try mlHandler?.classify(image, modelType: modelType)
          result(classification)
        } catch {
          result(FlutterError(code: "ML_ERROR", message: error.localizedDescription, details: nil))
        }
        
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
