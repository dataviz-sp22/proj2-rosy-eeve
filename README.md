How do 311 non-emergency requests differ across zipcodes in Chicago?
================
Kamran Ahmed, Kaylah Thomas, Thao Tran (Rosy Eeve)

## Introduction

In this project, we utilize interactive spatial visualization, R Shiny
app, to illustrate how the composition of non-emergency requests differ
across communities with varying sociodemographic characteristics in the
Chicago 311 Service Requests data.

The 311 system is a non-emergency response system where people can make
a request to find information about services, make complaints, or report
non-emergency problems, such as potholes and trash collection. While the
system was initially designed to reduce call volume on the overloaded
911 system, 311 request systems have become an integral part of the
e-government movement in which technological innovations are deployed to
help local governments deliver more efficient and effective services to
residents. Thus, we employ the 311 data in Chicago to provide insights
on the variation of communities’ needs and assist the city to better
allocate resources accordingly. We incorporate the demographic
distribution or socioeconomic measures in order to determine if areas
with unusually high or low requests for different services may correlate
to a certain distribution of the area.

We focus on two measures of interest regarding the 311 data: number of
requests and the amount of time it takes to complete a request. While
the first measure informs the demand of non-emergency services, the
second measures reflect on the quality of responses from the city to its
residents. We use zip codes to identify our geographical areas and merge
in socio-demographic information from the American Community Survey
(ACS) 2019. (See the [data](Data/README.md) folder of this repository
for information about the variables of interest used in this analysis.)

For our analysis, we use the data on 311 Service Requests received by
the City of Chicago that are publicly available on the Chicago Data
Portal. The dataset includes all completed requests created in 2019,
which has 1.6 million rows and 37 columns, where each row is a request.
Useful features from the data include request type, owner department,
created date, closed date, and zip code. From created date and closed
date, we calculate the response time in days, `daystoclose`, by finding
the difference between these two variables.

Since response time is one of our main measures of interest, we restrict
observations to requests that have been completed. In addition, we
remove observations without zip code, longitude, and latitude.

In the construction of the visualization and interactive app, we created
a subset the data, limiting it to a random sample of 1000 observations,
to relieve the strain on computation power and run time. See the
[codebook](Data/311%20codebook.csv) in data folder for all variables in
the 311 data. It is noted that the address for requests of the type “311
INFORMATION ONLY CALL” is often the address of the City’s 311 Center.
The variables of our interest in the 311 are describe below:

``` r
#knit 311 codebook table
knitr::kable(codebook_311 %>% filter(Column.Name %in% c("SR_NUMBER","SR_TYPE", "OWNER_DEPARTMENT","ZIP_CODE","daystoclose")))
```

| Column.Name       | Description                                                         | Type       |
|:------------------|:--------------------------------------------------------------------|:-----------|
| SR\_NUMBER        | Request ID                                                          | Plain Text |
| SR\_TYPE          | Request type                                                        | Plain Text |
| OWNER\_DEPARTMENT | The department with initial responsibility for the service request. | Plain Text |
| ZIP\_CODE         | Zip code                                                            | Plain Text |
| daystoclose       | Number of days from the created date to closed date                 | Number     |

For demographic characteristics, we use data from The American Community
Survey (ACS) that is a questionnaire conducted by the United States
Census Bureau yearly to collect information about American citizens.
Relevant socio-demographic elements were selected from this survey in
the year 2019 and converted into a workable dataset using `tidyCensus`.
Our subset of data includes 24 columns and 296 rows correlating to
Chicago and other outlying areas included in the Chicago Metropolitan
Statistical Area (MSA).

We limit the data to observations with zip codes that match with the zip
codes included in Chicago 311 dataset, which resulted in 72 unique zip
codes. Among the selected variables include factors relevant to race,
education, age, gender, and socioeconomic status. While the already
selected variables are robust, the many questions included in the
original survey allow for us to add or reduce the number of variables
included as necessary. See below or the
[codebook](Data/ACS2019_codebook.csv) in the data folder for all
variables of interest:

``` r
#knit acs codebook table
knitr::kable(codebook_acs,"pipe")
```

| Column.Name | Description                                                 | Type      |
|:------------|:------------------------------------------------------------|:----------|
| GEOID       | Zipcode                                                     | numeric   |
| Tract       | Tract                                                       | character |
| PEWhite     | Percent Estimate White                                      | numeric   |
| PEBlack     | Percent Estimate Black                                      | numeric   |
| PENative    | Percent Estimate American Indian and Alaska Native          | numeric   |
| PEAsian     | Percent Estimate Asian                                      | numeric   |
| PEHIPI      | Percent Estimate Native Hawaiian and Other Pacific Islander | numeric   |
| PEHispanic  | Percent Estimate Hispanic                                   | numeric   |
| GiniE       | Gini Inequality Index                                       | numeric   |
| MedincE     | Median Household Income                                     | numeric   |
| PEpubasst   | Percent Estimate Receiving Public Assitance                 | numeric   |
| PEnopubasst | Percent Estimate Not Receiving Public Assitance             | numeric   |
| PENoCollege | Percent Estimate Completed Less than Highschool Education   | numeric   |
| PECollege   | Percent Estimate Completed A Bachelor’s Degree or Higher    | numeric   |
| PEUnder18   | Percent Estimate Under 18                                   | numeric   |
| PE18t24     | Percent Estimate 18 to 24                                   | numeric   |
| PE25t34     | Percent Estimate 25 to 34                                   | numeric   |
| PE35t34     | Percent Estimate 35 to 44                                   | numeric   |
| PE45t54     | Percent Estimate 45 to 54                                   | numeric   |
| PE55t64     | Percent Estimate 55 to 64                                   | numeric   |
| PE65t74     | Percent Estimate 65 to 74                                   | numeric   |
| PE75over    | Percent Estimate 75 and over                                | numeric   |
| PEFemale    | Percent Estimate Female                                     | numeric   |
| PEMale      | Percent Estimate Male                                       | numeric   |

