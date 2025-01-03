import torch
import torch.nn as nn
import coremltools as ct
import onnx
import platform
from typing import Tuple, Optional

def get_torch_version():
    """Returns True if using torch 2.0 or later"""
    return int(torch.__version__.split('.')[0]) >= 2

def preprocess_image(image_size: Tuple[int, int] = (224, 224)):
    """Returns preprocessing pipeline for the model."""
    return torch.nn.Sequential(
        torch.nn.Resize(image_size),
        torch.nn.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    )

def convert_pytorch_to_coreml(
    model: nn.Module,
    input_shape: Tuple[int, ...],
    model_name: str,
    onnx_path: Optional[str] = None,
    coreml_path: Optional[str] = None
) -> None:
    """
    Convert PyTorch model to CoreML format via ONNX.
    
    Args:
        model: PyTorch model
        input_shape: Input shape (N,C,H,W)
        model_name: Name of the model
        onnx_path: Path to save ONNX model
        coreml_path: Path to save CoreML model
    """
    # Set model to evaluation mode
    model.eval()
    
    # Generate dummy input
    dummy_input = torch.randn(input_shape)
    
    # Export to ONNX with version-specific settings
    export_kwargs = {
        "input_names": ["input"],
        "output_names": ["output"],
        "dynamic_axes": {
            "input": {0: "batch_size"},
            "output": {0: "batch_size"}
        }
    }
    
    if get_torch_version():
        export_kwargs["export_params"] = True
    
    onnx_path = onnx_path or f"{model_name}.onnx"
    torch.onnx.export(model, dummy_input, onnx_path, **export_kwargs)
    
    # Load and verify ONNX model
    onnx_model = onnx.load(onnx_path)
    onnx.checker.check_model(onnx_model)
    
    # Convert to CoreML
    coreml_path = coreml_path or f"{model_name}.mlmodel"
    model = ct.converters.onnx.convert(
        model=onnx_path,
        minimum_deployment_target=ct.target.iOS15,
        convert_to="mlprogram",
        compute_units=ct.ComputeUnit.CPU_AND_NE
    )
    
    # Add metadata
    model.author = "SteinsAlbum"
    model.license = "MIT"
    model.short_description = f"Image classification model for {model_name}"
    
    # Save the CoreML model
    model.save(coreml_path)
    print(f"Successfully converted {model_name} to CoreML format at {coreml_path}")

if __name__ == "__main__":
    # Example usage for scene classification model
    # Note: Replace this with your actual model
    class DummyModel(nn.Module):
        def __init__(self):
            super().__init__()
            self.conv = nn.Conv2d(3, 64, 3)
            self.pool = nn.AdaptiveAvgPool2d((1, 1))
            self.fc = nn.Linear(64, 10)  # 10 scene categories
            
        def forward(self, x):
            x = self.conv(x)
            x = self.pool(x)
            x = torch.flatten(x, 1)
            return self.fc(x)
    
    # Convert scene classification model
    model = DummyModel()
    convert_pytorch_to_coreml(
        model=model,
        input_shape=(1, 3, 224, 224),
        model_name="scene_classifier",
        onnx_path="model_conversion/scene_classifier.onnx",
        coreml_path="src/ios/CoreMLModels/scene_classifier.mlmodel"
    ) 