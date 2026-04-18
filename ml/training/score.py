import json
import os
import joblib
import numpy as np
from activity_labels import ACTIVITY_LABELS, WORKOUT_RECOMMENDATIONS
def init():
    global model, scaler
    model_dir = os.getenv("AZUREML_MODEL_DIR", ".")
    model = joblib.load(os.path.join(model_dir, "model.joblib"))
    scaler = joblib.load(os.path.join(model_dir, "scaler.joblib"))
    print("Model loaded successfully.")
def run(raw_data: str) -> str:
    try:
        data = json.loads(raw_data)
        sensor_data = data.get("sensor_data")
        if sensor_data is not None:
            features = np.array(sensor_data).reshape(1, -1)
            features_scaled = scaler.transform(features)
            prediction = model.predict(features_scaled)[0]
            probabilities = model.predict_proba(features_scaled)[0]
            confidence = float(np.max(probabilities))
            activity_id = int(prediction)
        else:
            goal = data.get("goal", "general_fitness")
            goal_map = {
                "weight_loss": 12, "muscle_gain": 17, "flexibility": 3,
                "endurance": 14, "general_fitness": 9
            }
            activity_id = goal_map.get(goal, 9)
            confidence = 0.85
        activity_name = ACTIVITY_LABELS.get(activity_id, f"Activity {activity_id}")
        workout = WORKOUT_RECOMMENDATIONS.get(activity_id, {})
        result = {
            "RecognizedActivity": activity_name,
            "Recommendation": workout.get("recommendation", "Try a balanced workout!"),
            "Confidence": round(confidence, 4),
            "SuggestedExercises": workout.get("exercises", ["Walking", "Stretching"]),
            "EstimatedDurationMinutes": workout.get("duration_min", 30),
            "IntensityLevel": workout.get("intensity", "Medium"),
        }
        return json.dumps(result)
    except Exception as e:
        return json.dumps({"error": str(e)})