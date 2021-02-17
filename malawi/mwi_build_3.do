* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: Nov 2020
* Stata v.16.1

* does
	* merges together each section of malawi data
	* builds round 3
	* outputs round 3

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
	local			w = 3
	
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
	drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b s11q5 s11q6__1 ///
						s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 ///
						s11q6__7 s11q7__1 s11q7__2 s11q7__3 s11q7__4 ///
						s11q7__5 s11q7__6 s11q7__7 s11q7_os version

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

* merge in other data to get HHID to match 
	rename 			HHID y4_hhid 
	merge 			1:1 y4_hhid using "$root/wave_0`w'/secta_Cover_Page_r`w'"
	keep 			HHID hhsize wt_hh p_mod urban weight Above_18 wt_18 p_sev

* save temp file
	tempfile		tempe
	save			`tempe'


* ***********************************************************************
* 1f - reshape section on coping wide data
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/sect10_Coping_r`w'", clear
	
* drop other shock
	drop			shock_id_os s10q3_os

* generate shock variables
	forval i = 1/9 {
		gen				shock_`i' = 1 if s10q1 == 1 & shock_id == `i'
	}

* collapse to household level	
	collapse (max) s10q2__1- shock_9, by(HHID y4_hhid)
	
* save temp file
	tempfile		tempf
	save			`tempf'
	
	
* ***********************************************************************
* 2 - merge to build complete dataset for the round 
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/secta_Cover_Page_r`w'", clear
	
* merge formatted sections
	foreach 		x in a b c d e f {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	
* merge in other sections
	merge 1:1 		HHID using "$root/wave_0`w'/sect4_Behavior_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect5_Access_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6a_Employment1_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6a_Employment2_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6b_NFE_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6c_OtherIncome_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect6d_Credit_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect8_food_security_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect9_Concerns_r`w'.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/sect12_Interview_Result_r`w'.dta", nogen
	
*rename variables inconsistent with  wave 1
	rename			s6q1a rtrn_emp
	rename 	 		s6q2_1 emp_pre
	rename			s6q3a_1 emp_pre_why
	rename			s6q3b_1 emp_pre_act
	rename			s6q4a_1 emp_same
	rename			s6q4b_1 emp_chg_why
	rename			s6q4c_1 emp_pre_actc
	rename			s6q6_1 emp_stat
	rename			s6q7_1 emp_able
	rename			s6q8_1 emp_unable
	rename			s6q8a_1 emp_unable_why
	rename			s6q8b_1__1 emp_cont_1
	rename			s6q8b_1__2 emp_cont_2
	rename			s6q8b_1__3 emp_cont_3
	rename			s6q8b_1__4 emp_cont_4
	rename			s6q8c_1 contrct
	replace 		contrct = s6q8e if contrct == .
	drop 			s6q8e
	replace 		contrct = 0 if contrct == 2
	rename			s6bq11 bus_emp
	rename			s6qb12 bus_sect
	rename			s6qb13 bus_emp_inc
	rename			s6qb14 bus_why
	rename			s6q9_1 emp_hh
	rename			s6q15_1 farm_emp
	rename			s6q16_1 farm_norm
	rename			s6q17_1__1 farm_why_1
	rename			s6q17_1__2 farm_why_2
	rename			s6q17_1__3 farm_why_3
	rename			s6q17_1__4 farm_why_4
	rename			s6q17_1__5 farm_why_5
	rename			s6q17_1__6 farm_why_6
	rename			s6q17_1__96 farm_why_7
	rename			s6q17_1__7 farm_why_8
	
* edit employment activity
	rename			s6q5_1 emp_act
	replace 		emp_act = 11 if emp_act == 4
	replace 		emp_act = 13 if emp_act == 8
	replace 		emp_act = 7 if emp_act == 10
 
	replace 		s6q5 = -96 if s6q5 == 96
	replace 		s6q5 = 14 if s6q5 == 9
	replace 		s6q5 = 9 if s6q5 == 11
	replace 		s6q5 = 11 if s6q5 == 4
	replace 		s6q5 = 4 if s6q5 == 7
	replace 		s6q5 = 7 if s6q5 == 10
	replace 		s6q5 = 13 if s6q5 == 8
	replace 		s6q5 = 8 if s6q5 == 6
	
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
	
* rename access credit variables inconsistent with wave 4	
	rename 			s6dq1 ac_cr_need
	rename 			s6dq2 ac_cr_att
	rename 			s6dq3 ac_cr_loan
	forval 			x = 1/8 {
	    rename 		s6dq4__`x' ac_cr_lend_`x'
	}
	rename 			s6dq5 ac_cr_why_main
	rename 			s6dq6__0 ac_cr_who_1
	rename 			s6dq6__1 ac_cr_who_2
	rename 			s6dq7 ac_cr_due
	rename 			s6dq8 ac_cr_worry
	rename 			s6dq9 ac_cr_bef
	rename 			s6dq10 ac_cr_bef_why
	rename 			s6dq11 ac_cr_bef_worry
	rename 			s6dq12 ac_cr_miss
	rename 			s6dq13 ac_cr_delay	
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename			wt_round`w' phw
	label var		phw "sampling weights"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		