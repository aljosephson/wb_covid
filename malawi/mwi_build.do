* Project: WB COVID
* Created on: July 2020
* Created by: alj
* LAST EDITED: 2 AUGUST 2020 
* Stata v.16.1

* does
	* merges together each section of malawi data
	* renames variables
	* outputs panel data

* assumes
	* raw malawi data (wave_01 and wave_02)

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
* 1a - reshape section on income loss wide data - R1
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
* 1b - reshape section on safety nets wide data - R1
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
* 1c - reshape section on income loss wide data - R2
* ***********************************************************************

* load income_loss data
	use				"$root/wave_02/sect7_Income_Loss_r2", clear
	
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
	save			"$export/wave_02/sect7_Income_Loss_r2", replace	
	
* ***********************************************************************
* 1d - reshape section on safety nets wide data - R2
* ***********************************************************************
	
* load safety_net data 
	use				"$root/wave_02/sect11_Safety_Nets_r2", clear	
	
* reorganize difficulties variable to comport with section 
	gen 			s11q6 = . 
	replace 		s11q6 = 1 if s11q6__1 == 1
	replace 		s11q6 = 2 if s11q6__2 == 1
	replace 		s11q6 = 3 if s11q6__3 == 1
	replace 		s11q6 = 4 if s11q6__4 == 1
	replace 		s11q6 = 6 if s11q6__6 == 1
	replace 		s11q6 = 7 if s11q6__7 == 1
	label def 		s11q6 1 "mobility" 2 "incomplete payments" 3 "theft/crime" ///
						  4 "bribe" 5 "domestic violence" 6 "national id" /// 
						  7 "inadqueate information"

	gen 			s11q7 = . 
	replace 		s11q7 = 1 if s11q7__1 == 1
	replace 		s11q7 = 2 if s11q7__2 == 1
	replace 		s11q7 = 3 if s11q7__3 == 1
	replace 		s11q7 = 4 if s11q7__4 == 1
	replace 		s11q7 = 6 if s11q7__6 == 1
	replace 		s11q7 = 7 if s11q7__7 == 1
	label def 		s11q7 1 "did not report" 2 "redress mech" 3 "CUCI" ///
						  4 "payment service hotline" 5 "local gov" 6 "local leader" /// 
						  7 "other"						  
	
	drop 			s11q6__1 s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 s11q6__7 ///
					s11q7__1 s11q7__2 s11q7__3 s11q7__4 s11q7__5 s11q7__6 s11q7__7 /// 
					s11q3_os 
					

* reshape 
	reshape 		wide s11q1 s11q2 s11q3 s11q4a s11q4b s11q5 s11q6 s11q7, i(y4_hhid HHID) j(social_safetyid)
	
