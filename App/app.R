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

load("Chicago_311_clean_sample1K.Rdata")

#create response time
df$daystoclose <- as.numeric(as.Date(df$CLOSED_DATE,"%m/%d/%Y")-as.Date(df$CREATED_DATE,"%m/%d/%Y"))

#acs data 
acs <- read.csv("Chicago_zcta_subset_acs2019_clean.csv")

#rename acs variables
acs <- acs %>%
    select(-MedincE) %>%
    rename(PE35t44 = PE35t34)

names(acs) <- gsub("PE","",names(acs),fixed=TRUE)

#reshape data from wide to long
acsmelt <- acs %>% select(-Tract) %>% melt(id.vars = "GEOID")

# load zip code 
zipcode = st_read("ma_zip_shapefile/acs2020_5yr_B01003_86000US60140.shp")


# Define UI for application that draws a histogram
ui <- navbarPage("311 Service Request Trends",
                 tabPanel('Visualizations', fluidPage(
                     # Theme ----
                     theme = shinythemes::shinytheme("united"),
                     # App title ----
                     titlePanel("How do 311 non-emergency requests differ across zipcodes in Chicago?"),
                     # Sidebar layout with input and output definitions ----
                     sidebarLayout(
                         # Sidebar panel for inputs ----
                         sidebarPanel(
                             # Input: Choose a department type
                             radioButtons("dep", "311 Requests - Select a department:",
                                          sort(unique(df$OWNER_DEPARTMENT)),
                                          selected = sort(unique(df$OWNER_DEPARTMENT))[10]
                                          ),
                             # br() element to introduce extra vertical spacing ----
                             br(),
                             # Input: Choose demo variable
                             selectInput(inputId = "demo", 
                                         label = "Sociodemographic characteristics - Select a variable:",
                                         selected = names(acs[,3]),
                                         choices = c("Race & Ethinicity: White"="White",
                                                     "Race & Ethinicity: Black"="Black",
                                                     "Race & Ethinicity: Native"="Native",
                                                     "Race & Ethinicity: Asian"="Asian", 
                                                     "Race & Ethinicity: HIPI"="HIPI",  
                                                     "Race & Ethinicity: Hispanic"="Hispanic",  
                                                     "Income: Gini Index"="GiniE", 
                                                     "Income: Public Assistance"="pubasst",  
                                                     "Income: No Public Assistance"="nopubasst", 
                                                     "Education: No College"="NoCollege",
                                                     "Education: College"="College",
                                                     "Age: Under 18"="Under18", 
                                                     "Age: 18 to 24"="18t24", 
                                                     "Age: 25 to 34"="25t34", 
                                                     "Age: 35 to 44"="35t44", 
                                                     "Age: 45 to 54"="45t54", 
                                                     "Age: 55 to 64"="55t64", 
                                                     "Age: 65 to 74"="65t74", 
                                                     "Age: 75 over"="75over",
                                                     "Sex: Female"="Female",
                                                     "Sex: Male"="Male")
                                         ),
                             ),
                         # Main panel for displaying outputs ----
                         mainPanel(
                             # Output: Tabset w/ plot, summary, and table ----
                             tabsetPanel(type = "tabs",
                                         tabPanel("Request Volume",
                                                  fluidRow(splitLayout(cellWidths = c("49%", "49%"), 
                                                                       plotOutput("plot"), 
                                                                       plotOutput("plot2"))),
                                                  plotOutput("plot4")),
                                         tabPanel("Response Time",fluidRow(splitLayout(cellWidths = c("49%", "49%"), 
                                                                                       plotOutput("plotb"), 
                                                                                       plotOutput("plot2b"))),
                                                  plotOutput("plot4b"))
                                         )
                             )
                         )
                     )
                     ),
                 tabPanel("Dataset", htmlOutput("datatext"),tableOutput("data"),htmlOutput("data2text"), tableOutput("data2")),
                 tabPanel("About this App", htmlOutput("about"))
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
                title = paste(input$dep, "Request Volume"),
                subtitle = "by Chicago Zip Code",
                fill = "Request\nVolume"
                )+
            geom_sf()+
            scale_fill_continuous_sequential("SunsetDark")+
            theme_bw() +
            theme(legend.position = c(0.2, 0.3),
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
                subtitle = "by Chicago Zip Code",
                fill = paste('%', input$demo) 
            )+
            scale_fill_continuous_sequential("Mako")+
            theme_bw() +
            theme(legend.position = c(0.2, 0.3),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.line = element_line(),
                  axis.ticks = element_line())
    })

    
    # Generate a plot of the data ----
    output$plot4 <- renderPlot({

        acsbreaks <- acsmelt %>% 
            filter(GEOID %in% unique(df$ZIP)) %>%
            group_by(variable) %>% 
            mutate(cut  = cut(value,4,labels= FALSE))
        df2 <- df %>% 
            left_join(acsbreaks %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            filter(OWNER_DEPARTMENT == input$dep)
        
        if ((1 %in% unique(df2$cut)) | (4 %in% unique(df2$cut))) {
            
            cond_plot <- df2 %>% 
            filter(cut %in% c(1,4)) %>% 
            group_by(SR_TYPE,cut) %>%
            count() %>% 
            mutate(cut = ifelse(cut == 1,"Bottom 25%","Top 25%")) %>%
            ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = cut))+
            geom_col()+
            facet_wrap(~cut, labeller = labeller(cut = c("Bottom 25%" = "Number of Requests for Zip Codes\n below the 25th Percentile", 
                                                         "Top 25%" = "Number of Requests for Zip Codes\n above the 75th Percentile")))+
            theme_bw()+
            theme(legend.position = "none", strip.background = element_blank())+
            labs(
                title=paste(input$dep, 
                            "Request Volume for Zip Codes in\n Top and Bottom Quartiles of",
                            input$demo, 
                            "Population Percentage"),
                y="",
                x="Number of Requests",
                
            )+scale_fill_manual(values = c("red4","dodgerblue4"))
        }
        
        if (!(1 %in% unique(df2$cut)) | !(4 %in% unique(df2$cut))) {
            
            cond_plot <- df2 %>% 
                mutate(PEdist = ifelse(value >= 0.5, 1, 0)) %>%
                group_by(SR_TYPE,PEdist) %>%
                count() %>% 
                mutate(Half = ifelse(PEdist == 0,"Bottom 50%","Top 50%")) %>%
                ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = factor(Half)))+
                geom_col()+
                facet_wrap(~Half, labeller = labeller(Half = c("Bottom 50%" = "Sociodemographic distribution below 50%", 
                                                             "Top 50%" = "Sociodemographic distribution above 50%")))+
                theme_bw()+
                theme(legend.position = "none", strip.background = element_blank())+
                labs(
                    title=paste(input$dep, 
                                "Request Volume for Zip Codes\n Above or Below 50% of",
                                input$demo, 
                                "Population Percentage"),
                    y="",
                    x="Request Volume",
                    
                )+scale_fill_manual(values = c("red4","dodgerblue4"))
        }
        
            cond_plot
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
                title = paste(input$dep, "Request\n Response Time"),
                subtitle = "by Chicago Zip Code",
                fill = "Days until\n Response"
            )+
            geom_sf()+
            scale_fill_continuous_sequential("SunsetDark")+
            theme_bw()+
            theme(legend.position = c(0.2, 0.3),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.line = element_line(),
                  axis.ticks = element_line())
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
                title = paste("Population Share of \nSociodemographic variable:",input$demo),
                subtitle = "by Chicago Zip Code",
                fill = paste('%', input$demo) 
            )+
            scale_fill_continuous_sequential("Mako")+
            theme_bw()+
            theme(legend.position = c(0.2, 0.3),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.line = element_line(),
                  axis.ticks = element_line())
    })
    
    # Generate a plot of the data ----
    output$plot4b <- renderPlot({
        
        acsbreaks <- acsmelt %>% 
            filter(GEOID %in% unique(df$ZIP)) %>%
            group_by(variable) %>% 
            mutate(cut  = cut(value,4,labels= FALSE))
        df2 <- df %>% 
            left_join(acsbreaks %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            filter(OWNER_DEPARTMENT == input$dep)
        
        if ((1 %in% unique(df2$cut)) | (4 %in% unique(df2$cut))) {
            
            cond_plot <- df2 %>%  
            filter(cut %in% c(1,4)) %>% 
            group_by(SR_TYPE,cut) %>%
            summarize(n = mean(daystoclose[OWNER_DEPARTMENT == input$dep])) %>%
            mutate(cut = ifelse(cut == 1,"Bottom 25%","Top 25%")) %>%
            ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = cut))+
            geom_col()+
            facet_wrap(~cut, labeller = labeller(cut = c("Bottom 25%" = "Number of Requests for Zip Codes\n below the 25th Percentile", 
                                                         "Top 25%" = "Number of Requests for Zip Codes\n above the 75th Percentile")))+
            theme_bw()+
            theme(legend.position = "none", strip.background = element_blank())+
            labs(
                title=paste(input$dep, 
                            "Average Request Time for Zip Codes in\n Top and Bottom Quartiles of",
                            input$demo, 
                            "Population Percentage"),
                y="",
                x="Response Time (Days)",
                
            )+scale_fill_manual(values = c("red4","dodgerblue4"))
            }
        
        if (!(1 %in% unique(df2$cut)) & !(4 %in% unique(df2$cut))) {
            
            cond_plot <- df2 %>% 
                mutate(PEdist = ifelse(value >= 0.5, 1, 0)) %>%
                group_by(SR_TYPE,PEdist) %>%
                summarize(n = mean(daystoclose[OWNER_DEPARTMENT == input$dep])) %>%
                mutate(Half = ifelse(PEdist == 0,"Bottom 50%","Top 50%")) %>%
                ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = factor(Half)))+
                geom_col()+
                facet_wrap(~Half, labeller = labeller(Half = c("Bottom 50%" = "Sociodemographic distribution below 50%", 
                                                               "Top 50%" = "Sociodemographic distribution above 50%")))+
                theme_bw()+
                theme(legend.position = "none", strip.background = element_blank())+
                labs(
                    title=paste(input$dep, 
                                "Average Request Time for Zip Codes in\n Above or Below 50% of",
                                input$demo, 
                                "Population Percentage"),
                    y="",
                    x="Request Volume",
                    
                )+scale_fill_manual(values = c("red4","dodgerblue4"))
        }
        
        cond_plot
    })
    
    #======================================
    # About
    #======================================
    
    # Generate a summary content ----
    output$about <- renderPrint({
        HTML(paste(h1("Introduction:"),
                   br(),
                   p("In this project, we utilize interactive spatial visualization, R Shiny app, to illustrate how the composition of non-emergency requests differ across communities with varying sociodemographic characteristics in the Chicago 311 Service Requests data."),
                   br(),
                   p("The 311 system is a non-emergency response system where people can make a request to find information about services, make complaints, or report non-emergency problems, such as potholes and trash collection. While the system was initially designed to reduce call volume on the overloaded 911 system, 311 request systems have become an integral part of the e-government movement in which technological innovations are deployed to help local governments deliver more efficient and effective services to residents. Thus, we employ the 311 data in Chicago to provide insights on the variation of communities’ needs and assist the city to better allocate resources accordingly. We incorporate the demographic distribution or socioeconomic measures in order to determine if areas with unusually high or low requests for different services may correlate to a certain distribution of the area."),
                   br(),
                   p("We focus on two measures of interest regarding the 311 data: number of requests and the amount of time it takes to complete a request. While the first measure informs the demand of non-emergency services, the second measures reflect on the quality of responses from the city to its residents. We use zip codes to identify our geographical areas and merge in socio-demographic information from the American Community Survey (ACS) 2019. (See the [data](Data/README.md) folder of this repository for information about the variables of interest used in this analysis.)"),
                   br(),
                   p("For our analysis, we use the data on 311 Service Requests received by the City of Chicago that are publicly available on the Chicago Data Portal. The dataset includes all completed requests created in 2019, which has 1.6 million rows and 37 columns, where each row is a request. Useful features from the data include request type, owner department, created date, closed date, and zip code. From created date and closed date, we calculate the response time in days, `daystoclose`, by finding the difference between these two variables. "),
                   br(),
                   p("Since response time is one of our main measures of interest, we restrict observations to requests that have been completed. In addition, we remove observations without zip code, longitude, and latitude. In the construction of the visualization and interactive app, we created a subset the data, limiting it to a random sample of 1000 observations, to relieve the strain on computation power and run time. See the [codebook](Data/311 codebook.csv) in data folder for all variables in the 311 data. It is noted that the address for requests of the type “311 INFORMATION ONLY CALL” is often the address of the City’s 311 Center."),
                   br(),
                   p("For demographic characteristics, we use data from The American Community Survey (ACS) that is a questionnaire conducted by the United States Census Bureau yearly to collect information about American citizens. Relevant socio-demographic elements were selected from this survey in the year 2019 and converted into a workable dataset using `tidyCensus`. Our subset of data includes 24 columns and 296 rows correlating to Chicago and other outlying areas included in the Chicago Metropolitan Statistical Area (MSA)."),
                   br(),
                   p("We limit the data to observations with zip codes that match with the zip codes included in Chicago 311 dataset, which resulted in 72 unique zip codes. Among the selected variables include factors relevant to race, education, age, gender, and socioeconomic status. While the already selected variables are robust, the many questions included in the original survey allow for us to add or reduce the number of variables included as necessary."),
                   br(),
                   h1("Approach:"),
                   p("There are multiple aspects of the data in our objects: request types (13 categories), socio-demographic variables (22 variables), requests volume, and response time. Thus, the most optimal to present to our audience is through interactive visualizations in R shiny app. Our results will include two main tabs, requests volume and response time, as they are two key distinct concepts of measure in our analysis. The two interactive components are request types and socio-demographic variables. In particular for request types, we using department in charge of the requests, `OWNER_DEPARTMENT`, to categorize them since there are 95 types of request in the original variable, `SR_TYPE`.   


We believe that spatial visualizations are best suited to examine volume of different 311 service request types, response time to address those requests and varying socio-demographic characteristics across different areas of Chicago. To aid in illustrating the characteristics of a selected service domain, we use additional side-by-side bar charts to show the distribution of different request types within a domain/department for the top and bottom quartile of the selected demographic group. Switching to a different demographic group updates these bar charts along with the choropleths for the share of the selected sociodemographic group in different areas. 


This helps to show the relation between the department with initial responsibility for the service request or service type and socioeconomic indicators. For example, there is a positive correlation between influx of a DOB – Building service request and the share of native population. The bar charts help look at this relation in a clearer way as we can see the volume and request time for each request type for both the top and bottom quartile of selected characteristic. The comparison becomes much easier and detailed. 
"),
                   br(),
                   h1("Discussion"),
                   br(),
                   p("The choropleths of population share for socio-demographic characteristics show that the northern communities are concentrated with white population whereas the southern communities/localities with black population. Moreover, natives seem to be evenly distributed with a relatively slightly higher concentration in the eastern lakeside areas. Asians and Native Hawaiian and Pacific Islanders are relatively densely populated in the north than the south. Hispanic are relatively densely populated in the western communities than the east. The eastern communities also seem to have a relatively higher GINI than the west. Median income is relatively higher for the north parts of Chicago than the south. Income through public assistance is however higher for the south whereas income with no public assistance is higher for the north. Education level is higher for the north and lower for the south. Male population is slightly higher in the north and female in south. Youth population is higher in the west and aged 18-34 in the east around downtown and commercial areas."), 
                   br(),
                   p("Request for City Services seem to come from a community with higher black population share, higher GINI and higher income with public assistance. Requests related to animal care and control seem to come more from communities with higher black population share, and low media income and lower education level. Request for Services related to aviation come solely from region with high white population share, and high income with no public assistance. Request for Services related to Business Affairs and Consumer Protection come from communities with higher white population share, higher Native Hawaiian and Pacific Islanders population share and higher level of education. Request for Services related to planning and building come more from region with high Hispanic population share, and high income with no public assistance and lower education level. Request for Services related to planning and building come more from region with high black and Hispanic population share, high GINI, and lower median income and lower education level. Request for Services related to water and management come more from communities with high Hispanic population share, lower median income and lower education level."),
                   br(),
                   p("The response time for request for the service request type Stray Animal Control is longer for communities with high black population share around 18 days for the top 25 percent as compared to around 8 days for the bottom 25 percent. Similarly, the response time for request for the service request type Nuisance Animal Complaint is longer for communities with high Hispanic population share around 18 days for the top 25 percent as compared to around 9 days for the bottom 25 percent. The response time for request for the services related to transportation is generally longer for communities with high white population share or HIPI population share or higher education level, for almost all service request types. The response time is shorter for communities with higher share of black population, Asian population, or Hispanic population. The response time for requests of type Building Violation is longer for communities with low black population share as compared to those with higher black population share whereas it’s longer for communities with higher Hispanic population share and higher population with no college education. Response time for Sever cleaning inspection requests is longer for communities with higher median income as compared to those with lower median income. Response time for Restaurant complaints is much longer for communities with lower native population share as compared to those with higher native population shares. The trend is the opposite for HIPI population share. Response time for Tree removal requests is double (over 150 days) for communities with higher white population share as compared to those with lower white population shares (75 days). The response time for requests related to Streets and sanitation is generally higher for communities with lower median income compared to those with higher income. The visuals show that the volume and response time for various requests type generally differ across different socio-demographic groups and no general inference can be drawn for all requests all together. However, for each specific type of request, some interesting patterns can be seen as the volume and response time for a particular request is significantly different across different groups. Since we have limited our data to only 1000 observations it is quite hard to generate meaningful insights based on the limited data.")
                   
                   
        ))
    })
    
    #======================================
    # Data 
    #======================================
    
    # Generate a summary content ----
    output$datatext <- renderPrint({
        HTML(paste(h1("311 Non-Emergency Request Data"),
              br(),
              p("For our analysis, we use the data on 311 Service Requests received by the City of Chicago that are publicly available on the Chicago Data Portal. The dataset includes all completed requests created in 2019, which has 1.6 million rows and 37 columns, where each row is a request. Useful features from the data include request type, owner department, created date, closed date, and zip code. From created date and closed date, we calculate the response time in days, `daystoclose`, by finding the difference between these two variables."), 
              br(),
              p("Since response time is one of our main measures of interest, we restrict observations to requests that have been completed. In addition, we remove observations without zip code, longitude, and latitude."), 
              br(),
              p("In the construction of the visualization and interactive app, we created a subset the data, limiting it to a random sample of 1000 observations, to relieve the strain on computation power and run time. See the [codebook](Data/311 codebook.csv) in data folder for all variables in the 311 data. It is noted that the address for requests of the type “311 INFORMATION ONLY CALL” is often the address of the City’s 311 Center."),
              br()
              
        ))
        })
    
    # Generate an HTML table view of the data ----
    output$data <- renderTable({
        df %>%
            rename("Service Request Number" = SR_NUMBER,
                   "Service Request Type" = SR_TYPE,
                   "Department" = OWNER_DEPARTMENT,
                   "Date Created" = CREATED_DATE,
                   "Date Closed" = CLOSED_DATE,
                   "Zip Code" = ZIP,
                   "Year" = YEAR,
                   "Hour Created" = CREATED_HOUR,
                   "Day of Week Created" = CREATED_DAY_OF_WEEK,
                   "Month created" = CREATED_MONTH,
                   "Days until Completed" = daystoclose) %>%
            head()
    })
    
    # Generate a summary content ----
    output$data2text <- renderPrint({
        HTML(paste(h1("Sociodemographic Characteristics Data"),
                   br(),
                   p("For demographic characteristics, we use data from The American Community Survey (ACS) that is a questionnaire conducted by the United States Census Bureau yearly to collect information about American citizens. Relevant socio-demographic elements were selected from this survey in the year 2019 and converted into a workable dataset using `tidyCensus`. Our subset of data includes 24 columns and 296 rows correlating to Chicago and other outlying areas included in the Chicago Metropolitan Statistical Area (MSA). 


We limit the data to observations with zip codes that match with the zip codes included in Chicago 311 dataset, which resulted in 72 unique zip codes. Among the selected variables include factors relevant to race, education, age, gender, and socioeconomic status. While the already selected variables are robust, the many questions included in the original survey allow for us to add or reduce the number of variables included as necessary."),
                   br()
                   
        ))
    })
    
    # Generate an HTML table view of the data ----
    output$data2 <- renderTable({
        acs %>% 
            filter(GEOID %in% unique(df$ZIP)) %>%
            rename("Census Tract" = Tract,
                   "Gini Index" = GiniE,
                   "Public Assistance" = pubasst,
                   "No Public Assitance" = nopubasst,
                   "No College Education" = NoCollege,
                   "College Educated" = College,
                   "Under 18" = Under18) %>%
            head()
    })
    
}

# Run the application 
shinyApp(ui = ui, server = server)
