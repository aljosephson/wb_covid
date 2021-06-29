* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by : amf
* Last edited: December 2020
* Stata v.16.1

* does
	* reads in fifth round of Uganda data
	* builds round 5
	* outputs round 5

* assumes
	* raw Uganda data

* TO DO:
	CHECK WHICH DATA WE SHOULD USE (ONLINE ONE SKIPS R5 BUT R6 LOOKS LIKE IT MATCHES R5 SURVEY)


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/uganda/raw"
	global	fies	=	"$data/analysis/raw/Uganda"
	global	export	=	"$data/uganda/refined"
	global	logout	=	"$data/uganda/logs"

* open log
	cap log 		close
	log using		"$logout/uga_build", append
	
* set local wave number & file number
	local			w = 5
	
* make wave folder within refined folder if it does not already exist 
	capture mkdir "$export/wave_0`w'" 	
	

* ***********************************************************************
* 1 - reshape section 6 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_0`w'/SEC6", clear
	
* reformat HHID
	format 			%12.0f HHID

* replace value for "other"
	replace			income_loss__id = 96 if income_loss__id == -96

* reshape data
	reshape 		wide s6q01 s6q02 s6q03, i(HHID) j(income_loss__id)

* save temp file
	tempfile		temp1
	save			`temp1'


* ***********************************************************************
* 2 - reshape section 10 wide data 
* ***********************************************************************

* load safety net data - updated via convo with Talip 9/1
	use				"$root/wave_0`w'/SEC10", clear

* reformat HHID
	format 			%12.0f HHID

* drop other safety nets and missing values
	drop			s10q02 s10q03__1 s10q03__2 s10q03__3 s10q03__4 ///
						s10q03__5 s10q03__6 s10q03__n96 

* reshape data
	reshape 		wide s10q01, i(HHID) j(safety_net__id)
	*** note that cash = 102, food = 101, in-kind = 103 (unlike wave 1)

* rename variables
	gen				asst_food = 1 if s10q01101 == 1
	replace			asst_food = 0 if s10q01101 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s10q01102 == 1
	replace			asst_cash = 0 if s10q01102 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s10q01103 == 1
	replace			asst_kind = 0 if s10q01103 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
					asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s10q01101 s10q01102 s10q01103
	
* save temp file
	tempfile		temp2
	save			`temp2'


* ***********************************************************************
* 3 - get respondant gender
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/interview_result", clear

* drop all but household respondant
	keep			HHID Rq09

	rename			Rq09 hh_roster__id

	isid			HHID

* merge in household roster
	merge 1:1		HHID hh_roster__id using "$root/wave_02/SEC1.dta"

	keep if			_merge == 3

* rename variables and fill in missing values
	rename			hh_roster__id PID
	rename			s1q05 sex
	rename			s1q06 age
	rename			s1q07 relate_hoh
	drop if			PID == .

* drop all but gender and relation to HoH
	keep			HHID PID sex age relate_hoh

* save temp file
	tempfile		temp3
	save			`temp3'

	
* ***********************************************************************
* 4 - get household size and gender of HOH
* ***********************************************************************

* load data
	use				"$root/wave_0`w'/SEC1.dta", clear

* rename other variables 
	rename 			hh_roster__id ind_id 
	rename 			s1q03 curr_mem
	replace 		curr_mem = 1 if s1q02 == 1
	rename 			s1q05 sex_mem
	rename 			s1q06 age_mem
	rename 			s1q07 relat_mem
	
* generate counting variables
	gen				hhsize = 1 if curr_mem == 1
	gen 			hhsize_adult = 1 if curr_mem == 1 & age_mem > 18 & age_mem < .
	gen				hhsize_child = 1 if curr_mem == 1 & age_mem < 19 & age_mem != . 
	gen 			hhsize_schchild = 1 if curr_mem == 1 & age_mem > 4 & age_mem < 19 
	
* create hh head gender
	gen 			sexhh = . 
	replace			sexhh = sex_mem if relat_mem == 1
	label var 		sexhh "Sex of household head"
	
* generate migration vars
	rename 			s1q02 new_mem
	replace 		new_mem = 0 if new_mem >= .
	replace 		new_mem = 0 if s1q08 == 10
	replace 		s1q08 = . if s1q08 == 10
	replace 		curr_mem = 2 if curr_mem >= .
	gen 			mem_left = 1 if curr_mem == 2
	replace 		new_mem = 0 if new_mem == 2
	replace 		mem_left = 0 if mem_left == 2
	
	* why member left
		* no observations
	
	* why new member 
		preserve
			keep 		HHID s1q08 ind_id
			keep 		if s1q08 < .
			duplicates 	drop HHID s1q08, force
			replace 	s1q08 = 96 if s1q08 == -96
			reshape 	wide ind_id, i(HHID) j(s1q08)
			ds 			ind_id*
			foreach 	var in `r(varlist)' {
				replace 	`var' = 1 if `var' != .
			}
			rename 		ind_id* new_mem_why_*
			tempfile 	new_mem
			save 		`new_mem'
		restore
	
* collapse data to hh level and merge in why vars
	collapse	(sum) hhsize hhsize_adult hhsize_child hhsize_schchild new_mem mem_left ///
				(max) sexhh, by(HHID)
	replace 	new_mem = 1 if new_mem > 0 & new_mem < .
	replace 	mem_left = 1 if mem_left > 0 & new_mem < .	
	merge 		1:1 HHID using `new_mem', nogen
	ds 			new_mem_why_* 
	foreach		var in `r(varlist)' {
		replace 	`var' = 0 if `var' >= . & new_mem == 1
	}
	lab var		hhsize "Household size"
	lab var 	hhsize_adult "Household size - only adults"
	lab var 	hhsize_child "Household size - children 0 - 18"
	lab var 	hhsize_schchild "Household size - school-age children 5 - 18"
	lab var 	mem_left "Member of household left since last call"
	lab var 	new_mem "Member of household joined since last call"
	
