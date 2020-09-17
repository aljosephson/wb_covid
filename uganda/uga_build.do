* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by : jdm
* Last edited: 16 September 2020
* Stata v.16.1

* does
	* merges together each section of Uganda data
	* renames variables
	* outputs single cross section data

* assumes
	* raw Uganda data

* TO DO:
	* FIES R2 data
	* clean agriculture and livestock


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
* 1 - reshape wide data - R1
* ***********************************************************************


* ***********************************************************************
* 1a - reshape section 6 wide data - R1
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

* rename variables
	rename 			s6q011 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s6q021 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename 			s6q012 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s6q022 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"
	rename 			s6q013 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s6q023 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"
	rename			s6q014 unemp_inc
	lab var			unemp_inc "Income from unemployment benefits in the last 12 months"
	rename			s6q024 unemp_chg
	lab var			unemp_chg "Change in income from unemployment benefits since covid"
	rename 			s6q015 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename			s6q025 rem_for_chg
	label 			var rem_for_chg "Change in income from remittances abroad since covid"
	rename 			s6q016 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename			s6q026 rem_dom_chg
	label 			var rem_dom_chg "Change in income from remittances domestic since covid"
	rename 			s6q017 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename			s6q027 asst_chg
	label 			var asst_chg "Change in income from assistance from non-family since covid"
	rename 			s6q018 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename			s6q028 isp_chg
	label 			var isp_chg "Change in income from properties, investment since covid"
	rename 			s6q019 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"
	rename			s6q029 pen_chg
	label 			var pen_chg "Change in income from pension since covid"
	rename 			s6q0110 gov_inc
	label 			var gov_inc "Income from government assistance in last 12 months"
	rename			s6q0210 gov_chg
	label 			var gov_chg "Change in income from government assistance since covid"
	rename 			s6q0111 ngo_inc
	label 			var ngo_inc "Income from NGO assistance in last 12 months"
	rename			s6q0211 ngo_chg
	label 			var ngo_chg "Change in income from NGO assistance since covid"
	rename 			s6q0196 oth_inc
	label 			var oth_inc "Income from other source in last 12 months"
	rename			s6q0296 oth_chg
	label 			var oth_chg "Change in income from other source since covid"

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
		gen				shock_0`i' = 0 if s9q01 == 2 & shocks__id == `i'
		replace			shock_0`i' = 1 if s9q02 == 3 & shocks__id == `i'
		replace			shock_0`i' = 2 if s9q02 == 2 & shocks__id == `i'
		replace			shock_0`i' = 3 if s9q02 == 1 & shocks__id == `i'
		}

	rename			shock_010 shock_10
	rename			shock_011 shock_11
	rename			shock_012 shock_12
	rename			shock_013 shock_13

	gen				shock_14 = 0 if s9q01 == 2 & shocks__id == 96
	replace			shock_14 = 1 if s9q02 == 3 & shocks__id == 96
	replace			shock_14 = 2 if s9q02 == 2 & shocks__id == 96
	replace			shock_14 = 3 if s9q02 == 1 & shocks__id == 96

* rename cope variables
	rename			s9q03__1 cope_01
	rename			s9q03__2 cope_02
	rename			s9q03__3 cope_03
	rename			s9q03__4 cope_04
	rename			s9q03__5 cope_05
	rename			s9q03__6 cope_06
	rename			s9q03__7 cope_07
	rename			s9q03__8 cope_08
	rename			s9q03__9 cope_09
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
	collapse (max) cope_01- shock_14, by(HHID)

