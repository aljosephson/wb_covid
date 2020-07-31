* Project: WB COVID
* Created on: July 2020
* Created by: alj
* LAST EDITED: 31 July 2020 
* Stata v.16.1

* does
	* merges together each section of malawi data
	* renames variables
	* outputs single cross section data

* assumes
	* raw malawi data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"

* open log
	cap log 		close
	log using		"$logout/mal_build", append


* ***********************************************************************
* 1 - reshape wide data
* ***********************************************************************

* ***********************************************************************
* 1a - reshape section on income loss wide data
* ***********************************************************************

* reshape files which are currently long 

* load income_loss data
	use				"$root/wave_01/sect7_Income_Loss", clear
	
* drop other source 	
	drop 			income_source_os

*reshape data 	
	reshape 		wide s7q1 s7q2, i(y4_hhid HHID) j(income_source)
	
* rename variables	
	rename 			s7q11 farm_inc
	label 			var farm_inc "income from farming, fishing, livestock in last 12 months"
	rename			s7q21 farm_chg 
	label 			var farm_chg "change in income from farming since covid"
	rename 			s7q12 bus_inc
	label 			var bus_inc "income from non-farm family business in last 12 months"
	rename			s7q22 bus_chg
	label 			var bus_chg "change in income from non-farm family business since covid"	
	rename 			s7q13 wage_inc
	label 			var wage_inc "income from wage employment in last 12 months"
	rename			s7q23 wage_chg
	label 			var wage_chg "change in income from wage employment since covid"	
	rename 			s7q14 rem_for
	label 			var rem_for "income from remittances abroad in last 12 months"
	rename			s7q24 rem_for_chg
	label 			var rem_for_chg "change in income from remittances abroad since covid"	
	rename 			s7q15 rem_dom
	label 			var rem_dom "income from remittances domestic in last 12 months"
	rename			s7q25 rem_dom_chg
	label 			var rem_dom_chg "change in income from remittances domestic since covid"	
	rename 			s7q16 asst_inc
	label 			var asst_inc "income from assistance from non-family in last 12 months"
	rename			s7q26 asst_chg
	label 			var asst_chg "change in income from assistance from non-family since covid"
	rename 			s7q17 isp_inc
	label 			var isp_inc "income from properties, investment in last 12 months"
	rename			s7q27 isp_chg
	label 			var isp_chg "change in income from properties, investment since covid"
	rename 			s7q18 pen_inc
	label 			var pen_inc "income from pension in last 12 months"
	rename			s7q28 pen_chg
	label 			var pen_chg "change in income from pension since covid"
	rename 			s7q19 gov_inc
	label 			var gov_inc "income from government assistance in last 12 months"
	rename			s7q29 gov_chg
	label 			var gov_chg "change in income from government assistance since covid"	
	rename 			s7q110 ngo_inc
	label 			var ngo_inc "income from NGO assistance in last 12 months"
	rename			s7q210 ngo_chg
	label 			var ngo_chg "change in income from NGO assistance since covid"
	rename 			s7q196 other_inc
	label 			var other_inc "income from other source in last 12 months"
	rename			s7q296 other_chg
	label 			var other_chg "change in income from other source since covid"	
	drop 			s7q199 
	*** yes or no response to ``total income'' - unclear what this measures
	*** omit, but keep overall change 
	rename			s7q299 tot_inc_chg
	label 			var tot_inc_chg "change in total income since covid"
	
* save new file 
	save			"$export/wave_01/sect7_Income_Loss", replace	

* ***********************************************************************
* 1b - reshape section on safety nets wide data
* ***********************************************************************
	
* load safety_net data 
	use				"$root/wave_01/sect11_Safety_Nets", clear	

* drop other 
	drop 			s11q3_os

* reshape 
	reshape 		wide s11q1 s11q2 s11q3, i(y4_hhid HHID) j(social_safetyid)
	
