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
	keep			HHID PID s2q5 s2q6 s2q7

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
	rename 			s3q8 gov_pers_1
	rename 			s3q9 gov_pers_2
	rename 			s3q10 gov_pers_3
	rename 			s3q11 gov_pers_4
	rename 			s3q12 gov_pers_5
	rename			s6q1a edu
	rename			s6q1 emp
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
	
	



/*














* SEC 6A: employment




* SEC 9: concerns
	rename			s9q1 concern_01
	rename			s9q2 concern_02
	rename			s9q3 have_symp
	rename 			s9q4 have_test
	rename 			s9q5 concern_03

* SEC 6B: agriculture
	rename			s13q1 ag_prep
	rename			s13q2a ag_crop_01
	rename			s13q2b ag_crop_02
	rename			s13q2c ag_crop_03

	rename			s13q3 ag_prog
	rename 			s13q4 ag_chg

	rename			s13q5__1 ag_chg_08
	label var 		ag_chg_08 "activities affected - covid measures"
	rename			s13q5__2 ag_chg_09
	label var 		ag_chg_09 "activities affected - could not hire"
	rename			s13q5__3 ag_chg_10
	label var   	ag_chg_10 "activities affected - hired fewer workers"
	rename			s13q5__4 ag_chg_11
	label var 		ag_chg_11 "activities affected - abandoned crops"
	rename			s13q5__5 ag_chg_07
	label var 		ag_chg_07 "activities affected - delayed harvest"
	rename			s13q5__7 ag_chg_12
	label var 		ag_chg_12 "activities affected - early harvest"

	rename			s13q6__1 agcovid_chg_why_01
	rename 			s13q6__2 agcovid_chg_why_02
	rename 			s13q6__3 agcovid_chg_why_03
	rename			s13q6__4 agcovid_chg_why_04
	rename			s13q6__5 agcovid_chg_why_05
	rename 			s13q6__6 agcovid_chg_why_06
	rename 			s13q6__7 agcovid_chg_why_07
	rename 			s13q6__8 agcovid_chg_why_08
	rename 			s13q7 aghire_chg_why

	rename 			s13q8 ag_ext_need
	rename 			s13q9 ag_ext
	rename			s13q10 ag_live_lost
	rename			s13q11 ag_live_chg
	rename			s13q12__1 ag_live_chg_01
	rename			s13q12__2 ag_live_chg_02
	rename			s13q12__3 ag_live_chg_03
	rename			s13q12__4 ag_live_chg_04
	rename			s13q12__5 ag_live_chg_05
	rename			s13q12__6 ag_live_chg_06
	rename			s13q12__7 ag_live_chg_07

	rename			s13q13 ag_sold
	rename			s13q14 ag_sell
	rename 			s13q15 ag_price

* create country variables
	gen				country = 2
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

* drop unneeded variables
	drop 			hh_a16 hh_a17 result s5q1c1__* s5q1c4__* s5q2c__* s5q1c3__* ///
					s5q5__*  *_os s13q5_* s13q6_* *details  s6q8c__2 s6q8c__99 ///
					s6q10__*  interview__key nbrbst s12q2 s12q3__0 s12q3__* ///
					 s12q4__* s12q5 s12q6 s12q7 s12q8 s12q9 s12q10 s12q11 ///
					 s12q12 s12q13 s12q14

* save temp file
	save			"$root/wave_01/r1_sect_all", replace
	
	
	
	
	
	
	
	
	
	
	