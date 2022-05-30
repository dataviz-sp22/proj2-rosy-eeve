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
library(colorspace)

#load 311 data 
#load("App/Chicago_311_clean.Rdata")
#create test data
#set.seed(0)
#df = sample_n(df,1000)
#save(df,file = "Chicago_311_clean_sample1K.Rdata")
#load test data
#load("App/Chicago_311_clean_sample1K.Rdata")
load("Chicago_311_clean_sample1K.Rdata")

#create response time
df$daystoclose <- as.numeric(as.Date(df$CLOSED_DATE,"%m/%d/%Y")-as.Date(df$CREATED_DATE,"%m/%d/%Y"))

#acs data 
#acs = read.csv("App/Chicago_zcta_subset_acs2019_clean.csv")
acs <- read.csv("Chicago_zcta_subset_acs2019_clean.csv")

#rename acs variables
names(acs) <- gsub("PE","",names(acs),fixed=TRUE)

#reshape data from wide to long
acsmelt <- acs %>% select(-Tract) %>% melt(id.vars = "GEOID")

#read shp file
#zipcode <- st_read("App/ma_zip_shapefile/acs2020_5yr_B01003_86000US60140.shp")
zipcode <- st_read("ma_zip_shapefile/acs2020_5yr_B01003_86000US60140.shp")



