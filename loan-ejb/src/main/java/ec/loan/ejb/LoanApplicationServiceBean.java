package ec.loan.ejb;

import ec.loan.jpa.LoanRecord;

import javax.ejb.Stateless;
import javax.json.Json;
import javax.json.JsonObject;
import javax.json.JsonReader;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.HttpURLConnection;
import java.net.URL;

import javax.persistence.TypedQuery;
import java.util.List;

@Stateless
public class LoanApplicationServiceBean {

	private static final String FLASK_URL = "http://127.0.0.1:5000/predict";
	private static final String FLASK_HEALTH_URL = "http://127.0.0.1:5000/health";

	    // Spark 2.4.7 config - update paths for your machine
    private static final String SPARK_SUBMIT_PATH =
        "C:\\enterprise\\spark-2.4.7-bin-hadoop2.7\\bin\\spark-submit.cmd";

    // Directory where your Spark batch script and model live
    private static final String SPARK_PYTHON_DIR =
            "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\Python program";

    // Name of the Spark batch scoring script placed in SPARK_PYTHON_DIR
    private static final String SPARK_BATCH_SCRIPT_NAME =
            "loan_spark_batch_score.py";

	@PersistenceContext(unitName = "loanPU")
	private EntityManager em;

	/**
	 * Main business method used by the web layer. 1) Calls Flask /predict 2) Saves
	 * the result as a LoanRecord 3) Returns the decision to the caller
	 */
	public LoanDecision evaluateLoan(LoanRequest request) {
		// Call Python model
		LoanDecision decision = callFlaskPredict(request);

		// Persist into DB (even if rejected or error - you can change rule later)
		saveLoanRecord(request, decision);

		return decision;
	}

