* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by : amf
* Last edited: December 2020
* Stata v.16.1

* does
	* reads in first round of Uganda data
	* builds round 1
	* outputs round 1

* assumes
	* raw Uganda data

* TO DO:
	* everything
	* clean agriculture and livestock??


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
	
* ***********************************************************************
* 1 - reshape wide data 
* ***********************************************************************


* ***********************************************************************
* 1a - reshape section 6 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_01/SEC6", clear

* reformat HHID
	format 			%12.0f HHID

* drop other source
	drop			s6q01_Other

* replace value for "other"
	replace			income_loss__id = 96 if income_loss__id == -96

* reshape data
	reshape 		wide s6q01 s6q02, i(HHID) j(income_loss__id)

* save temp file
	save			"$root/wave_01/SEC6w", replace


* ***********************************************************************
* 1b - reshape section 9 wide data - R1
* ***********************************************************************

* load income data
	use				"$root/wave_01/SEC9", clear

* reformat HHID
	format 			%12.0f HHID

* drop other shock
	drop			s9q01_Other

* replace value for "other"
	replace			shocks__id = 96 if shocks__id == -96

* generate shock variables
	forval i = 1/13 {
		gen				shock_`i' = 0 if s9q01 == 2 & shocks__id == `i'
		replace			shock_`i' = 1 if s9q01 == 1 & shocks__id == `i'
		}

	gen				shock_14 = 0 if s9q01 == 2 & shocks__id == 96
	replace			shock_14 = 1 if s9q02 == 3 & shocks__id == 96
	replace			shock_14 = 2 if s9q02 == 2 & shocks__id == 96
	replace			shock_14 = 3 if s9q02 == 1 & shocks__id == 96

* rename cope variables
	rename			s9q03__1 cope_1
	rename			s9q03__2 cope_2
	rename			s9q03__3 cope_3
	rename			s9q03__4 cope_4
	rename			s9q03__5 cope_5
	rename			s9q03__6 cope_6
	rename			s9q03__7 cope_7
	rename			s9q03__8 cope_8
	rename			s9q03__9 cope_9
	rename			s9q03__10 cope_10
	rename			s9q03__11 cope_11
	rename			s9q03__12 cope_12
	rename			s9q03__13 cope_13
	rename			s9q03__14 cope_14
	rename			s9q03__15 cope_15
	rename			s9q03__16 cope_16
	rename			s9q03__n96 cope_17

* drop unnecessary variables
	drop	shocks__id s9q01 s9q02 s9q03_Other

* collapse to household level
	collapse (max) cope_1- shock_14, by(HHID)

* save temp file
	save			"$root/wave_01/SEC9w", replace


* ***********************************************************************
* 1c - reshape section 10 wide data - R1
* ***********************************************************************

* load safety net data - updated via convo with Talip 9/1
	use				"$root/wave_01/SEC10", clear

* reformat HHID
	format 			%12.0f HHID

* drop other safety nets and missing values
	drop			s10q02 s10q04 other_nets

* reshape data
	reshape 		wide s10q01 s10q03, i(HHID) j(safety_net__id)
	*** note that cash = 101, food = 102, in-kind = 103 (unlike wave 2)

* rename variables
	gen				asst_food = 1 if s10q01102 == 1 | s10q03102 == 1
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s10q01101 == 1 | s10q03101 ==1
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s10q01103 == 1 | s10q03103 == 1
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s10q01101 s10q03101 s10q01102 s10q03102 s10q01103 s10q03103
	
* save temp file
	save			"$root/wave_01/SEC10w", replace


* ***********************************************************************
* 1d - get respondant gender - R1
* ***********************************************************************

* load data
	use				"$root/wave_01/interview_result", clear

* drop all but household respondant
	keep			HHID Rq09

	rename			Rq09 hh_roster__id

	isid			HHID

* merge in household roster
	merge 1:1		HHID hh_roster__id using "$root/wave_01/SEC1.dta"

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
	save			"$export/wave_01/respond_r1", replace

	
* ***********************************************************************
* 1e - get household size and gender of HOH - R1
* ***********************************************************************

* load data 
	use				"$root/wave_01/SEC1.dta", clear

* rename other variables 
	rename 			hh_roster__id ind_id 
	rename 			s1q02 new_mem
	rename 			s1q03 curr_mem
	rename 			s1q05 sex_mem
	rename 			s1q06 age_mem
	rename 			s1q07 relat_mem
	
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
	save			"$export/wave_01/hhsize_r1", replace

