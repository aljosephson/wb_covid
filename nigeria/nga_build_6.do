* Project: WB COVID
* Created on: August 2020
* Created by: jdm
* Edited by: amf
* Last edited: Dec 2020 
* Stata v.16.1

* does
	* reads in sixth round of Nigeria data
	* reshapes and builds panel
	* outputs panel data 

* assumes
	* raw Nigeria data

* TO DO:
	* add sections, pull together, waiting on questionaire 

	
* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/nigeria/raw"
	global	export	=	"$data/nigeria/refined"
	global	logout	=	"$data/nigeria/logs"
	global  fies 	= 	"$data/analysis/raw/Nigeria"

* open log
	cap log 		close
	log using		"$logout/nga_reshape", append

* set local wave number & file number
	local			w = 6
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 
		
	
* ***********************************************************************
* 1 - format secitons and save tempfiles
* ***********************************************************************	


* ***********************************************************************
* 1a - section 2: household size and gender of HOH
* ***********************************************************************
	
* load data
	use				"$root/wave_0`w'/r`w'_sect_2.dta", clear

* rename other variables 
	rename 			indiv ind_id 
	rename 			s2q2 new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem
	
* generate counting variables
	gen				hhsize = 1
	gen 			hhsize_adult = 1 if age_mem > 18 & age_mem < .
	gen				hhsize_child = 1 if age_mem < 19 & age_mem != . 
	gen 			hhsize_schchild = 1 if age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* collapse data
	collapse		(sum) hhsize hhsize_adult hhsize_child hhsize_schchild (max) sexhh, by(hhid)
	lab var			hhsize "Household size"
	lab var 		hhsize_adult "Household size - only adults"
	lab var 		hhsize_child "Household size - children 0 - 18"
	lab var 		hhsize_schchild "Household size - school-age children 5 - 18"

* save temp file
	tempfile		tempa
	save			`tempa'
	

* ***********************************************************************
* 1b - respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_a_2_3a_6_9a_12", clear
	
* drop all but household respondant
	keep			hhid s12q9
	rename			s12q9 indiv
	isid			hhid
	
* merge in household roster
	merge 			1:1	hhid indiv using "$root/wave_0`w'/r`w'_sect_2.dta"
	keep 			if _merge == 3
	drop 			_merge
	
* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .
	rename			indiv PID
	
* drop all but gender and relation to HoH
	keep			hhid PID sex age relate_hoh

* save temp file
	tempfile		tempb
	save			`tempb'

	
* ***********************************************************************
* 1c - section 7: income
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1, i(hhid) j(source_cd)

* save temp file
	tempfile		tempc
	save			`tempc'	
	
	
* ***********************************************************************
* 1d - section 11: assistance
* ***********************************************************************	
	
* not avaiable for round 
	
		
* ***********************************************************************
* 1e - section 10: shocks
* ***********************************************************************

* not avaiable for round


* ***********************************************************************
* 1e - section 5c: education
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/r`w'_sect_5c.dta", clear	

	rename 			s5cq11 sch_att
	replace 		sch_att = 0 if sch_att == 2
	forval 			x = 1/14 {
	    gen 		sch_att_why_`x' = 0 if sch_att == 0
		replace 	sch_att_why_`x' = 1 if s5cq12 == `x'
	}		
	drop 			s5cq12_os
	rename 			s5cq12a sch_open 
	replace 		sch_open = 0 if sch_open == 2
	
	rename 			s5cq15 sch_onsite
	replace 		sch_onsite = 1 if sch_onsite == 2
	replace 		sch_onsite = 0 if sch_onsite == 3
	
	rename 			s5cq17 sch_online
	replace 		sch_online = 0 if sch_online == 2
	
	rename 			s5cq18 sch_child
	replace 		sch_child = 0 if sch_child == 2
	
	rename 			s5cq21 edu_act 
	replace 		edu_act = 0 if edu_act == 2
	
	collapse 		(sum) edu* sch*, by (hhid)
	
* replace missing values that became 0 with the collapse (sum)
	replace 		sch_onsite = . if sch_att == 0
	replace 		sch_online = . if sch_att == 0
	replace 		edu_act = . if sch_child == 0
	forval 			x = 1/14 {
	    replace 	sch_att_why_`x' = . if sch_att == 1
	}
	
	lab	def			yesno 0 "No" 1 "Yes", replace
	tostring 		hhid, replace
	ds,				has(type numeric)
	foreach 		var in `r(varlist)' {
	    replace 	`var' = 1 if `var' > 1 & `var' != .
		lab val 	`var' yesno
	}
	destring 		hhid, replace 
	
* save temp file
	tempfile	tempd
	save		`tempd'
	
	
* ***********************************************************************
* 2 - FIES score
* ***********************************************************************

* not available for round 
	

* ***********************************************************************
* 3 - merge sections into panel and save
* ***********************************************************************

* merge sections based on hhid
	use				"$root/wave_0`w'/r`w'_sect_a_2_3a_6_9a_12", clear
	foreach 		s in a b c d {
	    merge		1:1 hhid using `temp`s'', nogen
	}
	
* generate round variable
	gen				wave = `w'
	lab var			wave "Wave number"	
	
* clean variables inconsistent with other rounds	
	* educaiton
	forval 			x = 1/11 {
	    rename 		s5cq4__`x' sch_prec_`x'
	}
	rename 			s5cq4__99 sch_prec_none
	
* save round file
	save			"$export/wave_0`w'/r`w'", replace

* close the log
	log	close
	
	
/* END */		
	