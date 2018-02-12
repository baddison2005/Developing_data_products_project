library(shiny)
library(plotly)

shinyUI(fluidPage(
  titlePanel("Relation Between Host Star Temperature and Orbital Obliquity"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("rat_a_st_rad_value_slider", "What is the maximum a/Rs?", 4, 30, value = 10),
      submitButton("Submit")
    ),
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Figure1", br(), textOutput("pred1"),
                           plotlyOutput("plot1", height = "500px"),
                           h3("Temperature VS Spin-Orbit Misalignment")),
                  tabPanel("Figure2", br(),
                           plotlyOutput("plot2", height = "500px"),
                           h3("Distribution of Spin-Orbit Angles")),
                  tabPanel("Documentation", br(), 
                           h5("This application is used to show the relationship between the effective"),
                           h5("temperature of a host star and the degree of misalignment between the"),
                           h5("plane of a planet's orbit and the equator of its host star (spin-orbit angle)."),
                           h5("The first figure shows the stellar effective temperature vs spin-orbit angle."),
                           h5("Hot stars should host more planets on misaligned orbits but other variables"),
                           h5("are also involved, including the ratio of the orbital distance to the radius"),
                           h5("of the star. Use the slider to adjust the highest cutoff value for this"),
                           h5("parameter. A linear model is also fit."),
                           h5(" "),
                           h5("The second figure shows the distribution of spin-orbit angles."))

      )
      
      # textOutput("pred1"),
      # plotlyOutput("plot1", height = "500px"),
      # h3("Temperature VS Spin-Orbit Misalignment")
    )
  )
))