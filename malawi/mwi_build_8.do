* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 8
	* outputs round 8

* assumes
	* raw malawi data 

* TO DO:
	* ADD FIES DATA


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"
	global  fies 	= 	"$data/analysis/raw/Malawi"

* open log
	cap log 		close
	log using		"$logout/mal_build", append
	
* set local wave number & file number
	local			w = 8
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	
	
* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* no data 

	
* ***********************************************************************
* 1b - reshape section on safety nets wide data
* ***********************************************************************

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear

* drop other
	drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b 

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safety)
 
* collapse cash options into 1 to match round 1 
	rename 			s11q12 temp
	gen 			s11q12 = 1 if temp == 1 | s11q13 == 1 | s11q14 == 1
	replace 		s11q12 = 2 if s11q12 == .
	drop 			s11q13 s11q14  temp
	rename 			s11q15 s11q13

* save temp file
	tempfile		tempb
	save			`tempb'


* ***********************************************************************
* 1c - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/sect12_Interview_Result_r`w'", clear

* drop all but household respondant
	keep			HHID s12q9
	rename			s12q9 PID
	isid			HHID

* merge in household roster
	merge 1:1		HHID PID using "$root/wave_0`w'/sect2_Household_Roster_r`w'.dta"
	keep if			_merge == 3
	drop			_merge

* drop all but gender and relation to HoH
	keep			HHID PID s2q5 s2q6 s2q7 s2q9

* save temp file
	tempfile		tempc
	save			`tempc'
	
	
* ***********************************************************************
* 1d - get household size and gender of HOH
* ***********************************************************************

* load data
	use			"$root/wave_0`w'/sect2_Household_Roster_r`w'.dta", clear

* rename other variables 
	rename 			PID ind_id 
	rename 			s2q2 new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
* generate counting variables
	gen			hhsize = 1
	gen 		hhsize_adult = 1 if age_mem > 18 & age_mem < .
	gen			hhsize_child = 1 if age_mem < 19 & age_mem != . 
	gen 		hhsize_schchild = 1 if age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(HHID)
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	tempfile		tempd
	save			`tempd'
	
	
* ***********************************************************************
* 1e - FIES score
* ***********************************************************************
/*
* load data
	use				"$fies/MW_FIES_round`w'.dta", clear
	drop 			country round 

* merge in other data to get HHID to match 
	rename 			HHID y4_hhid 
	merge 			1:1 y4_hhid using "$root/wave_0`w'/secta_Cover_Page_r`w'"
	keep 			HHID hhsize wt_hh p_mod urban weight Above_18 wt_18 p_sev

* save temp file
	tempfile		tempe
	save			`tempe'

*/
* ***********************************************************************
* 1f - reshape section on coping wide data
* ***********************************************************************

* not available for round

	
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in b c d {
	    merge 		1:1 HHID using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 		HHID using "$root/wave_0`w'/sect4_Behavior_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5_Access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6b_NFE_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6a_Employment2_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6d_Credit_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect9_Concerns_r`w'.dta", nogen

* rename variables inconsistent with other waves


	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_round`w' phw_cs
	label var		phw "sampling weights - cross section"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		