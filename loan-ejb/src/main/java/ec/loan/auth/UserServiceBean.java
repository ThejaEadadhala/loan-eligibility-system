package ec.loan.auth;

import javax.ejb.Stateless;
import java.util.HashMap;
import java.util.Map;

@Stateless
public class UserServiceBean implements UserService {

    // Simple in-memory user store for now
    // username -> [password, role]
    private static final Map<String, String[]> USERS = new HashMap<>();

    static {
        // username, password, role
        USERS.put("admin1", new String[] {"admin123", "ADMIN"});
        USERS.put("officer1", new String[] {"officer123", "LOAN_OFFICER"});
    }

    @Override
    public User authenticate(String username, String password) {
        if (username == null || password == null) {
            return null;
        }

        String[] data = USERS.get(username);
        if (data == null) {
            return null;
        }

        String storedPassword = data[0];
        String roleName = data[1];

        if (!storedPassword.equals(password)) {
            return null;
        }

        UserRole role = UserRole.valueOf(roleName);
        return new User(username, role);
    }
}
