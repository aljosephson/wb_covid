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
	* CONSUMPTION AGGREGATES FROM TALIP

		
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
	
	replace 		region = 5001 if region == 1
	replace 		region = 5002 if region == 2
	replace 		region = 5003 if region == 3
	replace 		region = 5004 if region == 4
	replace 		region = 5005 if region == 5
	replace 		region = 5006 if region == 6
	replace 		region = 5007 if region == 7
	replace 		region = 5008 if region == 8
	replace 		region = 5009 if region == 9
	replace 		region = 5010 if region == 10
	replace 		region = 5011 if region == 11
	replace 		region = 5012 if region == 12
	replace			region = 5013 if region == 13
	
	rename 			commune zone_id 
	
	drop 			village b40 echantillon resultat weight

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
	
	gen 			staple_1 = 1 if AlimBase1 == "Maïs en grain"
	replace 		staple_1 = 2 if AlimBase1 == "Riz importé"
	gen 			staple_2 = 1 if AlimBase2 == "Maïs en grain"
	replace 		staple_2 = 2 if AlimBase2 == "Riz importé"
	replace 		staple_2 = 3 if AlimBase2 == "Sorgho"
	gen 			staple_3 = 1 if AlimBase3 == "Maïs en grain"
	replace  		staple_3 = 4 if AlimBase3 == "Farine de maïs"
	replace  		staple_3 = 5 if AlimBase3 == "Mil"
	replace  		staple_3 = 6 if AlimBase3 == "Riz local"
	
	lab def 		staple 1 "Maïs en grain" 2 "Riz importé" 3 "Sorgho" ///
						4 "Farine de maïs" 5 "Mil" 6 "Riz local"
	lab val 		staple_1 staple
	lab val 		staple_2 staple
	lab val 		staple_3 staple
	
	drop 			AlimBase*
	
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
	drop 			s05q03e_autre
	
	rename 			s05q09 ac_bank_need
	rename 			s05q11 ac_bank
	
	forval 			x = 1/5 {
	    rename 		s05q13__`x' exp_prob_`x'
	}
	rename 			s05q13__7 exp_prob_6
	rename 			s05q13__8 exp_prob_7
	drop 			s05q13__6 s05q13_autre
	
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
	rename 			s05q06__15 edu_17
	
	gen 			edu_act = 1 if s05q06__14 == 0
	replace 		edu_act = 0 if s05q06__14 == 1
	
	drop 			s05q06__7 s05q06__8 s05q06__14 
	
	rename 			s05q07 edu_cont
	
	forval 			x = 1/8 {
		rename 		s05q08__`x' edu_cont_`x'
	}
	drop 			s05q08__9 s05q08_autre
	
* employment 
	rename 			s06q01 emp
	rename 			s06q01a rtrn_emp
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
	replace 		emp_same = s06q05 if s06q05 != . & emp_same == .
	drop 			s06q04_2 s06q05
	
	gen 			emp_able = s06q06 if wave == 1
	replace 		s06q06 = . if wave == 1
	rename 			s06q06 emp_hrs_red
	
	rename 			s06q07a emp_unable
	rename 			s06q07b emp_unable_why
	drop 			s06q07b_autre
	rename 			s06q07c_* emp_cont*
	
	gen  			emp_able_hh = s06q08 if wave == 1
	replace 		s06q08 = . if wave == 1
	rename 			s06q08 emp_hrs_red_hh
	rename 			s06q08a emp_hrs_cov 
	
	forval 			x = 0/8 {
		replace 		s06q09__`x' = 1 if s06q09__`x' != .
	}
	egen 			emp_hrs_cov_num = rowtotal(s06q09__*)
	drop			s06q09*  				

	rename 			s06q10 bus_emp
	rename 			s06q10a_1 bus_stat
	replace 		bus_stat = s06q10a_2 if s06q10a_2 != .
	replace 		bus_stat = s06q10a_3 if s06q10a_3 != .	
	drop 			s06q10a_*
	rename 			s06q10b bus_closed
	replace 		bus_closed = 7 if bus_closed == 6
	drop 			s06q10b_autre
	rename 			s06q11 bus_sect
	rename 			s06q12 bus_emp_inc
	rename 			s06q13 bus_why
	replace 		bus_why = s06q13_1 if bus_why == . & s06q13_1 != .
	replace 		bus_why = s06q13_2 if bus_why == . & s06q13_2 != .
	drop 			s06q13_autre s06q13_1 s06q13_2 
	
	rename 			s06q13a__1 bus_chal_1
	rename 			s06q13a__2 bus_chal_2
	rename 			s06q13a__3 bus_chal_3
	rename 			s06q13a__4 bus_chal_5
	rename 			s06q13a__5 bus_chal_6
	
	rename 			s06q13b bus_beh
	rename 			s06q13c__1 bus_beh_4
	replace 		bus_beh_4 = s06q13c__2 if (bus_beh_4 == . | bus_beh_4 == 0) 
	rename 			s06q13c__3 bus_beh_5
	rename 			s06q13c__4 bus_beh_6
	rename 			s06q13c__5 bus_beh_1
	rename 			s06q13c__7 bus_beh_2
	rename 			s06q13c__8 bus_beh_3
	rename 			s06q13c__9 bus_beh_7
	drop 			s06q13c_autre s06q13c__2
	
