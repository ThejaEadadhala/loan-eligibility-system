import sys
import os
import pickle

import pandas as pd
from pyspark.sql import SparkSession

# Use the separate Spark model
MODEL_PATH = os.path.join(
    os.path.dirname(__file__),
    "loan_eligibility_model_spark.pkl"
)


def main(input_csv: str, output_csv: str) -> None:
    # 1) Start Spark
    spark = SparkSession.builder.appName("LoanBatchScoring").getOrCreate()

    # 2) Read input CSV with Spark
    df_spark = spark.read.csv(input_csv, header=True, inferSchema=True)

    # 3) Convert to Pandas for sklearn
    df = df_spark.toPandas()

    # 4) Clean and encode
    df = df.copy()
    df["Gender"] = df["Gender"].fillna("Male")
    df["Married"] = df["Married"].fillna("No")
    df["Dependents"] = df["Dependents"].fillna("0")
    df["Education"] = df["Education"].fillna("Graduate")
    df["Self_Employed"] = df["Self_Employed"].fillna("No")
    df["Property_Area"] = df["Property_Area"].fillna("Urban")

    df["ApplicantIncome"] = df["ApplicantIncome"].fillna(0)
    df["CoapplicantIncome"] = df["CoapplicantIncome"].fillna(0)
    df["LoanAmount"] = df["LoanAmount"].fillna(0)
    df["Loan_Amount_Term"] = df["Loan_Amount_Term"].fillna(360)
    df["Credit_History"] = df["Credit_History"].fillna(1)

    df["Gender"] = df["Gender"].map({"Male": 1, "Female": 0}).fillna(0)
    df["Married"] = df["Married"].map({"Yes": 1, "No": 0}).fillna(0)
    df["Education"] = df["Education"].map({"Graduate": 1, "Not Graduate": 0}).fillna(0)
    df["Self_Employed"] = df["Self_Employed"].map({"Yes": 1, "No": 0}).fillna(0)
    df["Property_Area"] = df["Property_Area"].map({"Urban": 2, "Semiurban": 1, "Rural": 0}).fillna(0)

    dep_map = {"0": 0, "1": 1, "2": 2, "3+": 3}
    df["Dependents"] = df["Dependents"].astype(str).map(dep_map).fillna(0)

    feature_cols = [
        "Gender",
        "Married",
        "Dependents",
        "Education",
        "Self_Employed",
        "ApplicantIncome",
        "CoapplicantIncome",
        "LoanAmount",
        "Loan_Amount_Term",
        "Credit_History",
        "Property_Area",
    ]

    X = df[feature_cols]

    # 5) Load Spark-specific model
    with open(MODEL_PATH, "rb") as f:
        model = pickle.load(f)

    # 6) Predict
    preds = model.predict(X)

    if hasattr(model, "predict_proba"):
        probs = model.predict_proba(X)[:, 1]
    else:
        probs = [0.0] * len(preds)

    # 7) Attach results to original data
    df["Prediction"] = ["Approved" if p == 1 else "Rejected" for p in preds]
    df["Probability"] = probs

    # 8) Save output CSV
    df.to_csv(output_csv, index=False)

    # 9) Stop Spark
    spark.stop()


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python loan_spark_batch_score.py <input_csv> <output_csv>")
        sys.exit(1)

    in_csv = sys.argv[1]
    out_csv = sys.argv[2]

    print("Running Spark batch scoring...")
    print("Input :", in_csv)
    print("Output:", out_csv)

    main(in_csv, out_csv)