# Define UI for application that draws a histogram
ui <- fluidPage(
    
    # App title ----
    titlePanel("How do 311 non-emergency requests differ across zipcodes in Chicago?"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
        
        # Sidebar panel for inputs ----
        sidebarPanel(
            
            # # Input: Select the demographics variable ----
            # selectInput("demo", "Socio-Demographic characteristics - Select a variable:",
            #             names(acs[,-c(1:2)]),"Female"
            #             #list(`Sex` = list("Female", "Male"),
            #             #     `Education` = list("College", "No College")
            #             #     )
            # ),
            
            
            # Input: Choose a department type
            radioButtons("dep", "311 Characteristics - Select a department:",
                        sort(unique(df$OWNER_DEPARTMENT)),
                        selected = sort(unique(df$OWNER_DEPARTMENT))[10]
            ),
            
            # br() element to introduce extra vertical spacing ----
            br(),
            
            # Input: Choose demo variable
            radioButtons("demo", "Socio-Demographic characteristics - Select a variable:",
                         choiceValues = names(acs[,-c(1:2)]),
                         selected = names(acs[,3]),
                         choiceNames = c("Race & Ethinicity: White","Race & Ethinicity: Black","Race & Ethinicity: Native","Race & Ethinicity: Asian", "Race & Ethinicity: HIPI",  "Race & Ethinicity: Hispanic",  
                                         "Income: Gini Index", "Income: Median Income" ,  "Income: Public Assistance" ,  "Income: No Public Assistance", 
                                         "Education: No College" ,"Education: College",
                                         "Age: Under 18" , "Age: 18 to 24", "Age: 25 to 34", "Age: 35 to 34", "Age: 45 to 54", "Age: 55 to 64", "Age: 65 to 74", "Age: 75 over",
                                         "Sex: Female","Sex: Male")
            ),
            
        ),
        
        # Main panel for displaying outputs ----
        mainPanel(
            
            # Output: Tabset w/ plot, summary, and table ----
            tabsetPanel(type = "tabs",
                        #tabPanel("Plot", plotOutput("plot"), plotOutput("plot2"), plotOutput("plot3")),
                        tabPanel("Request Volume",fluidRow(splitLayout(cellWidths = c("49%", "49%"), plotOutput("plot"), plotOutput("plot2"))),
                                 plotOutput("plot4")),
                        tabPanel("Response Time",fluidRow(splitLayout(cellWidths = c("50%", "50%"), plotOutput("plotb"), plotOutput("plot2b"))),
                                 plotOutput("plot4b")),
                        tabPanel("Data", htmlOutput("datatext"),tableOutput("data"),htmlOutput("data2text"), tableOutput("data2")),
                        tabPanel("About", htmlOutput("about"))
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
    
    #======================================
    # Request Volume
    #======================================
    
    # Generate a plot of the data ----
    output$plot <- renderPlot({
        #map 311 count 
        zipcode  %>%
            mutate(name = as.numeric(name)) %>%
            inner_join(df %>%
                           group_by(ZIP) %>% 
                           summarize(n = sum(OWNER_DEPARTMENT == input$dep)),
                       by=c("name"="ZIP")) %>%
            ggplot(aes(fill = n))+
            labs(
                title = paste("311 Request Volume per Zip Code:\n",input$dep),
                fill = "Request\nVolume"
                )+
            geom_sf()+
            scale_fill_continuous_sequential("SunsetDark")+
            theme_bw() +
            theme(legend.position = c(0.2, 0.2),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.line = element_line(),
                  axis.ticks = element_line())
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
                title = paste("Population Share of \nSociodemographic variable:",input$demo),
                subtitle = "in Chicago",
                fill = input$demo, 
            )+
            scale_fill_continuous_sequential("Mako")+
            theme_bw() +
            theme(legend.position = c(0.2, 0.2),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.line = element_line(),
                  axis.ticks = element_line())
    })
    
    
    # Generate a plot of the data ----
    output$plot3 <- renderPlot({
        
        #example of scatter plot highlight a zipcode 
        df %>% group_by(ZIP) %>%
            mutate(total_requests = n()) %>%
            group_by(ZIP,total_requests) %>% 
            summarize(n = sum(OWNER_DEPARTMENT == input$dep)) %>%
            left_join(acsmelt %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            ggplot(aes(y = n, x = value,size = total_requests))+
            geom_point()+
            geom_smooth(method=lm)+
            labs(
                title = paste("Scatterplot between 311 Requests from",input$dep,"and Population Share of",input$demo),
                y = paste("Request Volume in", input$dep),
                x=input$demo,
                size = "Volume of All Requests"
            )+
            theme_bw()
    })
    
    # Generate a plot of the data ----
    output$plot4 <- renderPlot({

        acsbreaks = acsmelt %>% 
            filter(GEOID %in% unique(df$ZIP)) %>%
            group_by(variable) %>% 
            mutate(cut  = cut(value,4,labels= FALSE))
        
        df %>% 
            left_join(acsbreaks %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            filter(OWNER_DEPARTMENT == input$dep) %>% 
            filter(cut %in% c(1,4)) %>% 
            group_by(SR_TYPE,cut) %>%
            count() %>% 
            mutate(cut = ifelse(cut == 1,"Bottom 25%","Top 25%")) %>%
            ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = cut))+
            geom_col()+
            facet_wrap(~cut)+
            theme_bw()+
            theme(legend.position = "none", strip.background = element_blank())+
            labs(
                title=paste("311 Request Volume for Each Request Type In",input$dep),
                subtitle = paste("By the top and bottom quartile of",input$demo,"population share"),
                y="",
                x="Request Volume",
                
            )+scale_fill_manual(values = c("red4","dodgerblue4"))
    })
    #======================================
    # Response Time
    #======================================
    # Generate a plot of the data ----
    output$plotb <- renderPlot({
        #map 311 count 
        zipcode  %>%
            mutate(name = as.numeric(name)) %>%
            inner_join(df %>%
                           group_by(ZIP) %>% 
                           summarize(n = mean(daystoclose[OWNER_DEPARTMENT == input$dep])),
                       by=c("name"="ZIP")) %>%
            ggplot(aes(fill = n))+
            labs(
                title = paste("Choropleths of 311 Response Time:",input$dep),
                fill = "Response Time in Days"
            )+
            geom_sf()+
            scale_fill_continuous_sequential("SunsetDark")+
            theme_bw()
    })
    
    # Generate a plot of the data ----
    output$plot2b <- renderPlot({
        
        #map demographic var
        zipcode  %>%
            mutate(name = as.numeric(name)) %>%
            filter(name %in% unique(df$ZIP)) %>% 
            left_join(acsmelt %>% filter(variable == input$demo),by=c("name"="GEOID")) %>%
            ggplot(aes(fill = value))+
            geom_sf()+
            labs(
                title = paste("Choropleths of Population Share for",input$demo),
                fill = input$demo, 
            )+
            scale_fill_continuous_sequential("Mako")+
            theme_bw()
    })
    
    
    # Generate a plot of the data ----
    output$plot3b <- renderPlot({
        
        #example of scatter plot highlight a zipcode 
        df %>% group_by(ZIP) %>%
            mutate(total_requests = n()) %>%
            group_by(ZIP,total_requests) %>% 
            summarize(n = mean(daystoclose[OWNER_DEPARTMENT == input$dep])) %>%
            left_join(acsmelt %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            ggplot(aes(y = n, x = value,size = total_requests))+
            geom_point()+
            geom_smooth(method=lm)+
            labs(
                title = paste("Scatterplot between 311 Requests from",input$dep,"and Population Share of",input$demo),
                y = paste("Response Time in", input$dep),
                x=input$demo,
                size = "Response Time in Days"
            )+
            theme_bw()
    })
    
    # Generate a plot of the data ----
    output$plot4b <- renderPlot({
        
        acsbreaks = acsmelt %>% 
            filter(GEOID %in% unique(df$ZIP)) %>%
            group_by(variable) %>% 
            mutate(cut  = cut(value,4,labels= FALSE))
        
        df %>% 
            left_join(acsbreaks %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            filter(OWNER_DEPARTMENT == input$dep) %>% 
            filter(cut %in% c(1,4)) %>% 
            group_by(SR_TYPE,cut) %>%
            summarize(n = mean(daystoclose[OWNER_DEPARTMENT == input$dep])) %>%
            mutate(cut = ifelse(cut == 1,"Bottom 25 percent","Top 25 percent")) %>%
            ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = cut))+
            geom_col()+
            facet_wrap(~cut)+
            theme_bw()+
            theme(legend.position = "none", strip.background = element_blank())+
            labs(
                title=paste("311 Response Time for Each Request Type In",input$dep),
                subtitle = paste("By the top and bottom quartile of",input$demo,"population share"),
                y="",
                x="Response Time in Days",
                
            )+scale_fill_manual(values = c("red4","dodgerblue4"))
    })
    
    #======================================
    # About
    #======================================
    
    # Generate a summary content ----
    output$about <- renderPrint({
        HTML(paste(h1("Introduction"),
                   br(),
                   p("In this project, we utilize interactive and animated spatio-temporal visualization to illustrate how the composition of non-emergency requests differ across communities with varying sociodemographic characteristics in the Chicago 311 Service Requests data. "),
                   br(),
                   p("The 311 system is a non-emergency response system where people can make a request to find information about services, make complaints, or report non-emergency problems, such as potholes and trash collection. While the system was initially designed to reduce call volume on the overloaded 911 system, 311 request systems have become an integral part of the e-government movement in which technological innovations are deployed to help local governments deliver more efficient and effective services to residents. Thus, we employ the 311 data in Chicago to provide insights on the variation of communities’ needs and assist the city to better allocate resources accordingly. We intend to incorporate the demographic distribution or socioeconomic measures in order to determine if areas with unusually high or low requests for different services may correlate to a certain distribution of the area."),
                   br(),
                   p("We focus on two measures of interest regarding the 311 data: number of requests and the amount of time it takes to complete a request. While the first measure informs the demand of non-emergency services, the second measures reflects on the quality of responses from the city to its residents. We use zip codes to identify our geographical areas and merge in socio-demographic information from the American Community Survey (ACS) 2019. ")
                  
                   
        ))
    })
    
    #======================================
    # Data 
    #======================================
    
    # Generate a summary content ----
    output$datatext <- renderPrint({
        HTML(paste(h1("311 Non-Emergency Request Data"),
              br(),
              p("The data on 311 Service Requests received by the City of Chicago are publicly available on the Chicago Data Portal. The dataset includes requests created after the launch of the new 311 system on 12/18/2018 and was last updated on May 11, 2022. Currently, it has 6 million rows and 37 columns, where each row is a request. Useful features from the data include request type, owner department, create date, closed date, and zip code. Since we are interested in the response time, we restrict observations to requests that have been completed. It is noted that the address for requests of the type “311 INFORMATION ONLY CALL” is often the address of the City's 311 Center."),
              br()
              
        ))
        })
    
    # Generate an HTML table view of the data ----
    output$data <- renderTable({
        head(df)
    })
    
    # Generate a summary content ----
    output$data2text <- renderPrint({
        HTML(paste(h1("Socio-Demographic Characteristics Data"),
                   br(),
                   p("The American Community Survey (ACS) is a questionnaire conducted by the United States Census Bureau yearly to collect information about American citizens. Relevant sociodemographic elements were selected from this survey in the year 2019, and converted into a workable dataset using `tidyCensus`. Our subset of data includes 24 columns and 296 rows correlating to Chicago and other outlying areas included in the Chicago Metropolitan Statistical Area (MSA). Only zip codes included in the Chicago 311 dataset will be selected from this dataset."),
                   br()
                   
        ))
    })
    
    # Generate an HTML table view of the data ----
    output$data2 <- renderTable({
        acs %>% filter(GEOID %in% unique(df$ZIP))
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