* agriculture 	
	rename 			s06q14 farm_emp
	gen 			ag_plan = s06q15 if wave == 3
	replace 		s06q15 = . if wave == 3
	rename 			s06q15 farm_norm
	
	rename 			s06q15_1__1 ag_nocrop_1
	rename 			s06q15_1__2 ag_nocrop_2
	rename 			s06q15_1__3 ag_nocrop_3
	rename 			s06q15_1__4 ag_nocrop_4
	rename 			s06q15_1__5 ag_nocrop_10
	rename 			s06q15_1__6 ag_nocrop_5
	rename 			s06q15_1__7 ag_nocrop_6
	rename 			s06q15_1__8 ag_nocrop_7
	rename 			s06q15_1__9 ag_nocrop_8

	gen 			ag_chg = s06q17 if wave == 3
	replace 		s06q17 = . if wave == 3
	rename 			s06q17 harv_sell_need

	rename 			s06q18 harv_sell
	forval 			x = 1/7 {
		rename 		s06q18__`x' ag_chg_`x'
	}
	drop 			s06q18__96 s06q18_autre
	
	rename 			s06q19 ag_price
	forval 			x = 1/9 {
	    rename 		s06q19__`x' ag_covid_`x'
	}
	drop 			s06q19__10
	
	rename 			s06q20 fam_asst
	rename 			s06q21 fam_asst_amt
	rename 			s06q22 fam_asst_freq
	
	forval 			x = 1/6 {
	    rename 		s06q20__`x' ag_ac_seed_why_`x'
		rename 		s06q21__`x' ag_ac_fert_why_`x'
		rename 		s06q22__`x' ag_ac_oth_why_`x'
	}
	
	replace 		ag_ac_seed_why_6 = 1 if s06q16a == 1
	drop 			s06q16a s06q16a_autre	
	
	drop  			s06a_filtre s06q03b_autre s06c_filtre s06q26_autre 
	
* FIES
	rename 			s07q01 fies_4
	rename 			s07q02 fies_5
	rename 			s07q03 fies_6
	rename 			s07q04 fies_7
	rename 			s07q05 fies_8
	rename 			s07q06 fies_1
	rename 			s07q07 fies_2
	rename 			s07q08 fies_3

* coping
	rename 			s09q03__1 cope_1
	forval 			x = 6/9 {
		local 		z = `x' - 4
		rename 		s09q03__`x' cope_`z'
	}
	forval 			x = 11/20 {
		local 		z = `x' - 5
		rename 		s09q03__`x' cope_`z'
	}
	drop 			s09q03__21 s09q03__22 
	
* fragility conflict violence
	rename 			s11q01 security 
	rename 			s11q02 trust
	forval 			x = 1/7 {
		rename 		s11q03__`x' tension_`x'
	}
	rename 			s11q04 move
	rename 			s11q05 move_why
	rename 			s11q06 hh_needs_met
	drop 			s11q*_autre
	
* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

* final clean 
	compress	
	describe
	summarize 
	rename 			hhid hhid_bf 
	label 			var hhid_bf "household id unique - Burkina Faso"
	
* save file
	customsave, 	idvar(hhid_bf) filename("bf_panel.dta") ///
					path("$export") dofile(bf_build_master) user($user)

* close the log
	log	close

/* END */	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	