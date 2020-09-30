* Project: WB COVID
* Created on: September 2020
* Created by: jdm
* Edited by: jdm
* Last edit: 16 September 2020 
* Stata v.16.1

* does
	* reads in COVID-19 excel file
	* calculates incidents rates
	* output cleaned data for merging with panel

* assumes
	* COVID-19 excel file

* TO DO:
	* everything


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/analysis/raw" 
	global	export	=	"$data/analysis"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/covid_data", append


* **********************************************************************
* 1 - create covid incidents variables
* **********************************************************************

* read in data
	import 			excel "$root\covid_data.xlsx", sheet("Sheet1") firstrow clear
	
* drop uganda for now
	drop if			country == 4
	
* generate pop density
	gen				pop_dens = population/area_km
	lab var			pop_dens "Population density (pop/kmsq)"
	
* generate infections per 100,000
	gen				infect = case_num / population * 100000
	lab var			infect "Infections per 100k"
	
	gen				lninfect = asinh(infect)
	lab var			lninfect "Ln infections per 100k"
	
* generate deaths per 100,000
	gen				death = mort_num / population * 100000
	lab var			death "Deaths per 100k"
	
	gen				lndeath = asinh(death)
	lab var			lndeath "Ln deaths per 100k"
	

* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

* drop strings
	drop			country_name region_name

	compress
	describe
	summarize


* save file
		customsave , idvar(region) filename("covid_data.dta") ///
			path("$export") dofile(covid_data) user($user)

* close the log
	log	close

/* END */
