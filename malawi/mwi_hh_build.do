* Project: WB COVID
* Created on: July 2020
* Created by: alj 
* Last edit: 7 August 2020 
* Stata v.16.1

* does
	* reads in first two rounds of malawi data for household roster 
	* builds roster panel
	* merges with panel data

* assumes
	* raw malawi data
	* cleaned malawi data
	
* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"

* open log
	cap log 		close
	log using		"$logout/mal_build_hh", append


* ***********************************************************************
* 1 - create malawi hh roster 
* ***********************************************************************

* read in data + append waves 
	use				"$mwi/wave_01/sect2_Household_Roster", clear
	
* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
	append using 	"$mwi/wave_02/sect2_Household_Roster_r2", force
	
* generate round variable
	replace 		wave = 2 if wave == . 
	
* reformat HHID
	rename			HHID household_id_an
	label 			var household_id_an "32 character alphanumeric - str32"
	encode 			household_id_an, generate(HHID)
	label           var HHID "unique identifier of the interview"
	format 			%12.0f HHID
	order 			y4_hhid HHID household_id_an 
	
	rename			HHID household_id
	lab var			household_id "Household ID (Full)"
	
	rename 			y4_hhid hhid_mwi 


* rename other variables 
	rename 			PID ind_id 
	rename 			new_member new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem
	
* create country id 
	gen				country = 2
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	lab var			country "Country"
	
* drop unneeded variables 
	drop s2q2 s2q4 s2q4_os s2q7_os s2q8 s2q8_os s2q9 s2q9_os s2q10 s2q11 household_id household_id_an 
	
* order variables 
	order 			country wave hhid_mwi ind_id 
	
compress
describe
summarize 

	save			"$export/mwi_hhroster", replace

* **********************************************************************
* 2 - match hh roster to panel
* **********************************************************************	

* read in data + append 
	use				"$export/mwi_hhroster", clear
	
	merge 			m:1 wave hhid_mwi using "$export/mwi_panel"
	
	
* save file 	
	save			"$export/mwi_panelroster", replace	
	
* **********************************************************************
* 3 - end matter, clean up to save
* **********************************************************************

	compress	
	describe
	summarize 

* save file
		customsave , idvar(hhid_mwi) filename("mwi_panelroster.dta") ///
			path("$export") dofile(mwi_hh_build) user($user)

* close the log
	log	close

/* END */