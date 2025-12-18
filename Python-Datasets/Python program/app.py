from flask import Flask, request, jsonify
import pandas as pd

from loan_train import load_model, predict_single_application

app = Flask(__name__)

# Load the trained model once at startup
model = load_model()


def build_application_dict(data: dict):
    """
    Build and normalize the application dict from incoming JSON.
    Assumes the JSON keys match the training features:
    Gender, Married, Dependents, Education, Self_Employed,
    ApplicantIncome, CoapplicantIncome, LoanAmount,
    Loan_Amount_Term, Credit_History, Property_Area
    """

    # Just pass through the fields - the model pipeline will handle encoding
    app_dict = {
        "Gender": data.get("Gender"),
        "Married": data.get("Married"),
        "Dependents": data.get("Dependents"),
        "Education": data.get("Education"),
        "Self_Employed": data.get("Self_Employed"),
        "ApplicantIncome": data.get("ApplicantIncome"),
        "CoapplicantIncome": data.get("CoapplicantIncome"),
        "LoanAmount": data.get("LoanAmount"),
        "Loan_Amount_Term": data.get("Loan_Amount_Term"),
        "Credit_History": data.get("Credit_History"),
        "Property_Area": data.get("Property_Area"),
    }

    return app_dict


def predict_with_probability(model, app_dict: dict):
    """
    Uses the saved pipeline to produce:
    - decision: "Approved" or "Rejected"
    - probability: probability of approval (if available)
    """

    # Decision label using the helper from loan_train.py
    decision = predict_single_application(model, app_dict)

    # Default probability if model has no predict_proba
    probability = None

    try:
        # Build single row DataFrame for predict_proba
        X_new = pd.DataFrame([app_dict])

        if hasattr(model, "predict_proba"):
            proba = model.predict_proba(X_new)[0]
            # Class index 1 means to "Approved" (1) in training
            probability = float(proba[1])
    except Exception:
        # If anything fails, we just keep probability as None
        probability = None

    return decision, probability


@app.route("/predict", methods=["POST"])
def predict_endpoint():
    """
    POST /predict
    JSON input:
    {
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
    """

    data = request.get_json()

    if data is None:
        return jsonify({"error": "Invalid or missing JSON body"}), 400

    app_dict = build_application_dict(data)

    # Simple required field check
    missing = [k for k, v in app_dict.items() if v is None]
    if missing:
        return jsonify({
            "error": "Missing required fields",
            "missing": missing
        }), 400

    decision, probability = predict_with_probability(model, app_dict)

    return jsonify({
        "decision": decision,
        "probability": probability
    })

# 29-11-2025: AS
@app.route("/health", methods=["GET"])
def health():
    """
    Simple health check for Java side.
    Returns status: ok if the service is running.
    """
    return jsonify({"status": "ok"}), 200


if __name__ == "__main__":
    # Run on 0.0.0.0 so Java on the same machine can reach it
    app.run(host="0.0.0.0", port=5000, debug=True)