* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 1
	* outputs round 1

* assumes
	* raw malawi data 

* TO DO:
	* complete


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
	local			w = 1
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	
* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* load income_loss data
	use				"$root/wave_0`w'/sect7_Income_Loss_r`w'", clear

* drop other source
	drop 			income_source_os
	
*reshape data
	reshape 		wide s7q1 s7q2, i(y4_hhid HHID) j(income_source)

* save temp file
	tempfile		tempa
	save			`tempa'

	
* ***********************************************************************
* 1b - reshape section on safety nets wide data
* ***********************************************************************

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/sect11_Safety_Nets_r`w'", clear

* drop other
	drop 			s11q2 s11q3 s11q3_os

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safetyid)

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
	rename 			new_member new_mem
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

* load data
	use				"$fies/MW_FIES_round`w'.dta", clear
	drop 			country round

* save temp file
	tempfile		tempe
	save			`tempe'
	
		
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in a b c d e {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	
* merge in other sections
	merge 1:1 		HHID using "$root/wave_0`w'/sect3_Knowledge_r`w'.dta",nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect4_Behavior_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5_Access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6_Employment_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect9_Concerns_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect12_Interview_Result_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect13_Agriculture_r`w'.dta", nogen

* rename variables inconsistent with other waves
	rename			s6q2 emp_pre
	rename			s6q3a emp_pre_why
	rename			s6q3b emp_pre_act
	rename			s6q4a emp_same
	rename			s6q4b emp_chg_why
	rename			s6q4c emp_pre_actc
	rename			s6q6 emp_stat
	rename			s6q7 emp_able
	rename			s6q8 emp_unable
	rename			s6q8a emp_unable_why
	rename			s6q8b__1 emp_cont_1
	rename			s6q8b__2 emp_cont_2
	rename			s6q8b__3 emp_cont_3
	rename			s6q8b__4 emp_cont_4
	rename			s6q8c__1 contrct
	rename			s6q9 emp_hh
	rename			s6q11 bus_emp
	rename			s6q12 bus_sect
	rename			s6q13 bus_emp_inc
	rename			s6q14 bus_why
	rename			s6q15 farm_emp
	rename			s6q16 farm_norm
	rename			s6q17__1 farm_why_1
	rename			s6q17__2 farm_why_2
	rename			s6q17__3 farm_why_3
	rename			s6q17__4 farm_why_4
	rename			s6q17__5 farm_why_5
	rename			s6q17__6 farm_why_6
	rename			s6q17__7 farm_why_7

* edit employment activity	
	rename			s6q5 emp_act
	replace 		emp_act = -96 if emp_act == 16
	replace 		emp_act = 16 if emp_act == 15
	replace 		emp_act = 15 if emp_act == 14
	replace 		emp_act = 14 if emp_act == 9
	replace 		emp_act = 9 if emp_act == 11 | emp_act == 12
	replace 		emp_act = 11 if emp_act == 4
	replace 		emp_act = 12 if emp_act == 5
	replace 		emp_act = 4 if emp_act == 7
	replace 		emp_act = 7 if emp_act == 10
	replace 		emp_act = 10 if emp_act == 2
	replace 		emp_act = 2 if emp_act == 3
	replace 		emp_act = 0 if emp_act == 8
	replace 		emp_act = 8 if emp_act == 6
	replace 		emp_act = 6 if emp_act == 13
	replace 		emp_act = 13 if emp_act == 0
	
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
	
		
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_baseline phw
	label var		phw "sampling weights"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		