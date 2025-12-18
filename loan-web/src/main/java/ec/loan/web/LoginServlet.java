package ec.loan.web;

import ec.loan.auth.User;
import ec.loan.auth.UserRole;
import ec.loan.auth.UserService;

import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @EJB
    private UserService userService;  

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Just forward to login.jsp
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        String username = req.getParameter("username");
        String password = req.getParameter("password");

        User user = userService.authenticate(username, password);

        if (user == null) {
            req.setAttribute("error", "Invalid username or password");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }
 
        HttpSession session = req.getSession(true);
        session.setAttribute("currentUser", user);
        session.setAttribute("userRole", user.getRole());

        // Redirect based on role
        if (user.getRole() == UserRole.ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/admin");     
        } else if (user.getRole() == UserRole.LOAN_OFFICER) {
            resp.sendRedirect(req.getContextPath() + "/loanofficer");
        } else {
            // fallback
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
        }
    }
}
