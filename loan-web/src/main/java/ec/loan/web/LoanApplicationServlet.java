package ec.loan.web;

import ec.loan.ejb.LoanApplicationServiceBean;
import ec.loan.ejb.LoanRequest;
import ec.loan.ejb.LoanDecision;

import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(name = "LoanApplicationServlet", urlPatterns = {"/loanofficer"})
public class LoanApplicationServlet extends HttpServlet {

    @EJB
    private LoanApplicationServiceBean service;  

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Read input parameters
        String gender = request.getParameter("Gender");
        String married = request.getParameter("Married");
        String dependents = request.getParameter("Dependents");
        String education = request.getParameter("Education");
        String selfEmployed = request.getParameter("Self_Employed");
        String applicantIncome = request.getParameter("ApplicantIncome");
        String coapplicantIncome = request.getParameter("CoapplicantIncome");
        String loanAmount = request.getParameter("LoanAmount");
        String loanAmountTerm = request.getParameter("Loan_Amount_Term");
        String creditHistory = request.getParameter("Credit_History");
        String propertyArea = request.getParameter("Property_Area");

        String decisionText;
        double probability = 0.0;

        try {
            // Build LoanRequest object for EJB
            LoanRequest lr = new LoanRequest();
            lr.setGender(gender);
            lr.setMarried(married);
            lr.setDependents(dependents);
            lr.setEducation(education);
            lr.setSelfEmployed(selfEmployed);
            lr.setApplicantIncome(Double.parseDouble(applicantIncome));
            lr.setCoapplicantIncome(Double.parseDouble(coapplicantIncome));
            lr.setLoanAmount(Double.parseDouble(loanAmount));
            lr.setLoanAmountTerm(Double.parseDouble(loanAmountTerm));
            lr.setCreditHistory(Double.parseDouble(creditHistory));
            lr.setPropertyArea(propertyArea);

            // Call EJB
            LoanDecision decision = service.evaluateLoan(lr);
            decisionText = decision.getDecision();
            probability = decision.getProbability();

        } catch (NumberFormatException ex) {
            // If any numeric value fails to parse
            decisionText = "Rejected (invalid numeric input)";
        }

        // Put everything into request attributes for JSP
        request.setAttribute("decision", decisionText);
        request.setAttribute("probability", probability);

        request.setAttribute("Gender", gender);
        request.setAttribute("Married", married);
        request.setAttribute("Dependents", dependents);
        request.setAttribute("Education", education);
        request.setAttribute("Self_Employed", selfEmployed);
        request.setAttribute("ApplicantIncome", applicantIncome);
        request.setAttribute("CoapplicantIncome", coapplicantIncome);
        request.setAttribute("LoanAmount", loanAmount);
        request.setAttribute("Loan_Amount_Term", loanAmountTerm);
        request.setAttribute("Credit_History", creditHistory);
        request.setAttribute("Property_Area", propertyArea);

        request.getRequestDispatcher("/WEB-INF/views/loanResult.jsp")
               .forward(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/loanForm.jsp")
               .forward(request, response);
    }
}
