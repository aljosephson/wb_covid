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
* 2 - create nigeria panel 
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
	
/*
* rationalize variables across waves
	gen 			phw = .
	foreach 		r in "$waves" {
		replace 	phw = phw`r' if phw`r' != . & wave == `r'
		drop 		phw`r'
	}
	lab var			phw "sampling weights"	
	
*/	
	
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
		replace 		ac_staple_`x'_need = 0 if ac_staple_`x' == 3
		replace 		ac_staple_`x'_need = 1 if ac_staple_`x' < 3 & ac_staple_`x'_need == .
		replace 		ac_staple_`x' = . if ac_staple_`x' == 3
	}
	
	
	asdf
	
	gen 			ac_staple = 1 if ac_staple_1 == 1 & ac_staple_2 == 1 & ac_staple_3 == 1
	replace 		ac_staple = 0 if ac_staple_1 == 2 | ac_staple_2 == 2 | ac_staple_3 == 2
	
	
	
	* gen access staple 1 2 & 3 and then gen ac_staple generic based on these 3
	
	
	
	
	
	
	
	
	
	
	
	
	
	