import json
import time
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.metrics import accuracy_score
from activity_labels import ACTIVITY_LABELS
DATA_DIR = Path(__file__).parent / "data" / "processed"
MODEL_DIR = Path(__file__).parent / "models"
def load_data():
    train_df = pd.read_csv(DATA_DIR / "train.csv")
    test_df = pd.read_csv(DATA_DIR / "test.csv")
    X_train = train_df.drop(columns=["activity"])
    y_train = train_df["activity"]
    X_test = test_df.drop(columns=["activity"])
    y_test = test_df["activity"]
    return X_train, y_train, X_test, y_test
def train_model(X_train, y_train):
    print("Scaling features...")
    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    print("Training Random Forest classifier...")
    model = RandomForestClassifier(
        n_estimators=200,
        max_depth=30,
        min_samples_split=5,
        min_samples_leaf=2,
        max_features="sqrt",
        random_state=42,
        n_jobs=-1,
        verbose=1,
    )
    start_time = time.time()
    model.fit(X_train_scaled, y_train)
    training_time = time.time() - start_time
    print(f"Training completed in {training_time:.1f} seconds.")
    return model, scaler, training_time
def evaluate_quick(model, scaler, X_train, y_train, X_test, y_test):
    X_train_scaled = scaler.transform(X_train)
    X_test_scaled = scaler.transform(X_test)
    train_acc = accuracy_score(y_train, model.predict(X_train_scaled))
    test_acc = accuracy_score(y_test, model.predict(X_test_scaled))
    print(f"Train accuracy: {train_acc:.4f}")
    print(f"Test accuracy:  {test_acc:.4f}")
    return train_acc, test_acc
def save_model(model, scaler, feature_names, training_time, train_acc, test_acc):
    MODEL_DIR.mkdir(parents=True, exist_ok=True)
    joblib.dump(model, MODEL_DIR / "model.joblib")
    joblib.dump(scaler, MODEL_DIR / "scaler.joblib")
    metadata = {
        "model_type": "RandomForestClassifier",
        "n_estimators": model.n_estimators,
        "max_depth": model.max_depth,
        "n_features": len(feature_names),
        "n_classes": len(ACTIVITY_LABELS),
        "feature_names": feature_names,
        "activity_labels": {str(k): v for k, v in ACTIVITY_LABELS.items()},
        "training_time_seconds": round(training_time, 1),
        "train_accuracy": round(train_acc, 4),
        "test_accuracy": round(test_acc, 4),
    }
    with open(MODEL_DIR / "metadata.json", "w") as f:
        json.dump(metadata, f, indent=2)
    print(f"\nModel saved to {MODEL_DIR}")
    print(f"Files: model.joblib, scaler.joblib, metadata.json")
def main():
    print("=" * 60)
    print("Daily and Sports Activities — Model Training")
    print("=" * 60)
    X_train, y_train, X_test, y_test = load_data()
    print(f"Train: {X_train.shape}, Test: {X_test.shape}")
    model, scaler, training_time = train_model(X_train, y_train)
    train_acc, test_acc = evaluate_quick(model, scaler, X_train, y_train, X_test, y_test)
    importances = model.feature_importances_
    feature_names = list(X_train.columns)
    top_indices = np.argsort(importances)[-10:][::-1]
    print("\nTop 10 important features:")
    for idx in top_indices:
        print(f"  {feature_names[idx]}: {importances[idx]:.4f}")
    save_model(model, scaler, feature_names, training_time, train_acc, test_acc)
    print("\nTraining complete!")
if __name__ == "__main__":
    main()