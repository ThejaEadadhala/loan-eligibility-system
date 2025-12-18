package ec.loan.ejb;

import java.io.Serializable;

public class LoanRequest implements Serializable {

    private String gender;
    private String married;
    private String dependents;
    private String education;
    private String selfEmployed;
    private double applicantIncome;
    private double coapplicantIncome;
    private double loanAmount;
    private double loanAmountTerm;
    private double creditHistory;
    private String propertyArea;

    // Getters and setters (Eclipse: Source > Generate Getters and Setters)
    // Only showing a couple here

    public String getGender() {
        return gender;
    }
    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getMarried() {
        return married;
    }
    public void setMarried(String married) {
        this.married = married;
    }

    public String getDependents() {
        return dependents;
    }
    public void setDependents(String dependents) {
        this.dependents = dependents;
    }

    public String getEducation() {
        return education;
    }
    public void setEducation(String education) {
        this.education = education;
    }

    public String getSelfEmployed() {
        return selfEmployed;
    }
    public void setSelfEmployed(String selfEmployed) {
        this.selfEmployed = selfEmployed;
    }

    public double getApplicantIncome() {
        return applicantIncome;
    }
    public void setApplicantIncome(double applicantIncome) {
        this.applicantIncome = applicantIncome;
    }

    public double getCoapplicantIncome() {
        return coapplicantIncome;
    }
    public void setCoapplicantIncome(double coapplicantIncome) {
        this.coapplicantIncome = coapplicantIncome;
    }

    public double getLoanAmount() {
        return loanAmount;
    }
    public void setLoanAmount(double loanAmount) {
        this.loanAmount = loanAmount;
    }

    public double getLoanAmountTerm() {
        return loanAmountTerm;
    }
    public void setLoanAmountTerm(double loanAmountTerm) {
        this.loanAmountTerm = loanAmountTerm;
    }

    public double getCreditHistory() {
        return creditHistory;
    }
    public void setCreditHistory(double creditHistory) {
        this.creditHistory = creditHistory;
    }

    public String getPropertyArea() {
        return propertyArea;
    }
    public void setPropertyArea(String propertyArea) {
        this.propertyArea = propertyArea;
    }
}