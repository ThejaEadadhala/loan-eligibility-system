README.txt  
Loan Eligibility Prediction System  
Java EE, EJB, JSP, WildFly, Flask ML, Spark Batch Scoring  

This project has three main parts  
A Java EE app using Servlets, JSP, and EJB  
A Flask Python service that predicts a single loan  
A Spark Python program that scores many loans in bulk  
A MySQL database running on XAMPP  

The main project folder is  
C:\enterprise\workspace\Project\loan-app  

From this folder, you can build everything and deploy the app.


1. Requirements

Java 8  
Maven 3  
WildFly 18.0.1.Final  

Backend tools  
XAMPP for Apache and MySQL  
Python 3.11 for the Flask service  
Python 3.7 for Spark batch scoring  
Apache Spark 2.4.7 with Hadoop 2.7  

Python libraries for Flask (Python 3.11)  
pip install flask pandas scikit-learn joblib  

Python libraries for Spark (Python 3.7)  
C:\Python37\python.exe -m pip install pandas scikit-learn  


2. Start Backend Services

Start XAMPP  
Open the XAMPP Control Panel  
Start Apache  
Start MySQL  

Start the Flask ML service using Python 3.11  
Go to the folder with app.py and loan_eligibility_model.pkl  
Run:
python app.py
OR
py -3.11 app.py

Flask will run on  
http://127.0.0.1:5000/predict  

Keep this terminal open.

Spark setup needs a small fix for Windows  
Make a folder  
C:\tmp\hive  
Give permission using winutils  
%HADOOP_HOME%\bin\winutils.exe chmod 777 /tmp/hive  

You can also start Spark master or worker if you want, but this is optional.  
To test Spark quickly  
spark-shell  


3. Set up Spark 2.4.7 to use Python 3.7

Download Spark 2.4.7 and extract it to  
C:\enterprise\spark-2.4.7-bin-hadoop2.7  

Set these environment variables  
SPARK_HOME = C:\enterprise\spark-2.4.7-bin-hadoop2.7  
Add %SPARK_HOME%\bin to PATH  

Tell Spark to use Python 3.7  
PYSPARK_PYTHON = C:\Python37\python.exe  
PYSPARK_DRIVER_PYTHON = C:\Python37\python.exe  

You can also set  
HADOOP_HOME = C:\enterprise\spark-2.4.7-bin-hadoop2.7  

Check if Spark is working  
spark-submit --version  


4. Train the Models

This project uses two models  
One model is used by Flask to score a single loan  
One model is used by Spark to score many loans at once  


4.1 Train the Single Loan Flask Model

You can train it in two ways.

(1) Manual training  
Run your Python training script in the same folder as app.py.  
This creates loan_eligibility_model.pkl.

(2) Training from the Admin page inside the web app  
Open the Admin page  
Choose a CSV file  
Click Trigger Model Retraining  
WildFly will call the training EJB  
A new model file will be saved  
Restart Flask so it loads the new file  


4.2 Train the Spark Batch Model using Python 3.7

There are also two ways to train this model.

(1) Manual training  
Go to  
C:\enterprise\workspace\Project\loan-app\Python-Datasets\Python program  

Run  
C:\Python37\python.exe loan_train_spark.py  
 "C:\enterprise\workspace\Project\loan-app\Python-Datasets\loan-datasets\train_u6lujuX_CVtuZ9i.csv"  

This creates  
loan_eligibility_model_spark.pkl  

(2) Training from the Admin page  
In the Admin dashboard click Train Spark Batch Model  
The app will call service.trainSparkBatchModel  
This will also create loan_eligibility_model_spark.pkl  


5. Test Spark Batch Scoring Manually (optional)

Go to  
C:\enterprise\workspace\Project\loan-app\Python-Datasets\Python program  

Set Python 3.7 for Spark  
set PYSPARK_PYTHON=C:\Python37\python.exe  
set PYSPARK_DRIVER_PYTHON=C:\Python37\python.exe  

Run  
spark-submit loan_spark_batch_score.py  
 "C:\enterprise\workspace\Project\loan-app\Python-Datasets\bulk\input.csv"  
 "C:\enterprise\workspace\Project\loan-app\Python-Datasets\bulk\output.csv"  


6. Build Java Modules

Go to the root folder  
C:\enterprise\workspace\Project\loan-app  

Run  
mvn clean install  

You can also build each module one by one

loan-ejb  
cd loan-ejb  
mvn clean install  

loan-web  
cd loan-web  
mvn clean install  

loan-ear  
cd loan-ear  
mvn clean package  

This creates  
loan-ear\target\loan-ear-0.1.0.ear  


7. Deploy the EAR to WildFly

Delete the old EAR in  
C:\enterprise\wildfly-18.0.1.Final\standalone\deployments  

Copy the new EAR  
copy <workspace>\loan-app\loan-ear\target\loan-ear-0.1.0.ear .  

Start WildFly  
standalone.bat -c standalone-full.xml  


8. Run the Web Application

Open  
http://127.0.0.1:8080/loan-app/  


Single Loan Prediction  
Go to  
loanofficer  

The flow is  
JSP  
Servlet  
EJB  
Flask (Python)  
EJB  
JSP  


Bulk Loan Scoring with Spark  
Go to  
bulk  

Upload a CSV  
The Spark job runs  
You will get a link to download the output CSV  


9. Folders for Spark Batch Scoring

Python-Datasets  
  Python program  
    loan_train_spark.py  
    loan_spark_batch_score.py  
    loan_eligibility_model_spark.pkl  

  loan-datasets  
    train_u6lujuX_CVtuZ9i.csv  

  bulk  
    applicants_TIMESTAMP.csv  
    predictions_TIMESTAMP.csv  


10. How Spark is Triggered from Java

LoanApplicationServiceBean  
Sets Python 3.7  
Builds spark-submit command  
Runs it  
Reads the output and error logs  
Returns status to servlet  

BulkLoanServlet  
Uploads CSV into bulk folder  
Calls runSparkBatchScore  
Shows a status message  
Shows download link if scoring worked  

DownloadBulkServlet  
Streams CSV file back to the user  


11. After Making Code Changes

If Java changes  
mvn clean install  
mvn clean package  
Deploy EAR again  

If Flask changes  
Restart python app.py  

If Spark scripts change  
Train the Spark model again  


12. Services that Must Be Running

XAMPP MySQL  
Flask app.py  
WildFly server  
Spark installed  
Python 3.7 installed  
Model files present  

loan_eligibility_model.pkl  
loan_eligibility_model_spark.pkl  


End of README