* ***********************************************************************
* 1f - FIES - R1
* ***********************************************************************

* load data
	use				"$fies/UG_FIES_round1.dta", clear

	drop 			country round
	destring 		HHID, replace

* save temp file
	save			"$export/wave_01/fies_r1", replace


* ***********************************************************************
* 1g - baseline data
* ***********************************************************************

* load data
	use				"$root/wave_00/Uganda UNPS 2019-20 Quintiles.dta", clear

	rename			hhid baseline_hhid
	rename 			quintile quints

	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui	
	
* save temp file
	save			"$export/wave_01/pov_r0", replace


* ***********************************************************************
* 3 - build uganda R1 cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_01/Cover", clear
	
* merge in other sections
	merge 1:1 		HHID using "$export/wave_01/respond_r1.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_01/hhsize_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC3.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC4.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC5.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC5A.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC6w.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC7.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC8.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC9w.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC9A.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC10w.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_01/fies_r1.dta", nogenerate

	
* ***********************************************************************
* 3a - rationalize variable names - R1
* ***********************************************************************

* rename behavioral changes
	rename			s3q01 bh_1
	rename			s3q02 bh_2
	rename			s3q03 bh_3
	rename			s3q05 bh_4
	rename			s3q06 bh_5
	
* rename government actions
	rename			s2q03__1 gov_1
	lab var			gov_1 "Advised citizens to stay at home"
	rename			s2q03__2 gov_2
	lab var			gov_2 "Restricted travel within country/area"
	rename			s2q03__3 gov_3
	lab var			gov_3 "Restricted international travel"
	rename			s2q03__4 gov_4
	lab var			gov_4 "Closure of schools and universities"
	rename			s2q03__5 gov_5
	lab var			gov_5 "Curfew/lockdown"
	rename			s2q03__6 gov_6
	lab var			gov_6 "Closure of non essential businesses"
	rename			s2q03__7 gov_7
	lab var			gov_7 "Building more hospitals or renting hotels to accomodate patients"
	rename			s2q03__8 gov_8
	lab var			gov_8 "Provide food to needed"
	rename			s2q03__9 gov_9
	lab var			gov_9 "Open clinics and testing locations"
	rename			s2q03__10 gov_11
	lab var			gov_11 "Disseminate knowledge about the virus"
	rename			s2q03__11 gov_13
	lab var			gov_13 "Compulsary putting on masks in public"
	rename			s2q03__12 gov_10
	lab var			gov_10 "Stopping or limiting social gatherings / social distancing"


	
	



	rename 			s4q012 children318
	rename 			s4q013 sch_child
	rename 			s4q014 edu_act
	rename 			s4q15__1 edu_1
	rename 			s4q15__2 edu_2
	rename 			s4q15__3 edu_3
	rename 			s4q15__4 edu_4
	rename 			s4q15__5 edu_5
	rename 			s4q15__6 edu_6
	rename 			s4q15__n96 edu_other

	rename 			s4q16 edu_cont
	rename			s4q17__1 edu_cont_1
	rename 			s4q17__2 edu_cont_2
	rename 			s4q17__3 edu_cont_3
	rename 			s4q17__4 edu_cont_4
	rename 			s4q17__5 edu_cont_5
	rename 			s4q17__6 edu_cont_6
	rename 			s4q17__7 edu_cont_7
	rename 			s4q17__8 edu_cont_8

	rename 			s4q18 bank
	rename 			s4q19 ac_bank
	rename 			s4q20 ac_bank_why

* rename employment
	rename			s5q01a edu
	rename			s5q01 emp
	rename			s5q02 emp_pre
	rename			s5q03 emp_pre_why
	rename			s504 emp_pre_act
	rename			s5q04a emp_same
	rename			s5q04b emp_chg_why
	rename			s504c emp_pre_actc
	rename			s5q05 emp_act
	rename			s5q06 emp_stat
	rename			s5q07 emp_able
	rename			s5q08 emp_unable
	rename			s5q08a emp_unable_why
	rename			s5q08b__1 emp_cont_1
	rename			s5q08b__2 emp_cont_2
	rename			s5q08b__3 emp_cont_3
	rename			s5q08b__4 emp_cont_4
	rename			s5q08c contrct
	rename			s5q09 emp_hh
	rename			s5q11 bus_emp
	rename			s5q12 bus_sect
	rename			s5q13 bus_emp_inc
	rename			s5q14 bus_why

