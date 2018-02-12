library(shiny)
library(corrplot)
library(plotly)

#Read in the spin-orbit angle dataset into R. Convert blank "" values into NA values.
spin_orbit_data = read.csv(paste("/Users/brettaddison/Dropbox/Coursera_data_science/",
                                 "Developing_Data_Products/Week4/Project/rossiter_list.csv",
                                 sep=""), na.strings=c("", "NA"))

#Remove unnecessary columns.
spin_orbit_data_cleaned <- subset(spin_orbit_data, select=-c(System, lambda, Author_string, Ephemeris_reference))
row.names(spin_orbit_data_cleaned) <- spin_orbit_data$System

#Remove uncertainty columns.
spin_orbit_data_cleaned2 <- subset(spin_orbit_data,
                                   select=-c(System, Teff_errup, Teff_errdn, lambda, lambda_errup, lambda_errdn,
                                             Ecc_errup, Ecc_errdn, Pl_mass_errup, Pl_mass_errdn, pl_radj_errup,
                                             pl_radj_errdn, st_mass_errup, st_mass_errdn, rat_a_st_rad_errup,
                                             rat_a_st_rad_errdn, st_metfeerrup, st_metfeerrdn, st_ageerrup,
                                             st_ageerrdn, Author_string, Ephemeris_reference))
row.names(spin_orbit_data_cleaned2) <- spin_orbit_data$System

#Convert the misaligned and multi columns into factor variables for model analysis.
spin_orbit_data_cleaned$Misaligned <- as.factor(spin_orbit_data_cleaned$Misaligned)
spin_orbit_data_cleaned$Multi <- as.factor(spin_orbit_data_cleaned$Multi)

spin_orbit_data_cleaned2$Misaligned <- as.factor(spin_orbit_data_cleaned2$Misaligned)
spin_orbit_data_cleaned2$Multi <- as.factor(spin_orbit_data_cleaned2$Multi)

shinyServer(function(input, output) {
  lm_print <- reactive({
    rat_a_st_rad_value_input <- input$rat_a_st_rad_value_slider
    spin_orbit_data_cleaned_ratio <- subset(spin_orbit_data_cleaned, 
                                          rat_a_st_rad <= rat_a_st_rad_value_input | is.na(rat_a_st_rad))
  
    lm_adjusted <- lm(spin_orbit_data_cleaned_ratio$lambda_abs ~ spin_orbit_data_cleaned_ratio$Teff)
    paste("Linear model fit with slope and intercept. ", "y=", 
                lm_adjusted$coefficients[2], "x + ", lm_adjusted$coefficients[1])
  })

  output$plot1 <- renderPlotly({
    rat_a_st_rad_value_input <- input$rat_a_st_rad_value_slider
    spin_orbit_data_cleaned_ratio <- subset(spin_orbit_data_cleaned, 
                                            rat_a_st_rad <= rat_a_st_rad_value_input | is.na(rat_a_st_rad))
    
    lm_adjusted <- lm(spin_orbit_data_cleaned_ratio$lambda_abs ~ spin_orbit_data_cleaned_ratio$Teff)
    
    xaxis <- list(title = "Stellar Effective Temperature (K)")
    yaxis <- list(title = "|Spin-Orbit Angle| (deg)", range = c(0, max(spin_orbit_data_cleaned_ratio$lambda_abs)+10))
    legendtitle <- list(yref='paper',xref="paper",y=1.03,x=1.1, text="a/Rs",showarrow=F)

    plot_ly(x = spin_orbit_data_cleaned_ratio$Teff, y = fitted(lm_adjusted), name="regression line", type = "scatter",
            mode = "lines + markers", error_y = 0, error_x = 0
      ) %>%
      add_trace(x = spin_orbit_data_cleaned_ratio$Teff, y = spin_orbit_data_cleaned_ratio$lambda_abs, name = ' ',
                text = rownames(spin_orbit_data_cleaned_ratio),
                mode='markers', type = "scatter", color = spin_orbit_data_cleaned_ratio$rat_a_st_rad,
                error_y = list(type='data', symmetric=FALSE, arrayminus=spin_orbit_data_cleaned_ratio$lambda_errdn,
                                array=spin_orbit_data_cleaned_ratio$lambda_errup),
                error_x = list(type='data', symmetric=FALSE, arrayminus=spin_orbit_data_cleaned_ratio$Teff_errdn,
                                array=spin_orbit_data_cleaned_ratio$Teff_errup)
      ) %>%
      layout(annotations=legendtitle, xaxis=xaxis, yaxis=yaxis)

  })
  
  output$plot2 <- renderPlotly({
    rat_a_st_rad_value_input <- input$rat_a_st_rad_value_slider
    spin_orbit_data_cleaned_ratio <- subset(spin_orbit_data_cleaned, 
                                            rat_a_st_rad <= rat_a_st_rad_value_input | is.na(rat_a_st_rad))
    
    #Plot a histogram of the lambda distribution.
    xaxis <- list(title = "|Spin-Orbit Angle| (deg)")
    yaxis <- list(title = "Frequency")
    plot_ly(x = spin_orbit_data_cleaned_ratio$lambda_abs, type = "histogram"
    ) %>%
    layout(xaxis=xaxis, yaxis=yaxis)
  })
  
  output$pred1 <- renderText({
    lm_print()
  })
  
})