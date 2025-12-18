package ec.loan.web;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import javax.ejb.EJB;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import ec.loan.ejb.LoanApplicationServiceBean;

@WebServlet("/bulk")
@MultipartConfig
public class BulkLoanServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // Base directory where uploaded and output CSV files will be stored.
    private static final String BULK_BASE_DIR =
            "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\bulk";

    @EJB
    private LoanApplicationServiceBean loanService;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("/WEB-INF/views/bulkLoan.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Make sure base directory exists
        File baseDir = new File(BULK_BASE_DIR);
        if (!baseDir.exists()) {
            baseDir.mkdirs();
        }

        Part filePart = request.getPart("applicantsFile");
        if (filePart == null || filePart.getSize() == 0) {
            request.setAttribute("statusMessage", "Please select a CSV file to upload.");
            request.getRequestDispatcher("/WEB-INF/views/bulkLoan.jsp")
                   .forward(request, response);
            return;
        }

        String timestamp = LocalDateTime.now()
                .format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss"));

        String inputFileName = "applicants_" + timestamp + ".csv";
        String outputFileName = "predictions_" + timestamp + ".csv";

        File inputFile = new File(baseDir, inputFileName);
        File outputFile = new File(baseDir, outputFileName);

        // Save the uploaded file to disk
        try (InputStream in = filePart.getInputStream();
             FileOutputStream out = new FileOutputStream(inputFile)) {

            byte[] buffer = new byte[8192];
            int len;
            while ((len = in.read(buffer)) != -1) {
                out.write(buffer, 0, len);
            }
        }

        // Call EJB to run Spark batch scoring
        String status = loanService.runSparkBatchScore(
                inputFile.getAbsolutePath(),
                outputFile.getAbsolutePath());

        request.setAttribute("statusMessage", status);

        // If Spark finished successfully, prepare download file name
        if (status != null && status.startsWith("OK")) {
            // JSP will build the full URL using contextPath + /download-bulk
            request.setAttribute("downloadFile", outputFileName);
        }

        request.getRequestDispatcher("/WEB-INF/views/bulkLoan.jsp")
               .forward(request, response);
    }
}