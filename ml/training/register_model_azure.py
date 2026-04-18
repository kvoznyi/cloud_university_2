import argparse
import json
from pathlib import Path
try:
    from azure.ai.ml import MLClient
    from azure.ai.ml.entities import (
        Model,
        ManagedOnlineEndpoint,
        ManagedOnlineDeployment,
        CodeConfiguration,
        Environment,
    )
    from azure.identity import DefaultAzureCredential
except ImportError:
    print("Azure ML SDK not installed. Run:")
    print("  pip install azure-ai-ml azure-identity")
    exit(1)
MODEL_DIR = Path(__file__).parent / "models"
TRAINING_DIR = Path(__file__).parent
SCORE_SCRIPT = Path(__file__).parent / "score.py"
def get_ml_client() -> MLClient:
    credential = DefaultAzureCredential()
    import os
    subscription_id = os.environ.get("AZURE_SUBSCRIPTION_ID")
    resource_group = os.environ.get("AZURE_RESOURCE_GROUP", "rg-workout-planner-dev")
    workspace_name = os.environ.get("AZURE_ML_WORKSPACE", "mlw-workout-planner")
    if not subscription_id:
        import subprocess
        result = subprocess.run(
            ["az", "account", "show", "--query", "id", "-o", "tsv"],
            capture_output=True, text=True
        )
        subscription_id = result.stdout.strip()
    return MLClient(credential, subscription_id, resource_group, workspace_name)
def register_model(ml_client: MLClient) -> Model:
    print("Registering model in Azure ML...")
    with open(MODEL_DIR / "metadata.json") as f:
        metadata = json.load(f)
    model = Model(
        path=str(MODEL_DIR),
        name="workout-activity-classifier",
        description="Random Forest classifier for Daily and Sports Activities dataset. "
                    f"Test accuracy: {metadata.get('test_accuracy', 'N/A')}",
        type="custom_model",
        tags={
            "algorithm": metadata.get("model_type", "RandomForest"),
            "accuracy": str(metadata.get("test_accuracy", "")),
            "n_features": str(metadata.get("n_features", "")),
            "n_classes": str(metadata.get("n_classes", "")),
            "framework": "scikit-learn",
        },
    )
    registered_model = ml_client.models.create_or_update(model)
    print(f"Model registered: {registered_model.name}, version: {registered_model.version}")
    return registered_model
def deploy_endpoint(ml_client: MLClient, model: Model):
    endpoint_name = "workout-planner-endpoint"
    print(f"Creating endpoint: {endpoint_name}...")
    endpoint = ManagedOnlineEndpoint(
        name=endpoint_name,
        description="Workout Planner activity recognition endpoint",
        auth_mode="key",
    )
    ml_client.online_endpoints.begin_create_or_update(endpoint).result()
    print(f"Endpoint created: {endpoint_name}")
    print("Creating deployment (this may take several minutes)...")
    deployment = ManagedOnlineDeployment(
        name="default",
        endpoint_name=endpoint_name,
        model=model,
        code_configuration=CodeConfiguration(
            code=str(TRAINING_DIR),
            scoring_script="score.py",
        ),
        environment=Environment(
            image="mcr.microsoft.com/azureml/openmpi4.1.0-ubuntu20.04",
            conda_file=str(TRAINING_DIR / "conda_env.yaml"),
        ),
        instance_type="Standard_DS1_v2",
        instance_count=1,
    )
    ml_client.online_deployments.begin_create_or_update(deployment).result()
    endpoint.traffic = {"default": 100}
    ml_client.online_endpoints.begin_create_or_update(endpoint).result()
    endpoint = ml_client.online_endpoints.get(endpoint_name)
    print(f"\nEndpoint deployed!")
    print(f"Scoring URI: {endpoint.scoring_uri}")
    print(f"Swagger URI: {endpoint.openapi_uri}")
def main():
    parser = argparse.ArgumentParser(description="Register model in Azure ML")
    parser.add_argument("--register", action="store_true", help="Register model")
    parser.add_argument("--deploy", action="store_true", help="Deploy as managed endpoint")
    args = parser.parse_args()
    if not args.register and not args.deploy:
        parser.print_help()
        return
    if not (MODEL_DIR / "model.joblib").exists():
        print("Error: Model not found. Run train.py first.")
        return
    ml_client = get_ml_client()
    if args.register:
        model = register_model(ml_client)
        if args.deploy:
            deploy_endpoint(ml_client, model)
    elif args.deploy:
        print("Error: --deploy requires --register")
if __name__ == "__main__":
    main()