* rename variables
	generate		cash_gov = 1 if s11q12 == 1 & s11q32 == 1
	lab var			cash_gov "Has any member of your household received cash transfers from government"
	generate		cash_gov_val = s11q22 if s11q12 == 1 & s11q32 == 1
	lab var			cash_gov_val "What was the total value of cash transfers from government"
	*** this appears to have no values ... 
	
	generate		cash_inst = 1 if s11q12 == 1 & s11q32 <= 1 & s11q32 >= . 
	lab var			cash_inst "Has any member of your household received cash transfers from government"
	generate		cash_inst_val = s11q22 if s11q12 == 1 & s11q32 <= 1 & s11q32 >= . 
	lab var			cash_inst_val "What was the total value of cash transfers from government"	
	
	generate		food_gov = 1 if s11q11 == 1 & s11q31 == 1
	lab var			food_gov "Has any member of your household received free food from government"
	generate		food_gov_val = s11q21 if s11q11 == 1 & s11q31 == 1
	lab var			food_gov_val "What was the total value of free food from government"
	
	generate		food_inst= 1 if s11q11 == 1 & s11q31 <= 1 & s11q31 >= . 
	lab var			food_inst "Has any member of your household received free food from other institutions"
	generate		food_inst_val = s11q21 if s11q11 == 1 & s11q31 <= 1 & s11q31 >= . 
	lab var			food_inst_val "What was the total value of free food from other institutions"
	
	generate		other_gov = 1 if s11q13 == 1 & s11q33 == 1 
	lab var			other_gov "Has any member of your household received in-kind transfers from government"
	generate		other_gov_val = s11q23 if s11q13 == 1 & s11q33 == 1
	lab var			other_gov_val "What was the total value of in-kind transfers from government"
	
	generate		other_inst = 1 if s11q13 <= 1 & s11q33 >= . 
	lab var			other_inst "Has any member of your household received in-kind transfers from other institutions"
	generate		other_inst_val = s11q23 if s11q13 <= 1 & s11q33 >= . 
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

* save new file 
	save			"$export/wave_01/sect11_Safety_Nets", replace
	

* ***********************************************************************
* 2 - build malawi cross section
* ***********************************************************************
	
* load cover data
	use				"$root/wave_01/secta_Cover_Page", clear

* merge in other sections
	merge 1:1 		HHID using "$root/wave_01/sect3_Knowledge.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect4_Behavior.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect5_Access.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect6_Employment.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$export/wave_01/sect7_Income_Loss.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect8_food_security.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect9_Concerns.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$export/wave_01/sect11_Safety_Nets.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect12_Interview_Result.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect13_Agriculture.dta", keep(match) nogenerate
	

* ***********************************************************************
* 3 - rationalize variable names
* ***********************************************************************
	
* reformat HHID
	rename			HHID household_id_an
	label 			var household_id_an "32 character alphanumeric - str32"
	encode 			household_id_an, generate(HHID)
	label           var HHID "unique identifier of the interview"
	format 			%12.0f HHID
	order 			y4_hhid HHID household_id_an
	
* rename basic information 
	
	rename 			wt_baseline phw
	label var		phw "sampling weights"
	
	rename			HHID household_id
	lab var			household_id "Household ID (Full)"

	gen				wave = 1
	lab var			wave "Wave number"
	order			y4_hhid wave phw, after(household_id)
	
	gen				sector = 2 if urb_rural == 1
	replace			sector = 1 if urb_rural == 2
	lab var			sector "Sector"
	lab def			sector 1 "Rural" 2 "Urban"
	lab var			sector "sector - urban or rural"
	drop			urb_rural
	order			sector, after(phw)
	
	gen 			region = . 
	replace			region = 17 if region == 100
	replace			region = 18 if region == 200
	replace 		region = 19 if region == 300
	lab def			region 1 "Tigray" 2 "Afar" 3 "Amhara" 4 "Oromia" 5 "Somali" ///
						6 "Benishangul-Gumuz" 7 "SNNPR" 8 "Bambela" 9 "Harar" ///
						10 "Addis Ababa" 11 "Dire Dawa" 12 "Central" ///
						13 "Eastern" 14 "Kampala" 15 "Northern" 16 "Western" /// 
						17 "North" 18 "Central" 19 "South"
	drop			hh_a00
	order			region, after(sector)
	lab var			region "Region"	
	
	rename			hh_a01 zone_id
	rename			interviewDate start_date 
	rename			Above_18 above18
	rename 			s3q1  know
	rename			s3q1a internet 
	
*** KNOWLEDGE 	
	
