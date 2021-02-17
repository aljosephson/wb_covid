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
	local			w = 4
	
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

* not available for round
	

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

* not available for round


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
	foreach 		x in a c d {
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
	merge 1:1 		HHID using "$root/wave_0`w'/sect6e_Agriculture_r`w'.dta", nogen
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
	replace 		emp_act = -96 if emp_act == 96
	replace 		emp_act = 7 if emp_act == 10
	replace 		emp_act = 13 if emp_act == 8
	replace 		emp_act = 8 if emp_act == 6

	replace 		s6q5 = -96 if s6q5 == 96
	replace 		s6q5 = 16 if s6q5 == 15
	replace 		s6q5 = 15 if s6q5 == 14
	replace 		s6q5 = 14 if s6q5 == 9
	replace 		s6q5 = 9 if s6q5 == 11 | s6q5 == 12
	replace 		s6q5 = 11 if s6q5 == 4
	replace 		s6q5 = 12 if s6q5 == 5
	replace 		s6q5 = 4 if s6q5 == 7
	replace 		s6q5 = 7 if s6q5 == 10
	replace 		s6q5 = 10 if s6q5 == 2
	replace 		s6q5 = 2 if s6q5 == 3
	replace 		s6q5 = 0 if s6q5 == 8
	replace 		s6q5 = 8 if s6q5 == 6
	replace 		s6q5 = 6 if s6q5 == 13
	replace 		s6q5 = 13 if s6q5 == 0
	
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
		
* rename access credit variables inconsistent with wave 3
	rename 			s6dq1 ac_cr_loan
	replace 		ac_cr_loan = 2 if ac_cr_loan == 3
	lab def 		ac_cr_loan 1 "Yes" 2 "Unable or did not try" 
	lab val 		ac_cr_loan ac_cr_loan 
	rename 			s6dq2 ac_cr_lend
	forval 			x = 1/8 {
	    gen 		ac_cr_lend_`x' = 1 if ac_cr_lend == `x'
	}
	drop 			ac_cr_lend
	rename 			s6dq3 ac_cr_lend_att
	forval 			x = 1/12 {
		rename 		s6dq4__`x' ac_cr_why_`x'
	}
	rename 			s6dq5 ac_cr_why_main
	rename 			s6dq6__0 ac_cr_who_1
	rename 			s6dq6__1 ac_cr_who_2
	rename 			s6dq6__2 ac_cr_who_3
	rename 			s6dq7__0 ac_cr_att_who_1
	rename 			s6dq7__1 ac_cr_att_who_2
	rename 			s6dq8 ac_cr_due
	rename 			s6dq9 ac_cr_worry
	rename 			s6dq10 ac_cr_bef
	rename 			s6dq10a ac_cr_prev_repay
	rename 			s6dq11 ac_cr_bef_why
	rename 			s6dq12__0 ac_cr_bef_who_1
	rename 			s6dq12__1 ac_cr_bef_who_2
	rename 			s6dq13 ac_cr_bef_worry
	rename 			s6dq14 ac_cr_miss
	rename 			s6dq15 ac_cr_delay	
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			wt_round`w' phw
	label var		phw "sampling weights"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		