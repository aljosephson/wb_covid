# wb_covid
 This README describes the directory structure & should enable users to replicate all tables and figures from "Estimating the Impact of Weather on Agriculture" project. The main project site is on [OSF][1].

 ## Index

 - [Introduction](#introduction)
 - [Data cleaning](#data-cleaning)
 - [Pre-requisites](#pre-requisites)
 - [Folder structure](#folder-structure)
 - Estimation

## Introduction

This is the repo for the weather project.<br>

Contributors:
* Jeffrey D. Michler
* Anna Josephson
* Talip Kilic

As described in more detail below, scripts various
go through each step, from cleaning raw data to analysis.

## Data cleaning

The code in `masterDoFile.do` (to be done) replicates
    the data cleaning and analysis.

### Pre-requisites

#### Stata req's

  * The data processing and analysis requires a number of user-written
    Stata programs:
    1. `blindschemes`
    2. `estout`
    3. `customsave`
    4. `winsor2`


#### Folder structure

The general repo structure looks as follows:<br>

```stata
wb_covid
├────README.md
├────masterDoFile.do
│    
├────country             /* one dir for each country */
│    ├──household_code
│    │  └──wave          /* one dir for each wave */
│    ├──covid_code
│    │  └──wave          /* one dir for each wave */
│    ├──regression_code
│    └──output
│       ├──tables
│       └──figures
│
│────Analysis            /* overall analysis */
│    ├──code
│    └──output
│       ├──tables
│       └──figures
│   
└────config
```
