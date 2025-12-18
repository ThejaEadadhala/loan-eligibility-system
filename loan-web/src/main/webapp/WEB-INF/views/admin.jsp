<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html>
<head>
<title>Admin Dashboard</title>

<style>
body {
	margin: 0;
	padding: 0;
	font-family: Arial, sans-serif;
	background-color: #f3f4f6;
	color: #333;
}

.page-container {
	max-width: 1200px;
	margin: 20px auto 40px auto;
	padding: 0 16px;
}

h1, h2, h3, h4 {
	margin: 0 0 10px 0;
}

h1 {
	font-size: 24px;
}

.subtitle {
	font-size: 13px;
	color: #666;
	margin-bottom: 16px;
}

.layout {
	display: flex;
	flex-wrap: wrap;
	gap: 16px;
}

.column {
	flex: 1;
	min-width: 320px;
}

.card {
	background-color: #ffffff;
	border-radius: 6px;
	box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
	padding: 16px 18px;
	margin-bottom: 16px;
}

.card-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	margin-bottom: 8px;
}

.card-header h3 {
	margin: 0;
	font-size: 16px;
}

.badge {
	display: inline-block;
	padding: 2px 8px;
	border-radius: 10px;
	font-size: 11px;
	background-color: #e5e7eb;
	color: #374151;
}

.badge-ok {
	background-color: #d1fae5;
	color: #065f46;
}

.badge-down {
	background-color: #fee2e2;
	color: #991b1b;
}

ul.info-list {
	list-style: none;
	padding-left: 0;
	margin: 4px 0 0 0;
	font-size: 13px;
}

ul.info-list li {
	margin-bottom: 4px;
}

/* Progress bar styles */
#progressContainer {
	display: none;
	margin-top: 8px;
	width: 100%;
	max-width: 360px;
	border: 1px solid #e5e7eb;
	padding: 4px 6px;
	font-size: 12px;
	background-color: #f9fafb;
	border-radius: 4px;
}

#progressBar {
	width: 0;
	height: 16px;
	background-color: #10b981;
	border-radius: 3px;
	transition: width 0.3s ease;
}

#progressText {
	display: block;
	margin-top: 4px;
}

button, .btn {
	display: inline-block;
	border: none;
	border-radius: 4px;
	padding: 6px 14px;
	font-size: 13px;
	cursor: pointer;
	background-color: #2563eb;
	color: #ffffff;
}

button:hover:not([disabled]) {
	background-color: #1d4ed8;
}

button[disabled] {
	opacity: 0.6;
	cursor: not-allowed;
}

select {
	padding: 4px 6px;
	font-size: 13px;
	border-radius: 4px;
	border: 1px solid #d1d5db;
	margin-left: 6px;
}

.field-row {
	margin: 8px 0;
	font-size: 13px;
}

.field-row label {
	font-weight: bold;
	margin-right: 6px;
}

/* Collapsible sections */
.collapsible-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	cursor: pointer;
	user-select: none;
}

.collapsible-header h3 {
	margin: 0;
	font-size: 15px;
}

.collapse-toggle {
	font-size: 11px;
	color: #2563eb;
	border: none;
	background: none;
	padding: 0;
	cursor: pointer;
}

.collapse-toggle:hover {
	text-decoration: underline;
}

.collapsible-body {
	margin-top: 10px;
}

.small-muted {
	font-size: 12px;
	color: #6b7280;
}

.csv-list {
	list-style: none;
	padding-left: 0;
	margin: 4px 0 0 0;
	font-size: 13px;
}

.csv-list li {
	margin-bottom: 3px;
}

.status-box {
	margin-top: 8px;
	font-size: 12px;
	background-color: #f9fafb;
	border-radius: 4px;
	padding: 8px;
	border: 1px solid #e5e7eb;
}

.status-box pre {
	margin: 0;
	font-size: 11px;
	white-space: pre-wrap;
}

