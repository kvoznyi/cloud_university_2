import os
import sys
import zipfile
import urllib.request
import numpy as np
import pandas as pd
from pathlib import Path
DATASET_URL = "https://archive.ics.uci.edu/static/public/256/daily+and+sports+activities.zip"
DATA_DIR = Path(__file__).parent / "data"
RAW_DIR = DATA_DIR / "raw"
OUTPUT_DIR = DATA_DIR / "processed"
NUM_ACTIVITIES = 19
NUM_SUBJECTS = 8
NUM_SEGMENTS = 60
NUM_TIMESTEPS = 125
NUM_CHANNELS = 45
SENSOR_UNITS = ["torso", "right_arm", "left_arm", "right_leg", "left_leg"]
SENSOR_AXES = ["acc_x", "acc_y", "acc_z", "gyro_x", "gyro_y", "gyro_z", "mag_x", "mag_y", "mag_z"]
def download_dataset():
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    RAW_DIR.mkdir(parents=True, exist_ok=True)
    zip_path = DATA_DIR / "dataset.zip"
    if not zip_path.exists():
        print(f"Downloading dataset from {DATASET_URL}...")
        progress_state = {'last_percent': -1}
        def reporthook(block_num, block_size, total_size):
            downloaded = block_num * block_size
            if total_size <= 0:
                total_size = 169335914 
            percent_float = downloaded * 100 / total_size
            if percent_float > 100: 
                percent_float = 100.0
            percent_int = int(percent_float)
            if percent_int > progress_state['last_percent']:
                progress_state['last_percent'] = percent_int
                bar_length = 50
                filled_length = int(bar_length * downloaded // total_size)
                if filled_length > bar_length:
                    filled_length = bar_length
                bar = '█' * filled_length + '-' * (bar_length - filled_length)
                downloaded_mb = downloaded / (1024 * 1024)
                total_mb = total_size / (1024 * 1024)
                sys.stdout.write(f'\33[2K\rProgress: |{bar}| {percent_float:.1f}% ({downloaded_mb:.1f} MB / {total_mb:.1f} MB)')
                sys.stdout.flush()
        urllib.request.urlretrieve(DATASET_URL, zip_path, reporthook=reporthook)
        print("\nDownload complete.")
    else:
        print("Dataset archive already exists, skipping download.")
    if not any(RAW_DIR.iterdir()):
        print("Extracting dataset...")
        with zipfile.ZipFile(zip_path, "r") as zf:
            zf.extractall(RAW_DIR)
        print("Extraction complete.")
    else:
        print("Dataset already extracted.")
def find_data_root():
    for root, dirs, files in os.walk(RAW_DIR):
        if any(d.startswith("a") and len(d) == 3 for d in dirs):
            return Path(root)
    raise FileNotFoundError(
        f"Could not find activity folders (a01-a19) in {RAW_DIR}. "
        "Check the dataset structure."
    )
def load_segment(file_path: Path) -> np.ndarray:
    return np.loadtxt(file_path, delimiter=",")
def extract_features(segment: np.ndarray) -> np.ndarray:
    features = []
    for ch in range(segment.shape[1]):
        channel_data = segment[:, ch]
        features.extend([
            np.mean(channel_data),
            np.std(channel_data),
            np.min(channel_data),
            np.max(channel_data),
            np.median(channel_data),
            np.sqrt(np.mean(channel_data ** 2)),  
        ])
    return np.array(features)
def generate_feature_names() -> list[str]:
    stats = ["mean", "std", "min", "max", "median", "rms"]
    names = []
    for unit_idx, unit in enumerate(SENSOR_UNITS):
        for axis in SENSOR_AXES:
            for stat in stats:
                names.append(f"{unit}_{axis}_{stat}")
    return names
def process_dataset():
    data_root = find_data_root()
    print(f"Data root found: {data_root}")
    all_features = []
    all_labels = []
    all_subjects = []
    for activity_idx in range(1, NUM_ACTIVITIES + 1):
        activity_dir = data_root / f"a{activity_idx:02d}"
        if not activity_dir.exists():
            print(f"Warning: {activity_dir} not found, skipping.")
            continue
        for subject_idx in range(1, NUM_SUBJECTS + 1):
            subject_dir = activity_dir / f"p{subject_idx}"
            if not subject_dir.exists():
                continue
            for segment_idx in range(1, NUM_SEGMENTS + 1):
                segment_file = subject_dir / f"s{segment_idx:02d}.txt"
                if not segment_file.exists():
                    continue
                try:
                    segment = load_segment(segment_file)
                    features = extract_features(segment)
                    all_features.append(features)
                    all_labels.append(activity_idx)
                    all_subjects.append(subject_idx)
                except Exception as e:
                    print(f"Error processing {segment_file}: {e}")
    print(f"Processed {len(all_features)} segments total.")
    feature_names = generate_feature_names()
    df = pd.DataFrame(all_features, columns=feature_names)
    df["activity"] = all_labels
    df["subject"] = all_subjects
    return df
def split_and_save(df: pd.DataFrame):
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    from sklearn.model_selection import train_test_split
    X = df.drop(columns=["activity", "subject"])
    y = df["activity"]
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    train_df = pd.concat([X_train, y_train], axis=1)
    test_df = pd.concat([X_test, y_test], axis=1)
    train_df.to_csv(OUTPUT_DIR / "train.csv", index=False)
    test_df.to_csv(OUTPUT_DIR / "test.csv", index=False)
    print(f"Train set: {len(train_df)} samples")
    print(f"Test set:  {len(test_df)} samples")
    print(f"Features:  {X.shape[1]}")
    print(f"Classes:   {y.nunique()}")
    print(f"Saved to {OUTPUT_DIR}")
def main():
    print("=" * 60)
    print("Daily and Sports Activities — Data Preparation")
    print("=" * 60)
    download_dataset()
    df = process_dataset()
    print(f"\nDataset shape: {df.shape}")
    print(f"Activity distribution:\n{df['activity'].value_counts().sort_index()}")
    split_and_save(df)
    print("\nData preparation complete!")
if __name__ == "__main__":
    main()