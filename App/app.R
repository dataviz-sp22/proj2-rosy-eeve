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
            selectInput(inputId = "demo", label = "Sociodemographic characteristics - Select a variable:",
                         #choiceValues = names(acs[,-c(1:2)]),
                         selected = names(acs[,3]),
                         choices = c("Race & Ethinicity: White"="White",
                                         "Race & Ethinicity: Black"="Black",
                                         "Race & Ethinicity: Native"="Native",
                                         "Race & Ethinicity: Asian"="Asian", 
                                         "Race & Ethinicity: HIPI"="HIPI",  
                                         "Race & Ethinicity: Hispanic"="Hispanic",  
                                         "Income: Gini Index"="GiniE", 
                                         "Income: Median Income"="MedincE",  
                                         "Income: Public Assistance"="pubasst",  
                                         "Income: No Public Assistance"="nopubasst", 
                                         "Education: No College"="NoCollege",
                                         "Education: College"="College",
                                         "Age: Under 18"="Under18", 
                                         "Age: 18 to 24"="18t24", 
                                         "Age: 25 to 34"="25t34", 
                                         "Age: 35 to 44"="35t34", 
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
                        #tabPanel("Plot", plotOutput("plot"), plotOutput("plot2"), plotOutput("plot3")),
                        tabPanel("Request Volume",fluidRow(splitLayout(cellWidths = c("49%", "49%"), plotOutput("plot"), plotOutput("plot2"))),
                                 plotOutput("plot4")),
                        tabPanel("Response Time",fluidRow(splitLayout(cellWidths = c("49%", "49%"), plotOutput("plotb"), plotOutput("plot2b"))),
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
                title = paste(input$dep, "Request Volume\n by Chicago Zip Code"),
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
                subtitle = "by Chicago Zip Code",
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

        acsbreaks <- acsmelt %>% 
            filter(GEOID %in% unique(df$ZIP)) %>%
            group_by(variable) %>% 
            mutate(cut  = cut(value,4,labels= FALSE))
        df <- df %>% 
            left_join(acsbreaks %>% filter(variable == input$demo),by=c("ZIP"="GEOID")) %>% na.omit() %>%
            filter(OWNER_DEPARTMENT == input$dep)
        
        if ((1 %in% unique(df$cut)) & (4 %in% unique(df$cut))) {
            
            cond_plot <- df %>% 
            filter(cut %in% c(1,4)) %>% 
            group_by(SR_TYPE,cut) %>%
            count() %>% 
            mutate(cut = ifelse(cut == 1,"Bottom 25%","Top 25%")) %>%
            ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = cut))+
            geom_col()+
            facet_wrap(~cut, labeller = labeller(cut = c("Bottom 25%" = "Requests for Zip Codes below the 25th Percentile", 
                                                         "Top 25%" = "Requests for Zip Codes above the 75th Percentile")))+
            theme_bw()+
            theme(legend.position = "none", strip.background = element_blank())+
            labs(
                title=paste("311 Request Volume by Chicago Zip Code for variable:\n",input$dep),
                subtitle = paste("By the top and bottom quartile of",input$demo,"population share"),
                y="",
                x="Request Volume",
                
            )+scale_fill_manual(values = c("red4","dodgerblue4"))
        }
        
        if (!(1 %in% unique(df$cut)) & !(4 %in% unique(df$cut))) {
            
            cond_plot <- df %>% 
                mutate(PEdist = ifelse(value >= 0.5, 1, 0)) %>%
                group_by(SR_TYPE,PEdist) %>%
                count() %>% 
                mutate(cut = ifelse(PEdist == 0,"Bottom 50%","Top 50%")) %>%
                ggplot(aes(y = reorder(SR_TYPE,n),x = n,fill = factor(PEdist)))+
                geom_col()+
                facet_wrap(~cut, labeller = labeller(cut = c("Bottom 50%" = "Sociodemographic distribution below 50%", 
                                                             "Top 50%" = "Sociodemographic distribution above 50%")))+
                theme_bw()+
                theme(legend.position = "none", strip.background = element_blank())+
                labs(
                    title=paste("311 Request Volume by Chicago Zip Code for variable:\n",input$dep),
                    subtitle = paste("By the top and bottom quartile of",input$demo,"population share"),
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
                title = paste(input$dep, "Request Response\n Time by Chicago Zip Code"),
                fill = "Days until\n Response"
            )+
            geom_sf()+
            scale_fill_continuous_sequential("SunsetDark")+
            theme_bw()+
            theme(legend.position = c(0.2, 0.2),
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
                fill = input$demo, 
            )+
            scale_fill_continuous_sequential("Mako")+
            theme_bw()+
            theme(legend.position = c(0.2, 0.2),
                  panel.grid.major = element_blank(),
                  panel.grid.minor = element_blank(),
                  axis.line = element_line(),
                  axis.ticks = element_line())
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
                   p("In this project, we utilize interactive and animated spatio-temporal visualization to illustrate how the composition of non-emergency requests differ across communities with varying sociodemographic characteristics in the Chicago 311 Service Requests data."),
                   br(),
                   p("The 311 system is a non-emergency response system where people can make a request to find information about services, make complaints, or report non-emergency problems, such as potholes and trash collection. While the system was initially designed to reduce call volume on the overloaded 911 system, 311 request systems have become an integral part of the e-government movement in which technological innovations are deployed to help local governments deliver more efficient and effective services to residents. Thus, we employ the 311 data in Chicago to provide insights on the variation of communities’ needs and assist the city to better allocate resources accordingly. We incorporate the demographic distribution or socioeconomic measures in order to determine if areas with unusually high or low requests for different services may correlate to a certain distribution of the area."),
                   br(),
                   p("We focus on two measures of interest regarding the 311 data: number of requests and the amount of time it takes to complete a request. While the first measure informs the demand of non-emergency services, the second measures reflect on the quality of responses from the city to its residents. We use zip codes to identify our geographical areas and merge in socio-demographic information from the American Community Survey (ACS) 2019. (see the [data](Data/README.md) folder of this repository for information about the variables of interest used in this analysis."),
                   br(),
                   p("For our analysis, we use the data on 311 Service Requests received by the City of Chicago that are publicly available on the Chicago Data Portal. The dataset includes requests created after the launch of the new 311 system on 12/18/2018 and was last updated on May 11, 2022. Currently, it has 6 million rows and 37 columns, where each row is a request. Useful features from the data include request type, owner department, create date, closed date, and zip code. Since we are interested in the response time, we restrict observations to requests that have been completed. It is noted that the address for requests of the type “311 INFORMATION ONLY CALL” is often the address of the City’s 311 Center. We have created a subset the data, limiting it to a sample of 1000 observations for the sake of faster loading for our demo purposes. See the [codebook](Data/ACS2019_codebook.csv) in data folder for all variables of interest."),
                   br(),
                   p("For demographic characteristics, we use data from The American Community Survey (ACS) that is a questionnaire conducted by the United States Census Bureau yearly to collect information about American citizens. Relevant sociodemographic elements were selected from this survey in the year 2019 and converted into a workable dataset using tidyCensus. Our subset of data includes 24 columns and 296 rows correlating to Chicago and other outlying areas included in the Chicago Metropolitan Statistical Area (MSA). We limit the data to observations with zip codes that match with the zip codes included in Chicago 311 dataset. Among the selected variables include factors relevant to race, education, age, gender, and socioeconomic status. While the already selected variables are robust, the many questions included in the original survey allow for us to add or reduce the number of variables included as necessary. See the [codebook](Data/ACS2019_codebook.csv) in the data folder for all variables of interest."),
                   br(),
                   h2("Approach:"),
                   br(),
                   p("We believe that spatial visualizations are best suited to examine volume of different 311 service request types, response time to address those requests and varying sociodemographic characteristics across different areas of Chicago. To aid in illustrating the characteristics of a selected service domain, we use additional basic ggplot2 visualizations i.e., bar charts to show the distribution of different request types within a domain/department for the top and bottom quartile of the selected demographic group. Switching to a different demographic group updates these bar charts along with the choropleth for the share of the selected sociodemographic group in different areas."),
                   br(),
                   p("This helps to show the relation between the department with initial responsibility for the service request or service type and socioeconomic indicators. For example, there is a positive correlation between influx of a DOB – Building service request and the share of native population. The bar charts help look at this relation in a clearer way as we can see the volume and request time for each request type for both the top and bottom quartile of selected characteristic. The comparison becomes much easier and detailed."),
                   br(),
                   p("We add an element of interactivity to this analysis using Shiny app. The app provides the feature to toogle certain categories of service requests, as well as select a community area in order to see the distribution of service requests and the demographic patterns associated with the frequency of requests in the area."),
                   h3("Discussion:"),
                   br(),
                   p("The choropleths of population share for socio-demographic characteristics show that the northern communities are concentrated with white population whereas the southern communities/localities with black population. Moreover, natives seem to be evenly distributed with a relatively slightly higher concentration in the eastern lakeside areas. Asians and Native Hawaiian and Pacific Islanders are relatively densely populated in the north than the south. Hispanic are relatively densely populated in the western communities than the east. The eastern communities also seem to have a relatively higher GINI than the west. Median income is relatively higher for the north parts of Chicago than the south. Income through public assistance is however higher for the south whereas income with no public assistance is higher for the north. Education level is higher for the north and lower for the south. Male population is slightly higher in the north and female in south. Youth population is higher in the west and aged 18-34 in the east around downtown and commercial areas."),
                   br(),
                   p("Request for City Services seem to come from a community with higher black population share, higher GINI and higher income with public assistance."),
                   br(),
                   p("Requests related to animal care and control seem to come more from communities with higher black population share, and low media income and lower education level."),
                   br(),
                   p("Request for Services related to aviation come solely from region with high white population share, and high income with no public assistance."),
                   br(),
                   p("Request for Services related to Business Affairs and Consumer Protection come from communities with higher white population share, higher Native Hawaiian and Pacific Islanders population share and higher level of education."),
                   br(),
                   p("Request for Services related to planning and building come more from region with high Hispanic population share, and high income with no public assistance and lower education level."),
                   br(),
                   p("Request for Services related to planning and building come more from region with high black and Hispanic population share, high GINI, and lower median income and lower education level."),
                   br(),
                   p("Request for Services related to water and management come more from communities with high Hispanic population share, lower median income and lower education level."),
                   br(),
                   p("The response time for request for the service request type Stray Animal Control is longer for communities with high black population share around 18 days for the top 25 percent as compared to around 8 days for the bottom 25 percent. Similarly, the response time for request for the service request type Nuisance Animal Complaint is longer for communities with high Hispanic population share around 18 days for the top 25 percent as compared to around 9 days for the bottom 25 percent."),
                   br(),
                   p("The response time for request for the services related to transportation is generally longer for communities with high white population share or HIPI population share or higher education level, for almost all service request types. The response time is shorter for communities with higher share of black population, Asian population, or Hispanic population."),
                   br(),
                   p("The response time for requests of type Building Violation is longer for communities with low black population share as compared to those with higher black population share whereas it’s longer for communities with higher Hispanic population share and higher population with no college education."),
                   br(),
                   p("Response time for Sever cleaning inspection requests is longer for communities with higher median income as compared to those with lower median income."),
                   br(),
                   p("Response time for Restaurant complaints is much longer for communities with lower native population share as compared to those with higher native population shares. The trend is the opposite for HIPI population share. Response time for Tree removal requests is double (over 150 days) for communities with higher white population share as compared to those with lower white population shares (75 days)."),
                   br(),
                   p("The response time for requests related to Streets and sanitation is generally higher for communities with lower median income compared to those with higher income."),
                   br(),
                   p("The visuals show that the volume and response time for various requests type generally differ across different socio-demographic groups and no general inference can be drawn for all requests all together. However, for each specific type of request, some interesting patterns can be seen as the volume and response time for a particular request is significantly different across different groups."),
                   br(),
                   p("Since we have limited our data to only 1000 observations it is quite hard to generate meaningful insights based on the limited data."),
                   
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
