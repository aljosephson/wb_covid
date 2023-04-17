# Socioeconomic impacts of COVID-19 in low income countries: Replication Code
This README describes the directory structure & should enable users to replicate all tables and figures for work related to the World Bank LSMS and World Bank COVID phone surveys. For more information and to access these phone surveys, visit the World Bank Microdata Library (https://microdata.worldbank.org/index.php/home). The relevant surveys are available under under the High-Frequency Phone Survey collection (http://bit.ly/microdata-hfps).   

For more information contact Anna Josephson and/or Jeffrey D. Michler. Contact information listed below.

Last update: January 2023. 

[![DOI](https://zenodo.org/badge/282963786.svg)](https://zenodo.org/badge/latestdoi/282963786)

 ## Index

 - [Introduction](#introduction)
 - [Data](#data)
 - [Data cleaning](#data-cleaning)
 - [Pre-requisites](#pre-requisites)
 - [Folder structure](#folder-structure)

## Introduction

Contributors:
* Anna Josephson (aljosephson@arizona.edu)
* Jeffrey D. Michler (jdmichler@arizona.edu)
* Ann Furbush 
* Talip Kilic 
* Lorin Rudin-Rush

As described in more detail below, scripts various go through each step, from cleaning raw data to analysis.

## Data 

The publicly-available data for each survey round is coupled with a basic information document, interview manual, and questionnaire for that round, which can be accessed through: 
 - Ethiopia: http://bit.ly/ethiopia-phonesurvey 
 - Malawi: http://bit.ly/malawi-phonesurvey 
 - Nigeria: http://bit.ly/nigeria-phonesurvey
 - Uganda: http://bit.ly/uganda-phonesurvey 
 
The approach to the phone survey questionnaire design and sampling is comparable across countries. It is informed by the template questionnaire and the phone survey sampling guidelines that have been publicly made available by the World Bank. These can be accessed through: 
 - Template Questionnaire: http://bit.ly/templateqx 
 - Manual: http://bit.ly/interviewermanual
 - Sampling Guidelines: http://bit.ly/samplingguidelines.

## Data cleaning

The code in this repository cleans all raw phone surveys for the High-Frequency Phone Survey collection: http://bit.ly/microdata-hfps, as of September 2022. The file `project.do' establishes an idential workspace between users, sets globals that define absolute paths, and loads user written packages needed for analysis (see Stata reqs, below). This file should serve as the starting point to find any do-file, dataset, or other output. 

Additionally, the code in this repository cleans the raw phone surveys and replicates material (both in text and supplementary material) related to "Socioeconomic impact of COVID-19 in four African countries". 

### Pre-requisites

#### Stata reqs

The data processing and analysis requires a number of user-written Stata programs:
   * 1. `blindschemes`
   * 2. `estout`
   * 3. `mdesc`
   * 4. `grc1leg2`
   * 5. `distinct`
   * 6. `winsor2`
   * 7. `palettes`
   * 8. `catplot`
   * 9. `colrspace` 

#### Folder structure

The general repo structure looks as follows:<br>

```stata
wb_covid
├────README.md
├────projectdo.do
├────LICENSE
│    
├────country             /* one dir for each country */
│    ├──household_data
│    │  └──wave          /* one dir for each wave */
│    ├──household_cleaning_code 
│
│────Analysis            /* overall analysis */
│    ├──code
│    └──output
│       ├──tables
│       └──figures
│   
└────config
```
