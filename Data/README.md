This Folder contains:

- [American Commuinty Survey (ACS) 2019 dataset](Chicago_zcta_subset_acs2019_clean.csv)
  + Collected using `TidyCensus` [(workflow)](ACS_vars.Rmd)


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


- [Chicago 311 requests](https://data.cityofchicago.org/Service-Requests/311-Service-Requests/v6vf-nfxy)
  + Downloaded from the Chicago Data Portal 
 
|Column Name             |Description                                                                                                                                                                                         |Type       |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|
|SR_NUMBER               |Request ID                                                                                                                                                                                          |Plain Text |
|SR_TYPE                 |Request type                                                                                                                                                                                        |Plain Text |
|SR_SHORT_CODE           |An internal code corresponding to the Service Request Type. This code allows for searching and filtering more easily than using the full SR_TYPE value.                                             |Plain Text |
|OWNER_DEPARTMENT        |The department with initial responsibility for the service request.                                                                                                                                 |Plain Text |
|STATUS                  |Status                                                                                                                                                                                              |Plain Text |
|CREATED_DATE            |Created date                                                                                                                                                                                        |Date & Time|
|LAST_MODIFIED_DATE      |Last modified date                                                                                                                                                                                  |Date & Time|
|CLOSED_DATE             |Closed date                                                                                                                                                                                         |Date & Time|
|STREET_ADDRESS          |Street address                                                                                                                                                                                      |Plain Text |
|CITY                    |City                                                                                                                                                                                                |Plain Text |
|STATE                   |State                                                                                                                                                                                               |Plain Text |
|ZIP_CODE                |Zip code                                                                                                                                                                                            |Plain Text |
|STREET_NUMBER           |Street number                                                                                                                                                                                       |Plain Text |
|STREET_DIRECTION        |Street direction                                                                                                                                                                                    |Plain Text |
|STREET_NAME             |Street name                                                                                                                                                                                         |Plain Text |
|STREET_TYPE             |Street type                                                                                                                                                                                         |Plain Text |
|DUPLICATE               |Is this request a duplicate of another request?                                                                                                                                                     |Checkbox   |
|LEGACY_RECORD           |Did this request originate in the previous 311 system?                                                                                                                                              |Checkbox   |
|LEGACY_SR_NUMBER        |If this request originated in the previous 311 system, the original Service Request Number.                                                                                                         |Plain Text |
|PARENT_SR_NUMBER        |Parent Service Request of the record if applicable. If the current Service Request record has been identified as a duplicate request, the record will be created as a child of the original request.|Plain Text |
|COMMUNITY_AREA          |Community area                                                                                                                                                                                      |Number     |
|WARD                    |Ward                                                                                                                                                                                                |Number     |
|ELECTRICAL_DISTRICT     |Electrical district                                                                                                                                                                                 |Plain Text |
|ELECTRICITY_GRID        |Electrical grid                                                                                                                                                                                     |Plain Text |
|POLICE_SECTOR           |Police sector                                                                                                                                                                                       |Plain Text |
|POLICE_DISTRICT         |Police district                                                                                                                                                                                     |Plain Text |
|POLICE_BEAT             |Police beat                                                                                                                                                                                         |Plain Text |
|PRECINCT                |Precinct                                                                                                                                                                                            |Plain Text |
|SANITATION_DIVISION_DAYS|Sanitation division days                                                                                                                                                                            |Plain Text |
|CREATED_HOUR            |The hour of the day component of CREATED_DATE.                                                                                                                                                      |Number     |
|CREATED_DAY_OF_WEEK     |The day of the week component of CREATED_DATE. Sunday=1                                                                                                                                             |Number     |
|CREATED_MONTH           |The month component of CREATED_DATE                                                                                                                                                                 |Number     |
|X_COORDINATE            |The x coordinate of the location in State Plane Illinois East NAD 1983 projection.                                                                                                                  |Number     |
|Y_COORDINATE            |The y coordinate of the location in State Plane Illinois East NAD 1983 projection.                                                                                                                  |Number     |
|LATITUDE                |The latitude of the location.                                                                                                                                                                       |Number     |
|LONGITUDE               |The longitude of the location.                                                                                                                                                                      |Number     |
|LOCATION                |The location in a format that allows for creation of maps and other geographic operations on this data portal.                                                                                      |Location   |

