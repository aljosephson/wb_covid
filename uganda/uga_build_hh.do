* Project: WB COVID
* Created on: July 2020
* Created by: alj 
* Last edit: 13 August 2020 
* Stata v.16.1

* does
	* reads in first two rounds of uganda data for household roster 
	* builds roster panel
	* merges with panel data

* assumes
	* raw uganda data
	* cleaned uganda data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************


* define 
	global	root	=	"$data/uganda/raw"
	global	export	=	"$data/uganda/refined"
	global	logout	=	"$data/uganda/logs"

* open log
	cap log 		close
	log using		"$logout/uga_build_hh", append


* ***********************************************************************
* 1 - create uganda hh roster 
* ***********************************************************************

* read in data + append waves 
	use				"$root/wave_01/SEC1", clear
	
* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
* read in data + append waves 
	use				"$root/wave_02/SEC1", clear
	
* generate round variable
	gen				wave = 2
	lab var			wave "Wave number"
	
	format 			%12.0f HHID
	rename 			HHID hhid_uga 

* rename other variables 
	rename 			hh_roster__id ind_id 
	rename 			s1q02 new_mem
	rename 			s1q03 curr_mem
	rename 			s1q05 sex_mem
	rename 			s1q06 age_mem
	rename 			s1q07 relat_mem
		
* create country id 
	gen				country = 4
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	lab var			country "Country"
	
* drop unneeded variables 
	drop t0_ubos_pid pid_ubos s1q02a s1q04 s1q08
	
* order variables 
	order 			country wave hhid_uga ind_id  
	
compress
describe
summarize 

	save			"$export/uga_hhroster", replace

* **********************************************************************
* 2 - match hh roster to panel
* **********************************************************************	

* read in data + append 
	use				"$export/uga_hhroster", clear
	
	merge 			m:1 wave hhid_uga using "$export/uga_panel"
	
	
* save file 	
	save			"$export/uga_panelroster", replace	
	*** 13 did not match 
	
* **********************************************************************
* 3 - end matter, clean up to save
* **********************************************************************

	compress	
	describe
	summarize 

* save file
		customsave , idvar(hhid_uga) filename("uga_panelroster.dta") ///
			path("$export") dofile(uga_hh_build) user($user)

* close the log
	log	close

/* END */