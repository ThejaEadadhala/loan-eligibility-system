<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <title>Loan App – Login</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <style>
        /* Reset-ish */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Arial, sans-serif;
            background: radial-gradient(circle at top, #2563eb 0, #020617 55%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #111827;
        }

        .login-wrapper {
            width: 100%;
            max-width: 420px;
            padding: 16px;
        }

        .card {
            background-color: #ffffff;
            border-radius: 12px;
            box-shadow: 0 20px 40px rgba(15, 23, 42, 0.35);
            padding: 24px 26px 22px 26px;
            position: relative;
            overflow: hidden;
        }

        .card::before {
            content: "";
            position: absolute;
            inset: 0;
            border-radius: inherit;
            padding: 1px;
            background: linear-gradient(135deg, #2563eb, #10b981);
            -webkit-mask: 
                linear-gradient(#000 0 0) content-box, 
                linear-gradient(#000 0 0);
            -webkit-mask-composite: xor;
                    mask-composite: exclude;
        }

        .card-inner {
            position: relative;
        }

        .app-title {
            font-size: 22px;
            font-weight: 600;
            color: #111827;
            margin-bottom: 4px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .app-pill {
            font-size: 11px;
            padding: 2px 8px;
            border-radius: 999px;
            background: #eff6ff;
            color: #1d4ed8;
            border: 1px solid #bfdbfe;
        }

        .subtitle {
            font-size: 13px;
            color: #6b7280;
            margin-bottom: 18px;
        }

        .role-hint {
            font-size: 11px;
            color: #9ca3af;
            margin-bottom: 10px;
        }

        .form-group {
            margin-bottom: 14px;
        }

        label {
            display: block;
            font-size: 13px;
            font-weight: 500;
            color: #374151;
            margin-bottom: 4px;
        }

        input[type="text"],
        input[type="password"] {
            width: 100%;
            padding: 8px 10px;
            font-size: 13px;
            border-radius: 6px;
            border: 1px solid #d1d5db;
            background-color: #f9fafb;
            transition: border-color 0.15s ease, box-shadow 0.15s ease, background-color 0.15s ease;
        }

        input[type="text"]:focus,
        input[type="password"]:focus {
            outline: none;
            border-color: #2563eb;
            background-color: #ffffff;
            box-shadow: 0 0 0 1px rgba(37, 99, 235, 0.2);
        }

        .error-box {
            font-size: 12px;
            color: #b91c1c;
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 6px;
            padding: 6px 8px;
            margin-bottom: 10px;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        .error-dot {
            width: 8px;
            height: 8px;
            border-radius: 999px;
            background-color: #dc2626;
            flex-shrink: 0;
        }

        .helper-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 4px;
            margin-bottom: 14px;
            font-size: 11px;
            color: #6b7280;
        }

        .hint {
            font-size: 11px;
            color: #9ca3af;
        }

        .btn-primary {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 100%;
            padding: 9px 12px;
            font-size: 14px;
            font-weight: 500;
            border-radius: 999px;
            border: none;
            cursor: pointer;
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: #ffffff;
            box-shadow: 0 12px 20px rgba(37, 99, 235, 0.35);
            transition: transform 0.1s ease, box-shadow 0.1s ease, background 0.1s ease;
        }

        .btn-primary:hover {
            background: linear-gradient(135deg, #1d4ed8, #1d4ed8);
            box-shadow: 0 8px 16px rgba(30, 64, 175, 0.4);
            transform: translateY(-1px);
        }

        .btn-primary:active {
            transform: translateY(0);
            box-shadow: 0 4px 10px rgba(30, 64, 175, 0.4);
        }

        .btn-primary:disabled {
            opacity: 0.55;
            cursor: not-allowed;
            box-shadow: none;
        }

        .btn-primary span.icon {
            margin-left: 6px;
            font-size: 13px;
        }

        .footer-text {
            margin-top: 10px;
            font-size: 11px;
            color: #9ca3af;
            text-align: center;
        }

        .footer-text strong {
            color: #6b7280;
        }

        @media (max-width: 480px) {
            .card {
                padding: 20px 18px 18px 18px;
            }

            .app-title {
                font-size: 20px;
            }
        }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div class="card">
        <div class="card-inner">
            <div class="app-title">
                Loan Eligibility
                <span class="app-pill">Officer &amp; Admin</span>
            </div>
            <div class="subtitle">
                Sign in with your assigned credentials to access your dashboard.
            </div>

            <div class="role-hint">
                Admin and Loan Officer are routed to different pages based on role.
            </div>

            <c:if test="${not empty error}">
                <div class="error-box">
                    <span class="error-dot"></span>
                    <span>${error}</span>
                </div>
            </c:if>

            <form method="post" action="${pageContext.request.contextPath}/login">
                <div class="form-group">
                    <label for="username">Username</label>
                    <input id="username"
                           type="text"
                           name="username"
                           autocomplete="username"
                           required />
                </div>

                <div class="form-group">
                    <label for="password">Password</label>
                    <input id="password"
                           type="password"
                           name="password"
                           autocomplete="current-password"
                           required />
                </div>

                <div class="helper-row">
                    <span class="hint">
                        Example: <strong>admin1 / admin123</strong> or <strong>officer1 / officer123</strong>
                    </span>
                </div>

                <button type="submit" class="btn-primary">
                    Sign in
                    <span class="icon">-></span>
                </button>
            </form>

            <div class="footer-text">
                <strong>Tip:</strong> Use your assigned admin or officer account.  
            </div>
        </div>
    </div>
</div>

</body>
</html>
