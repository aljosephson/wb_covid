* Project: WB COVID
* Created on: April 2021
* Created by: amf
* Edited by: amf
* Last edit: April 2021 
* Stata v.16.1

* does
	* reads in first round of BF data
	* builds round 1
	* outputs round 1

* assumes
	* raw BF data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/burkina_faso/raw"
	global	export	=	"$data/burkina_faso/refined"
	global	logout	=	"$data/burkina_faso/logs"
	global  fies 	= 	"$data/analysis/raw/Burkina_Faso"

* open log
	cap log 		close
	log using		"$logout/bf_build", append

* set local wave number & file number
	local			w = 1
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir 	"$export/wave_0`w'" 

	
* ***********************************************************************
* 1a - get respondent data
* ***********************************************************************	

* load respondant id data	
	use 			"$root/wave_0`w'/r`w'_sec1a_info_entretien_tentative", clear
	keep 			if s01aq08 == 1
	rename 			s01aq09 membres__id
	duplicates 		drop hhid membres__id, force
	duplicates		tag hhid, gen(dups)
	replace 		membres__id = -96 if dups > 0
	duplicates 		drop hhid membres__id, force
	lab def 		mem -96 "multiple respondents"
	lab val 		membres__id mem
	keep 			hhid membres__id

* load roster data with gender
	merge 1:1		hhid membres__id using "$root/wave_0`w'/r`w'_sec2_liste_membre_menage"
	keep 			if _m == 1 | _m == 3
	keep 			hhid s02q05 membres__id s02q07 s02q06
	rename 			membres__id resp_id
	rename 			s02q05 sex
	rename 			s02q06 age
	rename 			s02q07 relate_hoh

* save temp file
	tempfile		tempa
	save			`tempa'
	

* ***********************************************************************
* 1b - get household size and gender of HOH
* ***********************************************************************	

* load roster data	
	use 			"$root/wave_0`w'/r`w'_sec2_liste_membre_menage", clear
	drop 			if s02q03 == 2 //drop if not still hh member
	
* generate counting variables
	gen 			hhsize = 1
	gen 			hhsize_adult = 1 if s02q06 > 18 & s02q06 != .
	gen 			hhsize_child = 1 if s02q06 < 19 & s02q06 != .
	gen 			hhsize_schchild = 1 if s02q06 > 4 & s02q06 < 19
	
* generate hh head gender variable
	gen 			sexhh = .
	replace 		sexhh = s02q05 if s02q07 == 1
	lab var 		sexhh "Sex of household head"
	
* collapse data
	collapse		(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(hhid)
	lab var			hhsize "Household size"
	lab var 		hhsize_adult "Household size - only adults"
	lab var 		hhsize_child "Household size - children 0 - 18"
	lab var 		hhsize_schchild "Household size - school-age children 5 - 18"
	
* save temp file
	tempfile		tempb
	save			`tempb'
	
	
* ***********************************************************************
*  2 - merge
* ***********************************************************************

* load cover data
	use 		"$root/wave_0`w'/r`w'_sec0_cover", clear
	
* merge formatted sections
	foreach 		x in a b {
	    merge 		1:1 hhid using `temp`x'', nogen
	}
	
* merge in other sections
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec3_connaisance_covid19", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec4_comportaments", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec5_acces_service_base", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6_emploi_revenue", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec12_bilan_entretien", nogen

* clean variables inconsistent with other rounds
	rename 			s05q01 ac_med	
	
	
	
	
	
	
	
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			hhwcovid_r`w' phw_cs
	label var		phw_cs "sampling weights - cross section"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		