	/**
	 * Actually talks to the Flask /predict API and builds the LoanDecision. Kept
	 * separate so evaluateLoan() stays small.
	 */
	private LoanDecision callFlaskPredict(LoanRequest request) {
		try {
			JsonObject payload = Json.createObjectBuilder().add("Gender", valueOrEmpty(request.getGender()))
					.add("Married", valueOrEmpty(request.getMarried()))
					.add("Dependents", valueOrEmpty(request.getDependents()))
					.add("Education", valueOrEmpty(request.getEducation()))
					.add("Self_Employed", valueOrEmpty(request.getSelfEmployed()))
					.add("ApplicantIncome", request.getApplicantIncome())
					.add("CoapplicantIncome", request.getCoapplicantIncome()).add("LoanAmount", request.getLoanAmount())
					.add("Loan_Amount_Term", request.getLoanAmountTerm())
					.add("Credit_History", request.getCreditHistory())
					.add("Property_Area", valueOrEmpty(request.getPropertyArea())).build();

			// 2 - Open HTTP connection to Flask
			URL url = new URL(FLASK_URL);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("POST");
			conn.setDoOutput(true);
			conn.setConnectTimeout(5000);
			conn.setReadTimeout(5000);
			conn.setRequestProperty("Content-Type", "application/json");

			// 3 - Send JSON body
			try (OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream(), "UTF-8")) {
				writer.write(payload.toString());
				writer.flush();
			}

			int status = conn.getResponseCode();
			InputStream is;

			if (status >= 200 && status < 300) {
				is = conn.getInputStream();
			} else {
				is = conn.getErrorStream();
				if (is != null) {
					try (BufferedReader br = new BufferedReader(new InputStreamReader(is))) {
						String line;
						StringBuilder sb = new StringBuilder();
						while ((line = br.readLine()) != null) {
							sb.append(line);
						}
						System.out.println("Flask error response: " + sb.toString());
					}
				}
				return new LoanDecision("Rejected (Python service error " + status + ")", 0.0);
			}

			// 4 - Parse JSON response
			try (JsonReader jsonReader = Json.createReader(is)) {
				JsonObject resp = jsonReader.readObject();

				String decisionText = resp.getString("decision", "Rejected (no decision from model)");
				double probability = 0.0;

				if (resp.containsKey("probability") && !resp.isNull("probability")) {
					try {
						probability = resp.getJsonNumber("probability").doubleValue();
					} catch (Exception e) {
						// ignore, keep default 0.0
					}
				}

				return new LoanDecision(decisionText, probability);
			} finally {
				conn.disconnect();
			}

		} catch (IOException e) {
			e.printStackTrace();
			return new LoanDecision("Rejected (Python service unavailable)", 0.0);
		} catch (Exception e) {
			e.printStackTrace();
			return new LoanDecision("Rejected (unexpected error in EJB)", 0.0);
		}
	}

	// 29-11-2025: AS
	public String checkHealth() {
		try {
			URL url = new URL(FLASK_HEALTH_URL);
			HttpURLConnection conn = (HttpURLConnection) url.openConnection();
			conn.setRequestMethod("GET");
			conn.setConnectTimeout(3000);
			conn.setReadTimeout(3000);

			int status = conn.getResponseCode();
			if (status >= 200 && status < 300) {
				try (InputStream is = conn.getInputStream(); JsonReader reader = Json.createReader(is)) {

					JsonObject obj = reader.readObject();
					String statusText = obj.getString("status", "unknown");

					if ("ok".equalsIgnoreCase(statusText)) {
						return "Flask model service is UP";
					} else {
						return "Flask model service responded with status = " + statusText;
					}
				}
			} else {
				return "Flask model service returned HTTP " + status;
			}
		} catch (Exception e) {
			e.printStackTrace();
			return "Flask model service is DOWN or unreachable";
		}
	}

	// Helper - JSON builder does not accept null Strings directly
	private String valueOrEmpty(String s) {
		return (s == null) ? "" : s;
	}

	/**
	 * Persist one, LoanRecord row for each evaluated loan.
	 */
	private void saveLoanRecord(LoanRequest request, LoanDecision decision) {
		try {
			LoanRecord r = new LoanRecord();
			r.setGender(request.getGender());
			r.setMarried(request.getMarried());
			r.setDependents(request.getDependents());
			r.setEducation(request.getEducation());
			r.setSelfEmployed(request.getSelfEmployed());

			r.setApplicantIncome(request.getApplicantIncome());
			r.setCoapplicantIncome(request.getCoapplicantIncome());
			r.setLoanAmount(request.getLoanAmount());
			r.setLoanAmountTerm(request.getLoanAmountTerm());
			r.setCreditHistory(request.getCreditHistory());
			r.setPropertyArea(request.getPropertyArea());

			r.setDecision(decision.getDecision());
			r.setProbability(decision.getProbability());

			em.persist(r);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public List<LoanRecord> findRecentLoans(int maxResults) {
		TypedQuery<LoanRecord> q = em.createQuery("SELECT r FROM LoanRecord r ORDER BY r.createdAt DESC",
				LoanRecord.class);
		q.setMaxResults(maxResults);
		return q.getResultList();
	}

	/**
	 * Trigger model retraining by calling the Python training script. Adjust
	 * TRAIN_COMMAND to match real path.
	 */
	// Old no-arg method kept for compatibility
	public String triggerRetrain() {
		return triggerRetrain(null);
	}

	/**
	 * Trigger model retraining by calling the Python training script. If
	 * datasetPath is null or empty, the default training CSV is used.
	 */
	public String triggerRetrain(String datasetPath) {
		String pythonDir = "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\Python program";
		String modelPath = pythonDir + "\\loan_eligibility_model.pkl";

		// Default dataset if none passed
		String defaultDataset = "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\loan-datasets\\train_u6lujuX_CVtuZ9i.csv";

		if (datasetPath == null || datasetPath.trim().isEmpty()) {
			datasetPath = defaultDataset;
		}

		String command = "cd /d \"" + pythonDir + "\" && python loan_train.py \"" + datasetPath + "\"";

		try {
			ProcessBuilder pb = new ProcessBuilder("cmd.exe", "/c", command);
			pb.redirectErrorStream(true);
			Process p = pb.start();

			StringBuilder output = new StringBuilder();
			try (BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream(), "UTF-8"))) {
				String line;
				int lineCount = 0;
				while ((line = br.readLine()) != null && lineCount < 200) {
					output.append(line).append('\n');
					lineCount++;
				}
			}

			int exitCode = p.waitFor();
			String outText = output.toString();

			if (exitCode == 0 && outText.contains("Saved final model")) {
				return "Model retraining completed (exit code 0).\n" + "Model saved to: " + modelPath + "\n\n"
						+ "Output:\n" + outText;
			} else {
				return "Model retraining finished with exit code " + exitCode + ".\n"
						+ "Model path (may not be updated): " + modelPath + "\n\n" + "Output:\n" + outText;
			}

		} catch (Exception e) {
			e.printStackTrace();
			return "Model retraining failed - " + e.getMessage();
		}
	}

	public List<LoanRecord> findAllLoans() {
		TypedQuery<LoanRecord> q = em.createQuery("SELECT r FROM LoanRecord r ORDER BY r.createdAt ASC",
				LoanRecord.class);
		return q.getResultList();
	}
	
	public boolean deleteLoanById(Long id) {
	    if (id == null) return false;
	    LoanRecord r = em.find(LoanRecord.class, id);
	    if (r == null) {
	        return false;
	    }
	    em.remove(r);
	    return true;
	}

	    /**
     * Run Spark batch scoring for a CSV file of applicants.
     *
     * @param inputPath  full path of the uploaded applicants CSV
     * @param outputPath full path where Spark should write the predictions CSV
     * @return a status message that starts with "OK" if success, or "Model retraining finished..."
     */
    public String runSparkBatchScore(String inputPath, String outputPath) {

    String command = "cd /d \"" + SPARK_PYTHON_DIR + "\" && \"" + SPARK_SUBMIT_PATH + "\" "
            + "\"" + SPARK_BATCH_SCRIPT_NAME + "\" "
            + "\"" + inputPath + "\" "
            + "\"" + outputPath + "\"";

    System.out.println("Running Spark command: " + command);

    try {
        ProcessBuilder pb = new ProcessBuilder("cmd.exe", "/c", command);

        // IMPORTANT: force Spark to use Python 3.7 - to professor: Sprak 2.4.7 is incompatible with python3.11
        pb.environment().put("PYSPARK_PYTHON", "C:\\Python37\\python.exe");
        pb.environment().put("PYSPARK_DRIVER_PYTHON", "C:\\Python37\\python.exe");

        pb.redirectErrorStream(true);
        Process p = pb.start();

        StringBuilder output = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(p.getInputStream(), "UTF-8"))) {
            String line;
            int lineCount = 0;
            while ((line = br.readLine()) != null && lineCount < 300) {
                output.append(line).append('\n');
                lineCount++;
            }
        }

        int exitCode = p.waitFor();
        String outText = output.toString();

        if (exitCode == 0) {
            return "OK - Spark batch scoring completed.\n"
                    + "Output file: " + outputPath + "\n\n"
                    + "Spark output (first lines):\n" + outText;
        } else {
            return "Spark batch scoring finished with exit code " + exitCode + ".\n\n"
                    + "Spark output (first lines):\n" + outText;
        }

    } catch (Exception e) {
        e.printStackTrace();
        return "Spark batch scoring failed - " + e.getMessage();
    }
}
    
    public String trainSparkBatchModel() {
        String pythonExe = "C:\\Python37\\python.exe";
        String scriptDir = "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\Python program";
        String scriptName = "loan_train_spark.py";
        String datasetPath = "C:\\enterprise\\workspace\\Project\\loan-app\\Python-Datasets\\loan-datasets\\train_u6lujuX_CVtuZ9i.csv";

        ProcessBuilder pb = new ProcessBuilder(
                pythonExe,
                scriptName,
                datasetPath
        );

        pb.directory(new File(scriptDir)); // this is VERY important
        pb.redirectErrorStream(true);

        StringBuilder output = new StringBuilder();

        try {
            Process p = pb.start();
            BufferedReader reader = new BufferedReader(
                    new InputStreamReader(p.getInputStream())
            );
            String line;
            while ((line = reader.readLine()) != null) {
                output.append(line).append("\n");
            }

            int exit = p.waitFor();

            if (exit == 0) {
                return "OK - Spark batch model training finished:\n" + output;
            } else {
                return "ERROR - exit code " + exit + ":\n" + output;
            }

        } catch (Exception e) {
            return "Exception: " + e.getMessage();
        }
    }


}