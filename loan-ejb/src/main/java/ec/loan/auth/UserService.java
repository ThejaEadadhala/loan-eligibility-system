package ec.loan.auth;

import javax.ejb.Local;

@Local
public interface UserService {

    /**
     * Authenticates user by username & password.
     *
     * @return User object if credentials are correct, otherwise null.
     */
    User authenticate(String username, String password);
}
