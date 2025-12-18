<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<!DOCTYPE html>
<html>
<head>
<title>Loan Application – Loan Officer</title>
<meta name="viewport" content="width=device-width, initial-scale=1">

<style>
body {
	margin: 0;
	padding: 0;
	font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial,
		sans-serif;
	background: #f3f4f6;
	color: #111827;
}

.page-container {
	max-width: 800px;
	margin: 40px auto;
	padding: 0 20px;
}

.card {
	background: #ffffff;
	border-radius: 12px;
	padding: 24px 28px;
	box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
}

h2 {
	margin-top: 0;
	font-size: 24px;
	font-weight: 600;
	color: #1f2937;
}

.form-row {
	margin-bottom: 16px;
}

label {
	display: block;
	font-size: 14px;
	font-weight: 500;
	margin-bottom: 6px;
	color: #374151;
}

select, input[type="number"] {
	width: 100%;
	padding: 10px 12px;
	font-size: 14px;
	border-radius: 6px;
	border: 1px solid #d1d5db;
	background-color: #f9fafb;
	transition: border-color 0.2s ease, background 0.2s ease;
}

select:focus, input:focus {
	outline: none;
	border-color: #2563eb;
	background: #ffffff;
	box-shadow: 0 0 0 1px rgba(37, 99, 235, 0.25);
}

.btn-submit {
	width: 100%;
	padding: 12px 20px;
	font-size: 16px;
	font-weight: 600;
	border-radius: 8px;
	border: none;
	cursor: pointer;
	background: linear-gradient(135deg, #2563eb, #1d4ed8);
	color: #ffffff;
	box-shadow: 0 8px 16px rgba(37, 99, 235, 0.3);
	transition: all 0.15s ease;
	margin-top: 10px;
}

.btn-submit:hover {
	background: linear-gradient(135deg, #1d4ed8, #1e40af);
	box-shadow: 0 6px 14px rgba(30, 64, 175, 0.35);
}

.btn-submit:active {
	transform: translateY(1px);
	box-shadow: 0 3px 8px rgba(30, 64, 175, 0.35);
}

.two-col {
	display: flex;
	gap: 16px;
}

.two-col .form-row {
	flex: 1;
}

.logout-btn {
	display: inline-flex;
	align-items: center;
	padding: 8px 16px;
	font-size: 13px;
	font-weight: 600;
	border-radius: 8px;
	text-decoration: none;
	color: #ef4444;
	background-color: #fef2f2;
	border: 1px solid #fecaca;
	transition: all 0.2s ease;
	gap: 6px;
}

.logout-btn:hover {
	background-color: #fee2e2;
	border-color: #fca5a5;
	color: #b91c1c;
	transform: translateY(-2px);
	box-shadow: 0 4px 10px rgba(185, 28, 28, 0.25);
}

.logout-btn:active {
	transform: translateY(0);
	box-shadow: 0 2px 6px rgba(185, 28, 28, 0.25);
}
</style>
</head>
<body>
    <jsp:include page="/WEB-INF/views/navbar.jsp" />
	<div class="page-container">

		<div class="card">
			<h2>Loan Application Form</h2>
				<form action="${pageContext.request.contextPath}/loanofficer"
					method="post">

					<div class="two-col">
						<div class="form-row">
							<label for="Gender">Gender</label> <select id="Gender"
								name="Gender">
								<option value="Male">Male</option>
								<option value="Female">Female</option>
							</select>
						</div>

						<div class="form-row">
							<label for="Married">Married</label> <select id="Married"
								name="Married">
								<option value="Yes">Yes</option>
								<option value="No">No</option>
							</select>
						</div>
					</div>

					<div class="two-col">
						<div class="form-row">
							<label for="Dependents">Dependents</label> <select
								id="Dependents" name="Dependents">
								<option value="0">0</option>
								<option value="1">1</option>
								<option value="2">2</option>
								<option value="3+">3+</option>
							</select>
						</div>

						<div class="form-row">
							<label for="Education">Education</label> <select id="Education"
								name="Education">
								<option value="Graduate">Graduate</option>
								<option value="Not Graduate">Not Graduate</option>
							</select>
						</div>
					</div>

					<div class="two-col">
						<div class="form-row">
							<label for="Self_Employed">Self Employed</label> <select
								id="Self_Employed" name="Self_Employed">
								<option value="No">No</option>
								<option value="Yes">Yes</option>
							</select>
						</div>

						<div class="form-row">
							<label for="Credit_History">Credit History</label> <select
								id="Credit_History" name="Credit_History">
								<option value="1.0">1.0 (Good)</option>
								<option value="0.0">0.0 (Bad)</option>
							</select>
						</div>
					</div>

					<div class="form-row">
						<label for="ApplicantIncome">Applicant Income</label> <input
							type="number" id="ApplicantIncome" name="ApplicantIncome"
							required>
					</div>

					<div class="form-row">
						<label for="CoapplicantIncome">Coapplicant Income</label> <input
							type="number" id="CoapplicantIncome" name="CoapplicantIncome"
							required>
					</div>

					<div class="two-col">
						<div class="form-row">
							<label for="LoanAmount">Loan Amount (in thousands)</label> <input
								type="number" id="LoanAmount" name="LoanAmount" required>
						</div>

						<div class="form-row">
							<label for="Loan_Amount_Term">Loan Amount Term (in days)</label>
							<input type="number" id="Loan_Amount_Term"
								name="Loan_Amount_Term" required>
						</div>
					</div>

					<div class="form-row">
						<label for="Property_Area">Property Area</label> <select
							id="Property_Area" name="Property_Area">
							<option value="Urban">Urban</option>
							<option value="Semiurban">Semi-urban</option>
							<option value="Rural">Rural</option>
						</select>
					</div>

					<button type="submit" class="btn-submit">Check Eligibility</button>
				</form>
		</div>

	</div>

</body>
</html>
