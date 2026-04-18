import json
from pathlib import Path
import joblib
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")  
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import (
    accuracy_score,
    precision_score,
    recall_score,
    f1_score,
    classification_report,
    confusion_matrix,
)
from activity_labels import ACTIVITY_LABELS
DATA_DIR = Path(__file__).parent / "data" / "processed"
MODEL_DIR = Path(__file__).parent / "models"
OUTPUT_DIR = Path(__file__).parent / "outputs"
def load_model_and_data():
    model = joblib.load(MODEL_DIR / "model.joblib")
    scaler = joblib.load(MODEL_DIR / "scaler.joblib")
    test_df = pd.read_csv(DATA_DIR / "test.csv")
    X_test = test_df.drop(columns=["activity"])
    y_test = test_df["activity"]
    return model, scaler, X_test, y_test
def compute_metrics(y_true, y_pred):
    metrics = {
        "accuracy": round(accuracy_score(y_true, y_pred), 4),
        "precision_macro": round(precision_score(y_true, y_pred, average="macro"), 4),
        "precision_weighted": round(precision_score(y_true, y_pred, average="weighted"), 4),
        "recall_macro": round(recall_score(y_true, y_pred, average="macro"), 4),
        "recall_weighted": round(recall_score(y_true, y_pred, average="weighted"), 4),
        "f1_macro": round(f1_score(y_true, y_pred, average="macro"), 4),
        "f1_weighted": round(f1_score(y_true, y_pred, average="weighted"), 4),
    }
    return metrics
def plot_confusion_matrix(y_true, y_pred, output_path: Path):
    labels = sorted(y_true.unique())
    label_names = [ACTIVITY_LABELS.get(l, f"Activity {l}") for l in labels]
    cm = confusion_matrix(y_true, y_pred, labels=labels)
    cm_normalized = cm.astype("float") / cm.sum(axis=1)[:, np.newaxis]
    fig, ax = plt.subplots(figsize=(16, 14))
    sns.heatmap(
        cm_normalized,
        annot=True,
        fmt=".2f",
        cmap="Blues",
        xticklabels=label_names,
        yticklabels=label_names,
        ax=ax,
        linewidths=0.5,
        vmin=0,
        vmax=1,
    )
    ax.set_xlabel("Predicted Activity", fontsize=12)
    ax.set_ylabel("True Activity", fontsize=12)
    ax.set_title("Normalized Confusion Matrix — Activity Recognition", fontsize=14)
    plt.xticks(rotation=45, ha="right", fontsize=8)
    plt.yticks(rotation=0, fontsize=8)
    plt.tight_layout()
    plt.savefig(output_path, dpi=150, bbox_inches="tight")
    plt.close()
    print(f"Confusion matrix saved to {output_path}")
def main():
    print("=" * 60)
    print("Daily and Sports Activities — Model Evaluation")
    print("=" * 60)
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    model, scaler, X_test, y_test = load_model_and_data()
    X_test_scaled = scaler.transform(X_test)
    y_pred = model.predict(X_test_scaled)
    metrics = compute_metrics(y_test, y_pred)
    print("\nClassification Metrics:")
    for metric, value in metrics.items():
        print(f"  {metric}: {value}")
    label_names = [ACTIVITY_LABELS.get(i, f"Activity {i}") for i in sorted(y_test.unique())]
    report = classification_report(y_test, y_pred, target_names=label_names)
    print(f"\nDetailed Classification Report:\n{report}")
    with open(OUTPUT_DIR / "metrics.json", "w") as f:
        json.dump(metrics, f, indent=2)
    print(f"Metrics saved to {OUTPUT_DIR / 'metrics.json'}")
    with open(OUTPUT_DIR / "classification_report.txt", "w") as f:
        f.write(report)
    plot_confusion_matrix(y_test, y_pred, OUTPUT_DIR / "confusion_matrix.png")
    print("\nEvaluation complete!")
if __name__ == "__main__":
    main()