* rename knowledge  
	rename			s3q2__1 know_01
	lab var			know_01 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s3q2__2 know_09
	lab var			know_09 "Use of Sanitizer Reduces Risk of Coronavirus Contraction" 
	rename			s3q2__3 know_02
	lab var			know_02 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename 			s3q2__11 know_11 
	label var 		know_11 "Cough Etiquette Reduces Risk of Coronavirus Contract"
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
	rename			s3q3_os gov_16_details
	label var 		gov_16_details "details on other steps taken by government" 
	*** n = 85 - distribution of water buckets, soap primarily
	rename 			s3q3__11 gov_none 
	label var 		gov_none "government has taken no steps"
	rename 			s3q3__98 gov_dnk
	label var 		gov_dnk "do not know steps government has taken"
	
* information 
	rename			s3q4 info
	rename 			s3q5__1 info_01
	rename			s3q5__2 info_02
	rename 			s3q5__3 info_03
	rename 			s3q5__4 info_04
	rename 			s3q5__5 info_05
	rename 			s3q5__6	info_06
	rename 			s3q5__7 info_07
	rename 			s3q5__8 info_08
	rename 			s3q5__9	info_09
	rename 			s3q5__10 info_10
	rename 			s3q5__11 info_11 
	rename 			s3q5__12 info_12 
	rename 			s3q5__13 info_13 

* satisfaction + government perspectives 
	rename 			s3q6 satis 
	rename 			s3q7__1 satis_01
	rename			s3q7__2 satis_02 
	rename 			s3q7__3 satis_03
	rename 			s3q7__4 satis_04 
	rename 			s3q7__5 satis_05 
	rename 			s3q7__6 satisf_06 
	rename 			s3q7__96 satis_07 
	rename 			s3q7_os satis_07_details 
	
* gov / response agreement 
	rename 			s3q8 gov_pers_01
	rename 			s3q9 gov_pers_02 
	rename 			s3q10 gov_pers_03 
	rename 			s3q11 gov_pers_04 
	rename 			s3q12 gov_pers_05 
	
*** BEHAVIOR

	rename			s4q1 bh_01
	rename			s4q2a bh_02
	rename			s4q3a bh_06
	rename 			s4q3b bh_06a
	rename 			s4q4 bh_03
	rename			s4q5 bh_04
	rename			s4q6 bh_05 	
	
