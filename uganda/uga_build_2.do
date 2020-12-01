* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by : amf
* Last edited: December 2020
* Stata v.16.1

* does
	* reads in second round of Uganda data
	* builds round 2
	* outputs round 2

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
* 2 - reshape wide data - R2
* ***********************************************************************


* ***********************************************************************
* 2a - reshape section 6 wide data - R2
* ***********************************************************************

* load income data
	use				"$root/wave_02/SEC6", clear

* reformat HHID
	format 			%12.0f HHID

* drop other source
	drop			s6q01_Other BSEQNO Round1_interview_ID baseline_hhid

* replace value for "other"
	replace			income_loss__id = 96 if income_loss__id == -96

* reshape data
	reshape 		wide s6q01 s6q02, i(HHID) j(income_loss__id)

* save temp file
	save			"$root/wave_02/SEC6w", replace


* ***********************************************************************
* 2b - reshape section 10 wide data - R2
* ***********************************************************************

* load safety net data - updated via convo with Talip 9/1
	use				"$root/wave_02/SEC10", clear

* reformat HHID
	format 			%12.0f HHID

* drop other safety nets and missing values
	drop			BSEQNO s10q02 s10q03__1 s10q03__2 s10q03__3 s10q03__4 ///
						s10q03__5 s10q03__6 s10q03__n96 s10q05 s10q06__1 ///
						s10q06__2 s10q06__3 s10q06__4 s10q06__6 s10q06__7 ///
						s10q06__8 s10q06__n96

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
	save			"$root/wave_02/SEC10w", replace


* ***********************************************************************
* 2d - get respondant gender - R2
* ***********************************************************************

* load data
	use				"$root/wave_02/interview_result", clear

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
	save			"$export/wave_02/respond_r2", replace

	
* ***********************************************************************
* 2e - get household size and gender of HOH - R2
* ***********************************************************************

* load data
	use				"$root/wave_02/SEC1.dta", clear

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
	save			"$export/wave_02/hhsize_r2", replace

	
* ***********************************************************************
* 2f - FIES - R2
* ***********************************************************************

* load data
	use				"$fies/UG_FIES_round2.dta", clear

	drop 			country round
	destring 		HHID, replace

* save temp file
	save			"$export/wave_02/fies_r2", replace

	
* ***********************************************************************
* 4 - build uganda R2 cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_02/Cover", clear

* merge in other sections
	merge 1:1 		HHID using "$export/wave_02/respond_r2.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/hhsize_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC3.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC4.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC5.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC5A.dta", nogenerate
*	merge 1:1 		HHID using "$root/wave_02/SEC5B.dta", nogenerate *** harvest
*	merge 1:1 		HHID using "$root/wave_02/SEC5C.dta", nogenerate *** livestock
*	merge 1:1 		HHID using "$root/wave_02/SEC5C_1.dta", nogenerate *** livestock
	merge 1:1 		HHID using "$root/wave_02/SEC6w.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC7.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC9.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/SEC10w.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/fies_r2.dta", nogenerate	

* reformat HHID
	format 			%12.0f HHID


* ***********************************************************************
* 4a - rationalize variable names - R2
* ***********************************************************************

* rename behavioral changes
	rename			s3q01 bh_1
	rename			s3q02 bh_2
	rename			s3q03 bh_3
	rename			s3q04 bh_4
	rename			s3q05 bh_5
	rename			s3q06 bh_7
	rename			s3q07 bh_8

