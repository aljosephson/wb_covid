* Project: WB COVID
* Created on: July 2020
* Created by: alj 
* Last edit: 10 September 2020 
* Stata v.16.1

* does
	* reads in first two rounds of Ethiopia data for household roster 
	* builds roster panel
	* merges with panel data

* assumes
	* raw Ethiopia data
	* cleaned ethiopia data

* TO DO:
	* complete

* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/ethiopia/raw"
	global	export	=	"$data/ethiopia/refined"
	global	logout	=	"$data/ethiopia/logs"

* open log
	cap log 		close
	log using		"$logout/eth_build_hh", append


* ***********************************************************************
* 1 - create ethiopia hh roster 
* ***********************************************************************

* read in data + append waves 
	use				"$root/wave_01/200610_WB_LSMS_HFPM_HH_Survey_Roster-Round1_Clean-Public", clear
	
* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
	append using 	"$root/wave_02/200620_WB_LSMS_HFPM_HH_Survey_Roster-Round2_Clean-Public", force
	
* generate round variable
	replace 		wave = 2 if wave == . 
	
	append using 	"$root/wave_03/200729_WB_LSMS_HFPM_HH_Survey_Roster-Round3_Clean-Public", force
	
* generate round variable
	replace 		wave = 3 if wave == . 
	
* rename household id 
	encode 			household_id, generate (household_id_d)
	rename 			household_id hhid_eth 

* rename other variables 
	rename 			individual_id ind_id 
	rename 			bi2_hhm_new new_mem
	rename 			bi3_hhm_stillm curr_mem
	rename 			bi4_hhm_gender sex_mem
	rename 			bi5_hhm_age age_mem
	rename 			bi5_hhm_age_months age_month_mem
	rename 			bi6_hhm_relhhh relat_mem
	
* create country id 
	gen				country = 1
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	lab var			country "Country"
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	
* drop unneeded variables 
	drop bi6_hhm_relhhh_other key roster_key submissiondate bi7_hhm_reas bi7_hhm_reas_other bi8_hhm_where
	
* order variables 
	order 			country wave hhid_eth ind_id sexhh 
	
compress
describe
summarize 	

	save			"$export/eth_hhroster", replace

* **********************************************************************
* 2 - match hh roster to panel
* **********************************************************************	

* read in data + append 
	use				"$export/eth_hhroster", clear
	
	merge 			m:1 wave hhid_eth using "$export/eth_panel"
	
	
* save file 	
	save			"$export/eth_panelroster", replace	
	
* **********************************************************************
* 3 - end matter, clean up to save
* **********************************************************************

	compress	
	describe
	summarize 

* save file
		customsave , idvar(hhid_eth) filename("eth_panelroster.dta") ///
			path("$export") dofile(eth_hh_build) user($user)

* close the log
	log	close

/* END */