import pandas as pd
import joblib

MODEL_PATH = "loan_eligibility_model.pkl"
INPUT_CSV = "train_u6lujuX_CVtuZ9i.csv"   # change to any file you want to evaluate
OUTPUT_CSV = "predicted_results.csv"


def load_model(model_path=MODEL_PATH):
    return joblib.load(model_path)


def predict_full_csv(input_csv, output_csv):
    model = load_model(MODEL_PATH)

    df = pd.read_csv(input_csv)

    # Create a copy to preserve original data
    result_df = df.copy()

    # Remove Loan_Status if present
    features = result_df.drop(columns=["Loan_Status", "Loan_ID"], errors="ignore")

    preds = model.predict(features)

    # Map predictions back to Approved/Rejected
    result_df["Prediction"] = ["Approved" if p == 1 else "Rejected" for p in preds]

    # Save output
    result_df.to_csv(output_csv, index=False)
    print(f"Saved predictions to {output_csv}")


if __name__ == "__main__":
    predict_full_csv(INPUT_CSV, OUTPUT_CSV)