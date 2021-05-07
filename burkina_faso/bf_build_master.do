* Project: WB COVID
* Created on: April 2021
* Created by: amf
* Edited by: amf
* Last edited: Nov 2021 
* Stata v.16.1

* does
	* cleans Burkina Faso panel

* assumes
	* raw Burkina Faso data

* TO DO:
	* when new waves available:
		* create build for new wave based on previous ones
		* update global list of waves below
		* check variable crosswalk for differences/new variables & update code if needed
		* check QC flags for issues/discrepancies

		
* **********************************************************************
* 0 - setup
* **********************************************************************

* define list of waves
	global 			waves "1" "2" "3" 
	
* define 
	global	root	=	"$data/burkina_faso/raw"
	global	export	=	"$data/burkina_faso/refined"
	global	logout	=	"$data/burkina_faso/logs"

* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

    if `"`c(username)'"' == "aljosephson" {
        global 		code  	"C:/Users/aljosephson/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

	if `"`c(username)'"' == "annfu" {
		global 		code  	"C:/Users/annfu/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
	}
	
* open log
	cap log 		close
	log using 		"$logout/bf_build", append

	
* **********************************************************************
* 1 - run do files for each round & generate variable comparison excel
* **********************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/burkina_faso/bf_build_`r'"
		ds
		clear
		set 		obs 1
		gen 		variables = ""
		local 		counter = 1
		foreach 	var in `r(varlist)' {
			replace variables = "`var'" in `counter'
			local 	counter = `counter' + 1
			set 	obs `counter'
			recast str30 variables
		}
		gen 		wave`r' = 1
		tempfile 	t`r'
		save 		`t`r''
	}
	use 			`t1',clear
	foreach 		r in "$waves" {
		merge 		1:1 variables using `t`r'', nogen
	}
	drop 			if variables == ""
	export 			excel using "$export/bf_variable_crosswalk.xlsx", first(var) replace
	

* ***********************************************************************
* 2 - create burkina faso panel 
* ***********************************************************************

* append round datasets to build master panel
	foreach 		r in "$waves" {
	    if 			`r' == 1 {
			use		"$export/wave_01/r1", clear
		}
		else {
			append 	using "$export/wave_0`r'/r`r'"
		}
	}
	compress

* adjust household id
	recast 			long hhid
	format 			%12.0g hhid
/*	
* merge in quintiles
	merge m:1		hhid using "", 
	
* rename quintile variable
	rename 			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui	
*/
* create country variable
	gen				country = 5	
	
	
* ***********************************************************************
* 3 - clean bukina faso panel
* ***********************************************************************	
	
* administrative variables 
	rename 			milieu sector
	drop 			langue strate grappe 
	
* knowledge & govt
	rename 			s03q01 know
	forval 			x = 1/8 {
		rename 		s03q02__`x' know_`x'
	}
	forval 			x = 1/6 {
		rename 		s03q03__`x' gov_`x'
	}
	replace 		gov_6 = 1 if s03q03__7 == 1
	drop 			s03q03__7 s03q03_autre
	rename 			s03q03__8 gov_17
	rename 			s03q03__9 gov_18
	rename 			s03q03__10 gov_19
	rename 			s03q03__11 gov_10
	rename 			s03q03__12 gov_16
	
* behavior
	rename 			s04q01 bh_1	
	rename 			s04q02 bh_2
	rename 			s04q03 bh_3
	replace 		bh_3 = . if bh_3 == 3
	
