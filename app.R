rm(list = ls())
# load packages
library(tidyverse)
library(shiny)
library(DT)
library(ggsci)
library(haven)
library(broom)

# import data
rm(list = ls())
# import data
df_raw <- read_dta('ZA7500_v4-0-0.dta')
# select the variables
df <- subset(df_raw, select = c(v72, v80, country, age, v225_weight, v243_r_weight))
# rename
colnames(df)[4:6] <- c('Age', 'Sex', 'Education')

# the country name
country_res <- attributes(df$country)
countries <- names(country_res$labels)[c(1:15, 17:35)]

df <- df %>% mutate(Sex = factor(Sex, levels = c(1, 2), labels = c('Male', 'Female')),
                    Education = factor(Education, levels = 1:3,
                                       labels = c('lower', 'medium', 'higher'))) %>%
  filter(v72 >0, v80>0, Age > 0 ) %>%
  na.omit()


# UI
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      # Country
      selectInput(inputId = "Country", label = "Country", 
                  choices = countries, selected = 'Norway'),
      radioButtons(inputId = 'Outcome', label = 'Outcome', 
                   choices = c('child suffers with working mother (Q25A)' = 'v72',
                               'jobs are scarce: giving...(nation) priority (Q26A)' = 'v80')),
      checkboxGroupInput(inputId = 'Controls', label = 'Controls', 
                         choices = c('Education', 'Sex'), selected = NULL, inline = T),
      sliderInput(inputId = 'poly', label = 'Age polynomial', min = 1, max = 5, 
                  value = 1, step = 1),
      downloadButton("report", "Generate Report")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel(title = 'Overiview', 
                 p('This analysis website illustrates the attitude towards if chirlden suffer from working mother and if employers should given jobs to  national citizen when jobs are scare in different countries.'), br(),
                 p('There are four selections you can choose on the left side, including country, outcome (the attitude you want to check), education, gender and age of respondents. On the right side, there are two graphs visulizing the output of the selected question. "Exploration" indicates that the attitude of people in age groups of around 20-40, 41-60, 61-80, and 80+.The more people share one type of attitude, the darker the dot shows. The blue line is the fittered curve. "Regression" indicates how well the fittered curve fits the actual data. The flatter and closer to 0, the better regression capturing actual data. In addition, education, gender and age are only connected to "Regression". In this way, we could understand the actual attitude of two in different countries. Moreover, we could see the accuracy of the simulated prediction.'), br(),
                 p('If you want more infornation, please find in "Generate Report". Hope you will explore your interests in the web:https://lan513assignment4.shinyapps.io/FinalAssignment/') ),
        tabPanel(title = 'Exploration', plotOutput('figb1')),
        tabPanel(title = 'Regression', plotOutput('figc1'), dataTableOutput('dfc1'))
      )
    )
  )
)

server <- function(input, output){
  # parper the data
  df_temp <- reactive({
    index <- which(countries ==  input$Country)
    df %>% filter(country == country_res$labels[index]) %>%
      select(-country) 
  })
  
  p_temp <- reactive({
    ggplot(df_temp(), aes(x = Age, y = get(input$Outcome))) +
      geom_point(col = 'seagreen', alpha = 0.3, size = 2) + 
      geom_smooth(method = 'lm', formula = y ~ poly(x, input$poly), se = F, col = 'steelblue') +
      theme(axis.text.x = element_blank(), 
            plot.title = element_text(hjust = 0.5)) + 
      labs(y = ifelse(input$Outcome == 'v72', 'child suffers with working mother (Q25A)',
                      'jobs are scarce: giving...(nation) priority (Q26A)'),
           caption = ifelse(input$Outcome == 'v72', 
                            'strongly agree:1, agree:2, disagree:3, strongly disagree:4',
                            'strongly agree:1, agree:2, neutral:3, disagree:4, strongly disagree:5')) +
      theme_bw()
  })
  
 # the out for section 2
  output$figb1 <- renderPlot({
    p_temp()
  })
  
 # model
  mod_temp <- reactive({
    mf <- paste(input$Outcome, paste(c(paste0('poly(Age, ', input$poly, ')'), input$Controls), collapse = '+'), sep = '~')
    mod <- lm(as.formula(mf), data = df_temp())
  })  
  
  # the out for section 3
  output$figc1 <- renderPlot({
    plot(mod_temp(), which = 1, pch = 16, col = rgb(70, 130, 180, 80, maxColorValue = 255))
  })
  output$dfc1 <- renderDataTable(tidy(mod_temp()) %>% 
                                   mutate(across(is.numeric, ~round(.x, 3))), 
                                 options = list(lengthChange = FALSE))
  
  
  output$report <- downloadHandler(
    
    filename = paste(input$Country, "report.html", sep = '_'),
    content = function(file) {
      # Copy the report file to a temporary directory before processing it, in
      # case we don't have write permissions to the current working dir (which
      # can happen when deployed).
      
      # Set up parameters to pass to Rmd document
      params <- list(country = input$Country, 
                     outcome = input$Outcome,
                     p = p_temp(), mod = mod_temp())
      
      # Knit the document, passing in the `params` list, and eval it in a
      # child of the global environment (this isolates the code in the document
      # from the code in this app).
      rmarkdown::render(input = 'report.Rmd', output_file = file,
                        params = params,
                        envir = new.env(parent = globalenv())
      )
    }
  )
  
  
}

shinyApp(ui, server)


# https://lan513assignment4.shinyapps.io/FinalAssignment/