* save temp file
	tempfile		temp4
	save			`temp4'

	
* ***********************************************************************
* 5 - FIES
* ***********************************************************************

* load data
	use				"$fies/UG_FIES_round`w'.dta", clear

	drop 			country round
	destring 		HHID, replace

* save temp file
	tempfile		temp5
	save			`temp5'

	
* ***********************************************************************
* 6 - education 
* ***********************************************************************
	
* generate edu_act = 1 if any child engaged in learning activities
	use				"$root/wave_0`w'/SEC1C.dta", clear
	keep 			if s1cq09 != .
	replace 		s1cq09  = 0 if s1cq09  == 2
	collapse		(sum) s1cq09, by(HHID)
	gen 			edu_act = 1 if s1cq09 > 0 
	replace 		edu_act = 0 if edu_act == .
	keep 			HHID edu_act
	tempfile 		tempany
	save 			`tempany'

* rename other variables 	
	* edu_act_why
	use				"$root/wave_0`w'/SEC1C.dta", clear
	keep 			if s1cq09 == 2
	forval 			x = 1/11 {
		rename 		s1cq10__`x' edu_act_why_`x'
	}
	collapse 		(sum) edu* , by(HHID)
	forval 			x = 1/11 {
		replace 		edu_act_why_`x' = 1 if edu_act_why_`x' >= 1
	}
	tempfile 		tempactwhy
	save 			`tempactwhy'
		
	* edu & edu_chal
	use				"$root/wave_0`w'/SEC1C.dta", clear
	keep 			if s1cq09 == 1
	rename 			s1cq11__1 edu_1
	rename 			s1cq11__2 edu_2
	replace 		edu_2 = 1 if s1cq11__3 == 1 | s1cq11__4 == 1 | ///
						s1cq11__5 == 1 | s1cq11__6 == 1
	rename 			s1cq11__7 edu_3
	rename 			s1cq11__8 edu_4
	rename 			s1cq11__9 edu_5
	rename 			s1cq11__10 edu_8
	rename 			s1cq11__11 edu_9
	rename 			s1cq11__12 edu_10
	rename 			s1cq11__13 edu_11
	rename 			s1cq11__14 edu_12
	rename 			s1cq11__15 edu_7
	rename 	 		s1cq11__n96 edu_other
	forval 			x = 1/13 {
	    replace 	s1cq12__`x' = 0 if s1cq12__`x' == 2
	    rename 		s1cq12__`x' edu_chal_`x'
	}
	collapse 		(sum) edu* , by(HHID)
	ds edu* 
	foreach 		var in `r(varlist)' {
	    replace 		`var' = 1 if `var' >= 1
	}
	tempfile 		tempedu
	save 			`tempedu'
	
* merge data together 
	use				"$root/wave_0`w'/SEC1.dta", clear
	keep 			HHID 
	duplicates 		drop
	merge 			1:1 HHID using `tempany', nogen
	merge 			1:1 HHID using `tempactwhy', nogen
	merge 			1:1 HHID using `tempedu', nogen

* save temp file
	tempfile		temp5
	save			`temp5'

		
* ***********************************************************************
* 7 - build uganda cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_0`w'/Cover", clear
	
* merge in other sections	
	forval 			x = 1/5 {
	    merge 		1:1 HHID using `temp`x'', nogen
	}
	merge 1:1 		HHID using "$root/wave_0`w'/SEC3.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC4.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC4A.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5A.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC5B.dta", nogen 
	merge 1:1 		HHID using "$root/wave_0`w'/SEC8.dta", nogen
	merge 1:1 		HHID using "$root/wave_0`w'/SEC9.dta", nogen	
	
* reformat HHID
	format 			%12.0f HHID

* rename variables inconsistent with other waves



* save panel
	* gen wave data
		rename			wfinal phw_cs
		lab var			phw "sampling weights - cross section"	
		gen				wave = `w'
		lab var			wave "Wave number"
		order			baseline_hhid wave phw, after(HHID)

	* save file
		save			"$export/wave_0`w'/r`w'", replace

/* END */	