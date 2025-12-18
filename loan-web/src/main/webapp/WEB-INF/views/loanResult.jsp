<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Loan Decision</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
            background: #f3f4f6;
            margin: 0;
            padding: 0;
            color: #111827;
        }

        .page-container {
            max-width: 700px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .card {
            background: #ffffff;
            padding: 28px 30px;
            border-radius: 14px;
            box-shadow: 0 12px 24px rgba(0, 0, 0, 0.08);
        }

        h2 {
            margin-top: 0;
            font-size: 24px;
            color: #1f2937;
            font-weight: 600;
        }

        .decision-badge {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 999px;
            font-size: 14px;
            font-weight: 600;
        }

        .approved {
            background: #d1fae5;
            color: #065f46;
            border: 1px solid #6ee7b7;
        }

        .rejected {
            background: #fee2e2;
            color: #991b1b;
            border: 1px solid #fca5a5;
        }

        .probability-text {
            margin-top: 10px;
            font-size: 14px;
            color: #4b5563;
        }

        .detail-title {
            margin-top: 30px;
            color: #1f2937;
            font-size: 18px;
            font-weight: 600;
        }

        .detail-list {
            list-style: none;
            padding-left: 0;
            margin-top: 16px;
            font-size: 14px;
        }

        .detail-list li {
            padding: 8px 0;
            border-bottom: 1px solid #e5e7eb;
        }

        .detail-list li strong {
            display: inline-block;
            width: 170px;
            color: #374151;
        }

        .btn-back {
            display: inline-block;
            margin-top: 24px;
            padding: 10px 18px;
            font-size: 14px;
            font-weight: 500;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: #ffffff;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            text-decoration: none;
            box-shadow: 0 8px 16px rgba(37, 99, 235, 0.3);
            transition: transform 0.15s ease, box-shadow 0.15s ease, background 0.15s ease;
        }

        .btn-back:hover {
            background: linear-gradient(135deg, #1d4ed8, #1e40af);
            box-shadow: 0 6px 14px rgba(30, 64, 175, 0.35);
            transform: translateY(-1px);
        }

        .btn-back:active {
            transform: translateY(0);
            box-shadow: 0 3px 8px rgba(30, 64, 175, 0.35);
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/navbar.jsp" />

<div class="page-container">
    <div class="card">

        <h2>Loan Eligibility Result</h2>

        <!-- Make a robust "isApproved" flag using contains -->
        <c:set var="isApproved" value="${fn:contains(decision, 'Approved')}" />

        <c:choose>
            <c:when test="${isApproved}">
                <span class="decision-badge approved">Approved ✔</span>
            </c:when>
            <c:otherwise>
                <span class="decision-badge rejected">Rejected ✘</span>
            </c:otherwise>
        </c:choose>

        <!-- Show raw decision text + probability, if available -->
        <c:if test="${not empty decision}">
            <p class="probability-text">
                <strong>Decision:</strong> ${decision}
            </p>
        </c:if>

        <c:if test="${not empty probability}">
            <p class="probability-text">
                <strong>Model Probability:</strong>
                <c:out value="${probability}" /> 
            </p>
        </c:if>

        <h3 class="detail-title">Application Details</h3>

        <ul class="detail-list">
            <li><strong>Gender:</strong> <c:out value="${Gender}"/></li>
            <li><strong>Married:</strong> <c:out value="${Married}"/></li>
            <li><strong>Dependents:</strong> <c:out value="${Dependents}"/></li>
            <li><strong>Education:</strong> <c:out value="${Education}"/></li>
            <li><strong>Self Employed:</strong> <c:out value="${Self_Employed}"/></li>
            <li><strong>Applicant Income:</strong> <c:out value="${ApplicantIncome}"/></li>
            <li><strong>Co-applicant Income:</strong> <c:out value="${CoapplicantIncome}"/></li>
            <li><strong>Loan Amount:</strong> <c:out value="${LoanAmount}"/></li>
            <li><strong>Loan Amount Term:</strong> <c:out value="${Loan_Amount_Term}"/></li>
            <li><strong>Credit History:</strong> <c:out value="${Credit_History}"/></li>
            <li><strong>Property Area:</strong> <c:out value="${Property_Area}"/></li>
        </ul>

        <a class="btn-back" href="${pageContext.request.contextPath}/loanofficer">
            Check another application
        </a>

    </div>
</div>

</body>
</html>
