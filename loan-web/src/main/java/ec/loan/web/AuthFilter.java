package ec.loan.web;

import ec.loan.auth.User;
import ec.loan.auth.UserRole;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// Adjust urlPatterns to match your actual protected URLs
@WebFilter(urlPatterns = {"/admin", "/loanofficer", "/admin/*", "/officer/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // no-op
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req  = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User user = null;
        UserRole role = null;

        if (session != null) {
            Object u = session.getAttribute("currentUser");
            Object r = session.getAttribute("userRole");
            if (u instanceof User) {
                user = (User) u;
            }
            if (r instanceof UserRole) {
                role = (UserRole) r;
            }
        }

        String requestedUri = req.getRequestURI();

        if (user == null || role == null) {
            // Not logged in
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Simple role-based restriction:
        // If URL contains "/admin", require ADMIN
        if (requestedUri.contains("/admin") && role != UserRole.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not allowed to access this page.");
            return;
        }

        // If URL contains "/officer", require LOAN_OFFICER
        if (requestedUri.contains("/loanofficer") && role != UserRole.LOAN_OFFICER) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "You are not allowed to access this page.");
            return;
        }

        // All good
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // no-op
    }
}