## Approach:

There are multiple aspects of the data in our objects: request types (13
categories), socio-demographic variables (22 variables), requests
volume, and response time. Thus, the most optimal to present to our
audience is through interactive visualizations in R shiny app. Our
results will include two main tabs, requests volume and response time,
as they are two key distinct concepts of measure in our analysis. The
two interactive components are request types and socio-demographic
variables. In particular for request types, we using department in
charge of the requests, `OWNER_DEPARTMENT`, to categorize them since
there are 95 types of request in the original variable, `SR_TYPE`.

We believe that spatial visualizations are best suited to examine volume
of different 311 service request types, response time to address those
requests and varying socio-demographic characteristics across different
areas of Chicago. To aid in illustrating the characteristics of a
selected service domain, we use additional side-by-side bar charts to
show the distribution of different request types within a
domain/department for the top and bottom quartile of the selected
demographic group. Switching to a different demographic group updates
these bar charts along with the choropleths for the share of the
selected sociodemographic group in different areas.

This helps to show the relation between the department with initial
responsibility for the service request or service type and socioeconomic
indicators. For example, there is a positive correlation between influx
of a DOB – Building service request and the share of native population.
The bar charts help look at this relation in a clearer way as we can see
the volume and request time for each request type for both the top and
bottom quartile of selected characteristic. The comparison becomes much
easier and detailed.

## Code:

[Here](App/app.R) is the link to see to code documentation of our
interactive app.

## Visualization:

Please visit our interactive app at
<https://thaophuongtran.shinyapps.io/dataviz_project2_temp/>

## Discussion:

The choropleths of population share for socio-demographic
characteristics show that the northern communities are concentrated with
white population whereas the southern communities/localities with black
population. Moreover, natives seem to be evenly distributed with a
relatively slightly higher concentration in the eastern lakeside areas.
Asians and Native Hawaiian and Pacific Islanders are relatively densely
populated in the north than the south. Hispanic are relatively densely
populated in the western communities than the east. The eastern
communities also seem to have a relatively higher GINI than the west.
Median income is relatively higher for the north parts of Chicago than
the south. Income through public assistance is however higher for the
south whereas income with no public assistance is higher for the north.
Education level is higher for the north and lower for the south. Male
population is slightly higher in the north and female in south. Youth
population is higher in the west and aged 18-34 in the east around
downtown and commercial areas.

Request for City Services seem to come from a community with higher
black population share, higher GINI and higher income with public
assistance. Requests related to animal care and control seem to come
more from communities with higher black population share, and low media
income and lower education level. Request for Services related to
aviation come solely from region with high white population share, and
high income with no public assistance. Request for Services related to
Business Affairs and Consumer Protection come from communities with
higher white population share, higher Native Hawaiian and Pacific
Islanders population share and higher level of education. Request for
Services related to planning and building come more from region with
high Hispanic population share, and high income with no public
assistance and lower education level. Request for Services related to
planning and building come more from region with high black and Hispanic
population share, high GINI, and lower median income and lower education
level. Request for Services related to water and management come more
from communities with high Hispanic population share, lower median
income and lower education level.

The response time for request for the service request type Stray Animal
Control is longer for communities with high black population share
around 18 days for the top 25 percent as compared to around 8 days for
the bottom 25 percent. Similarly, the response time for request for the
service request type Nuisance Animal Complaint is longer for communities
with high Hispanic population share around 18 days for the top 25
percent as compared to around 9 days for the bottom 25 percent. The
response time for request for the services related to transportation is
generally longer for communities with high white population share or
HIPI population share or higher education level, for almost all service
request types. The response time is shorter for communities with higher
share of black population, Asian population, or Hispanic population. The
response time for requests of type Building Violation is longer for
communities with low black population share as compared to those with
higher black population share whereas it’s longer for communities with
higher Hispanic population share and higher population with no college
education. Response time for Sever cleaning inspection requests is
longer for communities with higher median income as compared to those
with lower median income. Response time for Restaurant complaints is
much longer for communities with lower native population share as
compared to those with higher native population shares. The trend is the
opposite for HIPI population share. Response time for Tree removal
requests is double (over 150 days) for communities with higher white
population share as compared to those with lower white population shares
(75 days). The response time for requests related to Streets and
sanitation is generally higher for communities with lower median income
compared to those with higher income. The visuals show that the volume
and response time for various requests type generally differ across
different socio-demographic groups and no general inference can be drawn
for all requests all together. However, for each specific type of
request, some interesting patterns can be seen as the volume and
response time for a particular request is significantly different across
different groups. Since we have limited our data to only 1000
observations it is quite hard to generate meaningful insights based on
the limited data.

## Repository Organization

-   [Data](./Data)
    -   Demographic data from the ACS via `tidycensus`
    -   311 data
-   [Proposal](Proposal/README.md)
-   [App](./Data)

## Citations

City of Chicago. “311 Service Requests.”
<https://data.cityofchicago.org/Service-Requests/311-Service-Requests/v6vf-nfxy>.
Accessed: 04/30/2022.
