* Project: WB COVID
* Created on: July 2020
* Created by: alj 
* Last edit: 7 August 2020 
* Stata v.16.1

* does
	* reads in first two rounds of nigeria data for household roster 
	* builds roster panel
	* merges with panel data

* assumes
	* raw nigeria data
	* cleaned nigeria data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/nigeria/raw"
	global	export	=	"$data/nigeria/refined"
	global	logout	=	"$data/nigeria/logs"

* open log
	cap log 		close
	log using		"$logout/nga_build_hh", append


* ***********************************************************************
* 1 - create nigeria hh roster 
* ***********************************************************************

* read in data + append waves 
	use				"$root/wave_01/r1_sect_2", clear
	
* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
	append using 	"$root/wave_02/r2_sect_2", force
	
* generate round variable
	replace 		wave = 2 if wave == . 
	
	append using 	"$root/wave_03/r3_sect_2", force
	
* generate round variable
	replace 		wave = 3 if wave == . 
	
* rename household id 
	rename hhid hhid_nga 

* rename other variables 
	rename 			indiv ind_id 
	rename 			s2q2 new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem
		
* create country id 
	gen				country = 3
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	lab var			country "Country"
	
* drop unneeded variables 
	drop s*  state lga sector ea zone
	
* order variables 
	order 			country wave hhid_nga ind_id  
	
compress
describe
summarize 

	save			"$export/nga_hhroster", replace

* **********************************************************************
* 2 - match hh roster to panel
* **********************************************************************	

* read in data + append 
	use				"$export/nga_hhroster", clear
	
	merge 			m:1 wave hhid_nga using "$export/nga_panel"
	
	
* save file 	
	save			"$export/nga_panelroster", replace	
	*** 440 did not match - seems to be okay 
	
* **********************************************************************
* 3 - end matter, clean up to save
* **********************************************************************

	compress	
	describe
	summarize 

* save file
		customsave , idvar(hhid_nga) filename("nga_panelroster.dta") ///
			path("$export") dofile(nga_hh_build) user($user)

* close the log
	log	close

/* END */