* access
	gen 			ac_med_need = 0 if ac_med == 3
	replace 		ac_med_need = 1 if ac_med < 3
	replace 		ac_med = . if ac_med == 3
	rename 			s05q01b ac_med_why
	replace 		ac_med_why = 6 if ac_med_why == 7
	drop 			s05q01b_autre s05q02*_autre
	
	rename 			s05q02_1 ac_staple_1_need
	rename 			s05q02_2 ac_staple_2_need
	rename 			s05q02_3 ac_staple_3_need
	rename 			s05q02a ac_staple_1
	rename 			s05q02b ac_staple_1_why
	rename 			s05q02c ac_staple_2
	rename 			s05q02d ac_staple_2_why
	rename 			s05q02e ac_staple_3
	rename 			s05q02f ac_staple_3_why
	forval 			x = 1/3 {
		replace 		ac_staple_`x'_need = 2 if ac_staple_`x' == 3
		replace 		ac_staple_`x'_need = 1 if ac_staple_`x' < 3 & ac_staple_`x'_need == .
		replace 		ac_staple_`x' = . if ac_staple_`x' == 3
	}	
	gen 			ac_staple = 1 if ac_staple_1 == 1 | ac_staple_2 == 1 | ac_staple_3 == 1 
	replace 		ac_staple = 0 if (ac_staple_1 == 0 & ac_staple_1_need == 1) | ///
						(ac_staple_2 == 0 & ac_staple_2_need == 1) | ///
						(ac_staple_3 == 0 & ac_staple_3_need == 1) 
	rename 			AlimBase1 staple_1
	rename 			AlimBase2 staple_2
	rename 			AlimBase3 staple_3
	
	rename 			s05q03a ac_medserv_need
	forval 			x = 1/11 {
		rename 		s05q03b__`x' ac_medserv_need_why_`x'
	}
	rename 			s05q03c ac_medserv_cvd
	rename 			s05q03d ac_medserv_oth
	gen 			ac_medserv = 0 if ac_medserv_cvd == 0 | ac_medserv_oth == 0
	replace 		ac_medserv = 1 if ac_medserv_cvd == 1 | ac_medserv_oth == 1
	rename 			s05q03e ac_medserv_why
	replace 		ac_medserv_why = . if ac_medserv_why == 4
	rename 			s05q04 med_ins
	
	rename 			s05q09 ac_bank_need
	rename 			s05q11 ac_bank
	
	forval 			x = 1/7 {
	    rename 		s05q13__`x' exp_prob_`x'
	}
	drop 			s05q13_autre
	
* education 
	rename 			s05q05 sch_child
	rename 			s05q06__1 edu_1
	replace 		edu_1 = 1 if s05q06__7 == 1
	
	rename 			s05q06__2 edu_other 
	replace 		edu_other = 1 if s05q06__8 == 1
	rename 			s05q06__3 edu_13
	rename 			s05q06__4 edu_14
	rename 			s05q06__5 edu_2
	rename 			s05q06__6 edu_3
	rename 			s05q06__9 edu_15
	rename 			s05q06__10 edu_4
	rename 			s05q06__11 edu_16
	rename 			s05q06__12 edu_9
	rename 			s05q06__13 edu_7
	
	gen 			edu_act = 1 if s05q06__14 == 0
	replace 		edu_act = 0 if s05q06__14 == 1
	
	drop 			s05q06__7 s05q06__8 s05q06__14 
	
	rename 			s05q07 edu_cont
	
	forval 			x = 1/8 {
		rename 		s05q08__`x' edu_cont_`x'
	}
	
* employment 
	rename 			s06q01 emp 
	rename 			s06q02 emp_pre
	rename 			s06q03 emp_pre_why
	drop 			s06q03_autre
	rename 			s06q03a emp_search
	rename 			s06q03b emp_search_how
	replace 		emp_search_how = 6 if emp_search_how == 7
	forval 			x = 8/12 {
	    replace 	emp_search_how = `x' - 1 if emp_search_how == `x'
	}
	replace			emp_search_how = 12 if emp_search_how == 14
	replace 		emp_search_how = 14 if emp_search_how == 3
	replace 		emp_search_how = 96 if emp_search_how == 15
	rename 			s06q04a emp_act 
	replace 		emp_act = -96 if emp_act == 15
	replace 		emp_act = 15 if emp_act == 14
	replace 		emp_act = 14 if emp_act == 9
	replace 		emp_act = 9 if emp_act == 11 | emp_act == 12
	replace 		emp_act = 12 if emp_act == 5
	replace 		emp_act = 11 if emp_act == 10
	replace 		emp_act = 10 if emp_act == 2
	replace 		emp_act = 2 if emp_act == 3
	drop 			s06q04a_autre
	
	rename 			s06q04b emp_stat
	replace 		emp_stat = 100 if emp_stat == 5 & wave == 2
	replace 		emp_stat = 5 if emp_stat == 6 & wave == 2
	replace 		emp_stat = 6 if emp_stat == 100 & wave == 2
	lab def 		emp_stat 1 "Own business" 2 "Family business" ///
						3 "Family farm" 4 "Employee for someone else" ///
						5 "Apprentice, trainee, intern" ///
						6 "Employee for the government" -96 "Other"
	lab val 		emp_stat emp_stat	
	rename 			s06q04_1 emp_same
	replace 		emp_same = s06q04_2 if s06q04_2 != .
	drop 			s06q04_2 
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	