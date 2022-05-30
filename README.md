Project 2 Write-Up
================

\#Project 2 Write-up

\#\#Kamran Ahmed, Kaylah Thomas, Thao Tran (Rosy Eeve) \#\#5/11/2022

## Introduction


In this project, we utilize interactive and animated spatio-temporal visualization to illustrate how the composition of non-emergency requests differ across communities with varying sociodemographic characteristics in the Chicago 311 Service Requests data.


The 311 system is a non-emergency response system where people can make a request to find information about services, make complaints, or report non-emergency problems, such as potholes and trash collection. While the system was initially designed to reduce call volume on the overloaded 911 system, 311 request systems have become an integral part of the e-government movement in which technological innovations are deployed to help local governments deliver more efficient and effective services to residents. Thus, we employ the 311 data in Chicago to provide insights on the variation of communities’ needs and assist the city to better allocate resources accordingly. We incorporate the demographic distribution or socioeconomic measures in order to determine if areas with unusually high or low requests for different services may correlate to a certain distribution of the area.


We focus on two measures of interest regarding the 311 data: number of requests and the amount of time it takes to complete a request. While the first measure informs the demand of non-emergency services, the second measures reflect on the quality of responses from the city to its residents. We use zip codes to identify our geographical areas and merge in socio-demographic information from the American Community Survey (ACS) 2019. (see the [data](Data/README.md) folder of this repository for information about the variables of interest used in this
analysis.

For our analysis, we use the data on 311 Service Requests received by the City of Chicago that are publicly available on the Chicago Data Portal. The dataset includes requests created after the launch of the new 311 system on 12/18/2018 and was last updated on May 11, 2022. Currently, it has 6 million rows and 37 columns, where each row is a request. Useful features from the data include request type, owner department, create date, closed date, and zip code. Since we are interested in the response time, we restrict observations to requests that have been completed. It is noted that the address for requests of the type “311 INFORMATION ONLY CALL” is often the address of the City’s 311 Center. We have created a subset the data, limiting it to a sample of 1000 observations for the sake of faster loading for our demo purposes. See the codebook in data folder for all variables of interest.

For demographic characteristics, we use data from The American Community Survey (ACS) that is a questionnaire conducted by the United States Census Bureau yearly to collect information about American citizens. Relevant sociodemographic elements were selected from this survey in the year 2019 and converted into a workable dataset using tidyCensus. Our subset of data includes 24 columns and 296 rows correlating to Chicago and other outlying areas included in the Chicago Metropolitan Statistical Area (MSA). We limit the data to observations with zip codes that match with the zip codes included in Chicago 311 dataset. Among the selected variables include factors relevant to race, education, age, gender, and socioeconomic status. While the already selected variables are robust, the many questions included in the original survey allow for us to add or reduce the number of variables included as necessary. See the codebook in the data folder for all variables of interest.

## Approach:
We believe that spatial visualizations are best suited to examine volume of different 311 service request types, response time to address those requests and varying sociodemographic characteristics across different areas of Chicago. To aid in illustrating the characteristics of a selected service domain, we use additional basic ggplot2 visualizations i.e., bar charts to show the distribution of different request types within a domain/department for the top and bottom quartile of the selected demographic group. Switching to a different demographic group updates these bar charts along with the choropleth for the share of the selected sociodemographic group in different areas. 
This helps to show the relation between the department with initial responsibility for the service request or service type and socioeconomic indicators. For example, there is a positive correlation between influx of a DOB – Building service request and the share of native population. The bar charts help look at this relation in a clearer way as we can see the volume and request time for each request type for both the top and bottom quartile of selected characteristic. The comparison becomes much easier and detailed. 
We add an element of interactivity to this analysis using Shiny app. The app provides the feature to toogle certain categories of service requests, as well as select a community area in order to see the distribution of service requests and the demographic patterns associated with the frequency of requests in the area.

## Discussion:
The choropleths of population share for socio-demographic characteristics show that the northern communities are concentrated with white population whereas the southern communities/localities with black population. Moreover, natives seem to be evenly distributed with a relatively slightly higher concentration in the eastern lakeside areas. Asians and Native Hawaiian and Pacific Islanders are relatively densely populated in the north than the south. Hispanic are relatively densely populated in the western communities than the east. The eastern communities also seem to have a relatively higher GINI than the west. Median income is relatively higher for the north parts of Chicago than the south. Income through public assistance is however higher for the south whereas income with no public assistance is higher for the north. Education level is higher for the north and lower for the south. Male population is slightly higher in the north and female in south. Youth population is higher in the west and aged 18-34 in the east around downtown and commercial areas. 
Request for City Services seem to come from a community with higher black population share, higher GINI and higher income with public assistance.
Requests related to animal care and control seem to come more from communities with higher black population share, and low media income and lower education level.
Request for Services related to aviation come solely from region with high white population share, and high income with no public assistance.
Request for Services related to Business Affairs and Consumer Protection come from communities with higher white population share, higher Native Hawaiian and Pacific Islanders population share and higher level of education.
Request for Services related to planning and building come more from region with high Hispanic population share, and high income with no public assistance and lower education level.
Request for Services related to planning and building come more from region with high black and Hispanic population share, high GINI, and lower median income and lower education level.
Request for Services related to water and management come more from communities with high Hispanic population share, lower median income and lower education level.

The response time for request for the service request type Stray Animal Control is longer for communities with high black population share around 18 days for the top 25 percent as compared to around 8 days for the bottom 25 percent. Similarly, the response time for request for the service request type Nuisance Animal Complaint is longer for communities with high Hispanic population share around 18 days for the top 25 percent as compared to around 9 days for the bottom 25 percent.
The response time for request for the services related to transportation is generally longer for communities with high white population share or HIPI population share or higher education level, for almost all service request types. The response time is shorter for communities with higher share of black population, Asian population, or Hispanic population.
The response time for requests of type Building Violation is longer for communities with low black population share as compared to those with higher black population share whereas it’s longer for communities with higher Hispanic population share and higher population with no college education.
Response time for Sever cleaning inspection requests is longer for communities with higher median income as compared to those with lower median income.
Response time for Restaurant complaints is much longer for communities with lower native population share as compared to those with higher native population shares. The trend is the opposite for HIPI population share.	.
Response time for Tree removal requests is double (over 150 days) for communities with higher white population share as compared to those with lower white population shares (75 days).
The response time for requests related to Streets and sanitation is generally higher for communities with lower median income compared to those with higher income.
The visuals show that the volume and response time for various requests type generally differ across different socio-demographic groups and no general inference can be drawn for all requests all together. However, for each specific type of request, some interesting patterns can be seen as the volume and response time for a particular request is significantly different across different groups.



## Repository Organization

  - [Data](Data)
      - Demographic data from the ACS via `tidycensus`
      - 311 data
  - [Presentation](Presentation/README.md)
  - [Proposal](Proposal/README.md)
  - [Write-up](README.md)

## Citations
