<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="nav-wrapper">
    <div class="topnav">
        <div class="nav-left">
            <span class="app-title">Loan Processing System</span>
            <c:if test="${not empty sessionScope.currentUser}">
                <span class="role-badge">${sessionScope.currentUser.role}</span>
            </c:if>
        </div>

        <div class="nav-right">
            <c:if test="${not empty sessionScope.currentUser}">
                <span class="user-name">Hi, ${sessionScope.currentUser.username}</span>
            </c:if>

            <a href="${pageContext.request.contextPath}/logout" class="logout-btn">Logout</a>
        </div>
    </div>
</div>

<style>
.nav-wrapper {
    width: 100%;
    background: #ffffff;
    box-shadow: 0 2px 8px rgba(0,0,0,0.08);
    margin-bottom: 20px;
}

.topnav {
    max-width: 1200px;
    margin: 0 auto;
    padding: 14px 22px;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.nav-left {
    display: flex;
    align-items: center;
    gap: 16px;
}

.app-title {
    font-size: 19px;
    font-weight: 600;
    color: #1f2937;
    letter-spacing: 0.4px;
}

/* new links block */
.nav-links {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-left: 10px;
}

.nav-link {
    font-size: 13px;
    color: #2563eb;
    text-decoration: none;
    padding: 4px 8px;
    border-radius: 4px;
    transition: background 0.15s ease, color 0.15s ease;
}

.nav-link:hover {
    background: #eff6ff;
    color: #1d4ed8;
}

.role-badge {
    background: #e0f2fe;
    color: #0369a1;
    padding: 4px 10px;
    font-size: 11px;
    font-weight: 600;
    border-radius: 8px;
    text-transform: uppercase;
    border: 1px solid #bae6fd;
}

/* Right side */
.nav-right {
    display: flex;
    align-items: center;
    gap: 18px;
}

.user-name {
    font-size: 14px;
    color: #4b5563;
}

.logout-btn {
    padding: 8px 16px;
    background: #2563eb;
    color: #ffffff;
    font-size: 13px;
    font-weight: 500;
    border-radius: 6px;
    text-decoration: none;
    transition: all 0.2s ease;
}

.logout-btn:hover {
    background: #1d4ed8;
    box-shadow: 0 4px 10px rgba(37,99,235,0.3);
}

.logout-btn:active {
    transform: scale(0.98);
}
</style>