* rename employment
	rename			s5q01 emp
	rename			s5q01a rtrn_emp
	rename			s5q01b rtrn_when
	
	rename			s5q01c rtrn_emp_why
	replace			rtrn_emp_why = s5q03 if rtrn_emp_why == .
	
	rename			s5q03a find_job
	rename			s5q03b find_job_do

	rename			s5q04a_1 emp_same
	replace			emp_same = s5q04a_2 if emp_same == .
	rename			s5q04b emp_chg_why

	rename			s5q05 emp_act
	rename			s5q06 emp_stat
	rename			s5q07 emp_able
	rename			s5q08 emp_unable
	rename			s5q08a emp_unable_why
	rename			s5q08b emp_hours
	rename			s5q08c emp_hours_chg
	rename			s5q08d__1 emp_cont_1
	rename			s5q08d__2 emp_cont_2
	rename			s5q08d__3 emp_cont_3
	rename			s5q08d__4 emp_cont_4
	rename			s5q08e contrct
	rename			s5q09 emp_hh
	
	rename			s5aq11 bus_emp
	rename			s5aq11a bus_stat
	
	gen				bus_stat_why = 1 if s5aq11b__1 == 1
	replace			bus_stat_why = 2 if s5aq11b__2 == 1
	replace			bus_stat_why = 3 if s5aq11b__3 == 1
	replace			bus_stat_why = 4 if s5aq11b__4 == 1
	replace			bus_stat_why = 5 if s5aq11b__5 == 1
	replace			bus_stat_why = 6 if s5aq11b__6 == 1
	replace			bus_stat_why = 7 if s5aq11b__7 == 1
	replace			bus_stat_why = 8 if s5aq11b__8 == 1
	replace			bus_stat_why = 9 if s5aq11b__9 == 1
	replace			bus_stat_why = 10 if s5aq11b__10 == 1
	replace			bus_stat_why = 11 if s5aq11b__n96 == 1
	lab var			bus_stat_why "Why is your family business closed?"
	order			bus_stat_why, after(bus_stat)
	
	rename			s5aq12 bus_sect
	rename			s5aq13 bus_emp_inc
	rename			s5aq14_1 bus_why
	replace			bus_why = s5aq14_2 if bus_why == .
	
	gen				bus_chlng_fce = 1 if s5aq15__1 == 1
	replace			bus_chlng_fce = 2 if s5aq15__2 == 1
	replace			bus_chlng_fce = 3 if s5aq15__3 == 1
	replace			bus_chlng_fce = 4 if s5aq15__4 == 1
	replace			bus_chlng_fce = 5 if s5aq15__5 == 1
	replace			bus_chlng_fce = 6 if s5aq15__6 == 1
	replace			bus_chlng_fce = 7 if s5aq15__n96 == 1
	lab def			bus_chlng_fce 1 "Difficulty buying and receiving supplies and inputs" ///
								  2 "Difficulty raising money for the business" ///
								  3 "Difficulty repaying loans or other debt obligations" ///
								  4 "Difficulty paying rent for business location" ///
								  5 "Difficulty paying workers" ///
								  6 "Difficulty selling goods or services to customers" ///
								  7 "Other"
	lab val			bus_chlng_fce bus_chlng_fce
	lab var			bus_chlng_fce "Business challanges faced"
	order			bus_chlng_fce, after(bus_why)
	
	rename			s5aq15a bus_cndct
	gen				bus_cndct_how = 1 if s5aq15b__1 == 1
	replace			bus_cndct_how = 1 if s5aq15b__2 == 1
	replace			bus_cndct_how = 1 if s5aq15b__3 == 1
	replace			bus_cndct_how = 1 if s5aq15b__4 == 1
	replace			bus_cndct_how = 1 if s5aq15b__5 == 1
	replace			bus_cndct_how = 1 if s5aq15b__6 == 1
	replace			bus_cndct_how = 1 if s5aq15b__n96 == 1
	lab def			bus_cndct_how 1 "Requiring customers to wear masks" ///
								  2 "Keeping distance between customers" ///
								  3 "Allowing a reduced number of customers" ///
								  4 "Use of phone and or social media to market" ///
								  5 "Switched to delivery services only" ///
								  6 "Switched product/service offering" ///
								  7 "Other"
	lab val			bus_cndct_how bus_cndct_how
	lab var			bus_cndct_how "Changed the way you conduct business due to the corona virus?"
	order			bus_cndct_how, after(bus_cndct)

	drop			s5q03 s5q04a_2 s5q10__0 s5q10__1 s5q10__2 s5q10__3 s5q10__4 ///
						s5q10__5 business_case_filter ///
						s5aq11b__1 s5aq11b__2 s5aq11b__3 s5aq11b__4 s5aq11b__5 ///
						s5aq11b__6 s5aq11b__7 s5aq11b__8 s5aq11b__9 s5aq11b__10 ///
						s5aq11b__n96 s5aq14_2 s5aq15__1 s5aq15__2 s5aq15__3 ///
						s5aq15__4 s5aq15__5 s5aq15__6 s5aq15__n96 s5aq15b__1 ///
						s5aq15b__2 s5aq15b__3 s5aq15b__4 s5aq15b__5 s5aq15b__6 ///
						s5aq15b__n96

