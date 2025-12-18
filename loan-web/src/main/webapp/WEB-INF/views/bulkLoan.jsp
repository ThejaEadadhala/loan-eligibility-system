<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Bulk Loan Scoring - Spark</title>

<style>
.page-container {
    max-width: 800px;
    margin: 0 auto;
    padding: 20px 24px;
    background: #ffffff;
    border-radius: 10px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}

.page-title {
    font-size: 22px;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 14px;
}

.section-desc {
    font-size: 14px;
    color: #4b5563;
    margin-bottom: 20px;
}

.upload-box {
    padding: 20px;
    border: 2px dashed #cbd5e1;
    border-radius: 8px;
    background: #f8fafc;
    text-align: center;
    margin-bottom: 20px;
}

.upload-box:hover {
    background: #f1f5f9;
}

.file-input {
    margin-top: 10px;
}

.submit-btn {
    padding: 10px 20px;
    background: #2563eb;
    color: #ffffff;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.2s ease;
}

.submit-btn:hover {
    background: #1d4ed8;
    box-shadow: 0 4px 10px rgba(37,99,235,0.3);
}

.submit-btn:disabled {
    background: #9ca3af;
    box-shadow: none;
    cursor: default;
}

.status-box {
    background: #f1f5f9;
    border-left: 4px solid #0ea5e9;
    padding: 12px 18px;
    margin-top: 20px;
    border-radius: 6px;
    font-size: 14px;
    color: #334155;
}

.download-link {
    display: inline-block;
    margin-top: 12px;
    padding: 8px 14px;
    background: #10b981;
    color: #ffffff;
    font-size: 13px;
    border-radius: 6px;
    text-decoration: none;
    transition: all 0.2s ease;
}

.download-link:hover {
    background: #059669;
}

/* Progress overlay */
.loading-overlay {
    position: fixed;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(15, 23, 42, 0.28);
    display: none;
    align-items: center;
    justify-content: center;
    z-index: 9999;
}

.loading-box {
    width: 320px;
    padding: 20px 22px;
    background: #ffffff;
    border-radius: 10px;
    box-shadow: 0 8px 24px rgba(15,23,42,0.35);
    text-align: left;
}

.loading-title {
    font-size: 15px;
    font-weight: 600;
    color: #0f172a;
    margin-bottom: 8px;
}

.loading-text {
    font-size: 13px;
    color: #4b5563;
    margin-bottom: 14px;
}

/* Indeterminate progress bar */
.progress-bar-track {
    width: 100%;
    height: 6px;
    background: #e5e7eb;
    border-radius: 999px;
    overflow: hidden;
    position: relative;
}

.progress-bar-fill {
    position: absolute;
    left: -40%;
    width: 40%;
    height: 100%;
    border-radius: 999px;
    background: linear-gradient(to right, #2563eb, #38bdf8);
    animation: loading-anim 1.2s infinite ease-in-out;
}

@keyframes loading-anim {
    0% {
        left: -40%;
    }
    50% {
        left: 60%;
    }
    100% {
        left: 100%;
    }
}
</style>

<script type="text/javascript">
function showProgress() {
    var overlay = document.getElementById("loading-overlay");
    var btn = document.getElementById("sparkSubmitBtn");

    if (overlay) {
        overlay.style.display = "flex";
    }
    if (btn) {
        btn.disabled = true;
        btn.innerText = "Running Spark batch scoring...";
    }

    // Allow form submit to continue
    return true;
}
</script>

</head>
<body>

    <jsp:include page="navbar.jsp" />

    <!-- Progress overlay shown while form is submitting -->
    <div id="loading-overlay" class="loading-overlay">
        <div class="loading-box">
            <div class="loading-title">Running Spark batch scoring</div>
            <div class="loading-text">
                Your CSV is being processed. This can take a short while depending on file size.
            </div>
            <div class="progress-bar-track">
                <div class="progress-bar-fill"></div>
            </div>
        </div>
    </div>

    <div class="page-container">

        <div class="page-title">Bulk Loan Scoring (Spark)</div>
        <div class="section-desc">
            Upload a CSV file containing multiple loan applicants.  
            The system will run a Spark batch scoring job using the trained ML model and generate a new CSV containing predictions.
        </div>

        <form action="${pageContext.request.contextPath}/bulk"
              method="post"
              enctype="multipart/form-data"
              onsubmit="return showProgress();">

            <div class="upload-box">
                <div>Select CSV File</div>
                <input type="file" name="applicantsFile" accept=".csv" class="file-input" required />
            </div>

            <button type="submit" id="sparkSubmitBtn" class="submit-btn">
                Run Spark Batch Scoring
            </button>
        </form>

        <c:if test="${not empty statusMessage}">
            <div class="status-box">
                ${statusMessage}
            </div>
        </c:if>

        <c:if test="${not empty downloadFile}">
            <a class="download-link"
               href="${pageContext.request.contextPath}/download-bulk?file=${downloadFile}">
               Download Scored CSV
            </a>
        </c:if>

    </div>

</body>
</html>