* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* LAST EDIT: 31 July 2020 
* Stata v.16.1

* does
	* merges together each section of Nigeria data
	* renames variables
	* outputs single cross section data

* assumes
	* raw Nigeria data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/nigeria/raw"
	global	export	=	"$data/nigeria/refined"
	global	logout	=	"$data/nigeria/logs"

* open log
	cap log 		close
	log using		"$logout/nga_build", append


* ***********************************************************************
* 1 - reshape wide data
* ***********************************************************************


* ***********************************************************************
* 1a - reshape section 7 wide data - wave 1
* ***********************************************************************

* read in section 7, wave 1
	use				"$root/wave_01/r1_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			source_cd_os zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1 s7q2, i(hhid) j(source_cd)

* rename variables	
	rename 			s7q11 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s7q21 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename 			s7q12 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s7q22 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"	
	rename 			s7q13 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s7q23 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"	
	rename 			s7q14 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename			s7q24 rem_for_chg
	label 			var rem_for_chg "Change in income from remittances abroad since covid"	
	rename 			s7q15 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename			s7q25 rem_dom_chg
	label 			var rem_dom_chg "Change in income from remittances domestic since covid"	
	rename 			s7q16 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename			s7q26 asst_chg
	label 			var asst_chg "Change in income from assistance from non-family since covid"
	rename 			s7q17 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename			s7q27 isp_chg
	label 			var isp_chg "Change in income from properties, investment since covid"
	rename 			s7q18 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"
	rename			s7q28 pen_chg
	label 			var pen_chg "Change in income from pension since covid"
	rename 			s7q19 gov_inc
	label 			var gov_inc "Income from government assistance in last 12 months"
	rename			s7q29 gov_chg
	label 			var gov_chg "Change in income from government assistance since covid"	
	rename 			s7q110 ngo_inc
	label 			var ngo_inc "Income from NGO assistance in last 12 months"
	rename			s7q210 ngo_chg
	label 			var ngo_chg "Change in income from NGO assistance since covid"
	rename 			s7q196 oth_inc
	label 			var oth_inc "Income from other source in last 12 months"
	rename			s7q296 oth_chg
	label 			var oth_chg "Change in income from other source since covid"	
	rename			s7q299 tot_inc_chg
	label 			var tot_inc_chg "Change in income from other source since covid"	

	drop			s7q199
	
* save temp file
	save			"$root/wave_01/r1_sect_7w", replace
	

* ***********************************************************************
* 1b - reshape section 7 wide data - wave 2
* ***********************************************************************

* read in section 7, wave 2
	use				"$root/wave_02/r2_sect_7", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other source
	drop			zone state lga sector ea
	
* reshape data	
	reshape 		wide s7q1, i(hhid) j(source_cd)

* rename variables	
	
	rename 			s7q14 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename 			s7q15 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename 			s7q16 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename 			s7q17 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename 			s7q18 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"

* save temp file
	save			"$root/wave_02/r2_sect_7w", replace
	
* ***********************************************************************
* 1c - reshape section 10 wide data - wave 1
* ***********************************************************************

* read in section 10, wave 1
	use				"$root/wave_01/r1_sect_10", clear

* reformat HHID
	format 			%5.0f hhid

* drop other shock
	drop			shock_cd_os s10q3_os
	
