* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by : alj
* Last edited: 11 August 2020 
* Stata v.16.1

* does
	* merges together each section of Uganda data
	* renames variables
	* outputs single cross section data

* assumes
	* raw Uganda data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/uganda/raw"
	global  fies	=	"$data/analysis/raw"
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
* 1b - reshape section 9 wide data
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
* 1c - reshape section 10 wide data
* ***********************************************************************

* load income data
	use				"$root/wave_01/SEC10", clear
	
* reformat HHID
	format 			%12.0f HHID
	
* drop other safety nets and missing values
	drop			other_nets
	drop if			safety_net__id == .
	
* reshape data	
	reshape 		wide s10q01 s10q02 s10q03 s10q04, i(HHID) j(safety_net__id)

* rename variables
	rename			s10q01101 cash_gov
	lab var			cash_gov "Has any member of your household received cash transfers from government"
	rename			s10q02101 cash_gov_val
	lab var			cash_gov_val "What was the total value of cash transfers from government"
	rename			s10q03101 cash_inst
	lab var			cash_inst "Has any member of your household received cash transfers from other institutions"
	rename			s10q04101 cash_inst_val
	lab var			cash_inst_val "What was the total value of cash transfers from other institutions"
	rename			s10q01102 food_gov
	lab var			food_gov "Has any member of your household received free food from government"
	rename			s10q02102 food_gov_val
	lab var			food_gov_val "What was the total value of free food from government"
	rename			s10q03102 food_inst
	lab var			food_inst "Has any member of your household received free food from other institutions"
	rename			s10q04102 food_inst_val
	lab var			food_inst_val "What was the total value of free food from other institutions"
	rename			s10q01103 kind_gov
	lab var			kind_gov "Has any member of your household received in-kind transfers from government"
	rename			s10q02103 kind_gov_val
	lab var			kind_gov_val "What was the total value of in-kind transfers from government"
	rename			s10q03103 kind_inst
	lab var			kind_inst "Has any member of your household received in-kind transfers from other institutions"
	rename			s10q04103 kind_inst_val
	lab var			kind_inst_val "What was the total value of in-kind transfers from other institutions"

* generate assistance variables like in Ethiopia
	gen				asst_01 = 1 if food_gov == 1 | food_inst == 1
	replace			asst_01 = 2 if asst_01 == .
	lab var			asst_01 "Recieved free food"
	lab val			asst_01 s10q01
	
	gen				asst_03 = 1 if cash_gov == 1 | cash_inst == 1
	replace			asst_03 = 2 if asst_03 == .
	lab var			asst_03 "Recieved direct cash transfer"
	lab val			asst_03 s10q01
	
	gen				asst_05 = 1 if kind_gov == 1 | kind_inst == 1
	replace			asst_05 = 2 if asst_05 == .
	lab var			asst_05 "Recieved in-kind transfer"
	lab val			asst_05 s10q01
	
	gen				asst_04 = 1 if asst_01 == 2 & asst_03 == 2 & asst_05 == 2
	replace			asst_04 = 2 if asst_04 == .
	lab var			asst_04 "Recieved none"
	lab val			asst_04 s10q01

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
* 1e - get household size - R1
* ***********************************************************************

* load data
	use			"$root/wave_01/SEC1.dta", clear
	
* generate counting variables
	gen			hhsize = 1
	
* collapse data
	collapse	(sum) hhsize, by(HHID)
	lab var		hhsize "Household size"
	
* save temp file
	save			"$export/wave_01/hhsize_r1", replace	
	
* ***********************************************************************
* 1f - FIES - R1
* ***********************************************************************

* load data
	use				"$fies/fies_uganda_r1.dta", clear
	
	keep 			HHID Above_18 wt_hh wt_18 p_mod p_sev
	rename 			HHID interview__id 
	
* save temp file
	save			"$export/wave_01/fies_r1", replace	

* ***********************************************************************
* 1g - baseline data
* ***********************************************************************

* load data
	use				"$root/wave_00/pov20.dta", clear
	
	keep			hhid quints
	rename 			hhid baseline_hhid 
	
* save temp file
	save			"$export/wave_01/pov_r0", replace			
	
* ***********************************************************************
* 2 - build uganda 1 cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_01/Cover", clear

* merge in other sections
	merge 1:1 		HHID using "$export/wave_01/respond_r1.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$export/wave_01/hhsize_r1.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC3.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC4.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC5.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC5A.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC6w.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC7.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC8.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC9w.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC9A.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC10w.dta", keep(match) nogenerate
	merge 1:1 		interview__id using "$export/wave_01/fies_r1.dta", keep(match) nogenerate
	merge 1:1 		baseline_hhid using "$export/wave_01/pov_r0.dta", keep(match) nogenerate

* reformat HHID
	format 			%12.0f HHID
	
	
* ***********************************************************************
* 3 - rationalize variable names
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
	
	gen				Region = 12 if region == "Central"
	replace			Region = 13 if region == "Eastern"
	replace			Region = 14 if region == "Kampala"
	replace			Region = 15 if region == "Northern"
	replace			Region = 16 if region == "Western"
	lab def			region 1 "Tigray" 2 "Afar" 3 "Amhara" 4 "Oromia" 5 "Somali" ///
						6 "Benishangul-Gumuz" 7 "SNNPR" 8 "Bambela" 9 "Harar" ///
						10 "Addis Ababa" 11 "Dire Dawa" 12 "Central" ///
						13 "Eastern" 14 "Kampala" 15 "Northern" 16 "Western" /// 
						17 "North" 18 "Central" 19 "South"
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


* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

	compress
	describe
	summarize 

	rename HHID hhid_uga 

* save file
		customsave , idvar(hhid_uga) filename("uga_panel.dta") ///
			path("$export") dofile(uga_build) user($user)

* close the log
	log	close

/* END */