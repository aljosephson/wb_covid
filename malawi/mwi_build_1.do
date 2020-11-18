* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* renames variables
	* outputs panel data

* assumes
	* raw malawi data 

* TO DO:
	* update this section
	* split out waves 
	* add wave 3


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
	use				"$fies/MW_FIES_round1.dta", clear
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
	merge 1:1 		HHID using "$root/wave_01/sect3_Knowledge_r1.dta",nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect4_Behavior_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect5_Access_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect6_Employment_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect8_food_security_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect9_Concerns_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect12_Interview_Result_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect13_Agriculture_r1.dta", nogenerate

*rename variables inconsistent with other waves
	rename			s6q2 emp_pre
	rename			s6q3a emp_pre_why
	rename			s6q3b emp_pre_act
	rename			s6q4a emp_same
	rename			s6q4b emp_chg_why
	rename			s6q4c emp_pre_actc
	rename			s6q5 emp_act
	rename			s6q6 emp_stat
	rename			s6q7 emp_able
	rename			s6q8 emp_unable
	rename			s6q8a emp_unable_why
	rename			s6q8b__1 emp_cont_01
	rename			s6q8b__2 emp_cont_02
	rename			s6q8b__3 emp_cont_03
	rename			s6q8b__4 emp_cont_04
	rename			s6q8c__1 contrct
	rename			s6q9 emp_hh
	rename			s6q11 bus_emp
	rename			s6q12 bus_sect
	rename			s6q13 bus_emp_inc
	rename			s6q14 bus_why
	rename			s6q15 farm_emp
	rename			s6q16 farm_norm
	rename			s6q17__1 farm_why_01
	rename			s6q17__2 farm_why_02
	rename			s6q17__3 farm_why_03
	rename			s6q17__4 farm_why_04
	rename			s6q17__5 farm_why_05
	rename			s6q17__6 farm_why_06
	rename			s6q17__7 farm_why_07
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_baseline phw
	label var		phw "sampling weights"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		