# WebAppForPaymentReconciliation
Payment Reconciliation Tool
This repository contains the code for the Payment Reconciliation Tool, a Shiny web application designed for payment reconciliation tasks. The app allows users to upload Excel files, which contain payment data, and processes them to display summary and reconciliation results.

Features:
File Upload: Upload Excel files containing stock and cost data.
Data Processing: The app processes data from two sheets (stock and cost) and calculates key metrics such as the total amount for stock and cost, as well as variance.
Data Summarization: The app summarizes the data based on predefined categories (e.g., Purchases, Returns, Credit Memos).
Downloadable Results: Users can download the processed results in Excel format for further analysis.
UI/UX: The interface has been designed to be user-friendly, with a responsive layout and simple navigation.
Requirements:
R (>= 4.0.0)
Shiny
readxl
dplyr
tidyr
writexl
scales
Installation:
To use the app locally, follow these steps:

Clone the repository:

bash
Copy code
git clone https://github.com/your_username/payment-reconciliation-tool.git
Set up the required packages in R:

r
Copy code
install.packages(c("shiny", "readxl", "dplyr", "tidyr", "writexl", "scales"))
Run the Shiny app:

r
Copy code
library(shiny)
runApp('path/to/repository')
Deployment:
The app is deployed on shinyapps.io, and can be accessed here.

How to Use:
Upload File: Select the Excel file containing your payment data (must have two sheets for stock and cost data).
View Results: The app will process the file and display the reconciled data along with the calculated variances.
Download Results: Download the results as an Excel file for further review and analysis.
Contributing:
Feel free to contribute to this project by submitting issues or pull requests. Your feedback and suggestions are welcome!

License:
This project is licensed under the MIT License - see the LICENSE file for details.
