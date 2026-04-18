import json
import sys
from pathlib import Path
import joblib
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
sys.path.insert(0, str(Path(__file__).parent.parent / "training"))
from activity_labels import ACTIVITY_LABELS, WORKOUT_RECOMMENDATIONS
MODEL_DIR = Path(__file__).parent / "model"
app = FastAPI(
    title="Workout Planner ML API",
    description="Activity recognition and workout recommendation service",
    version="1.0.0",
)
model = None
scaler = None
metadata = None
class PredictionRequest(BaseModel):
    age: int = Field(default=25, ge=10, le=100, description="User age")
    weight: float = Field(default=70.0, ge=30, le=300, description="Weight in kg")
    height: float = Field(default=175.0, ge=100, le=250, description="Height in cm")
    goal: str = Field(default="general_fitness", description="Fitness goal")
    fitness_level: str = Field(default="intermediate", description="Current fitness level")
    sensor_data: list[float] | None = Field(
        default=None,
        description="Raw sensor features (270 values). If None, returns demo recommendation."
    )
class PredictionResponse(BaseModel):
    recognized_activity: str = Field(alias="RecognizedActivity")
    recommendation: str = Field(alias="Recommendation")
    confidence: float = Field(alias="Confidence")
    suggested_exercises: list[str] = Field(alias="SuggestedExercises")
    estimated_duration_minutes: int = Field(alias="EstimatedDurationMinutes")
    intensity_level: str = Field(alias="IntensityLevel")
    class Config:
        populate_by_name = True
@app.on_event("startup")
async def load_model():
    global model, scaler, metadata
    model_path = MODEL_DIR / "model.joblib"
    scaler_path = MODEL_DIR / "scaler.joblib"
    metadata_path = MODEL_DIR / "metadata.json"
    if model_path.exists() and scaler_path.exists():
        model = joblib.load(model_path)
        scaler = joblib.load(scaler_path)
        print(f"Model loaded from {MODEL_DIR}")
    else:
        print(f"WARNING: Model files not found in {MODEL_DIR}. Running in demo mode.")
    if metadata_path.exists():
        with open(metadata_path) as f:
            metadata = json.load(f)
@app.get("/health")
async def health():
    return {
        "status": "healthy",
        "model_loaded": model is not None,
        "service": "workout-planner-ml",
    }
@app.get("/model-info")
async def model_info():
    if metadata is None:
        return {"status": "no model loaded", "mode": "demo"}
    return metadata
@app.post("/predict")
async def predict(request: PredictionRequest):
    if request.sensor_data is not None and model is not None and scaler is not None:
        expected_features = metadata.get("n_features", 270) if metadata else 270
        if len(request.sensor_data) != expected_features:
            raise HTTPException(
                status_code=400,
                detail=f"Expected {expected_features} sensor features, got {len(request.sensor_data)}"
            )
        features = np.array(request.sensor_data).reshape(1, -1)
        features_scaled = scaler.transform(features)
        prediction = model.predict(features_scaled)[0]
        probabilities = model.predict_proba(features_scaled)[0]
        confidence = float(np.max(probabilities))
        activity_id = int(prediction)
    else:
        goal_activity_map = {
            "weight_loss": 12,      
            "muscle_gain": 17,      
            "flexibility": 3,       
            "endurance": 14,        
            "general_fitness": 9,   
        }
        activity_id = goal_activity_map.get(request.goal, 9)
        confidence = 0.85
    activity_name = ACTIVITY_LABELS.get(activity_id, f"Activity {activity_id}")
    workout = WORKOUT_RECOMMENDATIONS.get(activity_id, {})
    return {
        "RecognizedActivity": activity_name,
        "Recommendation": workout.get("recommendation", "Try a balanced workout!"),
        "Confidence": round(confidence, 4),
        "SuggestedExercises": workout.get("exercises", ["Walking", "Stretching"]),
        "EstimatedDurationMinutes": workout.get("duration_min", 30),
        "IntensityLevel": workout.get("intensity", "Medium"),
    }