package ec.loan.jpa;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "loan_record")
public class LoanRecord {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Basic applicant info
    @Column(length = 10)
    private String gender;

    @Column(length = 10)
    private String married;

    @Column(length = 10)
    private String dependents;

    @Column(length = 20)
    private String education;

    @Column(name = "self_employed", length = 10)
    private String selfEmployed;

    // Numeric features
    @Column(name = "applicant_income")
    private Double applicantIncome;

    @Column(name = "coapplicant_income")
    private Double coapplicantIncome;

    @Column(name = "loan_amount")
    private Double loanAmount;

    @Column(name = "loan_amount_term")
    private Double loanAmountTerm;

    @Column(name = "credit_history")
    private Double creditHistory;

    @Column(name = "property_area", length = 20)
    private String propertyArea;

    // Model output
    @Column(length = 50)
    private String decision;

    private Double probability;

    @Column(name = "created_at", nullable = false)
    private Timestamp createdAt;

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = new Timestamp(System.currentTimeMillis());
        }
    }

    // Getters and setters

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public String getMarried() { return married; }
    public void setMarried(String married) { this.married = married; }

    public String getDependents() { return dependents; }
    public void setDependents(String dependents) { this.dependents = dependents; }

    public String getEducation() { return education; }
    public void setEducation(String education) { this.education = education; }

    public String getSelfEmployed() { return selfEmployed; }
    public void setSelfEmployed(String selfEmployed) { this.selfEmployed = selfEmployed; }

    public Double getApplicantIncome() { return applicantIncome; }
    public void setApplicantIncome(Double applicantIncome) { this.applicantIncome = applicantIncome; }

    public Double getCoapplicantIncome() { return coapplicantIncome; }
    public void setCoapplicantIncome(Double coapplicantIncome) { this.coapplicantIncome = coapplicantIncome; }

    public Double getLoanAmount() { return loanAmount; }
    public void setLoanAmount(Double loanAmount) { this.loanAmount = loanAmount; }

    public Double getLoanAmountTerm() { return loanAmountTerm; }
    public void setLoanAmountTerm(Double loanAmountTerm) { this.loanAmountTerm = loanAmountTerm; }

    public Double getCreditHistory() { return creditHistory; }
    public void setCreditHistory(Double creditHistory) { this.creditHistory = creditHistory; }

    public String getPropertyArea() { return propertyArea; }
    public void setPropertyArea(String propertyArea) { this.propertyArea = propertyArea; }

    public String getDecision() { return decision; }
    public void setDecision(String decision) { this.decision = decision; }

    public Double getProbability() { return probability; }
    public void setProbability(Double probability) { this.probability = probability; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
}