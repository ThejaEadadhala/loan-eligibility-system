package ec.loan.ejb;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;

@WebService(targetNamespace = "http://ejb.loan.ec/")
public interface LoanAdminService {

    @WebMethod(operationName = "deleteLoanById")
    boolean deleteLoanById(@WebParam(name = "id") Long id);
}