* rename credit
	rename			s7q01 credit
	rename			s7q02 credit_cvd
	rename			s7q03 credit_cvd_how
	
	gen				credit_source = 1 if s7q04__1
	replace			credit_source = 2 if s7q04__2
	replace			credit_source = 3 if s7q04__3
	replace			credit_source = 4 if s7q04__4
	replace			credit_source = 5 if s7q04__5
	replace			credit_source = 6 if s7q04__6
	replace			credit_source = 7 if s7q04__7
	replace			credit_source = 8 if s7q04__8
	replace			credit_source = 9 if s7q04__9
	replace			credit_source = 10 if s7q04__10
	replace			credit_source = 11 if s7q04__11
	replace			credit_source = 12 if s7q04__12
	replace			credit_source = 13 if s7q04__13
	replace			credit_source = 14 if s7q04__14
	replace			credit_source = 15 if s7q04__15
	replace			credit_source = 16 if s7q04__16
	replace			credit_source = 17 if s7q04__n96
	lab def			credit 1 "Commercial bank" 2 "Savings club" ///
								  3 "Credit Institution" 4 "ROSCAs" ///
								  5 "MDI" 6 "Welfare fund" ///
								  7 "SACCOs" 8 "Investment club" ///
								  9 "NGOs" 10 "Burial societies" ///
								  11 "ASCAs" 12 "MFIs" 13 "VSLAs" ///
								  14 "MOKASH" 15 "WEWOLE" ///
								  16 "Neighbour/friend" 17 "Other"
	lab val			credit_source credit
	lab var			credit_source "From whom did you borrow money?"
	order			credit_source, after(credit_cvd_how)
	
	rename			s7q05 credit_purp
	rename			s7q06 credit_wry
	
	drop			s6q0112 s6q0212 s7q04__1 s7q04__2 s7q04__3 s7q04__4 ///
						s7q04__5 s7q04__6 s7q04__7 s7q04__8 s7q04__9 ///
						s7q04__10 s7q04__11 s7q04__12 s7q04__13 s7q04__14 ///
						s7q04__15 s7q04__16 s7q04__n96 s7q04_Other s7q05_Other
	
* SEC 9: concerns
	rename			s9q01 concern_1
	rename			s9q02 concern_2
	gen				have_symp = 1 if s9q03__1 == 1 | s9q03__2 == 1 | s9q03__3 == 1 | ///
						s9q03__4 == 1 | s9q03__5 == 1 | s9q03__6 == 1 | ///
						s9q03__7 == 1 | s9q03__8 == 1
	replace			have_symp = 2 if have_symp == .
	lab var			have_symp "Has anyone in your hh experienced covid symptoms?:cough/shortness of breath etc."
	order			have_symp, after(concern_02)

	drop			s9q03__1 s9q03__2 s9q03__3 s9q03__4 s9q03__5 s9q03__6 s9q03__7 s9q03__8

	rename 			s9q04 have_test
	rename 			s9q05 concern_3
	rename			s9q06 concern_4
	lab var			concern_4 "Response to the COVID-19 emergency will limit my rights and freedoms"
	rename			s9q07 concern_5
	lab var			concern_5 "Money and supplies allocated for the COVID-19 response will be misused and captured by powerful people in the country"
	rename			s9q08 concern_6
	lab var			concern_6 "Corruption in the government has lowered the quality of medical supplies and care"

	rename			s9q09__1 curb_1 
	rename			s9q09__2 curb_2
	rename			s9q09__3 curb_3
	rename			s9q09__4 curb_4
	rename			s9q09__5 curb_5

* create country variables
	gen				country = 4
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

* delete temp files
	erase			"$root/wave_02/SEC6w.dta"
	erase			"$root/wave_02/SEC10w.dta"
	
	gen				wave = 2
	lab var			wave "Wave number"
	order			baseline_hhid wave phw, after(HHID)

* save temp file
	save			"$root/wave_02/r2_sect_all", replace

	