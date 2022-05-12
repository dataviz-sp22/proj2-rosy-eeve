Proposal
================
Kamran Ahmed, Kaylah Thomas, Thao Tran (Rosy Eeve)
5/11/2022

## Introduction

In this project, we utilize interactive and animated spatio-temporal
visualization to illustrate how the composition of non-emergency
requests differ across communities with varying sociodemographic
characteristics in the Chicago 311 Service Requests data.

The 311 system is a non-emergency response system where people can make
a request to find information about services, make complaints, or report
non-emergency problems, such as potholes and trash collection. While the
system was initially designed to reduce call volume on the overloaded
911 system, 311 request systems have become an integral part of the
e-government movement in which technological innovations are deployed to
help local governments deliver more efficient and effective services to
residents. Thus, we employ the 311 data in Chicago to provide insights
on the variation of communities’ needs and assist the city to better
allocate resources accordingly. We intend to incorporate the demographic
distribution or socioeconomic measures in order to determine if areas
with unusually high or low requests for different services may correlate
to a certain distribution of the area..

We focus on two measures of interest regarding the 311 data: number of
requests and the amount of time it takes to complete a request. While
the first measure informs the demand of non-emergency services, the
second measures reflects on the quality of responses from the city to
its residents. We use zip codes to identify our geographical areas and
merge in sociodemographic information from the American Community Survey
(ACS) 2019.

Our project will include spatial visualizations of different 311 service
request types, as well as other plots that will aid in illustrating the
characteristics of a selected area. This will help to show the
correlation between trends, for example, an influx of a graffiti
cleaning service request and the education level of those who reside in
that area. We plan to implement Shiny apps to show each type of 311
request. We would also like to consider using the package `rayshader` to
develop interactive 3-D maps to represent the frequency of service
requests in a given area. Basic `ggplot2` visualizations will be
developed in order to aid our 3-D interactive visualizations, such as
density plots, line plots, or bar charts.

## [Data](proj2-rosy-eeve/Data)

[Chicago 311 Service
Requests](google%20drive%20link%20to%20dataset%20here)

The data on 311 Service Requests received by the City of Chicago are
publicly available on the Chicago Data Portal. The dataset includes
requests created after the launch of the new 311 system on 12/18/2018
and was last updated on May 11, 2022. Currently, it has 6 million rows
and 37 columns, where each row is a request. Useful features from the
data include request type, owner department, create date, closed date,
and zip code. Since we are interested in the response time, we restrict
observations to requests that have been completed. It is noted that the
address for requests of the type “311 INFORMATION ONLY CALL” is often
the address of the City’s 311 Center. See the codebook below for all
variables of
interest.

| Column Name                | Description                                                                                                                                                                                          | Type        |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| SR\_NUMBER                 | Request ID                                                                                                                                                                                           | Plain Text  |
| SR\_TYPE                   | Request type                                                                                                                                                                                         | Plain Text  |
| SR\_SHORT\_CODE            | An internal code corresponding to the Service Request Type. This code allows for searching and filtering more easily than using the full SR\_TYPE value.                                             | Plain Text  |
| OWNER\_DEPARTMENT          | The department with initial responsibility for the service request.                                                                                                                                  | Plain Text  |
| STATUS                     | Status                                                                                                                                                                                               | Plain Text  |
| CREATED\_DATE              | Created date                                                                                                                                                                                         | Date & Time |
| LAST\_MODIFIED\_DATE       | Last modified date                                                                                                                                                                                   | Date & Time |
| CLOSED\_DATE               | Closed date                                                                                                                                                                                          | Date & Time |
| STREET\_ADDRESS            | Street address                                                                                                                                                                                       | Plain Text  |
| CITY                       | City                                                                                                                                                                                                 | Plain Text  |
| STATE                      | State                                                                                                                                                                                                | Plain Text  |
| ZIP\_CODE                  | Zip code                                                                                                                                                                                             | Plain Text  |
| STREET\_NUMBER             | Street number                                                                                                                                                                                        | Plain Text  |
| STREET\_DIRECTION          | Street direction                                                                                                                                                                                     | Plain Text  |
| STREET\_NAME               | Street name                                                                                                                                                                                          | Plain Text  |
| STREET\_TYPE               | Street type                                                                                                                                                                                          | Plain Text  |
| DUPLICATE                  | Is this request a duplicate of another request?                                                                                                                                                      | Checkbox    |
| LEGACY\_RECORD             | Did this request originate in the previous 311 system?                                                                                                                                               | Checkbox    |
| LEGACY\_SR\_NUMBER         | If this request originated in the previous 311 system, the original Service Request Number.                                                                                                          | Plain Text  |
| PARENT\_SR\_NUMBER         | Parent Service Request of the record if applicable. If the current Service Request record has been identified as a duplicate request, the record will be created as a child of the original request. | Plain Text  |
| COMMUNITY\_AREA            | Community area                                                                                                                                                                                       | Number      |
| WARD                       | Ward                                                                                                                                                                                                 | Number      |
| ELECTRICAL\_DISTRICT       | Electrical district                                                                                                                                                                                  | Plain Text  |
| ELECTRICITY\_GRID          | Electrical grid                                                                                                                                                                                      | Plain Text  |
| POLICE\_SECTOR             | Police sector                                                                                                                                                                                        | Plain Text  |
| POLICE\_DISTRICT           | Police district                                                                                                                                                                                      | Plain Text  |
| POLICE\_BEAT               | Police beat                                                                                                                                                                                          | Plain Text  |
| PRECINCT                   | Precinct                                                                                                                                                                                             | Plain Text  |
| SANITATION\_DIVISION\_DAYS | Sanitation division days                                                                                                                                                                             | Plain Text  |
| CREATED\_HOUR              | The hour of the day component of CREATED\_DATE.                                                                                                                                                      | Number      |
| CREATED\_DAY\_OF\_WEEK     | The day of the week component of CREATED\_DATE. Sunday=1                                                                                                                                             | Number      |
| CREATED\_MONTH             | The month component of CREATED\_DATE                                                                                                                                                                 | Number      |
| X\_COORDINATE              | The x coordinate of the location in State Plane Illinois East NAD 1983 projection.                                                                                                                   | Number      |
| Y\_COORDINATE              | The y coordinate of the location in State Plane Illinois East NAD 1983 projection.                                                                                                                   | Number      |
| LATITUDE                   | The latitude of the location.                                                                                                                                                                        | Number      |
| LONGITUDE                  | The longitude of the location.                                                                                                                                                                       | Number      |
| LOCATION                   | The location in a format that allows for creation of maps and other geographic operations on this data portal.                                                                                       | Location    |

