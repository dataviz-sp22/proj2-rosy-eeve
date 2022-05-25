#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

# load package
library(shiny)
library(tidyverse)
library(reshape2)
library(sf)
library(gganimate)
library(transformr)
library(patchwork)

#load 311 data 
#load("Chicago_311_clean.Rdata")
#create test data
#set.seed(0)
#df = sample_n(df,1000)
#save(df,file = "Chicago_311_clean_sample1K.Rdata")
#load test data
load("Chicago_311_clean_sample1K.Rdata")

#create response time
df$daystoclose = as.numeric(as.Date(df$CLOSED_DATE,"%m/%d/%Y")-as.Date(df$CREATED_DATE,"%m/%d/%Y"))

#acs data 
acs = read.csv("Chicago_zcta_subset_acs2019_clean.csv")

#rename acs variables
names(acs) = gsub("PE","",names(acs),fixed=TRUE)

#reshape data from wide to long
acsmelt = acs %>% select(-Tract) %>% melt(id.vars = "GEOID")

#read shp file
zipcode <- st_read("ma_zip_shapefile/acs2020_5yr_B01003_86000US60140.shp")

# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # App title ----
    titlePanel("How do 311 non-emergency requests differ across communities?"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # Input: Select the demographics variable ----
            selectInput("demo", "Select a demographic characteristics:",
                        names(acs[,-c(1:2)]),"Female"
                        #list(`Sex` = list("Female", "Male"),
                        #     `Education` = list("College", "No College")
                        #     )
            ),
            
            # br() element to introduce extra vertical spacing ----
            br(),
            
            # Input: Choose a department type
            radioButtons("dep", "311 Characteristics - Select a department:",
                        unique(df$OWNER_DEPARTMENT),
                        selected = unique(df$OWNER_DEPARTMENT)[1]
            ),
            
            # Input: Choose a requests type
            selectInput("type", "311 Characteristics - Select a request type:",
                        unique(df$SR_TYPE),
                        selected = unique(df$SR_TYPE)[1]
            ),
            
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            # Output: Tabset w/ plot, summary, and table ----
            tabsetPanel(type = "tabs",
                        tabPanel("Plot", plotOutput("plot"), plotOutput("plot2"), plotOutput("plot3")),
                        tabPanel("Data", tableOutput("data")),
                        tabPanel("About", textOutput("about"))
            )
            
        )
    )
)

# Define server logic for random distribution app ----
server <- function(input, output) {
    
    # Reactive expression to generate the requested distribution ----
    # This is called whenever the inputs change. The output functions
    # defined below then use the value computed from this expression
    d <- reactive({
        
    })
    
    # Generate a plot of the data ----
    output$plot <- renderPlot({
        #map 311 count 
        zipcode  %>%
            mutate(name = as.numeric(name)) %>%
            inner_join(df %>%
                           group_by(ZIP) %>% 
                           summarize(n = sum(SR_TYPE == input$type & OWNER_DEPARTMENT == input$dep)),
                       by=c("name"="ZIP")) %>%
            ggplot(aes(fill = n))+
            labs(
                title = "Choropleths of 311 Requests Volume",
                fill = "Request Volume"
                )+
            geom_sf()+
            theme_bw()
    })
    
    # Generate a plot of the data ----
    output$plot2 <- renderPlot({
        
        #map demographic var
        zipcode  %>%
            mutate(name = as.numeric(name)) %>%
            filter(name %in% unique(df$ZIP)) %>% 
            left_join(acsmelt %>% filter(variable == input$demo),by=c("name"="GEOID")) %>%
            ggplot(aes(fill = value))+
            geom_sf()+
            labs(
                title = "Choropleths of Population Share for the Corresponding Socio-Demographic Characteristics",
                fill = input$demo, 
            )+
            theme_bw()
    })
    
    
    # Generate a plot of the data ----
    output$plot3 <- renderPlot({
        
        #example of scatter plot highlight a zipcode 
        df %>% group_by(ZIP) %>%
            mutate(total_requests = n()) %>%
            group_by(ZIP,total_requests) %>% 
            summarize(n = sum(SR_TYPE == input$type & OWNER_DEPARTMENT == input$dep)) %>%
            left_join(acsmelt %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            ggplot(aes(y = n, x = value,size = total_requests))+
            geom_point()+
            geom_smooth(method=lm)+
            labs(
                title = "Scatterplot between 311 Requests and Socio-Demographic Characteristics",
                y = paste(input$SR_TYPE,"-", input$dep),
                x=input$demo,
                size = "Volume of All Requests"
            )+
            theme_bw()
    })
    
    # Generate a summary of the data ----
    output$about <- renderText({
        print("In this project, we utilize interactive and animated spatio-temporal visualization to illustrate how the composition of non-emergency requests differ across communities with varying sociodemographic characteristics in the Chicago 311 Service Requests data. 
\n

The 311 system is a non-emergency response system where people can make a request to find information about services, make complaints, or report non-emergency problems, such as potholes and trash collection. While the system was initially designed to reduce call volume on the overloaded 911 system, 311 request systems have become an integral part of the e-government movement in which technological innovations are deployed to help local governments deliver more efficient and effective services to residents. Thus, we employ the 311 data in Chicago to provide insights on the variation of communities' needs and assist the city to better allocate resources accordingly. We intend to incorporate the demographic distribution or socioeconomic measures in order to determine if areas with unusually high or low requests for different services may correlate to a certain distribution of the area..

\n

We focus on two measures of interest regarding the 311 data: number of requests and the amount of time it takes to complete a request. While the first measure informs the demand of non-emergency services, the second measures reflects on the quality of responses from the city to its residents. We use zip codes to identify our geographical areas and merge in socio-demographic information from the American Community Survey (ACS) 2019. 
")
    })
    
    # Generate an HTML table view of the data ----
    output$data <- renderTable({
        head(df %>% left_join(acs, by = c("ZIP"="GEOID")))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
