import torch
import torch.nn as nn
import timm
from torch.hub import load_state_dict_from_url
import os
from pathlib import Path

MODELS_DIR = Path(__file__).parent / "models"

def download_scene_model():
    """Downloads MobileViT-XXS pretrained on Places365"""
    save_dir = MODELS_DIR / "scene"
    save_dir.mkdir(parents=True, exist_ok=True)
    
    # Download from timm
    model = timm.create_model('mobilevitv2_050.cvnets_in1k', pretrained=True)
    
    # Modify final layer for Places365
    model.head.fc = nn.Linear(model.head.fc.in_features, 365)
    
    # Download Places365 weights
    state_dict = load_state_dict_from_url(
        'https://dl.fbaipublicfiles.com/mobilevit/places365/mobilevitv2_050_places365.pth',
        map_location='cpu'
    )
    model.load_state_dict(state_dict)
    
    torch.save(model.state_dict(), save_dir / "mobilevit_places365.pth")
    print("Scene model downloaded successfully")

def download_selfie_model():
    """Downloads BlazeFace model"""
    save_dir = MODELS_DIR / "selfie"
    save_dir.mkdir(parents=True, exist_ok=True)
    
    # Download from MediaPipe's GitHub
    url = "https://github.com/google/mediapipe/raw/master/mediapipe/modules/face_detection/face_detection_short_range.tflite"
    
    import urllib.request
    urllib.request.urlretrieve(url, save_dir / "blazeface.tflite")
    print("Selfie model downloaded successfully")

def download_content_model():
    """Downloads MobileNetV3-Small pretrained model"""
    save_dir = MODELS_DIR / "content"
    save_dir.mkdir(parents=True, exist_ok=True)
    
    model = torch.hub.load('pytorch/vision:v0.10.0', 'mobilenet_v3_small', pretrained=True)
    torch.save(model.state_dict(), save_dir / "mobilenetv3_small.pth")
    print("Content model downloaded successfully")

if __name__ == "__main__":
    download_scene_model()
    download_selfie_model()
    download_content_model() 