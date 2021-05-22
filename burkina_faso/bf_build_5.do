* Project: WB COVID
* Created on: April 2021
* Created by: amf
* Edited by: amf
* Last edit: April 2021 
* Stata v.16.1

* does
	* reads in fifth round of BF data
	* builds round 5
	* outputs round 5

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
	local			w = 5
	
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
* 2 - other revenues
* ***********************************************************************		
	
* load data	
	use 		"$root/wave_0`w'/r`w'_sec8_autres_revenu",clear
	
* drop other vars
	keep 		hhid revenu__id s08q0*
	
* reshape 
	reshape 	wide s08q0*, i(hhid) j(revenu__id)
	
* format vars
	rename 		s08q011 oth_inc_1
	rename 		s08q012 oth_inc_2
	rename 		s08q013 oth_inc_3
	rename 		s08q014 oth_inc_4
	rename 		s08q015 oth_inc_5
	
	rename 		s08q021 oth_inc_chg_1
	rename 		s08q022 oth_inc_chg_2
	rename 		s08q023 oth_inc_chg_3
	rename 		s08q024 oth_inc_chg_4
	rename 		s08q025 oth_inc_chg_5
	
* save temp file
	tempfile		tempc
	save			`tempc'
	
	
* ***********************************************************************
* 3 - assistance
* ***********************************************************************	

* load data	
	use 		"$root/wave_0`w'/r`w'_sec10_protection_sociale", clear
	
* drop other vars
	keep 		hhid assistance__id s10q01
	
* reshape 
	reshape 	wide s10q01, i(hhid) j(assistance__id)

* format vars
	rename 		s10q01101 asst_food
	rename 		s10q01102 asst_cash
	rename 		s10q01103 asst_kind

* save temp file
	tempfile	tempd
	save		`tempd'
	
	
* ***********************************************************************
*  4 - education
* ***********************************************************************		
	
	use 			"$root/wave_0`w'/r`w'_sec5e_education", clear
	
	rename 			s05eq01 sch_att
	replace 		sch_att = 0 if sch_att == 2
	forval 			x = 1/14 {
	    gen 		sch_att_why_`x' = 0 if sch_att == 0
		replace 	sch_att_why_`x' = 1 if s05eq02 == `x'
	}		
	drop 			s05eq02 s05eq02_autre
	
	rename 			s05eq05 sch_onsite
	replace 		sch_onsite = 1 if sch_onsite == 2
	replace 		sch_onsite = 0 if sch_onsite == 3
	
	forval 			x = 1/11 {
	    rename 		s05eq07__`x' sch_prec_`x'
	}	
	
	rename 			s05eq08 sch_online
	replace 		sch_online = 0 if sch_online == 2
	
	rename 			s05eq09__* edu_act_why_*
	
	replace 		edu_act_why_1 = 1 if edu_act_why_2 == 1 
	drop 			edu_act_why_2 edu_act_why_96 edu_act_why_13
	forval 			x = 3/12 {
	    local 		z = `x' - 1
		rename 		edu_act_why_`x' edu_act_why_`z'
	}
	
	rename 			s05eq12 sch_child 
	replace 		sch_child = 0 if sch_child == 2
	rename 			s05eq15 edu_act
	replace 		edu_act = 0 if edu_act == 2
	
	
	
	
	
	collapse 		(sum) sch* edu* , by (hhid) 
	
	
	
	lab	def				yesno 0 "No" 1 "Yes", replace
	tostring 		hhid, replace
	ds,				has(type numeric)
	foreach 		var in `r(varlist)' {
	    replace 	`var' = 1 if `var' > 1
		lab val 	`var' yesno
	}
	destring 		hhid, replace 
	
ann you are here - replace values that are no but should be missing with . 
and check that this is done in UGA
	
* ***********************************************************************
*  5 - FIES
* ***********************************************************************	
/*
* load data
	use 			"$fies/BF_FIES_round`w'", clear
	
* format hhid & vars
	destring 		HHID, gen(hhid)
	drop 			country round HHID
	
* save temp file
	tempfile		tempf
	save			`tempf'	
	
*/

	
* ***********************************************************************
*  5 - merge
* ***********************************************************************

* load cover data
	use 		"$root/wave_0`w'/r`w'_sec0_cover", clear
	
* merge formatted sections
	foreach 	x in a b c d e {
	    merge 	1:1 hhid using `temp`x'', nogen
	}

* merge in other sections
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec3_connaisance_covid19", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec4_comportaments", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec4b_vaccination_covid19", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec5_acces_service_base", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6a_emplrev_general", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6b_emplrev_travailsalarie", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6c_emplrev_nonagr", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec6d_emplrev_agr", nogen
	merge 1:1 	hhid using "$root/wave_0`w'/r`w'_sec7_securite_alimentaire", nogen

* clean variables inconsistent with other rounds
	* ac_med
	rename 			s05q01a ac_med		
	replace 		ac_med = 1 if ac_med == 2 | ac_med == 3
	replace 		ac_med = 2 if ac_med == 4
	replace 		ac_med = 3 if ac_med == 5
	
	* employment 
	rename 			s06q04_0 emp_chg_why
	replace 		emp_chg_why = 96 if emp_chg_why == 13
	
	* agriculture
	rename 			s06q23 ag_crop_lost
	rename 			s06q24 ag_live
	rename 			s06q25 ag_live_chg
	forval 			x = 1/7 {
		rename 		s06q26__`x' ag_live_chg_`x'
	}
	rename 			s06q27 ag_live_loc
	
* drop 55 variables re main type of crop grown
	drop 			s06q16_*
	
* generate round variables
	gen				wave = `w'
	lab var			wave "Wave number"
	rename 			hhwcovid_r`w'_cs phw_cs
	rename 			hhwcovid_r`w'_pnl phw_pnl
	label var		phw_cs "sampling weights- cross section"
	label var		phw_pnl "sampling weights- panel"
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

/* END */		