* rename agriculture
	rename			s5aq16 ag_prep
	rename			s5aq17 ag_plan
	rename			s5qaq17_1 ag_plan_why
	rename			s5aq18__0 ag_crop_1
	rename			s5aq18__1 ag_crop_2
	rename			s5aq18__2 ag_crop_3
	rename			s5aq19 ag_chg
	rename			s5aq20__1 ag_chg_1
	rename			s5aq20__2 ag_chg_2
	rename			s5aq20__3 ag_chg_3
	rename			s5aq20__4 ag_chg_4
	rename			s5aq20__5 ag_chg_5
	rename			s5aq20__6 ag_chg_6
	rename			s5aq20__7 ag_chg_7
	rename			s5aq21__1 ag_covid_1
	rename			s5aq21__2 ag_covid_2
	rename			s5aq21__3 ag_covid_3
	rename			s5aq21__4 ag_covid_4
	rename			s5aq21__5 ag_covid_5
	rename			s5aq21__6 ag_covid_6
	rename			s5aq21__7 ag_covid_7
	rename			s5aq21__8 ag_covid_8
	rename			s5aq21__9 ag_covid_9
	rename			s5aq22__1 ag_seed_1
	rename			s5aq22__2 ag_seed_2
	rename			s5aq22__3 ag_seed_3
	rename			s5aq22__4 ag_seed_4
	rename			s5aq22__5 ag_seed_5
	rename			s5aq22__6 ag_seed_6
	rename			s5aq23 ag_fert
	rename			s5aq24 ag_input
	rename			s5aq25 ag_crop_lost
	rename			s5aq26 ag_live_lost
	rename			s5aq27 ag_live_chg
	rename			s5aq28__1 ag_live_chg_1
	rename			s5aq28__2 ag_live_chg_2
	rename			s5aq28__3 ag_live_chg_3
	rename			s5aq28__4 ag_live_chg_4
	rename			s5aq28__5 ag_live_chg_5
	rename			s5aq28__6 ag_live_chg_6
	rename			s5aq28__7 ag_live_chg_7
	rename			s5aq29 ag_graze
	rename			s5aq30 ag_sold
	rename			s5aq31 ag_sell

* rename food security
	rename			s7q01 fies_4
	lab var			fies_4 "Worried about not having enough food to eat"
	rename			s7q02 fies_5
	lab var			fies_5 "Unable to eat healthy and nutritious/preferred foods"
	rename			s7q03 fies_6
	lab var			fies_6 "Ate only a few kinds of food"
	rename			s7q04 fies_7
	lab var			fies_7 "Skipped a meal"
	rename			s7q05 fies_8
	lab var			fies_8 "Ate less than you thought you should"
	rename			s7q06 fies_1
	lab var			fies_1 "Ran out of food"
	rename			s7q07 fies_2
	lab var			fies_2 "Hungry but did not eat"
	rename			s7q08 fies_3
	lab var			fies_3 "Went without eating for a whole dat"

* rename concerns
	rename			s8q01 concern_1
	rename			a8q02 concern_2

* rename coping
	rename			s9q04 meal
	rename			s9q05 meal_source

* create country variables
	gen				country = 4
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

* drop unnecessary variables
	drop			 BSEQNO DistrictName ///
						CountyName SubcountyName ParishName ///
						subreg s2q01b__n96 s2q01b_Other s5qaq17_1_Other ///
						s5aq20__n96 s5aq20_Other s5aq21__n96 s5aq21_Other ///
						s5aq22__n96 s5aq22_Other s5aq23_Other s5aq24_Other ///
						s5q10__0 ///
						s5q10__1 s5q10__2 s5q10__3 s5q10__4 s5q10__5 ///
						s5q10__6 s5q10__7 s5q10__8 s5q10__9 *_Other	 ///
						s4*

* delete temp files
	erase			"$root/wave_01/SEC6w.dta"
	erase			"$root/wave_01/SEC9w.dta"
	erase			"$root/wave_01/SEC10w.dta"	

	gen				wave = 1
	lab var			wave "Wave number"
	order			baseline_hhid wave phw, after(HHID)	
	
* save temp file
	save			"$root/wave_01/r1_sect_all", replace
	
	