import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.linear_model import LogisticRegression
from sklearn.tree import DecisionTreeClassifier
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import sys


TRAIN_CSV = "../loan-datasets/train_u6lujuX_CVtuZ9i.csv"
MODEL_PATH = "loan_eligibility_model.pkl"


def load_data(train_csv: str = TRAIN_CSV):
    df = pd.read_csv(train_csv)

    # Remove leading/trailing spaces from column names
    df = df.rename(columns={c: c.strip() for c in df.columns})
    cols = list(df.columns)
    lower_cols = [c.lower() for c in cols]

    # Case 1 - Original Kaggle train file
    if "Loan_Status" in cols and "Loan_ID" in cols:
        y = df["Loan_Status"].map({"Y": 1, "N": 0})

        # Drop rows where target is NaN (just in case)
        mask = y.notna()
        X = df.loc[mask].drop(columns=["Loan_Status", "Loan_ID"])
        y = y.loc[mask].astype(int)
        return X, y

    # Case 2 - "Loan Eligibility Prediction.csv"
    if "Loan_Status" in cols and "Customer_ID" in cols:
        y = df["Loan_Status"].map({"Y": 1, "N": 0})

        rename_map = {}
        if "Applicant_Income" in cols:
            rename_map["Applicant_Income"] = "ApplicantIncome"
        if "Coapplicant_Income" in cols:
            rename_map["Coapplicant_Income"] = "CoapplicantIncome"
        if "Loan_Amount" in cols:
            rename_map["Loan_Amount"] = "LoanAmount"

        if rename_map:
            df = df.rename(columns=rename_map)

        # Drop rows where target is NaN
        mask = y.notna()
        X = df.loc[mask].drop(columns=["Loan_Status", "Customer_ID"])
        y = y.loc[mask].astype(int)
        return X, y

    # Case 3 - "loan_approval_dataset.csv"
    if "loan_status" in lower_cols and "loan_id" in lower_cols:
        # Only consider first 5 records (as you requested)
        df = df.head(5)
        cols = list(df.columns)
        lower_cols = [c.lower() for c in cols]

        # Find the actual target column name: loan_status / Loan_status etc.
        loan_status_col = cols[lower_cols.index("loan_status")]

        # Clean and map target: Approved / Rejected
        status = df[loan_status_col].astype(str).str.strip()
        y = status.map({"Approved": 1, "Rejected": 0})

        # Build standard feature DataFrame
        X = pd.DataFrame({
            "Gender": ["Male"] * len(df),  # dummy constant
            "Married": ["Yes"] * len(df),  # dummy constant
            "Dependents": df["no_of_dependents"].astype(str),
            "Education": df["education"],
            "Self_Employed": df["self_employed"],
            "ApplicantIncome": df["income_annum"],
            "CoapplicantIncome": 0,  # no separate coapplicant income in this dataset
            "LoanAmount": df["loan_amount"],
            "Loan_Amount_Term": df["loan_term"],
            "Credit_History": (df["cibil_score"] >= 750).astype(int),
            "Property_Area": ["Urban"] * len(df)  # dummy constant
        })

        # Drop rows where target could not be mapped
        mask = y.notna()
        X = X.loc[mask].reset_index(drop=True)
        y = y.loc[mask].astype(int).reset_index(drop=True)

        if len(y) == 0:
            raise ValueError(
                f"After cleaning, no valid labels remained in {train_csv}. "
                f"Check values in {loan_status_col}."
            )

        return X, y

    # If we reach here, schema is unknown
    raise ValueError(
        f"Unsupported dataset schema for file {train_csv}. "
        f"Columns: {cols}"
    )


def build_preprocessor(X: pd.DataFrame):
    # Numeric and categorical columns
    numeric_features = ["ApplicantIncome",
                        "CoapplicantIncome",
                        "LoanAmount",
                        "Loan_Amount_Term",
                        "Credit_History"]

    categorical_features = [col for col in X.columns if col not in numeric_features]

    numeric_transformer = Pipeline(steps=[
        ("imputer", SimpleImputer(strategy="median"))
    ])

    categorical_transformer = Pipeline(steps=[
        ("imputer", SimpleImputer(strategy="most_frequent")),
        ("onehot", OneHotEncoder(handle_unknown="ignore"))
    ])

    preprocessor = ColumnTransformer(
        transformers=[
            ("num", numeric_transformer, numeric_features),
            ("cat", categorical_transformer, categorical_features)
        ]
    )

    return preprocessor