* rename variables
	generate		cash_gov = 1 if s11q12 == 1 & s11q32 == 1
	lab var			cash_gov "Has any member of your household received cash transfers from government"
	generate		cash_gov_val = s11q22 if s11q12 == 1 & s11q32 == 1
	lab var			cash_gov_val "What was the total value of cash transfers from government"
	
	generate		cash_gov_date = s11q4a2 if cash_gov == 1
	lab var			cash_gov "Date received cash transfers from government"
	generate		cash_gov_month = s11q4b2 if cash_gov == 1
	lab var			cash_gov_month "Month received cash transfers from government"
	
	generate		cash_inst = 1 if s11q12 == 1 & s11q32 <= 1 & s11q32 >= . 
	lab var			cash_inst "Has any member of your household received cash transfers from government"
	generate		cash_inst_val = s11q22 if s11q12 == 1 & s11q32 <= 1 & s11q32 >= . 
	lab var			cash_inst_val "What was the total value of cash transfers from government"	

	generate		cash_inst_date = s11q4a2 if cash_inst == 1
	lab var			cash_inst_date "Date received cash transfers from government"
	generate		cash_inst_month = s11q4b2 if cash_inst == 1
	lab var			cash_inst_month "Month received cash transfers from government"	
		
	generate		food_gov = 1 if s11q11 == 1 & s11q31 == 1
	lab var			food_gov "Has any member of your household received free food from government"
	generate		food_gov_val = s11q21 if s11q11 == 1 & s11q31 == 1
	lab var			food_gov_val "What was the total value of free food from government"
	
	generate		food_gov_date = s11q4a1 if food_gov == 1
	lab var			food_gov_date "Date received free food from government"
	generate		food_gov_month = s11q4b1 if food_gov == 1
	lab var			food_gov_month "Month received free food from government"
	
	generate		food_inst= 1 if s11q11 == 1 & s11q31 <= 1 & s11q31 >= . 
	lab var			food_inst "Has any member of your household received free food from other institutions"
	generate		food_inst_val = s11q21 if s11q11 == 1 & s11q31 <= 1 & s11q31 >= . 
	lab var			food_inst_val "What was the total value of free food from other institutions"
	
	generate		food_inst_date = s11q4a1 if food_inst == 1
	lab var			food_inst_date "Date received free food from other institutions"
	generate		food_inst_month = s11q4b1 if food_inst == 1
	lab var			food_inst_month "Month received free food from other institutions"	
	
	generate		other_gov = 1 if s11q13 == 1 & s11q33 == 1 
	lab var			other_gov "Has any member of your household received in-kind transfers from government"
	generate		other_gov_val = s11q23 if s11q13 == 1 & s11q33 == 1
	lab var			other_gov_val "What was the total value of in-kind transfers from government"

	generate		other_gov_date = s11q4a3 if other_gov == 1
	lab var			other_gov_date "Date received in-kind transfers from government"
	generate		other_gov_month = s11q4b3 if other_gov == 1
	lab var			other_gov_month "Month received in-kind transfers from government"
	
	generate		other_inst = 1 if s11q13 <= 1 & s11q33 >= . 
	lab var			other_inst "Has any member of your household received in-kind transfers from other institutions"
	generate		other_inst_val = s11q23 if s11q13 <= 1 & s11q33 >= . 
	lab var			other_inst_val "What was the total value of in-kind transfers from other institutions"
	
	generate		other_inst_date = s11q4a3 if other_inst == 1
	lab var			other_inst_date "Has any member of your household received in-kind transfers from other institutions"
	generate		other_inst_month = s11q4b3 if other_inst == 1
	lab var			other_inst_month "What was the total value of in-kind transfers from other institutions"

* rename variables for difficulties + reported difficulties 
	generate		cash_gov_diff = 1 if s11q52 == 1 & s11q32 >= 3
	lab var			cash_gov_diff "Difficulties with cash transfers from government"
	generate		cash_gov_diff_why = s11q62 if s11q52 == 1 & s11q32 >= 3
	lab var			cash_gov_diff_why "Reason for difficulties with cash transfers from government"
	generate 		cash_gov_diff_rep = s11q72 if s11q52 == 1 & s11q32 >= 3
	lab var			cash_gov_diff_rep "Mechanism to report difficulties with cash transfers from government"
	
	generate		cash_inst_diff = 1 if s11q52 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_diff "Difficulties with cash transfers from other institions"
	generate		cash_inst_diff_why = s11q62 if s11q52 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_diff_why "Reason for difficulties with cash transfers from other institions"	
	generate		cash_inst_diff_rep = s11q72 if s11q52 == 1 & s11q32 <= 4 & s11q32 >= . 
	lab var			cash_inst_diff_rep "Mechanism to report difficulties with cash transfers from other institions"
	
	generate		food_gov_diff = 1 if s11q51 == 1 & s11q31 >= 3
	lab var			food_gov_diff "Difficulties with free food from government"
	generate		food_gov_diff_why = s11q61 if s11q51 == 1 & s11q31 >= 3
	lab var			food_gov_diff_why "Reason for difficulties with free food from government"
	generate		food_gov_diff_rep = s11q71 if s11q51 == 1 & s11q31 >= 3
	lab var			food_gov_diff_rep "Mechanism to report difficulties with free food from government"
	
	generate		food_inst_diff = 1 if s11q51 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_diff "Difficulties with free food from other institutions"
	generate		food_inst_diff_why = s11q61 if s11q51 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_diff_why "Reason for difficulties with free food from other institutions"
	generate		food_inst_diff_rep = s11q71 if s11q51 == 1 & s11q31 <= 4 & s11q31 >= . 
	lab var			food_inst_diff_rep "Mechanism to difficulties with free food from other institutions"
	
	generate		other_gov_diff = 1 if s11q53 == 1 & s11q33 >= 3
	lab var			other_gov_diff "Difficulties with in-kind transfers from government"
	generate		other_gov_diff_why = s11q63 if s11q53 == 1 & s11q33 >= 3
	lab var			other_gov_diff_why "Reason for difficulties with in-kind transfers from government"
	generate		other_gov_diff_rep = s11q73 if s11q53 == 1 & s11q33 >= 3
	lab var			other_gov_diff_rep "Mechanism to report difficulties with in-kind transfers from government"
	
	generate		other_inst_diff = 1 if s11q53 <= 4 & s11q33 >= . 
	lab var			other_inst_diff "Difficulties with in-kind transfers from other institutions"
	generate		other_inst_diff_why = s11q63 if s11q53 <= 4 & s11q33 >= . 
	lab var			other_inst_diff_why "Reason for difficulties with in-kind transfers from other institutions"
	generate		other_inst_diff_rep = s11q73 if s11q53 <= 4 & s11q33 >= . 
	lab var			other_inst_diff_rep "Mechanism to report difficulties with in-kind transfers from other institutions"
	
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
	
