package ec.loan.web.rest;

import javax.ws.rs.ApplicationPath;
import javax.ws.rs.core.Application;

/**
 * Activates JAX-RS for this application under /api.
 */
@ApplicationPath("/api")
public class RestApplication extends Application {
}