*** ACCESS 

	rename 			s5q1a1 ac_soap_need
	rename 			s5q1b1 ac_soap 
	generate		ac_soap_why = . 
	replace			ac_soap_why = 1 if s5q1c1__1 == 1 
	replace 		ac_soap_why = 2 if s5q1c1__2 == 1
	replace 		ac_soap_why = 3 if s5q1c1__3 == 1
	replace 		ac_soap_why = 4 if s5q1c1__4 == 1
	replace 		ac_soap_why = 5 if s5q1c1__5 == 1
	replace 		ac_soap_why = 6 if s5q1c1__6 == 1
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money"
	label var 		ac_soap_why "reason for unable to purchase soap"
								
	rename 			s5q1a2 ac_water
	rename 			s5q1b2 ac_water_why
	
	rename 			s5q1a4 ac_clean_need 
	rename 			s5q1b4 ac_clean
	gen 			ac_clean_why = . 
	replace			ac_clean_why = 1 if s5q1c4__1 == 1 
	replace 		ac_clean_why = 2 if s5q1c4__2 == 1
	replace 		ac_clean_why = 3 if s5q1c4__3 == 1
	replace 		ac_clean_why = 4 if s5q1c4__4 == 1
	replace 		ac_clean_why = 5 if s5q1c4__5 == 1
	replace 		ac_clean_why = 6 if s5q1c4__6 == 1
	lab def			ac_clean_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money"
	label var 		ac_clean_why "reason for unable to purchase cleaning supplies" 			
	
	rename 			s5q2 ac_staple_def
	rename			s5q2a ac_staple_need
	rename 			s5q2b ac_staple
	gen 			ac_staple_why = . 
	replace			ac_staple_why = 1 if s5q2c__1 == 1 
	replace 		ac_staple_why = 2 if s5q2c__2 == 1
	replace 		ac_staple_why = 3 if s5q2c__3 == 1
	replace 		ac_staple_why = 4 if s5q2c__4 == 1
	replace 		ac_staple_why = 5 if s5q2c__5 == 1
	replace 		ac_staple_why = 6 if s5q2c__6 == 1
	replace 		ac_staple_why = 7 if s5q2c__7 == 1
	lab def			ac_staple_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	label var 		ac_staple_why "reason for unable to purchase staple food"
	*** of 1728 observations reported - 1665 are maize ac_staple_def
	
	generate		ac_maize_need = ac_staple_need if ac_staple_def == 1 
	generate 		ac_maize = ac_staple if ac_staple_def == 1 
	gen 			ac_maize_why = . 
	replace			ac_maize_why = 1 if s5q2c__1 == 1 & ac_staple_def == 1 
	replace 		ac_maize_why = 2 if s5q2c__2 == 1 & ac_staple_def == 1 
	replace 		ac_maize_why = 3 if s5q2c__3 == 1 & ac_staple_def == 1 
	replace 		ac_maize_why = 4 if s5q2c__4 == 1 & ac_staple_def == 1 
	replace 		ac_maize_why = 5 if s5q2c__5 == 1 & ac_staple_def == 1 
	replace 		ac_maize_why = 6 if s5q2c__6 == 1 & ac_staple_def == 1 
	replace 		ac_maize_why = 7 if s5q2c__7 == 1 & ac_staple_def == 1 
	lab def			ac_maize_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	label var 		ac_maize_why "reason for unable to purchase maize"
	
	rename 			s5q1a3 ac_med_need
	rename 			s5q1b3 ac_med
	gen 			ac_med_why = . 
	replace			ac_med_why = 1 if s5q1c3__1 == 1 
	replace 		ac_med_why = 2 if s5q1c3__2 == 1 
	replace 		ac_med_why = 3 if s5q1c3__3 == 1 
	replace 		ac_med_why = 4 if s5q1c3__4 == 1 
	replace 		ac_med_why = 5 if s5q1c3__5 == 1 
	replace 		ac_med_why = 6 if s5q1c3__6 == 1 
	lab def			ac_med_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" 
	label var 		ac_med_why "reason for unable to purchase medicine"
	
	rename 			s5q3 ac_medserv_need
	rename 			s5q4 acserv_med
	gen 			ac_medserv_why = . 
	replace			ac_medserv_why = 1 if s5q5__1 == 1 
	replace 		ac_medserv_why = 2 if s5q5__2 == 1 
	replace 		ac_medserv_why = 3 if s5q5__3 == 1 
	replace 		ac_medserv_why = 4 if s5q5__4 == 1 
	replace 		ac_medserv_why = 5 if s5q5__5 == 1 
	replace 		ac_medserv_why = 6 if s5q5__6 == 1 
	replace 		ac_medserv_why = 5 if s5q5__7 == 1 
	replace 		ac_medserv_why = 4 if s5q5__8 == 1 
	lab def			ac_medserv_why 1 "no money" 2 "no med personnel" 3 "facility full" /// 
								4 "other" 5 "no transportation" 6 "restrictions to go out" /// 
								7 "afraid of virus" 
	label var 		ac_med_why "reason for unable to access medical services"

	rename 			filter1 children618
	rename 			s5q6a sch_child
	rename 			s5q6b sch_child_meal
	rename 			s5q6c sch_child_mealskip
	rename 			s5q6d edu_act 
	rename 			s5q6__1 edu_01 
	rename 			s5q6__2 edu_02  
	rename 			s5q6__3 edu_03 
	rename 			s5q6__4 edu_04 
	rename 			s5q6__5 edu_05 
	rename 			s5q6__96 edu_other 
	
	rename 			s5q7 edu_cont
	rename			s5q8__1 edu_cont_01
	rename 			s5q8__2 edu_cont_02 
	rename 			s5q8__3 edu_cont_03 
	rename 			s5q8__4 edu_cont_04 
	rename 			s5q8__5 edu_cont_05 
	rename 			s5q8__6 edu_cont_06 
	rename 			s5q8__7 edu_cont_07 
	
	rename 			s5q9 bank
	rename 			s5q10 ac_bank 
	rename 			s5q11 ac_bank_why 
	
*** EMPLOYMENT 

	rename			s6q1a edu
	rename			s6q1 emp
	rename			s6q2 emp_pre
	rename			s6q3a emp_pre_why
	rename			s6q3b emp_pre_act
	rename			s6q4a emp_same
	rename			s6q4b emp_chg_why
	rename			s6q4c emp_pre_actc
	rename			s6q5 emp_act
	rename			s6q6 emp_stat
	rename			s6q7 emp_able
	rename			s6q8 emp_unable	
	rename			s6q8a emp_unable_why	
	rename			s6q8b__1 emp_cont_01
	rename			s6q8b__2 emp_cont_02
	rename			s6q8b__3 emp_cont_03
	rename			s6q8b__4 emp_cont_04
	rename			s6q8c__1 contrct
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
	rename			s6q17__7 farm_why_07
	
	