/* Recent loans table */
.table-container {
	max-height: 360px;
	overflow: auto;
	margin-top: 8px;
	border: 1px solid #e5e7eb;
	border-radius: 4px;
}

table.loans {
	width: 100%;
	border-collapse: collapse;
	font-size: 12px;
}

table.loans th, table.loans td {
	padding: 4px 6px;
	border-bottom: 1px solid #e5e7eb;
	text-align: left;
}

table.loans th {
	background-color: #f3f4f6;
	position: sticky;
	top: 0;
	z-index: 1;
}

table.loans tr:nth-child(even) td {
	background-color: #f9fafb;
}

.footer-link {
	margin-top: 16px;
	font-size: 13px;
}
</style>
</head>
<body>
	<jsp:include page="/WEB-INF/views/navbaradmin.jsp" />
	<div class="page-container">
		<h1>Admin Dashboard</h1>
		<div class="subtitle">Monitor Flask service, manage datasets,
			and retrain the loan eligibility model.</div>

		<div class="layout">
			<!-- Left column: app info, health, retrain -->
			<div class="column">

				<div class="card">
					<div class="card-header">
						<h3>Application Info</h3>
						<span class="badge">EAR ${earVersion}</span>
					</div>
					<ul class="info-list">
						<li><strong>Application:</strong> ${appName}</li>
						<li><strong>Model file:</strong> ${modelName}</li>
					</ul>
				</div>

				<div class="card">
					<div class="card-header">
						<h3>Flask Health</h3>
						<c:choose>
							<c:when test="${fn:contains(healthStatus, 'UP')}">
								<span class="badge badge-ok">UP</span>
							</c:when>
							<c:otherwise>
								<span class="badge badge-down">Check</span>
							</c:otherwise>
						</c:choose>
					</div>
					<div class="small-muted">${healthStatus}</div>
				</div>

				<div class="card">
					<div class="card-header">
						<h3>Trigger Model Retraining</h3>
					</div>

					<form id="retrainForm" action="admin" method="post">
						<input type="hidden" name="action" value="retrain" />

						<div class="field-row">
							<label for="datasetFile">Training dataset:</label> <select
								name="datasetFile" id="datasetFile">
								<c:forEach var="f" items="${datasetFiles}">
									<option value="${f.name}">${f.name}</option>
								</c:forEach>
							</select>
						</div>

						<button type="submit" id="retrainButton">Trigger Model
							Retraining</button>

						<div id="progressContainer">
							<div id="progressBar"></div>
							<span id="progressText">Retraining model, please wait...</span>
						</div>
					</form>

					<c:if test="${not empty retrainStatus}">
						<div class="status-box">
							<strong>Retrain Status</strong>
							<pre>${retrainStatus}</pre>
						</div>
					</c:if>
				</div>

				<div class="card">
					<div class="card-header">
						<h3>Train Spark Batch Model</h3>
					</div>

					<p class="small-muted">
						This Train's 
						<code>loan_eligibility_model_spark.pkl</code>
						file using the main training dataset (
						<code>train_u6lujuX_CVtuZ9i.csv</code>
						).<br> This model is used for the <strong>Bulk Loan
							Scoring</strong> feature, where Loan Officers upload a CSV containing
						multiple applicants and Spark returns a new CSV with <strong>Prediction</strong>
						and <strong>Probability</strong> for each row.
					</p>


					<form action="admin" method="post">
						<input type="hidden" name="action" value="trainSparkBatch" />
						<button type="submit">Train Spark Batch Model</button>
					</form>

					<c:if test="${not empty sparkTrainStatus}">
						<div class="status-box" style="margin-top: 10px;">
							<strong>Spark Batch Train Status</strong>
							<pre>${sparkTrainStatus}</pre>
						</div>
					</c:if>
				</div>

				<div class="footer-link">
					<a href="index.jsp">Back to main page</a>
				</div>
			</div>

			<!-- Right column: datasets + recent loans -->
			<div class="column">

				<div class="card">
					<div class="collapsible-header"
						onclick="toggleSection('datasetSectionBody')">
						<h3>Dataset Directory and CSV Files</h3>
						<button type="button" class="collapse-toggle"
							onclick="toggleSection('datasetSectionBody'); event.stopPropagation();">
							toggle</button>
					</div>

					<div id="datasetSectionBody" class="collapsible-body">
						<div class="small-muted">
							<strong>Directory:</strong> ${datasetDir}
						</div>

						<c:if test="${not empty datasetFiles}">
							<h4 style="font-size: 13px; margin-top: 10px;">Available CSV
								files</h4>
							<ul class="csv-list">
								<c:forEach var="f" items="${datasetFiles}">
									<li>${f}</li>
								</c:forEach>
							</ul>
						</c:if>
						<c:if test="${empty datasetFiles}">
							<p class="small-muted">No CSV files found in the dataset
								directory.</p>
						</c:if>
					</div>
				</div>

				<div class="card">
					<div class="collapsible-header"
						onclick="toggleSection('recentLoansBody')">
						<h3>Recent Loan Predictions</h3>
						<button type="button" class="collapse-toggle"
							onclick="toggleSection('recentLoansBody'); event.stopPropagation();">
							toggle</button>
					</div>

					<div id="recentLoansBody" class="collapsible-body">
						<div class="field-row"
							style="display: flex; justify-content: space-between; align-items: center;">
							<span class="small-muted" id="loansStatus">Loading recent
								loans...</span>

							<div>
								<label for="decisionFilter" class="small-muted">Filter:</label>
								<select id="decisionFilter">
									<option value="ALL">All</option>
									<option value="Approved">Approved</option>
									<option value="Rejected">Rejected</option>
								</select>
							</div>
						</div>

						<div class="table-container" id="loansTableContainer"
							style="display: none;">
							<table class="loans" id="loansTable">
								<thead>
									<tr>
										<th>ID</th>
										<th>Created</th>
										<th>Gender</th>
										<th>Married</th>
										<th>Dependents</th>
										<th>Education</th>
										<th>Self Employed</th>
										<th>Applicant Income</th>
										<th>Loan Amount</th>
										<th>Credit History</th>
										<th>Property Area</th>
										<th>Decision</th>
										<th>Probability</th>
										<th>Actions</th>
									</tr>

								</thead>
								<tbody>
									<!-- Rows will be inserted here by JavaScript -->
								</tbody>
							</table>
						</div>

					</div>
				</div>
			</div>
		</div>
	</div>
	<script>
		function toggleSection(id) {
			var body = document.getElementById(id);
			if (!body)
				return;
			if (body.style.display === "none") {
				body.style.display = "block";
			} else {
				body.style.display = "none";
			}
		}
		(function() {
			var form = document.getElementById("retrainForm");
			if (!form) {
				return;
			}

			form
					.addEventListener(
							"submit",
							function() {
								var btn = document
										.getElementById("retrainButton");
								var container = document
										.getElementById("progressContainer");
								var bar = document
										.getElementById("progressBar");
								var text = document
										.getElementById("progressText");

								if (btn) {
									btn.disabled = true;
									btn.textContent = "Retraining in progress...";
								}

								if (container && bar) {
									container.style.display = "block";
									bar.style.width = "0%";

									var width = 0;
									var interval = setInterval(
											function() {
												if (width >= 90) {
													clearInterval(interval);
													bar.style.width = "100%";
													if (text) {
														text.textContent = "Waiting for server response...";
													}
												} else {
													width += 5;
													bar.style.width = width
															+ "%";
												}
											}, 500);
								}
							});
		})();
	</script>
	<script>
		document.addEventListener("DOMContentLoaded", function() {
			var select = document.getElementById("datasetFile");
			if (!select)
				return;

			var saved = localStorage.getItem("loan_selected_dataset");
			if (saved) {
				for (var i = 0; i < select.options.length; i++) {
					if (select.options[i].value === saved) {
						select.selectedIndex = i;
						break;
					}
				}
			}

			select.addEventListener("change", function() {
				localStorage.setItem("loan_selected_dataset", this.value);
			});
		});
	</script>
	<script>