def train_and_select_model(X, y):
    preprocessor = build_preprocessor(X)

    models = {
        "logreg": LogisticRegression(max_iter=1000),
        "dtree": DecisionTreeClassifier(random_state=42),
        "rf": RandomForestClassifier(
            n_estimators=200,
            random_state=42
        )
    }

    # Check if we can safely stratify
    class_counts = y.value_counts()
    can_stratify = (class_counts.min() >= 2) and (len(y) >= 4)

    if can_stratify:
        # Normal case - enough samples in each class
        X_train, X_val, y_train, y_val = train_test_split(
            X, y, test_size=0.2, random_state=42, stratify=y
        )
    else:
        # Very small or highly imbalanced dataset:
        # train and evaluate on the same data (not ideal but OK for this admin retrain)
        X_train, y_train = X, y
        X_val, y_val = X, y
        print("Warning: not enough samples per class to stratify - "
              "training and evaluating on full dataset.")

    best_name = None
    best_acc = -1.0
    best_pipeline = None

    for name, model in models.items():
        pipe = Pipeline(steps=[
            ("preprocess", preprocessor),
            ("model", model)
        ])

        pipe.fit(X_train, y_train)
        preds = pipe.predict(X_val)
        acc = accuracy_score(y_val, preds)
        print(f"{name} validation accuracy: {acc:.4f}")

        if acc > best_acc:
            best_acc = acc
            best_name = name
            best_pipeline = pipe

    print(f"Best model: {best_name} with accuracy {best_acc:.4f}")
    return best_pipeline, best_name, best_acc


def train_final_model_and_save(train_csv_path: str = TRAIN_CSV):
    # Load data (using selected CSV)
    X, y = load_data(train_csv_path)

    # Train and pick best model
    best_pipeline, best_name, best_acc = train_and_select_model(X, y)

    # Retrain best model on all data
    print("Retraining best model on full training data...")
    best_pipeline.fit(X, y)

    # Save final model
    joblib.dump(best_pipeline, MODEL_PATH)
    print(f"Saved final model ({best_name}) to {MODEL_PATH}")


def load_model(model_path: str = MODEL_PATH):
    return joblib.load(model_path)


def predict_single_application(model, application_dict: dict):
    """
    application_dict must contain ALL required fields:
    Gender, Married, Dependents, Education, Self_Employed,
    ApplicantIncome, CoapplicantIncome, LoanAmount,
    Loan_Amount_Term, Credit_History, Property_Area
    """

    # Build single-row DataFrame
    X_new = pd.DataFrame([application_dict])

    # Predict 0 or 1
    pred = model.predict(X_new)[0]

    # Map 1 -> Approved, 0 -> Rejected
    return "Approved" if pred == 1 else "Rejected"


if __name__ == "__main__":
    # If a CSV path is passed as argument, use it, otherwise use default TRAIN_CSV
    if len(sys.argv) > 1:
        train_csv_path = sys.argv[1]
    else:
        train_csv_path = TRAIN_CSV

    print(f"Using training dataset: {train_csv_path}")

    # Step 1: train and save model with chosen dataset
    train_final_model_and_save(train_csv_path)

    # Step 2: quick sanity test on a fake application
    print("\nTesting a sample application prediction...")

    model = load_model(MODEL_PATH)

    sample_app = {
        "Gender": "Male",
        "Married": "Yes",
        "Dependents": "1",
        "Education": "Graduate",
        "Self_Employed": "No",
        "ApplicantIncome": 5000,
        "CoapplicantIncome": 0,
        "LoanAmount": 128,
        "Loan_Amount_Term": 360,
        "Credit_History": 1.0,
        "Property_Area": "Urban"
    }

    decision = predict_single_application(model, sample_app)
    print("Sample decision:", decision)