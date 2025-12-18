package ec.loan.web.rest;

import ec.loan.ejb.LoanApplicationServiceBean;
import ec.loan.ejb.LoanDecision;
import ec.loan.ejb.LoanRequest;
import ec.loan.jpa.LoanRecord;

import java.util.List;

import javax.ejb.EJB;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

@Path("/loans")
@Produces(MediaType.APPLICATION_JSON)
@Consumes(MediaType.APPLICATION_JSON)
public class LoanRestResource {

    @EJB
    private LoanApplicationServiceBean service;

    @POST
    @Path("/evaluate")
    public Response evaluateLoan(LoanRequest request) {
        try {
            LoanDecision decision = service.evaluateLoan(request);
            return Response.ok(decision).build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}")
                    .build();
        }
    }
    
    @GET
    public List<LoanRecord> getAllEvaluatedLoans() {
        return service.findAllLoans();  
    }
}