*** FIES

	rename			s8q1 fies_04
	lab var			fies_04 "Worried about not having enough food to eat"
	rename			s8q2 fies_05
	lab var			fies_05 "Unable to eat healthy and nutritious/preferred foods"
	rename			s8q3 fies_06
	lab var			fies_06 "Ate only a few kinds of food"
	rename			s8q4 fies_07
	lab var			fies_07 "Skipped a meal"
	rename			s8q5 fies_08
	lab var			fies_08 "Ate less than you thought you should"
	rename			s8q6 fies_01
	lab var			fies_01 "Ran out of food"
	rename			s8q7 fies_02
	lab var			fies_02 "Hungry but did not eat"
	rename			s8q8 fies_03
	lab var			fies_03 "Went without eating for a whole day"	 
	
*** CONCERNS

	rename			s9q1 concern_01
	rename			s9q2 concern_02
	rename			s9q3 have_symp
	rename 			s9q4 have_test 
	rename 			s9q5 have_vuln

*** AGRICULTURE

	rename			s13q1 ag_prep
	rename			s13q2a ag_crop_01
	rename			s13q2b ag_crop_02
	rename			s13q2c ag_crop_03
	
	rename			s13q3 ag_prog
	rename 			s13q4 ag_chg
	

	rename			s13q5__1 ag_chg_08  
	label var 		ag_chg_08 "activities affected - covid measures"
	rename			s13q5__2 ag_chg_09  
	label var 		ag_chg_09 "activities affected - could not hire"
	rename			s13q5__3 ag_chg_10 
	label var   	ag_chg_10 "activities affected - hired fewer workers"
	rename			s13q5__4 ag_chg_11  
	label var 		ag_chg_11 "activities affected - abandoned crops"
	rename			s13q5__5 ag_chg_07 
	label var 		ag_chg_07 "activities affected - delayed harvest"
	rename			s13q5__7 ag_chg_12 
	label var 		ag_chg_12 "activities affected - early harvest"
	
	rename			s13q6__1 agcovid_chg_why_01 
	rename 			s13q6__2 agcovid_chg_why_02
	rename 			s13q6__3 agcovid_chg_why_03
	rename			s13q6__4 agcovid_chg_why_04
	rename			s13q6__5 agcovid_chg_why_05	 
	rename 			s13q6__6 agcovid_chg_why_06
	rename 			s13q6__7 agcovid_chg_why_07
	rename 			s13q6__8 agcovid_chg_why_08	
	rename 			s13q7 aghire_chg_why 
	
	rename 			s13q8 ag_ext_need
	rename 			s13q9 ag_ext 
	rename			s13q10 ag_live_lost
	rename			s13q11 ag_live_chg
	rename			s13q12__1 ag_live_chg_01
	rename			s13q12__2 ag_live_chg_02
	rename			s13q12__3 ag_live_chg_03
	rename			s13q12__4 ag_live_chg_04
	rename			s13q12__5 ag_live_chg_05
	rename			s13q12__6 ag_live_chg_06
	rename			s13q12__7 ag_live_chg_07
	
	rename			s13q13 ag_sold
	rename			s13q14 ag_sell
	rename 			s13q15 ag_price 
	
* create country variables
	gen				country = 2
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	 	    
* drop unneeded variables	
	drop 			hh_a16 hh_a17 result s5q1c1__* s5q1c4__* s5q2c__* s5q1c3__* /// 
					s5q5__*  *_os s13q5_* s13q6_* *details  s6q8c__2 s6q8c__99 /// 
					s6q10__*  interview__key nbrbst s12q2 s12q3__0 s12q3__* ///
					 s12q4__* s12q5 s12q6 s12q7 s12q8 s12q9 s12q10 s12q11 ///
					 s12q12 s12q13 s12q14 s11q* 

* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 

rename household_id hhid_mwi 

* save file
		customsave , idvar(hhid_mwi) filename("mwi_panel.dta") ///
			path("$export") dofile(mwi_build) user($user)

* close the log
	log	close

/* END */ 