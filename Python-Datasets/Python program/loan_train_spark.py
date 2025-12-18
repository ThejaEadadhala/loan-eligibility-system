import sys
import os
import pickle

import pandas as pd
from sklearn.linear_model import LogisticRegression

# To professor: Adjust this if your dataset is elsewhere
DEFAULT_DATASET = os.path.join(
    os.path.dirname(__file__),
    "..",
    "loan-datasets",
    "train_u6lujuX_CVtuZ9i.csv"
)


def load_and_prepare_data(csv_path: str):
    df = pd.read_csv(csv_path)

    # Target column
    y = df["Loan_Status"].map({"Y": 1, "N": 0})

    # Drop ID and target from features
    if "Loan_ID" in df.columns:
        df = df.drop(columns=["Loan_ID"])
    X = df.drop(columns=["Loan_Status"])

    # Basic cleaning
    X = X.copy()
    X["Gender"] = X["Gender"].fillna("Male")
    X["Married"] = X["Married"].fillna("No")
    X["Dependents"] = X["Dependents"].fillna("0")
    X["Education"] = X["Education"].fillna("Graduate")
    X["Self_Employed"] = X["Self_Employed"].fillna("No")
    X["Property_Area"] = X["Property_Area"].fillna("Urban")

    X["ApplicantIncome"] = X["ApplicantIncome"].fillna(0)
    X["CoapplicantIncome"] = X["CoapplicantIncome"].fillna(0)
    X["LoanAmount"] = X["LoanAmount"].fillna(0)
    X["Loan_Amount_Term"] = X["Loan_Amount_Term"].fillna(360)
    X["Credit_History"] = X["Credit_History"].fillna(1)

    # Manual encoding - must match scoring script
    X["Gender"] = X["Gender"].map({"Male": 1, "Female": 0}).fillna(0)
    X["Married"] = X["Married"].map({"Yes": 1, "No": 0}).fillna(0)
    X["Education"] = X["Education"].map({"Graduate": 1, "Not Graduate": 0}).fillna(0)
    X["Self_Employed"] = X["Self_Employed"].map({"Yes": 1, "No": 0}).fillna(0)
    X["Property_Area"] = X["Property_Area"].map({"Urban": 2, "Semiurban": 1, "Rural": 0}).fillna(0)

    # Dependents like "0","1","2","3+"
    dep_map = {"0": 0, "1": 1, "2": 2, "3+": 3}
    X["Dependents"] = X["Dependents"].astype(str).map(dep_map).fillna(0)

    # Keep the same feature order that scoring uses
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

    X = X[feature_cols]

    return X, y


def train_and_save_model(csv_path: str):
    X, y = load_and_prepare_data(csv_path)

    clf = LogisticRegression(max_iter=1000)
    clf.fit(X, y)

    model_path = os.path.join(
        os.path.dirname(__file__),
        "loan_eligibility_model_spark.pkl"
    )

    with open(model_path, "wb") as f:
        pickle.dump(clf, f)

    print("Saved Spark batch model to:", model_path)


if __name__ == "__main__":
    if len(sys.argv) == 2:
        dataset = sys.argv[1]
    else:
        dataset = DEFAULT_DATASET

    print("Training Spark batch model with dataset:", dataset)
    train_and_save_model(dataset)