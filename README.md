# proj2
*Here is a preliminary explanation of our Project, this document reflects [Proposal.md](proj2-rosy-eeve//Proposal/Proposal.md)*

## Introduction

In this project, we utilize interactive and animated spatio-temporal visualization to illustrate how the composition of non-emergency requests differ across communities with varying sociodemographic characteristics in the Chicago 311 Service Requests data. 

The 311 system is a non-emergency response system where people can make a request to find information about services, make complaints, or report non-emergency problems, such as potholes and trash collection. While the system was initially designed to reduce call volume on the overloaded 911 system, 311 request systems have become an integral part of the e-government movement in which technological innovations are deployed to help local governments deliver more efficient and effective services to residents. Thus, we employ the 311 data in Chicago to provide insights on the variation of communities’ needs and assist the city to better allocate resources accordingly. We intend to incorporate the demographic distribution or socioeconomic measures in order to determine if areas with unusually high or low requests for different services may correlate to a certain distribution of the area..

We focus on two measures of interest regarding the 311 data: number of requests and the amount of time it takes to complete a request. While the first measure informs the demand of non-emergency services, the second measures reflects on the quality of responses from the city to its residents. We use zip codes to identify our geographical areas and merge in socio-demographic information from the American Community Survey (ACS) 2019. 

## [Data](proj2-rosy-eeve/Data)

[Chicago 311 Service Requests](https://data.cityofchicago.org/Service-Requests/311-Service-Requests/v6vf-nfxy)

The data on 311 Service Requests received by the City of Chicago are publicly available on the Chicago Data Portal. The dataset includes requests created after the launch of the new 311 system on 12/18/2018 and was last updated on May 11, 2022. Currently, it has 6 million rows and 37 columns, where each row is a request. Useful features from the data include request type, owner department, create date, closed date, and zip code. Since we are interested in the response time, we restrict observations to requests that have been completed. It is noted that the address for requests of the type “311 INFORMATION ONLY CALL” is often the address of the City's 311 Center. See the codebook below for all variables of interest.


[Demographic Variables](proj2-rosy-eeve/Data/Chicago_zcta_subset_acs2019_clean.csv)

The American Community Survey (ACS) is a questionnaire conducted by the United States Census Bureau yearly to collect information about American citizens. Relevant sociodemographic elements were selected from this survey in the year 2019, and converted into a workable dataset using `tidyCensus`. Our subset of data includes 24 columns and 296 rows correlating to Chicago and other outlying areas included in the Chicago Metropolitan Statistical Area (MSA). Only zip codes included in the Chicago 311 dataset will be selected from this dataset. See the codebook below for all variables of interest. 

| variable_id | label                                                       | class     |
|-------------|-------------------------------------------------------------|-----------|
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
| PECollege   | Percent Estimate Completed A Bachelor's Degree or Higher    | numeric   |
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



## Weekly “plan of attack”
- Week 3 of project (week of Mon, May 16): 
  + Conduct peer review on project proposals
  + Submit an updated version of your proposal.
  + Initial visualization drafts 
- Week 4 of project (week of Mon, May 23): 
  + Finetune visualization 
  + Create interactive and animated visualization in an Shiny app 
- Week 5 of project (week of Mon, May 30): 
  + Present final finished outputs and products
  
## Repository Organization
- [Data](proj2-rosy-eeve/Data/README.md)
  + Demographic data from the ACS via `tidycensus`
  + 311 data 
- [Presentation](proj2-rosy-eeve/Presentation/README.md)
- [Proposal](proj2-rosy-eeve/Proposal/README.md)
- [Write-up](proj2-rosy-eeve/README.md)

## Citations