* generate shock variables
	forval i = 1/9 {
		gen				shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_cd == `i'
		}
	
* need to make shock variables match uganda 
* shock 2 - 9 need to be change
* shock 1 is okay
	rename 			shock_08 shock_12 
	rename 			shock_09 shock_14 
	rename 			shock_05 shock_08 
	rename			shock_06 shock_10
	rename 			shock_07 shock_11 
	rename 			shock_02 shock_05
	rename			shock_03 shock_06
	rename 			shock_04 shock_07
	
* rename cope variables
	rename			s10q3__1 cope_01
	rename			s10q3__6 cope_02
	rename			s10q3__7 cope_03
	rename			s10q3__8 cope_04
	rename			s10q3__9 cope_05
	rename			s10q3__11 cope_06
	rename			s10q3__12 cope_07
	rename			s10q3__13 cope_08
	rename			s10q3__14 cope_09
	rename			s10q3__15 cope_10
	rename			s10q3__16 cope_11
	rename			s10q3__17 cope_12
	rename			s10q3__18 cope_13
	rename			s10q3__19 cope_14
	rename			s10q3__20 cope_15
	rename			s10q3__21 cope_16
	rename			s10q3__96 cope_17
	
* drop unnecessary variables
	drop	shock_cd s10q1 zone state lga sector ea 	

* collapse to household level
	collapse (max) cope_01- shock_14, by(hhid)
	
* label variables
	lab var			shock_01 "Death of disability of an adult working member of the household"
	lab var			shock_05 "Job loss"
	lab var			shock_06 "Non-farm business failure"
	lab var			shock_07 "Theft of crops, cash, livestock or other property"
	lab var			shock_08 "Destruction of harvest by insufficient labor"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items c"
	lab var			shock_14 "Other shock"
	* differs from uganda (other country with shock questions) - asked binary here
	
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
	save			"$root/wave_01/r1_sect_10w", replace

* ***********************************************************************
* 1d - reshape section 11 wide data - wave 1
* ***********************************************************************

* read in section 11, wave 1
	use				"$root/wave_01/r1_sect_11", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other 
	drop 			s11q3_os zone state lga sector ea 

* reshape 
	reshape 		wide s11q1 s11q2 s11q3, i(hhid) j(assistance_cd)
	
* rename variables
	generate		cash_gov = 1 if s11q12 == 1 & s11q32 >= 3
	lab var			cash_gov "Has any member of your household received cash transfers from government"
	generate		cash_gov_val = s11q22 if s11q12 == 1 & s11q32 >= 3
	lab var			cash_gov_val "What was the total value of cash transfers from government"
	
	generate		cash_inst = 1 if s11q12 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst "Has any member of your household received cash transfers from government"
	generate		cash_inst_val = s11q22 if s11q12 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_val "What was the total value of cash transfers from government"	
	
	generate		food_gov = 1 if s11q11 == 1 & s11q31 >= 3
	lab var			food_gov "Has any member of your household received free food from government"
	generate		food_gov_val = s11q12 if s11q11 == 1 & s11q31 >= 3
	lab var			food_gov_val "What was the total value of free food from government"
	
	generate		food_inst= 1 if s11q11 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst "Has any member of your household received free food from other institutions"
	generate		food_inst_val = s11q21 if s11q11 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_val "What was the total value of free food from other institutions"
	
	generate		other_gov = 1 if s11q13 == 1 & s11q33 >= 3
	lab var			other_gov "Has any member of your household received in-kind transfers from government"
	generate		other_gov_val = s11q23 if s11q13 == 1 & s11q33 >= 3
	lab var			other_gov_val "What was the total value of in-kind transfers from government"
	
	generate		other_inst = 1 if s11q13 <= 4 & s11q33 >= . 
	lab var			other_inst "Has any member of your household received in-kind transfers from other institutions"
	generate		other_inst_val = s11q23 if s11q13 <= 4 & s11q33 >= . 
	lab var			other_inst_val "What was the total value of in-kind transfers from other institutions"
 
* generate assistance variables like in Ethiopia
	gen				asst_01 = 1 if food_gov == 1 | food_inst == 1
	replace			asst_01 = 2 if asst_01 == .
	lab var			asst_01 "Recieved free food"
	lab val			asst_01 s10q01
	
	gen				asst_03 = 1 if cash_gov == 1 | cash_inst == 1
	replace			asst_03 = 2 if asst_03 == .
	lab var			asst_03 "Recieved direct cash transfer"
	lab val			asst_03 s10q01
	
	gen				asst_06 = 1 if other_gov == 1 | other_inst == 1
	replace			asst_06 = 2 if asst_06 == .
	lab var			asst_06 "Recieved other transfer"
	lab val			asst_06 s10q01
	
	gen				asst_04 = 1 if asst_01 == 2 & asst_03 == 2 & asst_06 == 2
	replace			asst_04 = 2 if asst_04 == .
	lab var			asst_04 "Recieved none"
	lab val			asst_04 s10q01

* save temp file
	save			"$root/wave_01/r1_sect_11w", replace
	
* ***********************************************************************
* 1e - reshape section 11 wide data - wave 2
* ***********************************************************************

* read in section 11, wave 2
	use				"$root/wave_02/r2_sect_11", clear

* reformat HHID
	format 			%5.0f hhid
	
* drop other 
	drop 			s11q3_os s11q6_os zone state lga sector ea 
	
* reorganize source variable to comport with previous code 
	gen 			s11q3 = .
	replace 		s11q3 = 1 if s11q3__1 == 1
	replace 		s11q3 = 2 if s11q3__2 == 1
	replace 		s11q3 = 3 if s11q3__3 == 1
	replace 		s11q3 = 4 if s11q3__4 == 1
	replace 		s11q3 = 5 if s11q3__5 == 1
	replace 		s11q3 = 6 if s11q3__6 == 1
	replace 		s11q3 = 7 if s11q3__7 == 1
	replace 		s11q3 = 8 if s11q3__96 == 1

	drop			 s11q3__1 s11q3__2 s11q3__3 s11q3__4 s11q3__5 s11q3__6 s11q3__7 s11q3__96
	
* reorganize difficulties variable to comport with section 
	gen 			s11q6 = . 
	replace 		s11q6 = 1 if s11q6__1 == 1
	replace 		s11q6 = 2 if s11q6__2 == 1
	replace 		s11q6 = 3 if s11q6__3 == 1
	replace 		s11q6 = 4 if s11q6__4 == 1
	replace 		s11q6 = 6 if s11q6__6 == 1
	replace 		s11q6 = 7 if s11q6__7 == 1
	replace 		s11q6 = 8 if s11q6__96 == 1
	
	drop 			s11q6__1 s11q6__2 s11q6__3 s11q6__4 s11q6__6 s11q6__7 s11q6__96

* reshape 
	reshape 		wide s11q1 s11q2 s11q3 s11q5 s11q6, i(hhid) j(assistance_cd)
	
* rename variables
	generate		cash_gov = 1 if s11q12 == 1 & s11q32 >= 3
	lab var			cash_gov "Has any member of your household received cash transfers from government"
	generate		cash_gov_val = s11q22 if s11q12 == 1 & s11q32 >= 3
	lab var			cash_gov_val "What was the total value of cash transfers from government"
	
	generate		cash_inst = 1 if s11q12 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst "Has any member of your household received cash transfers from non-government"
	generate		cash_inst_val = s11q22 if s11q12 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_val "What was the total value of cash transfers from government"	
	
	generate		food_gov = 1 if s11q11 == 1 & s11q31 >= 3
	lab var			food_gov "Has any member of your household received free food from government"
	generate		food_gov_val = s11q21 if s11q11 == 1 & s11q31 >= 3
	lab var			food_gov_val "What was the total value of free food from government"
	
	generate		food_inst= 1 if s11q11 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst "Has any member of your household received free food from other institutions"
	generate		food_inst_val = s11q21 if s11q11 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_val "What was the total value of free food from other institutions"
	
	generate		other_gov = 1 if s11q13 == 1 & s11q33 >= 3
	lab var			other_gov "Has any member of your household received in-kind transfers from government"
	generate		other_gov_val = s11q23 if s11q13 == 1 & s11q33 >= 3
	lab var			other_gov_val "What was the total value of in-kind transfers from government"
	
	generate		other_inst = 1 if s11q13 <= 4 & s11q33 >= . 
	lab var			other_inst "Has any member of your household received in-kind transfers from other institutions"
	generate		other_inst_val = s11q23 if s11q13 <= 4 & s11q33 >= . 
	lab var			other_inst_val "What was the total value of in-kind transfers from other institutions"

	
* rename variables for difficulties 
	generate		cash_gov_diff = 1 if s11q52 == 1 & s11q32 >= 3
	lab var			cash_gov_diff "Difficulties with cash transfers from government"
	generate		cash_gov_diff_why = s11q62 if s11q52 == 1 & s11q32 >= 3
	lab var			cash_gov_diff_why "Reason for difficulties with cash transfers from government"
	
	generate		cash_inst_diff = 1 if s11q52 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_diff "Difficulties with cash transfers from other institions"
	generate		cash_inst_diff_why = s11q62 if s11q52 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_diff_why "Reason for difficulties with cash transfers from other institions"	
	
	generate		food_gov_diff = 1 if s11q51 == 1 & s11q31 >= 3
	lab var			food_gov_diff "Difficulties with free food from government"
	generate		food_gov_diff_why = s11q61 if s11q51 == 1 & s11q31 >= 3
	lab var			food_gov_diff_why "Reason for difficulties with free food from government"
	
	generate		food_inst_diff = 1 if s11q51 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_diff "Difficulties with free food from other institutions"
	generate		food_inst_diff_why = s11q61 if s11q51 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_diff_why "Reason for difficulties with free food from other institutions"
	
	generate		other_gov_diff = 1 if s11q53 == 1 & s11q33 >= 3
	lab var			other_gov_diff "Difficulties with in-kind transfers from government"
	generate		other_gov_diff_why = s11q63 if s11q53 == 1 & s11q33 >= 3
	lab var			other_gov_diff_why "Reason for difficulties with in-kind transfers from government"
	
	generate		other_inst_diff = 1 if s11q53 <= 4 & s11q33 >= . 
	lab var			other_inst_diff "Difficulties with in-kind transfers from other institutions"
	generate		other_inst_diff_why = s11q63 if s11q53 <= 4 & s11q33 >= . 
	lab var			other_inst_diff_why "Reason for difficulties with in-kind transfers from other institutions"
	
 
* generate assistance variables like in Ethiopia
	gen				asst_01 = 1 if food_gov == 1 | food_inst == 1
	replace			asst_01 = 2 if asst_01 == .
	lab var			asst_01 "Recieved free food"
	lab val			asst_01 s10q01
	
	gen				asst_03 = 1 if cash_gov == 1 | cash_inst == 1
	replace			asst_03 = 2 if asst_03 == .
	lab var			asst_03 "Recieved direct cash transfer"
	lab val			asst_03 s10q01
	
	gen				asst_06 = 1 if other_gov == 1 | other_inst == 1
	replace			asst_06 = 2 if asst_06 == .
	lab var			asst_06 "Recieved other transfer"
	lab val			asst_06 s10q01
	
	gen				asst_04 = 1 if asst_01 == 2 & asst_03 == 2 & asst_06 == 2
	replace			asst_04 = 2 if asst_04 == .
	lab var			asst_04 "Recieved none"
	lab val			asst_04 s10q01
	
* generate difficulty variables like above 

	gen				asst_diff_01 = 1 if food_gov_diff == 1 | food_inst_diff == 1
	replace			asst_diff_01 = 2 if asst_diff_01 == .
	lab var			asst_diff_01 "Difficulties with free food"
	
	gen				asst_diff_03 = 1 if cash_gov_diff == 1 | cash_inst_diff == 1
	replace			asst_diff_03 = 2 if asst_diff_03 == .
	lab var			asst_diff_03 "Difficulties with direct cash transfer"
	
	gen				asst_diff_06 = 1 if other_gov_diff == 1 | other_inst_diff == 1
	replace			asst_diff_06 = 2 if asst_diff_06 == .
	lab var			asst_diff_06 "Difficulties with other transfer"
	
* drop original variables
	drop 			s11* 

* save temp file
	save			"$root/wave_02/r2_sect_11w", replace				
	
* ***********************************************************************
* 2a - build nigeria wave 1 panel 
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_a_3_4_5_6_8_9_12", ///
						clear
						
* merge in other sections
	merge 1:1 		hhid using "$root/wave_01/r1_sect_7w.dta", keep(match) nogenerate
	merge 1:1 		hhid using "$root/wave_01/r1_sect_10w.dta", keep(match) nogenerate
	merge 1:1 		hhid using "$root/wave_01/r1_sect_11w.dta", keep(match) nogenerate

* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
* save temp file
	save			"$root/wave_01/r1_sect_all", replace	
	
* ***********************************************************************
* 2b - build nigeria wave 2 panel 
* ***********************************************************************

* load round 2 of the data
	use				"$root/wave_02/r2_sect_a_2_5_6_8_12", ///
						clear
						
* merge in other sections
	merge 1:1 		hhid using "$root/wave_02/r2_sect_7w.dta", keep(match) nogenerate
	merge 1:1 		hhid using "$root/wave_02/r2_sect_11w.dta", keep(match) nogenerate

* generate round variable
	gen				wave = 2
	lab var			wave "Wave number"
	
* save temp file
	save			"$root/wave_02/r2_sect_all", replace	

* ***********************************************************************
* 2c - build nigeria panel 
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_all.dta", ///
						clear

* append round 2 of the data
	append 			using "$root/wave_02/r2_sect_all", ///
						force	
	order			wave, after(hhid)

* rationalize variables across waves
	gen				phw = wt_baseline if wt_baseline != .
	replace			phw = wt_round2 if wt_round2 != .
	lab var			phw "sampling weights"
	order			phw, after(wt_baseline)
	drop			wt_baseline wt_round2
	
* rename administrative variables 	
	
	rename			sector urb_rural 
	gen				sector = 2 if urb_rural == 1
	replace			sector = 1 if urb_rural == 2
	lab var			sector "Sector"
	*lab def			sector 1 "Rural" 2 "Urban"
	drop			urb_rural
	order			sector, after(phw)
	
	gen 			region = . 
	replace			region = 20 if zone == 1
	replace			region = 21 if zone == 2
	replace 		region = 22 if zone == 3
	replace			region = 23 if zone == 4
	replace			region = 24 if zone == 5
	replace 		region = 25 if zone == 6	
	lab define		region 1 "Tigray" 2 "Afar" 3 "Amhara" 4 "Oromia" 5 "Somali" ///
						6 "Benishangul-Gumuz" 7 "SNNPR" 8 "Bambela" 9 "Harar" ///
						10 "Addis Ababa" 11 "Dire Dawa" 12 "Central" ///
						13 "Eastern" 14 "Kampala" 15 "Northern" 16 "Western" /// 
						17 "North" 18 "Central" 19 "South" /// 
						20 "North Central" 21 "North East" 22 "North West" /// 
						23 "South East" 24 "South South" 25 "South West"
	drop			zone
	order			region, after(sector)
	lab var			region "Region"	
	
	rename 			s2q0a hhleft
	rename 			s2q0b hhjoin 
	
*** KNOWLEDGE 

	rename 			s3q1  know
	rename			s3q2__1 know_01
	lab var			know_01 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s3q2__2 know_09
	lab var			know_09 "Use of Sanitizer Reduces Risk of Coronavirus Contraction" 
	rename			s3q2__3 know_02
	lab var			know_02 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename 			s3q2__4 know_03 
	lab var			know_03 "Using Masks and/or Gloves Reduces Risk of Coronavirus Contraction"
	rename			s3q2__5 know_10
	lab var			know_10 "Using Gloves Reduces Risk of Coronavirus Contraction"
	rename			s3q2__6 know_04
	lab var			know_04 "Avoiding Travel Reduces Risk of Coronavirus Contraction"
	rename			s3q2__7 know_05
	lab var			know_05 "Staying at Home Reduces Risk of Coronavirus Contraction"
	rename			s3q2__8 know_06
	lab var			know_06 "Avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction"
	rename			s3q2__9 know_07
	lab var			know_07 "Mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Contraction"
	rename			s3q2__10 know_08
	lab var			know_08 "Avoiding Face Touching Reduces Risk of Coronavirus Contraction" 	
	
* rename steps
	rename 			s3q3__1 gov_01
	label var 		gov_01 "government taken steps to advise citizens to stay home"
	rename 			s3q3__2 gov_10
	label var 		gov_10 "government taken steps to advise to avoid social gatherings"
	rename 			s3q3__3 gov_02
	label var 		gov_02 "government restricted travel within country"
	rename 			s3q3__4 gov_03
	label var 		gov_03 "government restricted international travel"
	rename 			s3q3__5 gov_04
	label var 		gov_04 "government closure of schools and universities"
	rename 			s3q3__6 gov_05
	label var		gov_05 "government institute government / lockdown"
	rename 			s3q3__7 gov_06
	label var 		gov_06 "government closure of non-essential businesses"
	rename 			s3q3__8 gov_11
	label var 		gov_11 "government steps of sensitization / public awareness"
	rename			s3q3__9 gov_14
	label var		gov_14 "government establish isolation centers"
	rename 			s3q3__10 gov_15
	label var 		gov_15 "government disinfect public spaces"
	rename 			s3q3__96 gov_16
	label var		gov_16 "government take other steps"
	rename 			s3q3__11 gov_none 
	label var 		gov_none "government has taken no steps"
	rename 			s3q3__98 gov_dnk
	label var 		gov_dnk "do not know steps government has taken"
	
* satisfaction + government perspectives 
	rename 			s3q4 satis 
	rename 			s3q5__1 satis_01
	rename			s3q5__2 satis_02 
	rename 			s3q5__3 satis_03
	rename 			s3q5__4 satis_04 
	rename 			s3q5__5 satis_05 
	rename 			s3q5__6 satisf_06 
	rename 			s3q5__96 satis_07 
	
*** BEHAVIOR

	rename			s4q1 bh_01
	rename			s4q2 bh_02
	rename 			s4q3 bh_03
	rename			s4q4 bh_04

*** ACCESS 

	rename 			s5q1a2 ac_soap_need
	rename 			s5q1b2 ac_soap 
	generate		ac_soap_why = . 
	replace			ac_soap_why = 1 if s5q1c2__1 == 1 
	replace 		ac_soap_why = 2 if s5q1c2__2 == 1
	replace 		ac_soap_why = 3 if s5q1c2__3 == 1
	replace 		ac_soap_why = 4 if s5q1c2__4 == 1
	replace 		ac_soap_why = 5 if s5q1c2__5 == 1
	replace 		ac_soap_why = 6 if s5q1c2__6 == 1
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money"
	label var 		ac_soap_why "reason for unable to purchase soap"
								
	rename 			s5q1a3 ac_clean_need 
	rename 			s5q1b3 ac_clean
	gen 			ac_clean_why = . 
	replace			ac_clean_why = 1 if s5q1c3__1 == 1 
	replace 		ac_clean_why = 2 if s5q1c3__2 == 1
	replace 		ac_clean_why = 3 if s5q1c3__3 == 1
	replace 		ac_clean_why = 4 if s5q1c3__4 == 1
	replace 		ac_clean_why = 5 if s5q1c3__5 == 1
	replace 		ac_clean_why = 6 if s5q1c3__6 == 1
	lab def			ac_clean_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money"
	label var 		ac_clean_why "reason for unable to purchase cleaning supplies" 			

	rename 			s5q1a4 ac_rice_need
	rename 			s5q1b4 ac_rice
	gen 			ac_rice_why = . 
	replace			ac_rice_why = 1 if s5q1c4__1 == 1 
	replace 		ac_rice_why = 2 if s5q1c4__2 == 1
	replace 		ac_rice_why = 3 if s5q1c4__3 == 1 
	replace 		ac_rice_why = 4 if s5q1c4__4 == 1 
	replace 		ac_rice_why = 5 if s5q1c4__5 == 1 
	replace 		ac_rice_why = 6 if s5q1c4__6 == 1 
	lab def			ac_rice_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_rice_why "reason for unable to purchase rice"
	
	rename 			s5q1a5 ac_beans_need
	rename 			s5q1b5 ac_beans
	gen 			ac_beans_why = . 
	replace			ac_beans_why = 1 if s5q1c5__1 == 1 
	replace 		ac_beans_why = 2 if s5q1c5__2 == 1
	replace 		ac_beans_why = 3 if s5q1c5__3 == 1 
	replace 		ac_beans_why = 4 if s5q1c5__4 == 1 
	replace 		ac_beans_why = 5 if s5q1c5__5 == 1 
	replace 		ac_beans_why = 6 if s5q1c5__6 == 1 
	lab def			ac_beans_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_beans_why "reason for unable to purchase beans"
		
	rename 			s5q1a6 ac_cass_need
	rename 			s5q1b6 ac_cass
	gen 			ac_cass_why = . 
	replace			ac_cass_why = 1 if s5q1c6__1 == 1 
	replace 		ac_cass_why = 2 if s5q1c6__2 == 1
	replace 		ac_cass_why = 3 if s5q1c6__3 == 1 
	replace 		ac_cass_why = 4 if s5q1c6__4 == 1 
	replace 		ac_cass_why = 5 if s5q1c6__5 == 1 
	replace 		ac_cass_why = 6 if s5q1c6__6 == 1 
	lab def			ac_cass_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_cass_why "reason for unable to purchase cassava"
	
	rename 			s5q1a7 ac_yam_need
	rename 			s5q1b7 ac_yam
	gen 			ac_yam_why = . 
	replace			ac_yam_why = 1 if s5q1c7__1 == 1 
	replace 		ac_yam_why = 2 if s5q1c7__2 == 1
	replace 		ac_yam_why = 3 if s5q1c7__3 == 1 
	replace 		ac_yam_why = 4 if s5q1c7__4 == 1 
	replace 		ac_yam_why = 5 if s5q1c7__5 == 1 
	replace 		ac_yam_why = 6 if s5q1c7__6 == 1 
	lab def			ac_yam_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_yam_why "reason for unable to purchase yam"
	
	rename 			s5q1a8 ac_sorg_need
	rename 			s5q1b8 ac_sorg
	gen 			ac_sorg_why = . 
	replace			ac_sorg_why = 1 if s5q1c8__1 == 1 
	replace 		ac_sorg_why = 2 if s5q1c8__2 == 1
	replace 		ac_sorg_why = 3 if s5q1c8__3 == 1 
	replace 		ac_sorg_why = 4 if s5q1c8__4 == 1 
	replace 		ac_sorg_why = 5 if s5q1c8__5 == 1 
	replace 		ac_sorg_why = 6 if s5q1c8__6 == 1 
	lab def			ac_sorg_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_sorg_why "reason for unable to purchase sorghum"
	
	rename 			s5q1a1 ac_med_need
	rename 			s5q1b1 ac_med
	gen 			ac_med_why = . 
	replace			ac_med_why = 1 if s5q1c1__1 == 1 
	replace 		ac_med_why = 2 if s5q1c1__2 == 1 
	replace 		ac_med_why = 3 if s5q1c1__3 == 1 
	replace 		ac_med_why = 4 if s5q1c1__4 == 1 
	replace 		ac_med_why = 5 if s5q1c1__5 == 1 
	replace 		ac_med_why = 6 if s5q1c1__6 == 1 
	lab def			ac_med_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_med_why "reason for unable to purchase medicine"


	rename 			s5q2 ac_medserv_need
	rename 			s5q3 acserv_med
	rename 			s5q4 ac_medserv_why 
	replace 		ac_medserv_why = 6 if ac_medserv_why == 4
	replace 		ac_medserv_why = 4 if ac_medserv_why == 96 
	lab def			ac_medserv_why 1 "no money" 2 "no med personnel" 3 "facility full" /// 
								4 "other" 5 "no transportation" 6 "restrictions to go out" /// 
								7 "afraid of virus" 
	label var 		ac_med_why "reason for unable to access medical services"
	
	rename 			filter1 children520
	rename 			s5q4a sch_child
	rename 			s5q4b edu_act 
	rename 			s5q5__1 edu_01 
	rename 			s5q5__2 edu_02  
	rename 			s5q5__3 edu_03 
	rename 			s5q5__4 edu_04 
	rename 			s5q5__7 edu_05 
	rename 			s5q5__96 edu_other 
	rename 			s5q5__5 edu_06 
	rename 			s5q5__6 edu_07 
	
	rename 			s5q6 edu_cont
	rename			s5q7__1 edu_cont_01
	rename 			s5q7__2 edu_cont_02 
	rename 			s5q7__3 edu_cont_03 
	rename 			s5q7__4 edu_cont_05 
	rename 			s5q7__5 edu_cont_06 
	rename 			s5q7__6 edu_cont_07 
	rename 			s5q7__7	educ_cont_08 
	
	rename 			s5q8 bank
	rename 			s5q9 ac_bank 
	rename 			s5q10 ac_bank_why 
	
* round 2 access differs from round 1 access 
	
	rename 			s5q1e suff_waterdrink
	rename 			s5q1f suff_waterdrink_why 
	rename 			s5q1a suff_soap_ac
	rename 			s5q1b suff_waterwash 
	rename 			s5q1c freq_washsoap 
	rename 			s5q1d freq_mask
	
*** EMPLOYMENT 

	rename			s6q1 emp
	rename			s6q2 emp_pre
	rename			s6q3 emp_pre_why
	rename			s6q4 emp_pre_act
	rename			s6q5 emp_act
	rename			s6q6 emp_stat
	rename			s6q7 emp_able
	rename			s6q8 emp_unable	
	rename			s6q8a emp_unable_why	
	rename			s6q9 emp_hh
	rename			s6q11 bus_emp
	rename			s6q12 bus_sect
	rename			s6q13 bus_emp_inc
	rename			s6q14 bus_why
	rename			s6q15 farm_emp 
	rename			s6q16 farm_norm
	rename			s6q17__1 farm_why_01
	rename			s6q17__2 farm_why_02
	rename			s6q17__3 farm_why_03
	rename			s6q17__4 farm_why_04
	rename			s6q17__5 farm_why_05
	rename			s6q17__6 farm_why_06
	rename			s6q17__96 farm_why_07
	
* round 2 access differs from round 1 access 

	rename 			s6q1a emp_7
	rename 			s6q1b emp_7ret 
	rename 			s6q1c emp_7why
	rename 			s6q3a emp_search_month
	rename 			s6q3b emp_search 
	rename			s6q4a emp_same
	rename			s6q4b emp_chg_why 
	rename 			s6q8b emp_hours7
	rename 			s6q8c emp_hoursmarch 
	rename			s6q8d__1 emp_cont_01
	rename			s6q8d__2 emp_cont_02
	rename			s6q8d__3 emp_cont_03
	rename			s6q8d__4 emp_cont_04
	rename			s6q8e contrct
	rename 			s6q11a bus_status 
	rename 			s6q11b bus_closed 
	rename 			s6q15__1 bus_chal_01	
	rename 			s6q15__2 bus_chal_02 
	rename 			s6q15__3 bus_chal_03 
	rename 			s6q15__4 bus_chal_04 
	rename 			s6q15__5 bus_chal_05 
	rename 			s6q15__6 bus_chal_06 
	rename 			s6q15__96 bus_chal_07 
	rename 			s6q15a bus_beh
	rename 			s6q15b__1 bus_beh_01 
	rename 			s6q15b__2 bus_beh_02 
	rename 			s6q15b__3 bus_beh_03 
	rename 			s6q15b__4 bus_beh_04 
	rename 			s6q15b__5 bus_beh_05 
	rename 			s6q15b__6 bus_beh_06 
	rename 			s6q15b__96 bus_beh_07 
	

*** AGRICULTURE

	rename			s6q17 ag_prep
	rename			s6q18_1 ag_crop_01
	rename			s6q18_2 ag_crop_02
	rename			s6q18_3 ag_crop_03
	rename 			s6q19 ag_chg	
	rename			s6q20__1 ag_chg_01
	rename			s6q20__2 ag_chg_02
	rename			s6q20__3 ag_chg_03
	rename			s6q20__4 ag_chg_04
	rename			s6q20__5 ag_chg_05
	rename			s6q20__6 ag_chg_06
	rename			s6q20__7 ag_chg_07
	rename 			s6q20__96 ag_chg_13
	rename			s6q21a__1 agcovid_chg_why_01 
	rename 			s6q21a__2 agcovid_chg_why_02
	rename 			s6q21a__3 agcovid_chg_why_03
	rename			s6q21a__4 agcovid_chg_why_04
	rename			s6q21a__5 agcovid_chg_why_05	 
	rename 			s6q21a__6 agcovid_chg_why_06
	rename 			s6q21a__7 agcovid_chg_why_07
	rename 			s6q21a__8 agcovid_chg_why_08	
	rename 			s6q21a__96 agcovid_chg_why_09 
	rename 			s6q21b__1 ag_nocrop_01 
	rename 			s6q21b__2 ag_nocrop_02 
	rename 			s6q21b__3 ag_nocrop_03 
	rename 			s6q21b__4 ag_nocrop_04 
	rename 			s6q21b__5 ag_nocrop_05 
	rename 			s6q21b__6 ag_nocrop_06 
	rename 			s6q21b__7 ag_nocrop_07 
	rename 			s6q21b__8 ag_nocrop_08 
	rename 			s6q21b__96 ag_nocrop_09 
	rename			s6q22__1 ag_seed_01
	rename			s6q22__2 ag_seed_02
	rename			s6q22__3 ag_seed_03
	rename			s6q22__4 ag_seed_04
	rename			s6q22__5 ag_seed_05
	rename			s6q22__6 ag_seed_06
	rename 			s6q22__96 ag_seed_07 
	rename 			s6q23 ag_live_lost 
	
*** FIES

	rename			s8q4 fies_07
	lab var			fies_07 "Skipped a meal"
	rename			s8q6 fies_01
	lab var			fies_01 "Ran out of food"
	rename			s8q8 fies_03
	lab var			fies_03 "Went without eating for a whole day"	 

* round 2 has different (additional) questions 

	rename			s8q1 fies_04
	lab var			fies_04 "Worried about not having enough food to eat"
	rename			s8q2 fies_05
	lab var			fies_05 "Unable to eat healthy and nutritious/preferred foods"
	rename			s8q3 fies_06
	lab var			fies_06 "Ate only a few kinds of food"
	rename			s8q5 fies_08
	lab var			fies_08 "Ate less than you thought you should"
	rename			s8q7 fies_02
	lab var			fies_02 "Hungry but did not eat"

*** CONCERNS

	rename			s9q1 concern_01
	rename			s9q2 concern_02

	
* drop unnecessary variables
	drop			interviewer_id *_os  s6q10_* s12q3__* s12q4__* /// 
						s12q5 s12q9 s12q10 s12q10_os s12q11 s12q14 s11* baseline_date ///
						s12q10a s5* 
	
* create country variables
	gen				country = 1
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	

* reorder variables
	order			fies_02 fies_03 fies_04 fies_05 fies_06 fies_07 fies_08, after(fies_01)
			
* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 

* save file
		customsave , idvar(hhid) filename("nga_panel.dta") ///
			path("$export") dofile(nga_build) user($user)

* close the log
	log	close

/* END */