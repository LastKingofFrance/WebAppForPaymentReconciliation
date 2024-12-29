library(shiny)
library(readxl)
library(dplyr)
library(tidyr)
library(writexl)
library(scales)
library(future)

# Increase the file upload size limit to 50MB
options(shiny.maxRequestSize = 50 * 1024^2)
options(shiny.timeout = 600)  # Increase the timeout limit to 10 minutes

plan(multisession)  # Use multiple sessions to run tasks in parallel

# UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body {
        background-image: url('https://cdn.standardmedia.co.ke/images/wysiwyg/images/9yuQSAXlnyz1ASiHnNel6ykISOf5v6b80gNR23I1.jpg');
        background-size: cover;
        color: #333;
      }
      .title {
        text-align: center;
        font-size: 2.5em;
        font-weight: bold;
        margin-top: 20px;
        color: #0056b3;
      }
      .panel {
        background: rgba(255, 255, 255, 0.8);
        padding: 20px;
        border-radius: 10px;
      }
      table {
        width: 100%;
        border-collapse: collapse;
        margin: 20px 0;
      }
      th, td {
        border: 1px solid #ddd;
        padding: 8px;
        text-align: center;
      }
      th {
        background-color: #f2f2f2;
        color: black;
      }
    "))
  ),
  div(class = "title", "Payment Reconciliation Tool"),
  div(
    class = "panel",
    sidebarLayout(
      sidebarPanel(
        fileInput("file", "Upload Excel File", accept = ".xlsx"),
        downloadButton("download", "Download Results")
      ),
      mainPanel(
        tableOutput("summary")
      )
    )
  )
)

# Server
server <- function(input, output) {
  process_data <- reactive({
    req(input$file)
    file <- input$file$datapath
    
    future({
      lab_stock_data <- read_excel(file, sheet = 1) %>% select(`Document No.`, Amount)
      lab_cost_data <- read_excel(file, sheet = 2) %>% select(`Document No.`, Amount)
      
      summed_stock_data <- lab_stock_data %>%
        summarise(Total_Amount_Stock = sum(Amount, na.rm = TRUE), .by = `Document No.`)
      
      summed_cost_data <- lab_cost_data %>%
        summarise(Total_Amount_Cost = sum(Amount, na.rm = TRUE), .by = `Document No.`)
      
      final_data <- full_join(summed_stock_data, summed_cost_data, by = "Document No.") %>%
        replace_na(list(Total_Amount_Stock = 0, Total_Amount_Cost = 0)) %>%
        mutate(Variance = Total_Amount_Stock + Total_Amount_Cost)
      
      categories <- list(
        Purchases = "GRN|PINV",
        Purchase_Returns = "PRS",
        Purchase_Credit_Memo = "PCRE",
        Purchased_Directly_No_Stock_Account = "PINV"
      )
      
      important_values <- bind_rows(
        lapply(names(categories), function(cat) {
          if (cat == "Purchased_Directly_No_Stock_Account") {
            summed_cost_data %>%
              filter(grepl(categories[[cat]], `Document No.`)) %>%
              summarise(Value = sum(Total_Amount_Cost, na.rm = TRUE)) %>%
              mutate(Category = gsub("_", " ", cat)) %>% 
              select(Category, Value)
          } else {
            final_data %>%
              filter(grepl(categories[[cat]], `Document No.`)) %>%
              summarise(Value = sum(Variance, na.rm = TRUE)) %>%
              mutate(Category = gsub("_", " ", cat)) %>% 
              select(Category, Value)
          }
        })
      )
      
      important_values <- important_values %>%
        mutate(Value = scales::number(Value, big.mark = ",", decimal.mark = ".", accuracy = 0.01))
      
      return(important_values)
    })
  })
  
  output$summary <- renderTable({
    process_data()
  }, align = "c")
  
  output$download <- downloadHandler(
    filename = function() {
      paste0("important_values.xlsx")
    },
    content = function(file) {
      write_xlsx(process_data(), file)
    }
  )
}

# Run the app
shinyApp(ui, server)
