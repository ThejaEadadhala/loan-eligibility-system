package ec.loan.web;

import ec.loan.ejb.LoanApplicationServiceBean;
import ec.loan.jpa.LoanRecord;
import ec.loan.ejb.LoanAdminService;

import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;

import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.util.Arrays;
import java.util.List;
import java.util.ArrayList;

@WebServlet(name = "AdminServlet", urlPatterns = {"/admin"})
public class AdminServlet extends HttpServlet {

    @EJB
    private LoanApplicationServiceBean service;

    // Folder that contains dataset CSV files
    private static final String DATASET_DIR = "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\loan-datasets";

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        populateCommonAttributes(request, null);
        request.getRequestDispatcher("/WEB-INF/views/admin.jsp").forward(request, response);
    }

    @Override
protected void doPost(HttpServletRequest request,
                      HttpServletResponse response)
        throws ServletException, IOException {

    String action = request.getParameter("action");
    String retrainStatus = null;

    if ("retrain".equals(action)) {
        String datasetFile = request.getParameter("datasetFile");
        String fullPath = null;
        if (datasetFile != null && !datasetFile.isEmpty()) {
            fullPath = DATASET_DIR + File.separator + datasetFile;
        }

        // call EJB
        retrainStatus = service.triggerRetrain(fullPath);

        // populate attributes including retrainStatus
        populateCommonAttributes(request, retrainStatus);

        // forward to JSP in the same request
        request.getRequestDispatcher("/WEB-INF/views/admin.jsp")
               .forward(request, response);
        return;
    }

    if ("trainSparkBatch".equals(action)) {
    String sparkTrainStatus = service.trainSparkBatchModel();
    request.setAttribute("sparkTrainStatus", sparkTrainStatus);

    populateCommonAttributes(request, null);

    request.getRequestDispatcher("/WEB-INF/views/admin.jsp")
           .forward(request, response);
    return;
}

    if ("deleteLoan".equals(action)) {
        String idStr = request.getParameter("loanId");
        try {
            Long id = Long.parseLong(idStr);
            boolean deleted = deleteLoanViaSoap(id, request);
            // optionally store delete status somewhere if you want
        } catch (Exception e) {
            e.printStackTrace();
        }

        response.sendRedirect(request.getContextPath() + "/admin");
        return;
    }

    // fallback
    populateCommonAttributes(request, null);
    request.getRequestDispatcher("/WEB-INF/views/admin.jsp")
           .forward(request, response);
}
   
    // SOAP ENDPOINT
    private boolean deleteLoanViaSoap(Long id, HttpServletRequest req) throws Exception {
        String wsdlUrl = "http://localhost:8080/ec.project-loan-ejb-1.0.0/LoanAdminService/LoanAdminSoapEndpoint?wsdl";
        URL url = new URL(wsdlUrl);

        QName serviceName = new QName("http://ejb.loan.ec/", "LoanAdminService");

        Service svc = Service.create(url, serviceName);

        LoanAdminService port = svc.getPort(LoanAdminService.class);

        return port.deleteLoanById(id);
    }


    private void populateCommonAttributes(HttpServletRequest request,
                                          String retrainStatus) {

        // Static app info
        request.setAttribute("appName", "Loan Eligibility Prediction System");
        request.setAttribute("earVersion", "0.1.0");
        request.setAttribute("modelName", "Logistic Regression - loan_eligibility_model.pkl");
        request.setAttribute("flaskUrl", "http://127.0.0.1:5000/predict");

        // Health check
        String healthStatus = service.checkHealth();
        request.setAttribute("healthStatus", healthStatus);

        // General status message
        request.setAttribute("statusMessage",
                "Web, EJB and Python Flask integration configured inside loan-ear.");

        // Dataset info
            File dir = new File(DATASET_DIR);
            File[] csvFiles = null;

            if (dir.exists() && dir.isDirectory()) {
                csvFiles = dir.listFiles((d, name) ->
                        name.toLowerCase().endsWith(".csv"));
            }

            List<File> datasetFiles;
            if (csvFiles == null) {
                datasetFiles = new ArrayList<File>();
            } else {
                datasetFiles = Arrays.asList(csvFiles);
            }

            request.setAttribute("datasetDir", DATASET_DIR);
            request.setAttribute("datasetFiles", datasetFiles);


        // Recent loans
        List<LoanRecord> recent = service.findRecentLoans(10);
        request.setAttribute("recentLoans", recent);

        // Retrain status message (only set after POST)
        if (retrainStatus != null) {
            request.setAttribute("retrainStatus", retrainStatus);
        }
        if (request.getAttribute("sparkTrainStatus") != null) {
    request.setAttribute("sparkTrainStatus", request.getAttribute("sparkTrainStatus"));
}
    }
}