[Demographic
Variables](proj2-rosy-eeve/Data/Chicago_zcta_subset_acs2019_clean.csv)

The American Community Survey (ACS) is a questionnaire conducted by the
United States Census Bureau yearly to collect information about American
citizens. Relevant sociodemographic elements were selected from this
survey in the year 2019, and converted into a workable dataset using
`tidyCensus`. Our subset of data includes 24 columns and 296 rows
correlating to Chicago and other outlying areas included in the Chicago
Metropolitan Statistical Area (MSA). Only zip codes included in the
Chicago 311 dataset will be selected from this dataset. See the codebook
below for all variables of
interest.

| variable\_id | label                                                       | class     |
| ------------ | ----------------------------------------------------------- | --------- |
| GEOID        | Zipcode                                                     | numeric   |
| Tract        | Tract                                                       | character |
| PEWhite      | Percent Estimate White                                      | numeric   |
| PEBlack      | Percent Estimate Black                                      | numeric   |
| PENative     | Percent Estimate American Indian and Alaska Native          | numeric   |
| PEAsian      | Percent Estimate Asian                                      | numeric   |
| PEHIPI       | Percent Estimate Native Hawaiian and Other Pacific Islander | numeric   |
| PEHispanic   | Percent Estimate Hispanic                                   | numeric   |
| GiniE        | Gini Inequality Index                                       | numeric   |
| MedincE      | Median Household Income                                     | numeric   |
| PEpubasst    | Percent Estimate Receiving Public Assitance                 | numeric   |
| PEnopubasst  | Percent Estimate Not Receiving Public Assitance             | numeric   |
| PENoCollege  | Percent Estimate Completed Less than Highschool Education   | numeric   |
| PECollege    | Percent Estimate Completed A Bachelor’s Degree or Higher    | numeric   |
| PEUnder18    | Percent Estimate Under 18                                   | numeric   |
| PE18t24      | Percent Estimate 18 to 24                                   | numeric   |
| PE25t34      | Percent Estimate 25 to 34                                   | numeric   |
| PE35t34      | Percent Estimate 35 to 44                                   | numeric   |
| PE45t54      | Percent Estimate 45 to 54                                   | numeric   |
| PE55t64      | Percent Estimate 55 to 64                                   | numeric   |
| PE65t74      | Percent Estimate 65 to 74                                   | numeric   |
| PE75over     | Percent Estimate 75 and over                                | numeric   |
| PEFemale     | Percent Estimate Female                                     | numeric   |
| PEMale       | Percent Estimate Male                                       | numeric   |

## Weekly “plan of attack”

  - Week 3 of project (week of Mon, May 16):
      - Conduct peer review on project proposals
      - Submit an updated version of your proposal.
      - Initial visualization drafts
  - Week 4 of project (week of Mon, May 23):
      - Finetune visualization
      - Create interactive and animated visualization in an Shiny app
  - Week 5 of project (week of Mon, May 30):
      - Present final finished outputs and products

## Repository Organization

  - [Data](proj2-rosy-eeve/Data/README.md)
      - Demographic data from the ACS via `tidycensus`
      - 311 data
  - [Presentation](proj2-rosy-eeve/Presentation/README.md)
  - [Proposal](proj2-rosy-eeve/Proposal/README.md)
  - [Write-up](proj2-rosy-eeve/README.md)

## Citations
