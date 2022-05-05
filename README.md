# Final-assignment

The final project mainly contains documents of app.R, report.Rmd. 
The topic is to discover the attitudes of two questions:
- chirlden suffering with working mothers
- if job is scarce, national citizen should have priority. 

In the below web, you could find several variables: country, outcome, education, sex and age.
https://lan513assignment4.shinyapps.io/FinalAssignment/

The "Overview" section indicates the purpose of the analysis and brief introductions of each section.
The "Exploration" section indicates that regarding the two questions, the actual values collocted from survey and a fittered linear regression. 
The "Regession" section measures how well the proposed fittered regression in "Exploration" fits reality.

Regarding report.Rmd, the input is from Shiny. You could find details by clicking the button "Generate Report". 

The function of "Generate Report" is to generate four plots for evaluating regression model's fitting degree. 
The plot "Residuals vs Fitted" and "Scale-Location" is to identify whether the regression is linear.
If the residuals are uniformly distributed, the regression is linear. 
If the residuales are shown as a curve, the regression would be nonlinear. 

The plot "Normal Q-Q" is to compare the probability of real distribution with modelled distribution in order to check that if the model distribution fitting the actual distribution, if they are similar. 

The plot "Residuals vs Leverage" is to check the influence of one single point to the general result. If residual is large value and leverage is also large value, then the point is influential points. If too many influential points appear, then the regression model is needed to reevaluate. 

Finally, I am very appreciated for your great support!