* could also make date of assistance variables and reporting mechanism difficulties
* due to very few observations - will not do this at this point	
	
* drop wide versions of variables
	drop 			s11* 

* save new file 
	save			"$export/wave_02/sect11_Safety_Nets_r2", replace
	
* ***********************************************************************
* 1e - reshape section on coping wide data - R2
* ***********************************************************************

* read in coping data, wave 2 only 
	use				"$root/wave_02/sect10_Coping_r2", clear

* drop other shock
	drop			shock_id_os s10q3_os
	
* generate shock variables
	forval i = 1/9 {
		gen				shock_0`i' = 1 if s10q1 == 1 & shock_id == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_id == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_id == `i'
		replace			shock_0`i' = 1 if s10q1 == 1 & shock_id == `i'
		}
	
* need to make shock variables match uganda 
	rename 			shock_09 shock_14
	rename 			shock_07 shock_12
	rename 			shock_03 shock_07
	rename 			shock_08 shock_03 
	rename			shock_06 shock_11
	rename 			shock_05 shock_10 
	rename 			shock_04 shock_16 
	rename 			shock_02 shock_06
	rename 			shock_01 shock_05 
	
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
	
* rename affected variables 
	rename			s10q2__1 elseaff_01
	rename			s10q2__2 elseaff_02
	rename			s10q2__3 elseaff_03
	rename			s10q2__4 elseaff_04
	rename			s10q2__5 elseaff_05
	
* drop unnecessary variables
	drop	shock_id s10q1 	

* collapse to household level
	collapse (max) elseaff_01- shock_14, by(HHID y4_hhid)
	
* label variables
	lab var			shock_05 "Job loss"
	lab var 		shock_03 "Injury or death of income earner"
	lab var			shock_06 "Non-farm business failure"
	lab var			shock_07 "Theft of crops, cash, livestock or other property"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items"
	lab var			shock_14 "Other shock"
	lab var 		shock_16 "Disruption of farming, livestock, fishing, etc."
	
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

	lab var			elseaff_01 "just household affected by shock"
	lab var			elseaff_02 "famliy members outside household affected by shock"
	lab var			elseaff_03 "several hh in village affected by shock"
	lab var			elseaff_04 "most or all hhs in village affected by shock"
	lab var			elseaff_05	"several villages affected by shock"
	
* save temp file
	save			"$export/wave_02/sect10_Coping_r2", replace	

* ***********************************************************************
* 2 - build malawi panel 
* ***********************************************************************

* ***********************************************************************
* 2a - build malawi R1 cross section  
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

* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
* save temp file
	save			"$root/wave_01/r1_sect_all", replace		
	
* ***********************************************************************
* 2b - build malawi R2 cross section  
* ***********************************************************************
		
* load cover data
	use				"$root/wave_02/secta_Cover_Page_r2", clear

* merge in other sections
	merge 1:1 		HHID using "$root/wave_02/sect3_Knowledge_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect4_Behavior_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect5_Access_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect6_Employment_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect6b_NFE_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect6c_OtherIncome_r2.dta", keep(match) nogenerate	
	merge 1:1 		HHID using "$export/wave_02/sect7_Income_Loss_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect8_food_security_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect9_Concerns_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$export/wave_02/sect10_Coping_r2.dta", keep(match) nogenerate	
	merge 1:1 		HHID using "$export/wave_02/sect11_Safety_Nets_r2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect12_Interview_Result_r2.dta", keep(match) nogenerate

* generate round variable
	gen				wave = 2
	lab var			wave "Wave number"
	
* save temp file
	save			"$root/wave_02/r2_sect_all", replace		
	
