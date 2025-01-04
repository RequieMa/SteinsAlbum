import torch
import torch.nn as nn
import coremltools as ct
from typing import Tuple, Optional, List
import os

def convert_pytorch_to_coreml(
    model: nn.Module,
    input_shape: Tuple[int, ...],
    model_name: str,
    class_labels: List[str],
    coreml_path: Optional[str] = None
) -> None:
    """
    Convert PyTorch model directly to CoreML format.
    
    Args:
        model: PyTorch model
        input_shape: Input shape (N,C,H,W)
        model_name: Name of the model
        class_labels: List of class labels
        coreml_path: Path to save CoreML model
    """
    # Set model to evaluation mode
    model.eval()
    
    # Trace the model with example input
    example_input = torch.rand(*input_shape)
    traced_model = torch.jit.trace(model, example_input)
    
    # Convert to CoreML
    coreml_path = coreml_path or f"{model_name}.mlmodel"
    
    # Define input image format
    image_input = ct.ImageType(
        name="input",
        shape=input_shape,
        color_layout="RGB",
        scale=1.0 / 255.0,  # Normalize to [0,1]
        bias=[-0.485/0.229, -0.456/0.224, -0.406/0.225]  # ImageNet normalization
    )
    
    # Convert the model
    model = ct.convert(
        traced_model,
        inputs=[image_input],
        classifier_config=ct.ClassifierConfig(class_labels),
        minimum_deployment_target=ct.target.iOS15,
        convert_to="mlprogram",
        compute_units=ct.ComputeUnit.CPU_AND_NE
    )
    
    # Add metadata
    model.author = "SteinsAlbum"
    model.license = "MIT"
    model.short_description = f"Image classification model for {model_name}"
    model.version = "1.0"
    
    # Save the CoreML model
    model.save(coreml_path)
    print(f"Successfully converted {model_name} to CoreML format at {coreml_path}")

def convert_scene_model():
    """Convert MobileViT Places365 model"""
    import timm
    
    model = timm.create_model('mobilevitv2_050.cvnets_in1k', pretrained=False)
    model.head.fc = nn.Linear(model.head.fc.in_features, 365)
    
    state_dict = torch.load("models/scene/mobilevit_places365.pth")
    model.load_state_dict(state_dict)
    
    # Load Places365 labels
    with open("models/scene/places365_labels.txt") as f:
        labels = [line.strip() for line in f.readlines()]
    
    convert_pytorch_to_coreml(
        model=model,
        input_shape=(1, 3, 224, 224),
        model_name="scene_classifier",
        class_labels=labels,
        coreml_path="../ios/Runner/CoreMLModels/scene_classifier.mlmodel"
    )

def convert_selfie_model():
    """Convert BlazeFace model"""
    # Note: This requires additional TFLite to CoreML conversion
    import coremltools as ct
    
    model = ct.convert(
        "models/selfie/blazeface.tflite",
        source="tensorflow_lite",
        minimum_deployment_target=ct.target.iOS15
    )
    model.save("../ios/Runner/CoreMLModels/selfie_detector.mlmodel")

def convert_content_model():
    """Convert MobileNetV3-Small model"""
    model = torch.hub.load('pytorch/vision:v0.10.0', 'mobilenet_v3_small', pretrained=False)
    state_dict = torch.load("models/content/mobilenetv3_small.pth")
    model.load_state_dict(state_dict)
    
    # Custom labels for content classification
    labels = ["meme", "screenshot", "artwork", "other"]
    
    convert_pytorch_to_coreml(
        model=model,
        input_shape=(1, 3, 224, 224),
        model_name="content_classifier",
        class_labels=labels,
        coreml_path="../ios/Runner/CoreMLModels/content_classifier.mlmodel"
    )

if __name__ == "__main__":
    # Create output directory
    os.makedirs("../ios/Runner/CoreMLModels", exist_ok=True)
    
    convert_scene_model()
    convert_selfie_model()
    convert_content_model() 