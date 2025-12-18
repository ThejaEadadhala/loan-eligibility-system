package ec.loan.ejb;

import java.io.Serializable;

public class LoanDecision implements Serializable {

    private String decision;     // "Approved" or "Rejected"
    private double probability;  // 0.0 to 1.0 (from Python later)

    public LoanDecision() {}

    public LoanDecision(String decision, double probability) {
        this.decision = decision;
        this.probability = probability;
    }

    public String getDecision() {
        return decision;
    }
    public void setDecision(String decision) {
        this.decision = decision;
    }

    public double getProbability() {
        return probability;
    }
    public void setProbability(double probability) {
        this.probability = probability;
    }
}