* ***********************************************************************
* 2c - build malawi panel 
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_all.dta", ///
						clear

* append round 2 of the data
	append 			using "$root/wave_02/r2_sect_all", ///
						force	
	order			wave, after(HHID)

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
	replace			gov_pers_01 = s3q8_1 if wave == 2 & gov_pers_01 == . 
	replace 		gov_pers_02 = s3q8_2 if wave == 2 & gov_pers_02 == . 
	replace			gov_pers_03 = s3q8_3 if wave == 2 & gov_pers_03 == . 
	replace 		gov_pers_04 = s3q8_4 if wave == 2 & gov_pers_04 == . 	
	replace			gov_pers_05 = s3q8_5 if wave == 2 & gov_pers_05 == . 
	rename 			s3q8_6 gov_pers_06
	rename 			s3q8_7 ngo_pers_01 
	rename 			s3q8_8 gov_pers_07 
	
	rename 			s3q13 bribe 
	rename 			s3q14__0 dis_gov_act_01
	rename 			s3q14__1 dis_gov_act_02
	rename 			s3q14__2 dis_gov_act_03
	rename 			s3q14__4 dis_gov_act_04
	rename 			s3q15 comm_lead
	
*** BEHAVIOR

	rename			s4q1 bh_01
	rename			s4q2a bh_02
	rename			s4q3a bh_06
	rename 			s4q3b bh_06a
	rename 			s4q4 bh_03
	rename			s4q5 bh_04
	rename			s4q6 bh_05 	
	
*** ACCESS 
* round 2 access differs from round 1 access 
	
	rename 			s4q7 freq_washsoap 
	rename 			s4q8 freq_mask

	rename 			s5q1a1 ac_soap_need
	rename 			s5q1b1 ac_soap 
	generate		ac_soap_why = . 
	replace			ac_soap_why = 1 if s5q1c1__1 == 1 
	replace 		ac_soap_why = 2 if s5q1c1__2 == 1
	replace 		ac_soap_why = 3 if s5q1c1__3 == 1
	replace 		ac_soap_why = 4 if s5q1c1__4 == 1
	replace 		ac_soap_why = 5 if s5q1c1__5 == 1
	replace 		ac_soap_why = 6 if s5q1c1__6 == 1
	* number changes for responses in R2 
	replace			ac_soap_why = 1 if s5q1b1__1 == 1 
	replace 		ac_soap_why = 2 if s5q1b1__2 == 1
	replace 		ac_soap_why = 3 if s5q1b1__3 == 1
	replace 		ac_soap_why = 4 if s5q1b1__4 == 1
	replace 		ac_soap_why = 5 if s5q1b1__5 == 1
	replace 		ac_soap_why = 6 if s5q1b1__6 == 1
	replace 		ac_soap_why = 7 if s5q1b1__7 == 1
	replace 		ac_soap_why = 8 if s5q1b1__8 == 1
	replace 		ac_soap_why = 9 if s5q1b1__9 == 1 

	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" /// 
								4 "restrictions to go out" 5 "increase in price" 6 "no money" /// 
								7 "cannot afford" 8 "afraid to go out" 9 "other"								
	label var 		ac_soap_why "reason for unable to purchase soap"
								
	rename 			s5q1a2 ac_water
	replace 		ac_water = s5q1a2_1 if wave == 2 & ac_water == . 
	rename 			s5q1b2 ac_water_why
	replace 		ac_water_why = s5q1a2_2 if wave == 2 & ac_water == . 

	generate		ac_wash_why = . 
	replace			ac_wash_why = 1 if s5q1b2__1 == 1 
	replace 		ac_wash_why = 2 if s5q1b2__4 == 1
	replace 		ac_wash_why = 3 if s5q1c1__3 == 1
	replace 		ac_wash_why = 4 if s5q1c1__4 == 1
	replace 		ac_wash_why = 5 if s5q1b2__5 == 1
	
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
	replace 		acserv_med = s5q5 if wave == 2 & acserv_med == . 
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
	rename 			s5q6__6 edu_06
	rename 			s5q6__7 edu_07
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
	
	rename 			s5q12 internet7 
	rename 			s5q13 internet7_diff
	