document.addEventListener("DOMContentLoaded", function () {
    var base = "<%=request.getContextPath()%>";  // e.g. /loan-app
    var url  = base + "/api/loans";

    var statusEl   = document.getElementById("loansStatus");
    var container  = document.getElementById("loansTableContainer");
    var tableBody  = document.querySelector("#loansTable tbody");
    var filterSel  = document.getElementById("decisionFilter");

    if (!statusEl || !container || !tableBody || !filterSel) {
        return;
    }

    var allLoans = []; // store all loans from REST

    function renderLoans(filterValue) {
        // Clear old rows
        while (tableBody.firstChild) {
            tableBody.removeChild(tableBody.firstChild);
        }

        var count = 0;

        allLoans.forEach(function (loan) {
            var decision = loan.decision || "";

            // Apply filter
            if (filterValue !== "ALL" && decision !== filterValue) {
                return;
            }

            count++;

            var tr = document.createElement("tr");

            function cell(value) {
                var td = document.createElement("td");
                td.textContent = (value == null ? "" : value);
                return td;
            }

            tr.appendChild(cell(loan.id));
            tr.appendChild(cell(loan.createdAt));
            tr.appendChild(cell(loan.gender));
            tr.appendChild(cell(loan.married));
            tr.appendChild(cell(loan.dependents));
            tr.appendChild(cell(loan.education));
            tr.appendChild(cell(loan.selfEmployed));
            tr.appendChild(cell(loan.applicantIncome));
            tr.appendChild(cell(loan.loanAmount));
            tr.appendChild(cell(loan.creditHistory));
            tr.appendChild(cell(loan.propertyArea));
            tr.appendChild(cell(loan.decision));
            tr.appendChild(cell(loan.probability));

            // Actions cell with Delete form
            var actionTd = document.createElement("td");
            var form = document.createElement("form");
            form.method = "post";
            form.action = base + "/admin";

            var actionInput = document.createElement("input");
            actionInput.type = "hidden";
            actionInput.name = "action";
            actionInput.value = "deleteLoan";

            var idInput = document.createElement("input");
            idInput.type = "hidden";
            idInput.name = "loanId";
            idInput.value = loan.id;

            var btn = document.createElement("button");
            btn.type = "submit";
            btn.textContent = "Delete";
            btn.className = "btn"; // uses your existing .btn style

            form.appendChild(actionInput);
            form.appendChild(idInput);
            form.appendChild(btn);
            actionTd.appendChild(form);

            tr.appendChild(actionTd);

            tableBody.appendChild(tr);

        });

        if (allLoans.length === 0) {
            statusEl.textContent = "No recent loan records found.";
        } else if (filterValue === "ALL") {
            statusEl.textContent = "Showing " + count + " of " + allLoans.length + " loans.";
        } else {
            statusEl.textContent = "Showing " + count + " " + filterValue + " loans (out of " + allLoans.length + ").";
        }
    }

    // Load data once from REST
    fetch(url)
        .then(function (resp) {
            if (!resp.ok) {
                throw new Error("HTTP " + resp.status);
            }
            return resp.json();
        })
        .then(function (data) {
            if (!Array.isArray(data) || data.length === 0) {
                statusEl.textContent = "No recent loan records found.";
                return;
            }

            allLoans = data;
            container.style.display = "block";
            renderLoans("ALL"); // default view
        })
        .catch(function (err) {
            statusEl.textContent = "Failed to load recent loans: " + err;
            statusEl.classList.add("error");
        });

    // Change handler for dropdown
    filterSel.addEventListener("change", function () {
        var selected = filterSel.value; // ALL / Approved / Rejected
        renderLoans(selected);
    });
});
</script>

</body>
</html>