* label variables
	lab var			shock_01 "Death of disability of an adult working member of the household"
	lab var			shock_02 "Death of someone who sends remittances to the household"
	lab var			shock_03 "Illness of income earning member of the household"
	lab var			shock_04 "Loss of an important contact"
	lab var			shock_05 "Job loss"
	lab var			shock_06 "Non-farm business failure"
	lab var			shock_07 "Theft of crops, cash, livestock or other property"
	lab var			shock_08 "Destruction of harvest by insufficient labor"
	lab var			shock_09 "Disease/Pest invasion that caused harvest failure or storage loss"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items c"
	lab var			shock_13 "Floods"
	lab var			shock_14 "Other shock"

	lab def			shock 0 "None" 1 "Severe" 2 "More Severe" 3 "Most Severe"

	foreach var of varlist shock_01-shock_14 {
		lab val		`var' shock
		}

	lab var			cope_01 "Sale of assets (Agricultural and Non_agricultural)"
	lab var			cope_02 "Engaged in additional income generating activities"
	lab var			cope_03 "Received assistance from friends & family"
	lab var			cope_04 "Borrowed from friends & family"
	lab var			cope_05 "Took a loan from a financial institution"
	lab var			cope_06 "Credited purchases"
	lab var			cope_07 "Delayed payment obligations"
	lab var			cope_08 "Sold harvest in advance"
	lab var			cope_09 "Reduced food consumption"
	lab var			cope_10 "Reduced non_food consumption"
	lab var			cope_11 "Relied on savings"
	lab var			cope_12 "Received assistance from NGO"
	lab var			cope_13 "Took advanced payment from employer"
	lab var			cope_14 "Received assistance from government"
	lab var			cope_15 "Was covered by insurance policy"
	lab var			cope_16 "Did nothing"
	lab var			cope_17 "Other"

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

* rename variables
	rename 			s6q011 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s6q021 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename 			s6q012 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s6q022 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"
	rename 			s6q013 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s6q023 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"
	rename			s6q014 unemp_inc
	lab var			unemp_inc "Income from unemployment benefits in the last 12 months"
	rename			s6q024 unemp_chg
	lab var			unemp_chg "Change in income from unemployment benefits since covid"
	rename 			s6q015 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename			s6q025 rem_for_chg
	label 			var rem_for_chg "Change in income from remittances abroad since covid"
	rename 			s6q016 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename			s6q026 rem_dom_chg
	label 			var rem_dom_chg "Change in income from remittances domestic since covid"
	rename 			s6q017 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename			s6q027 asst_chg
	label 			var asst_chg "Change in income from assistance from non-family since covid"
	rename 			s6q018 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename			s6q028 isp_chg
	label 			var isp_chg "Change in income from properties, investment since covid"
	rename 			s6q019 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"
	rename			s6q029 pen_chg
	label 			var pen_chg "Change in income from pension since covid"
	rename 			s6q0110 gov_inc
	label 			var gov_inc "Income from government assistance in last 12 months"
	rename			s6q0210 gov_chg
	label 			var gov_chg "Change in income from government assistance since covid"
	rename 			s6q0111 ngo_inc
	label 			var ngo_inc "Income from NGO assistance in last 12 months"
	rename			s6q0211 ngo_chg
	label 			var ngo_chg "Change in income from NGO assistance since covid"
	rename 			s6q0196 oth_inc
	label 			var oth_inc "Income from other source in last 12 months"
	rename			s6q0296 oth_chg
	label 			var oth_chg "Change in income from other source since covid"

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

/* load data
	use				"$fies/UG_FIES_round2.dta", clear

	drop 			country round
	destring 		HHID, replace

* save temp file
	save			"$export/wave_02/fies_r2", replace
*/


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
	
* rename basic information
	rename			wfinal phw
	lab var			phw "sampling weights"

	gen				wave = 1
	lab var			wave "Wave number"
	order			baseline_hhid wave phw, after(HHID)

	gen				sector = 2 if urban == 1
	replace			sector = 1 if sector == .
	lab var			sector "Sector"
	lab def			sector 1 "Rural" 2 "Urban"
	lab val			sector sector
	drop			urban
	order			sector, after(phw)

	gen				Region = 4012 if region == "Central"
	replace			Region = 4013 if region == "Eastern"
	replace			Region = 4014 if region == "Kampala"
	replace			Region = 4015 if region == "Northern"
	replace			Region = 4016 if region == "Western"
	lab define		region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
						"Oromia" 1005 "Somali" 1006 "Benishangul-Gumuz" 1007 ///
						"SNNPR" 1008 "Gambela" 1009 "Harar" 1010 ///
						"Addis Ababa" 1011 "Dire Dawa" 2101 "Chitipa" 2102 ///
						"Karonga" 2103 "Nkhata Bay" 2104 "Rumphi" 2105 ///
						"Mzimba" 2106 "Likoma" 2107 "Mzuzu City" 2201 ///
						"Kasungu" 2202 "Nkhotakota" 2203 "Ntchisi" 2204 ///
						"Dowa" 2205 "Salima" 2206 "Lilongwe" 2207 ///
						"Mchinji" 2208 "Dedza" 2209 "Ntcheu" 2210 ///
						"Lilongwe City" 2301 "Mangochi" 2302 "Machinga" 2303 ///
						"Zomba" 2304 "Chiradzulu" 2305 "Blantyre" 2306 ///
						"Mwanza" 2307 "Thyolo" 2308 "Mulanje" 2309 ///
						"Phalombe" 2310 "Chikwawa" 2311 "Nsanje" 2312 ///
						"Balaka" 2313 "Neno" 2314 "Zomba City" 2315 ///
						"Blantyre City" 3001 "Abia" 3002 "Adamawa" 3003 ///
						"Akwa Ibom" 3004 "Anambra" 3005 "Bauchi" 3006 ///
						"Bayelsa" 3007 "Benue" 3008 "Borno" 3009 ///
						"Cross River" 3010 "Delta" 3011 "Ebonyi" 3012 ///
						"Edo" 3013 "Ekiti" 3014 "Enugu" 3015 "Gombe" 3016 ///
						"Imo" 3017 "Jigawa" 3018 "Kaduna" 3019 "Kano" 3020 ///
						"Katsina" 3021 "Kebbi" 3022 "Kogi" 3023 "Kwara" 3024 ///
						"Lagos" 3025 "Nasarawa" 3026 "Niger" 3027 "Ogun" 3028 ///
						"Ondo" 3029 "Osun" 3030 "Oyo" 3031 "Plateau" 3032 ///
						"Rivers" 3033 "Sokoto" 3034 "Taraba" 3035 "Yobe" 3036 ///
						"Zamfara" 3037 "FCT" 4012 "Central" 4013 ///
						"Eastern" 4014 "Kampala" 4015 "Northern" 4016 ///
						"Western" 4017 "North" 4018 "Central" 4019 "South", replace
	lab val			Region region
	drop			region
	rename			Region region
	order			region, after(sector)
	lab var			region "Region"

	rename			DistrictCode zone_id
	rename			CountyCode county_id
	rename			SubcountyCode city_id
	rename			ParishCode subcity_id

	rename			Sq02 start_date
	rename			s2q01 know

* rename symptoms
	rename			s2q01b__1 symp_01
	rename			s2q01b__2 symp_02
	rename			s2q01b__3 symp_03
	rename			s2q01b__4 symp_04
	rename			s2q01b__5 symp_05
	rename			s2q01b__6 symp_06
	rename			s2q01b__7 symp_07
	rename			s2q01b__8 symp_08
	rename			s2q01b__9 symp_09
	rename			s2q01b__10 symp_10
	rename			s2q01b__11 symp_11
	rename			s2q01b__12 symp_12
	rename			s2q01b__13 symp_13
	rename			s2q01b__14 symp_14
	rename			s2q01b__n98 symp_15

* rename knowledge
	rename			s2q02__1 know_01
	lab var			know_01 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s2q02__2 know_09
	lab var			know_09 "Use of Sanitizer Reduces Risk of Coronavirus Contraction"
	rename			s2q02__3 know_02
	lab var			know_02 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename			s2q02__4 know_03
	lab var			know_03 "Using Masks and/or Gloves Reduces Risk of Coronavirus Contraction"
	rename			s2q02__5 know_10
	lab var			know_10 "Using Gloves Reduces Risk of Coronavirus Contraction"
	rename			s2q02__6 know_04
	lab var			know_04 "Avoiding Travel Reduces Risk of Coronavirus Contraction"
	rename			s2q02__7 know_05
	lab var			know_05 "Staying at Home Reduces Risk of Coronavirus Contraction"
	rename			s2q02__8 know_06
	lab var			know_06 "Avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction"
	rename			s2q02__9 know_07
	lab var			know_07 "Mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Contraction"
	rename			s2q02__10 know_08
	lab var			know_08 "Avoiding Face Touching Reduces Risk of Coronavirus Contraction"

* rename myths
	rename			s2q02a_1 myth_01
	rename			s2q02a_2 myth_02
	rename			s2q02a_3 myth_03
	rename			s2q02a_4 myth_04
	rename			s2q02a_5 myth_05
	rename			s2q02a_6 myth_06
	rename			s2q02a_7 myth_07

* rename government actions
	rename			s2q03__1 gov_01
	lab var			gov_01 "Advised citizens to stay at home"
	rename			s2q03__2 gov_02
	lab var			gov_02 "Restricted travel within country/area"
	rename			s2q03__3 gov_03
	lab var			gov_03 "Restricted international travel"
	rename			s2q03__4 gov_04
	lab var			gov_04 "Closure of schools and universities"
	rename			s2q03__5 gov_05
	lab var			gov_05 "Curfew/lockdown"
	rename			s2q03__6 gov_06
	lab var			gov_06 "Closure of non essential businesses"
	rename			s2q03__7 gov_07
	lab var			gov_07 "Building more hospitals or renting hotels to accomodate patients"
	rename			s2q03__8 gov_08
	lab var			gov_08 "Provide food to needed"
	rename			s2q03__9 gov_09
	lab var			gov_09 "Open clinics and testing locations"
	rename			s2q03__10 gov_11
	lab var			gov_11 "Disseminate knowledge about the virus"
	rename			s2q03__11 gov_13
	lab var			gov_13 "Compulsary putting on masks in public"
	rename			s2q03__12 gov_10
	lab var			gov_10 "Stopping or limiting social gatherings / social distancing"

* rename behavioral changes
	rename			s3q01 bh_01
	rename			s3q02 bh_02
	rename			s3q03 bh_03
	rename			s3q05 bh_04
	rename			s3q06 bh_05

* rename access
	rename 			s4q01 ac_soap
	rename			s4q02 ac_soap_why
	replace			ac_soap_why = 9 if ac_soap_why == -96
	replace			ac_soap_why = . if ac_soap_why == 99
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "cannot afford it" 8 "afraid to go out" 9 "other"
	lab var 		ac_soap_why "reason for unable to purchase soap"

	rename 			s4q03 ac_water
	rename 			s4q04 ac_water_why

	rename 			s4q05 ac_staple_def
	rename 			s4q06 ac_staple
	rename			s4q07 ac_staple_why
	replace			ac_staple_why = 7 if ac_staple_why == -96
	lab def			ac_staple_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	lab var 		ac_staple_why "reason for unable to purchase staple food"

	rename 			s4q07a ac_sauce_def
	rename 			s4q07b ac_sauce
	rename			s4q07c ac_sauce_why
	replace			ac_sauce_why = 7 if ac_sauce_why == -96
	lab def			ac_sauce_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	lab var 		ac_sauce_why "reason for unable to purchase staple food"

	rename 			s4q08 ac_med

	rename 			s4q09 ac_medserv_need
	rename 			s4q10 ac_medserv
	rename 			s4q11 ac_medserv_why
	replace			ac_medserv_why = 3 if ac_medserv_why == 5
	replace			ac_medserv_why = 5 if ac_medserv_why == 7
	replace 		ac_medserv_why = 7 if ac_medserv_why == 4
	replace			ac_medserv_why = 4 if ac_medserv_why == -96
	lab def			ac_medserv_why 1 "no money" 2 "no med personnel" 3 "facility full / closed" ///
								4 "other" 5 "no transportation" 6 "restrictions to go out" ///
								7 "afraid of virus" 8 "facility closed "
	lab var 		ac_medserv_why "reason for unable to access medical services"

	rename 			s4q012 children318
	rename 			s4q013 sch_child
	rename 			s4q014 edu_act
	rename 			s4q15__1 edu_01
	rename 			s4q15__2 edu_02
	rename 			s4q15__3 edu_03
	rename 			s4q15__4 edu_04
	rename 			s4q15__5 edu_05
	rename 			s4q15__6 edu_06
	rename 			s4q15__n96 edu_other

	rename 			s4q16 edu_cont
	rename			s4q17__1 edu_cont_01
	rename 			s4q17__2 edu_cont_02
	rename 			s4q17__3 edu_cont_03
	rename 			s4q17__4 edu_cont_04
	rename 			s4q17__5 edu_cont_05
	rename 			s4q17__6 edu_cont_06
	rename 			s4q17__7 edu_cont_07
	rename 			s4q17__8 edu_cont_08

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
	rename			s5q08b__1 emp_cont_01
	rename			s5q08b__2 emp_cont_02
	rename			s5q08b__3 emp_cont_03
	rename			s5q08b__4 emp_cont_04
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
	rename			s5aq18__0 ag_crop_01
	rename			s5aq18__1 ag_crop_02
	rename			s5aq18__2 ag_crop_03
	rename			s5aq19 ag_chg
	rename			s5aq20__1 ag_chg_01
	rename			s5aq20__2 ag_chg_02
	rename			s5aq20__3 ag_chg_03
	rename			s5aq20__4 ag_chg_04
	rename			s5aq20__5 ag_chg_05
	rename			s5aq20__6 ag_chg_06
	rename			s5aq20__7 ag_chg_07
	rename			s5aq21__1 ag_covid_01
	rename			s5aq21__2 ag_covid_02
	rename			s5aq21__3 ag_covid_03
	rename			s5aq21__4 ag_covid_04
	rename			s5aq21__5 ag_covid_05
	rename			s5aq21__6 ag_covid_06
	rename			s5aq21__7 ag_covid_07
	rename			s5aq21__8 ag_covid_08
	rename			s5aq21__9 ag_covid_09
	rename			s5aq22__1 ag_seed_01
	rename			s5aq22__2 ag_seed_02
	rename			s5aq22__3 ag_seed_03
	rename			s5aq22__4 ag_seed_04
	rename			s5aq22__5 ag_seed_05
	rename			s5aq22__6 ag_seed_06
	rename			s5aq23 ag_fert
	rename			s5aq24 ag_input
	rename			s5aq25 ag_crop_lost
	rename			s5aq26 ag_live_lost
	rename			s5aq27 ag_live_chg
	rename			s5aq28__1 ag_live_chg_01
	rename			s5aq28__2 ag_live_chg_02
	rename			s5aq28__3 ag_live_chg_03
	rename			s5aq28__4 ag_live_chg_04
	rename			s5aq28__5 ag_live_chg_05
	rename			s5aq28__6 ag_live_chg_06
	rename			s5aq28__7 ag_live_chg_07
	rename			s5aq29 ag_graze
	rename			s5aq30 ag_sold
	rename			s5aq31 ag_sell

* rename food security
	rename			s7q01 fies_04
	lab var			fies_04 "Worried about not having enough food to eat"
	rename			s7q02 fies_05
	lab var			fies_05 "Unable to eat healthy and nutritious/preferred foods"
	rename			s7q03 fies_06
	lab var			fies_06 "Ate only a few kinds of food"
	rename			s7q04 fies_07
	lab var			fies_07 "Skipped a meal"
	rename			s7q05 fies_08
	lab var			fies_08 "Ate less than you thought you should"
	rename			s7q06 fies_01
	lab var			fies_01 "Ran out of food"
	rename			s7q07 fies_02
	lab var			fies_02 "Hungry bu did not eat"
	rename			s7q08 fies_03
	lab var			fies_03 "Went without eating for a whole dat"

* rename concerns
	rename			s8q01 concern_01
	rename			a8q02 concern_02

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
	
* save temp file
	save			"$root/wave_01/r1_sect_all", replace
	
	
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
*	merge 1:1 		HHID using "$export/wave_02/fies_r2.dta", nogenerate	

* reformat HHID
	format 			%12.0f HHID


* ***********************************************************************
* 4a - rationalize variable names - R2
* ***********************************************************************

* rename basic information
	rename			wfinal2 phw
	lab var			phw "sampling weights"

	gen				wave = 2
	lab var			wave "Wave number"
	order			baseline_hhid wave phw, after(HHID)

	gen				sector = 2 if urban == 1
	replace			sector = 1 if sector == .
	lab var			sector "Sector"
	lab def			sector 1 "Rural" 2 "Urban"
	lab val			sector sector
	drop			urban
	order			sector, after(phw)


	gen				Region = 4012 if region == "Central"
	replace			Region = 4013 if region == "Eastern"
	replace			Region = 4014 if region == "Kampala"
	replace			Region = 4015 if region == "Northern"
	replace			Region = 4016 if region == "Western"
	lab define		region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
						"Oromia" 1005 "Somali" 1006 "Benishangul-Gumuz" 1007 ///
						"SNNPR" 1008 "Gambela" 1009 "Harar" 1010 ///
						"Addis Ababa" 1011 "Dire Dawa" 2101 "Chitipa" 2102 ///
						"Karonga" 2103 "Nkhata Bay" 2104 "Rumphi" 2105 ///
						"Mzimba" 2106 "Likoma" 2107 "Mzuzu City" 2201 ///
						"Kasungu" 2202 "Nkhotakota" 2203 "Ntchisi" 2204 ///
						"Dowa" 2205 "Salima" 2206 "Lilongwe" 2207 ///
						"Mchinji" 2208 "Dedza" 2209 "Ntcheu" 2210 ///
						"Lilongwe City" 2301 "Mangochi" 2302 "Machinga" 2303 ///
						"Zomba" 2304 "Chiradzulu" 2305 "Blantyre" 2306 ///
						"Mwanza" 2307 "Thyolo" 2308 "Mulanje" 2309 ///
						"Phalombe" 2310 "Chikwawa" 2311 "Nsanje" 2312 ///
						"Balaka" 2313 "Neno" 2314 "Zomba City" 2315 ///
						"Blantyre City" 3001 "Abia" 3002 "Adamawa" 3003 ///
						"Akwa Ibom" 3004 "Anambra" 3005 "Bauchi" 3006 ///
						"Bayelsa" 3007 "Benue" 3008 "Borno" 3009 ///
						"Cross River" 3010 "Delta" 3011 "Ebonyi" 3012 ///
						"Edo" 3013 "Ekiti" 3014 "Enugu" 3015 "Gombe" 3016 ///
						"Imo" 3017 "Jigawa" 3018 "Kaduna" 3019 "Kano" 3020 ///
						"Katsina" 3021 "Kebbi" 3022 "Kogi" 3023 "Kwara" 3024 ///
						"Lagos" 3025 "Nasarawa" 3026 "Niger" 3027 "Ogun" 3028 ///
						"Ondo" 3029 "Osun" 3030 "Oyo" 3031 "Plateau" 3032 ///
						"Rivers" 3033 "Sokoto" 3034 "Taraba" 3035 "Yobe" 3036 ///
						"Zamfara" 3037 "FCT" 4012 "Central" 4013 ///
						"Eastern" 4014 "Kampala" 4015 "Northern" 4016 ///
						"Western" 4017 "North" 4018 "Central" 4019 "South", replace
	lab val			Region region
	drop			region
	rename			Region region
	order			region, after(sector)
	lab var			region "Region"

	rename			DistrictCode zone_id
	rename			CountyCode county_id
	rename			SubcountyCode city_id
	rename			ParishCode subcity_id

	rename			Sq02 start_date
	rename			s2gq01 revised

	drop			BSEQNO Cq08 Cq08_1a Cq08_1b Cq08_1c Cq08_1d start_date ///
						Sq04 sec0_startime sec0_endtime
	
* rename government contribution to spread
	rename			s2gq02__1 spread_01
	rename			s2gq02__2 spread_02
	rename			s2gq02__3 spread_03
	rename			s2gq02__4 spread_04
	rename			s2gq02__5 spread_05
	rename			s2gq02__6 spread_06

* rename behavioral changes
	rename			s3q01 bh_01
	rename			s3q02 bh_02
	rename			s3q03 bh_03
	rename			s3q04 bh_04
	rename			s3q05 bh_05
	rename			s3q06 bh_07
	rename			s3q07 bh_08

* rename access
	rename			s4q01e ac_drink
	rename			s4q01f ac_drink_why

	rename 			s4q01 ac_soap
	rename			s4q02 ac_soap_why
	replace			ac_soap_why = 9 if ac_soap_why == -96
	replace			ac_soap_why = . if ac_soap_why == 99
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "cannot afford it" 8 "afraid to go out" 9 "other"
	lab var 		ac_soap_why "reason for unable to purchase soap"

	rename 			s4q03 ac_water
	rename 			s4q04 ac_water_why

	rename 			s4q08 ac_med

	rename 			s4q09 ac_medserv_need
	rename 			s4q10 ac_medserv
	rename 			s4q11 ac_medserv_why
	replace			ac_medserv_why = 3 if ac_medserv_why == 5
	replace			ac_medserv_why = 5 if ac_medserv_why == 7
	replace 		ac_medserv_why = 7 if ac_medserv_why == 4
	replace			ac_medserv_why = 4 if ac_medserv_why == -96
	lab def			ac_medserv_why 1 "no money" 2 "no med personnel" 3 "facility full / closed" ///
								4 "other" 5 "no transportation" 6 "restrictions to go out" ///
								7 "afraid of virus" 8 "facility closed "
	lab var 		ac_medserv_why "reason for unable to access medical services"

	rename			s4q12__1 asset_01
	rename			s4q12__2 asset_02
	rename			s4q12__3 asset_03
	rename			s4q12__4 asset_04
	rename			s4q12__5 asset_05

	drop			s4q01f_Other s4q02_Other s4q04_Other s4q11_Other case_filter
	
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
	rename			s5q08d__1 emp_cont_01
	rename			s5q08d__2 emp_cont_02
	rename			s5q08d__3 emp_cont_03
	rename			s5q08d__4 emp_cont_04
	rename			s5q08e contrct
	rename			s5q09 emp_hh
	
	rename			s5aq11 bus_emp
	rename			s5aq11a_1 bus_stat
	replace			bus_stat = s5aq11a_2 if bus_stat == .
	replace			bus_stat = s5aq11a_3 if bus_stat == .
	
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
						s5q10__5 s5aq11a_2 business_case_filter s5aq11a_3 ///
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
	rename			s9q01 concern_01
	rename			s9q02 concern_02
	gen				have_symp = 1 if s9q03__1 == 1 | s9q03__2 == 1 | s9q03__3 == 1 | ///
						s9q03__4 == 1 | s9q03__5 == 1 | s9q03__6 == 1 | ///
						s9q03__7 == 1 | s9q03__8 == 1
	replace			have_symp = 2 if have_symp == .
	lab var			have_symp "Has anyone in your hh experienced covid symptoms?:cough/shortness of breath etc."
	order			have_symp, after(concern_02)

	drop			s9q03__1 s9q03__2 s9q03__3 s9q03__4 s9q03__5 s9q03__6 s9q03__7 s9q03__8

	rename 			s9q04 have_test
	rename 			s9q05 concern_03
	rename			s9q06 concern_04
	lab var			concern_04 "Response to the COVID-19 emergency will limit my rights and freedoms"
	rename			s9q07 concern_05
	lab var			concern_05 "Money and supplies allocated for the COVID-19 response will be misused and captured by powerful people in the country"
	rename			s9q08 concern_06
	lab var			concern_06 "Corruption in the government has lowered the quality of medical supplies and care"

	rename			s9q09__1 curb_01 
	rename			s9q09__2 curb_02
	rename			s9q09__3 curb_03
	rename			s9q09__4 curb_04
	rename			s9q09__5 curb_05

* create country variables
	gen				country = 4
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

* delete temp files
	erase			"$root/wave_02/SEC6w.dta"
	erase			"$root/wave_02/SEC10w.dta"

* save temp file
	save			"$root/wave_02/r2_sect_all", replace

	
* **********************************************************************
* 5 - build uganda panel
* **********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_all.dta", ///
						clear

* append round 2 of the data
	append 			using "$root/wave_02/r2_sect_all", ///
						force

* merge in consumption aggregate
	merge m:1		baseline_hhid using "$export/wave_01/pov_r0.dta", nogenerate
	
	
* **********************************************************************
* 6 - end matter, clean up to save
* **********************************************************************

	compress
	describe
	summarize

	rename HHID hhid_uga
	drop if hhid_uga == .

* save file
		customsave , idvar(hhid_uga) filename("uga_panel.dta") ///
			path("$export") dofile(uga_build) user($user)

* close the log
	log	close

/* END */
