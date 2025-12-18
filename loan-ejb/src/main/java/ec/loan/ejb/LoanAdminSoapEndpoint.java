package ec.loan.ejb;

import javax.ejb.EJB;
import javax.ejb.Stateless;
import javax.jws.WebService;

@Stateless
@WebService(
        serviceName     = "LoanAdminService",
        portName        = "LoanAdminPort",
        targetNamespace = "http://ejb.loan.ec/",
        endpointInterface = "ec.loan.ejb.LoanAdminService"
)
public class LoanAdminSoapEndpoint implements LoanAdminService {

    @EJB
    private LoanApplicationServiceBean service;

    @Override
    public boolean deleteLoanById(Long id) {
        return service.deleteLoanById(id);
    }
}