*** EMPLOYMENT 

	rename			s6q1a edu
	rename			s6q1 emp
	rename			s6q2 emp_pre
	replace 		emp_pre = s6q2_1 if wave == 2 & emp_pre == . 
	rename			s6q3a emp_pre_why 
	replace 		emp_pre_why = s6q3a_1 if wave == 2 & emp_pre == .
	rename			s6q3b emp_pre_pay
	replace 		emp_pre_pay = s6q3b_1 if wave == 2 & emp_pre_pay == .	
	rename			s6q4a emp_same
	replace 		emp_same = s6q4a_1 if wave == 2 & emp_same == .	
	rename 			s6q1b emp_ret 
	rename			s6q4b emp_chg_why
	replace 		emp_chg_why = s6q4b_1 if wave == 2 & emp_chg_why == . 
	rename			s6q4c emp_pre_actc
	rename			s6q5 emp_act
	rename 			s6q4c_1 emp_pre_act 
	rename			s6q6 emp_stat
	replace 		emp_stat = s6q6_1 if wave == 2 & emp_stat == . 
	rename			s6q7 emp_able
	replace 		emp_able = s6q7_1 if wave == 2 & emp_able == . 
	rename			s6q8 emp_unable	
	replace 		emp_unable = s6q8_1 if wave == 2 & emp_unable == . 
	rename			s6q8a emp_unable_why	
	replace 		emp_unable_why = s6q8_1 if wave == 2 & emp_unable_why == . 
	rename			s6q8b__1 emp_cont_01
	replace 		emp_cont_01 = s6q8b_1__1 if emp_cont_01 == . & wave == 2
	rename			s6q8b__2 emp_cont_02
	replace 		emp_cont_02 = s6q8b_1__2 if emp_cont_02 == . & wave == 2
	rename			s6q8b__3 emp_cont_03
	replace 		emp_cont_03 = s6q8b_1__3 if emp_cont_03 == . & wave == 2
	rename			s6q8b__4 emp_cont_04
	replace 		emp_cont_04 = s6q8b_1__4 if emp_cont_04 == . & wave == 2
	rename			s6q8c__1 contrct
	replace 		contrct = s6q8c_1__1 if contrct == . & wave == 2 
	rename			s6q9 emp_hh
	replace 		emp_hh = s6q9_1 if emp_hh = . & wave == 2
	rename			s6q11 bus_emp
	rename			s6q12 bus_sect
	rename			s6q13 bus_emp_inc
	rename			s6q14 bus_why
	rename			s6q15 farm_emp 
	replace 		farm_emp = s6q15_1 if farm_emp == . & wave == 2
	rename			s6q16 farm_norm
	replace 		farm_norm = s6q16 if farm_norm == . & wave == 2
	rename			s6q17__1 farm_why_01
	replace 		farm_why_01 = s6q17_1__1 if farm_why_01 == . & wave == 2
	rename			s6q17__2 farm_why_02
	replace 		farm_why_02 = s6q17_1__2 if farm_why_02 == . & wave == 2
	rename			s6q17__3 farm_why_03
	replace 		farm_why_03 = s6q17_1__3 if farm_why_03 == . & wave == 2
	rename			s6q17__4 farm_why_04
	replace 		farm_why_04 = s6q17_1__4 if farm_why_04 == . & wave == 2
	rename			s6q17__5 farm_why_05
	replace 		farm_why_05 = s6q17_1__5 if farm_why_05 == . & wave == 2
	rename			s6q17__6 farm_why_06
	replace 		farm_why_06 = s6q17_1__6 if farm_why_06 == . & wave == 2
	rename			s6q17__7 farm_why_07
	replace 		farm_why_07 = s6q17_1__7 if farm_why_07 == . & wave == 2
	rename 			s6q17_1__96 farm_why_other 

	rename 			s6q1_1 emp_7
	rename 			s6q3a_1a emp_search_month
	rename 			s6q3a_2a emp_search 
	rename 			s6q8d_1 emp_hours7
	rename 			s6q8e_1 emp_hoursmarch 
	
	rename 			
	 
	*** a few variables called *hidden? unsure of what they are 
	*** making a note - but will end up dropping for now?? 
	
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
	
* rename myths	
	rename			s3q2_1 myth_01
	rename			s3q2_2 myth_02
	rename			s3q2_3 myth_03
	rename			s3q2_4 myth_04
	rename			s3q2_5 myth_05
	
* create country variables
	gen				country = 2
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	 	    
* drop unneeded variables	
	drop 			hh_a16 hh_a17 result s5* *_os s13* *details  s6*  ///
					interview__key nbrbst s12* s11* s3* s5* 

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