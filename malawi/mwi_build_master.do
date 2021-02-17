* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm, amf
* Last edited: November 2020
* Stata v.16.1

* does
	* merges together each round
	* cleans data
	* outputs panel data

* assumes
	* raw malawi data 

* TO DO:
	* complete
	* when new waves available:
		* create build for new wave based on previous ones
		* update global list of waves below
		* check variable crosswalk for differences/new variables & update code if needed
		* check QC flags for issues/discrepancies

		
* **********************************************************************
* 0 - setup
* **********************************************************************

* define list of waves
	global 			waves "1" "2" "3" "4"
	
* define
	global	root	=	"$data/malawi/raw"
	global	export	=	"$data/malawi/refined"
	global	logout	=	"$data/malawi/logs"
	global  fies 	= 	"$data/analysis/raw/Malawi"

* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

    if `"`c(username)'"' == "aljosephson" {
        global 		code  	"C:/Users/aljosephson/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

	if `"`c(username)'"' == "annfu" {
		global 		code  	"C:/Users/annfu/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
	}
	
* open log
	cap log 		close
	log using		"$logout/mal_build", append
	

* ***********************************************************************
* 1 - run do files for each round & generate variable comparison excel
* ***********************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/malawi/mwi_build_`r'"
		ds
		clear
		set 		obs 1
		gen 		variables = ""
		local 		counter = 1
		foreach 	var in `r(varlist)' {
			replace variables = "`var'" in `counter'
			local 	counter = `counter' + 1
			set 	obs `counter'
			recast 	str30 variables
		}
		gen 		wave`r' = 1
		tempfile 	t`r'
		save 		`t`r''
	}
	use 			`t1',clear
	foreach 		r in "$waves" {
		merge 		1:1 variables using `t`r'', nogen
	}
	drop 			if variables == ""
	export 			excel using "$export/mwi_variable_crosswalk.xlsx", first(var) replace
	

* ***********************************************************************
* 2 - create malawi panel
* ***********************************************************************

* append round datasets to build master panel
	foreach 		r in "$waves" {
	    if 			`r' == 1 {
			use		"$export/wave_01/r1", clear
		}
		else {
			append 	using "$export/wave_0`r'/r`r'"
		}
	}

* merge in consumption aggregate
	merge m:1		y4_hhid using "$root/wave_00/Malawi IHPS 2019 Quintiles.dta"
	keep if			_merge == 3
	drop			_merge
	rename			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui
	
* create country variables
	gen				country = 2
	
* ***********************************************************************
* 3 - clean malawi panel
* ***********************************************************************	

* drop meta data
	drop			interview__key nbrbst s12q2 s12q3__0 s12q3__1 s12q3__2 ///
						s12q3__3 s12q3__4 s12q3__5 s12q3__6 s12q3__7 s12q4__0 ///
						s12q4__1 s12q4__2 s12q4__3 s12q5 s12q6 s12q7 s12q8 ///
						s12q9 s12q10 s12q10_os s12q11 s12q12 s12q13 s12q14

* income
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
	rename 			s7q196 oth_inc
	label 			var oth_inc "income from other source in last 12 months"
	rename			s7q296 oth_chg
	label 			var oth_chg "change in income from other source since covid"
	drop 			s7q199
	*** yes or no response to ``total income'' - unclear what this measures
	*** omit, but keep overall change
	rename			s7q299 tot_inc_chg
	label 			var tot_inc_chg "change in total income since covid"	
 
* assistance
	rename 			s11q11 asst_food
	replace			asst_food = 0 if asst_food == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	rename 			s11q12 asst_cash
	replace 		asst_cash = 0 if asst_cash == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	rename 			s11q13 asst_kind 
	replace			asst_kind = 0 if asst_kind == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist	

* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .

* shock variables	
 * need to make shock variables match uganda
	rename 			shock_9 shock_14
	rename 			shock_7 shock_12
	rename 			shock_3 shock_7
	rename 			shock_8 shock_3
	rename			shock_6 shock_11
	rename 			shock_5 shock_10
	rename 			shock_4 shock_16
	rename 			shock_2 shock_6
	rename 			shock_1 shock_5
	lab var			shock_5 "Job loss"
	lab var 		shock_3 "Injury or death of income earner"
	lab var			shock_6 "Non-farm business failure"
	lab var			shock_7 "Theft of crops, cash, livestock or other property"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items"
	lab var			shock_14 "Other shock"
	lab var 		shock_16 "Disruption of farming, livestock, fishing, etc."
	gen				shock_any = 1 if shock_5 == 1 | shock_6 == 1 | ///
					shock_7 == 1 | shock_16 == 1 | shock_10 == 1 | ///
					shock_11 == 1 | shock_12 == 1 | shock_3 == 1 | ///
					shock_14 == 1
	replace			shock_any = 0 if shock_any == . & (wave == 2 | wave == 3)
	lab var			shock_any "Experience some shock"
	
* cope variables
	rename			s10q3__1 cope_1
	rename			s10q3__6 cope_2
	rename			s10q3__7 cope_3
	rename			s10q3__8 cope_4
	rename			s10q3__9 cope_5
	rename			s10q3__11 cope_6
	rename			s10q3__12 cope_7
	rename			s10q3__13 cope_8
	rename			s10q3__14 cope_9
	rename			s10q3__15 cope_10
	rename			s10q3__16 cope_11
	rename			s10q3__17 cope_12
	rename			s10q3__18 cope_13
	rename			s10q3__19 cope_14
	rename			s10q3__20 cope_15
	rename			s10q3__21 cope_16
	rename			s10q3__96 cope_17
	lab var			cope_1 "Sale of assets (Agricultural and Non_agricultural)"
	lab var			cope_2 "Engaged in additional income generating activities"
	lab var			cope_3 "Received assistance from friends & family"
	lab var			cope_4 "Borrowed from friends & family"
	lab var			cope_5 "Took a loan from a financial institution"
	lab var			cope_6 "Credited purchases"
	lab var			cope_7 "Delayed payment obligations"
	lab var			cope_8 "Sold harvest in advance"
	lab var			cope_9 "Reduced food consumption"
	lab var			cope_10 "Reduced non_food consumption"
	lab var			cope_11 "Relied on savings"
	lab var			cope_12 "Received assistance from NGO"
	lab var			cope_13 "Took advanced payment from employer"
	lab var			cope_14 "Received assistance from government"
	lab var			cope_15 "Was covered by insurance policy"
	lab var			cope_16 "Did nothing"
	lab var			cope_17 "Other"
	
* affected variables
	rename			s10q2__1 elseaff_1
	rename			s10q2__2 elseaff_2
	rename			s10q2__3 elseaff_3
	rename			s10q2__4 elseaff_4
	rename			s10q2__5 elseaff_5
	lab var			elseaff_1 "just household affected by shock"
	lab var			elseaff_2 "famliy members outside household affected by shock"
	lab var			elseaff_3 "several hh in village affected by shock"
	lab var			elseaff_4 "most or all hhs in village affected by shock"
	lab var			elseaff_5 "several villages affected by shock"
	
* knowledge
	rename 			s3q1  know
	rename			s3q1a ac_internet
	rename			s3q2__1 know_1
	lab var			know_1 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s3q2__2 know_9
	lab var			know_9 "Use of Sanitizer Reduces Risk of Coronavirus Contraction"
	rename			s3q2__3 know_2
	lab var			know_2 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename 			s3q2__11 know_11
	label var 		know_11 "Cough Etiquette Reduces Risk of Coronavirus Contract"
	rename 			s3q2__4 know_3
	lab var			know_3 "Using Masks and/or Gloves Reduces Risk of Coronavirus Contraction"
	rename			s3q2__5 know_10
	lab var			know_10 "Using Gloves Reduces Risk of Coronavirus Contraction"
	rename			s3q2__6 know_4
	lab var			know_4 "Avoiding Travel Reduces Risk of Coronavirus Contraction"
	rename			s3q2__7 know_5
	lab var			know_5 "Staying at Home Reduces Risk of Coronavirus Contraction"
	rename			s3q2__8 know_6
	lab var			know_6 "Avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction"
	rename			s3q2__9 know_7
	lab var			know_7 "Mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Contraction"
	rename			s3q2__10 know_8
	lab var			know_8 "Avoiding Face Touching Reduces Risk of Coronavirus Contraction"
	
* govt steps
	rename 			s3q3__1 gov_1
	label var 		gov_1 "government taken steps to advise citizens to stay home"
	rename 			s3q3__2 gov_10
	label var 		gov_10 "government taken steps to advise to avoid social gatherings"
	rename 			s3q3__3 gov_2
	label var 		gov_2 "government restricted travel within country"
	rename 			s3q3__4 gov_3
	label var 		gov_3 "government restricted international travel"
	rename 			s3q3__5 gov_4
	label var 		gov_4 "government closure of schools and universities"
	rename 			s3q3__6 gov_5
	label var		gov_5 "government institute government / lockdown"
	rename 			s3q3__7 gov_6
	label var 		gov_6 "government closure of non-essential businesses"
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
 
* govt perseption
 * note: r1 has 5 step scale, r2 only 3 options, adjust here
	forval x = 8/12 {
		replace 		s3q`x' = . if s3q`x' == .a
		replace 		s3q`x' = 1 if s3q`x' < 3
		replace 		s3q`x' = 2 if s3q`x' == 3
		replace 		s3q`x' = 3 if s3q`x' > 3 & s3q`x' != .
	}
	rename 			s3q8_1 gov_pers_1
	rename 			s3q8_2 gov_pers_2
	rename 			s3q8_3 gov_pers_3
	rename 			s3q8_4 gov_pers_4
	rename 			s3q8_5 gov_pers_5
	rename 			s3q8_6 gov_pers_6
	rename 			s3q8_8 gov_pers_7
	replace 		gov_pers_1 = s3q8 if s3q8 != .
	replace 		gov_pers_2 = s3q9 if s3q9 != .
	replace 		gov_pers_3 = s3q10 if s3q10 != .
	replace 		gov_pers_4 = s3q11 if s3q11 != .
	replace 		gov_pers_5 = s3q12 if s3q12 != .
	forval 			x = 8/12 {
		drop 		s3q`x'
	}
 
* information
	rename			s3q4 info
	rename 			s3q5__1 info_1
	rename			s3q5__2 info_2
	rename 			s3q5__3 info_3
	rename 			s3q5__4 info_4
	rename 			s3q5__5 info_5
	rename 			s3q5__6	info_6
	rename 			s3q5__7 info_7
	rename 			s3q5__8 info_8
	rename 			s3q5__9	info_9
	rename 			s3q5__10 info_10
	rename 			s3q5__11 info_11
	rename 			s3q5__12 info_12
	rename 			s3q5__13 info_13
	
* myths
	rename			s3q2_1 myth_1
	rename			s3q2_2 myth_2
	rename			s3q2_3 myth_3
	rename			s3q2_4 myth_4
	rename			s3q2_5 myth_5
	
* satisfaction + government perspectives
	rename 			s3q6 satis
	rename 			s3q7__1 satis_1
	rename			s3q7__2 satis_2
	rename 			s3q7__3 satis_3
	rename 			s3q7__4 satis_4
	rename 			s3q7__5 satis_5
	rename 			s3q7__6 satis_6
	rename 			s3q7__96 satis_7
	rename 			s3q7_os satis_7_details
	rename 			s3q8_7 ngo_pers_1	
	rename 			s3q13 bribe
	rename 			s3q14__0 dis_gov_act_1
	rename 			s3q14__1 dis_gov_act_2
	rename 			s3q14__2 dis_gov_act_3
	rename 			s3q14__3 dis_gov_act_4
	rename 			s3q14__4 dis_gov_act_5
	rename 			s3q15 comm_lead
	
* behavior
	rename			s4q1 bh_1
	rename			s4q2a bh_2
	rename			s4q3a bh_6
	rename 			s4q3b bh_6a
	rename 			s4q3c bh_6b
	rename 			s4q4 bh_3
	rename			s4q5 bh_4
	rename			s4q6 bh_5
	replace 		bh_5 = 7 if bh_5 == 1 & wave > 2
	replace 		bh_5 = 1 if (bh_5 == 2 | bh_5 == 3) & wave > 2
	replace 		bh_5 = 2 if bh_5 == 7
	replace 		bh_5 = . if bh_5 == 4
	rename			s4q7 bh_7
	rename			s4q8 bh_8
	rename 			s4q9 bh_comply_1
	rename 			s4q10 bh_comply_2
	rename 			s4q11 bh_comply_3
	rename 			s4q12 bh_comply_4
	 
* access
 * soap
	rename 			s5q1a1 ac_soap_need
	rename 			s5q1b1 ac_soap
	gen				ac_soap_why = .
	replace			ac_soap_why = 1 if s5q1c1__1 == 1 | s5q1b1__1 == 1
	replace 		ac_soap_why = 2 if s5q1c1__2 == 1 | s5q1b1__2 == 1
	replace 		ac_soap_why = 3 if s5q1c1__3 == 1 | s5q1b1__3 == 1
	replace 		ac_soap_why = 4 if s5q1c1__4 == 1 | s5q1b1__4 == 1
	replace 		ac_soap_why = 5 if s5q1c1__5 == 1 | s5q1b1__5 == 1
	replace 		ac_soap_why = 6 if s5q1c1__6 == 1 | s5q1b1__6 == 1
	replace 		ac_soap_why = 7 if s5q1b1__7 == 1
	replace 		ac_soap_why = 8 if s5q1b1__8 == 1
	replace 		ac_soap_why = 9 if s5q1b1__9 == 1
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "cannot afford" 8 "afraid to go out" 9 "other"
	lab val 		ac_soap_why ac_soap_why
	lab var 		ac_soap_why "reason unable to purchase soap"
	order			ac_soap_why, after(ac_soap_need)
	drop			s5q1b1__1 s5q1b1__2 s5q1b1__3 s5q1b1__4 s5q1b1__5 ///
						s5q1b1__6 s5q1b1__7 s5q1b1__8 s5q1b1__9 s5q1b1__99

 * clean
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
	lab val 		ac_clean_why ac_clean_why
	lab var 		ac_clean_why "reason for unable to purchase cleaning supplies"
		
 * water
	rename 			s5q1a2 ac_water
	replace 		ac_water = ac_water - 1
	lab var 		ac_water "was your household able to access water"
	rename 			s5q1b2 ac_water_why	
	replace			ac_water_why = 1 if s5q1b2__1 == 1
	replace 		ac_water_why = 2 if s5q1b2__2 == 1
	replace 		ac_water_why = 3 if s5q1b2__3 == 1
	replace 		ac_water_why = 4 if s5q1b2__4 == 1
	replace 		ac_water_why = 5 if s5q1b2__5 == 1
	replace 		ac_water_why = 12 if ac_water_why == 1
	replace 		ac_water_why = 13 if ac_water_why == 2
	replace 		ac_water_why = 14 if ac_water_why == 3
	replace 		ac_water_why = 8 if ac_water_why == 4
	replace 		ac_water_why = 15 if ac_water_why == 5
	lab def 		ac_water_why 1 "water supply not available" 2 "water supply reduced" ///
					3 "unable to access communal supply" 4 "unable to access water tanks" ///
					5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
					8 "restriction to go out" 9 "increase in price" 10 "cannot afford" ///
					11 "afraid to get viurs" 12 "water source too far" ///
					13 "too many people at water source" 14 "large household size" ///
					15 "lack of money", replace
	lab val 		ac_water_why ac_water_why 
	lab var 		ac_water_why "reason unable to access water for washing hands"
	rename			s5q1a2_1 ac_drink
	rename			s5q1a2_2 ac_drink_why
	replace 		ac_drink_why = 95 if ac_drink_why == 6
	replace 		ac_drink_why = 10 if ac_drink_why == 4
	lab def 		ac_drink_why 1 "water supply not available" 2 "water supply reduced" ///
					3 "unable to access communal supply" 4 "unable to access water tanks" ///
					5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
					8 "restriction to go out" 9 "increase in price" 10 "cannot afford"
	lab val 		ac_drink_why ac_drink_why
	lab val 		ac_drink_why ac_drink_why
	
 * staple
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
	lab val 		ac_staple_why ac_staple_why
	lab var 		ac_staple_why "reason for unable to purchase staple food"
	
 * maize	
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
	lab val 		ac_maize_why ac_maize_why
	lab var 		ac_maize_why "reason unable to purchase maize"
	lab var			ac_maize_need "Since 20th March, did you or anyone in your household need to buy maize?"
	lab var			ac_maize "Were you or someone in your household able to buy maize"

 * medicine
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
	lab val 		ac_med_why ac_med_why 
	lab var 		ac_med_why "reason unable to purchase medicine"

 * medical services
	rename 			s5q3 ac_medserv_need
	rename 			s5q4 ac_medserv
	rename 			s5q5 ac_medserv_why
	replace 		ac_medserv_why = . if ac_medserv_why == 4 | ac_medserv_why == 8
	replace 		ac_medserv_why = 8 if ac_medserv_why == 7
	replace 		ac_medserv_why = 7 if ac_medserv_why == 6
	replace 		ac_medserv_why = 6 if ac_medserv_why == 5
	replace			ac_medserv_why = 1 if s5q5__1 == 1
	replace 		ac_medserv_why = 2 if s5q5__2 == 1
	replace 		ac_medserv_why = 3 if s5q5__3 == 1
	replace 		ac_medserv_why = 6 if s5q5__5 == 1
	replace 		ac_medserv_why = 7 if s5q5__6 == 1
	replace 		ac_medserv_why = 8 if s5q5__7 == 1
	lab def			ac_medserv_why 1 "lack of money" 2 "no med personnel" 3 "facility full" ///
								4 "facility closed" 5 "not enough supplies" ///
								6 "lack of transportation" 7 "restriction to go out" ///
								8 "afraid to get virus"
	lab val 		ac_medserv_why ac_medserv_why
	lab var 		ac_medserv_why "reason unable to access medical services"

 * post/pre natal care
	rename 			filter1_sec5 ac_nat_filter
	rename 			s5q2_2a ac_nat_need
	rename 			s5q2_2b ac_nat
	forval 			x = 1/6 {
		rename 		s5q2_2c__`x' ac_nat_why_`x'
	}
	lab var 		ac_nat_why_6 "..not able to access pre/post-natal care: REFUSED TREATMENT BY FACILITY"
 * preventative care
	rename 			s5q2_2d ac_prev_app
	rename 			s5q2_2e ac_prev_canc
	replace 		ac_prev_canc = 0 if ac_prev_canc == 3
	lab def 		ac_prev_canc 0 "NO" 1 " YES, HAD APPOINTMENT THAT WAS CANCELED" ///
					2 "YES, WAS PLANNING TO GO BUT DID NOT"
	lab val 		ac_prev_canc ac_prev_canc
	forval 			x = 1/9 {
	    rename 		s5q2_2f__`x' ac_prev_why_`x'
	}
 * vaccines
	rename 			s5q2_2j ac_vac_need
	rename 			s5q2_2k ac_vac
	rename 			s5q2_2l ac_vac_why
	
 * credit 
	rename 			ac_cr_lend_1 ac_cr_lend_11
	rename 			ac_cr_lend_2 ac_cr_lend_12
	rename 			ac_cr_lend_7 ac_cr_lend_13
	rename 			ac_cr_lend_8 ac_cr_lend_14
	rename 			ac_cr_lend_3 ac_cr_lend_7
	rename 			ac_cr_lend_4 ac_cr_lend_8
	rename 			ac_cr_lend_5 ac_cr_lend_1
	rename 			ac_cr_lend_6 ac_cr_lend_4
	
 * order access variables	
	order			ac_soap_need ac_soap ac_soap_why ac_water ac_water_why ///
					ac_clean_need ac_clean ac_clean_why ac_staple_def ///
					ac_staple_need ac_staple ac_staple_why ac_maize_need ///
					ac_maize ac_maize_why ac_med_need ac_med ac_med_why ///
					ac_medserv_need ac_medserv ac_medserv_why, after(bh_5)

* education
	rename 			filter1 children618
	replace 		children618 = filter2_sec5 if children618 == .
	rename 			s5q6a sch_child

	rename 			s5q6b sch_child_meal
	rename 			s5q6c sch_child_mealskip
	rename 			s5q6d edu_act
	rename 			s5q6__1 edu_1
	rename 			s5q6__2 edu_2
	rename 			s5q6__3 edu_3
	rename 			s5q6__4 edu_4
	rename 			s5q6__5 edu_5
	rename 			s5q6__6 edu_6
	rename 			s5q6__7 edu_7
	rename 			s5q6__96 edu_other
	rename 			s5q7 edu_cont
	rename			s5q8__1 edu_cont_1
	rename 			s5q8__2 edu_cont_2
	rename 			s5q8__3 edu_cont_3
	rename 			s5q8__4 edu_cont_4
	rename 			s5q8__5 edu_cont_5
	rename 			s5q8__6 edu_cont_6
	rename 			s5q8__7 edu_cont_7
	rename 			s5q8__8 edu_cont_8
	rename 			s5q9 ac_bank_need
	rename 			s5q10 ac_bank
	rename 			s5q11 ac_bank_why
	rename 			s5q12 ac_internet_able
	rename 			s5q13 ac_internet_qual	
	rename 			s5q17 sch_open 
	gen 			sch_open_act = sch_open if wave > 3
	lab def 		sch_open_act 1 "yes, they returned" 2 "no, they will return next phase" ///
					3 "no, they will not return" 4 "not sure" 5 "children do not attend school"
	lab val 		sch_open_act sch_open_act
	replace 		sch_open = . if wave > 3
	rename 			s5q17a sch_open_why	
	rename 			s5q18 edu_meas
	rename 			s5q19 edu_meas_sat
	
* employment
	rename			s6q1 emp	
	rename			s6q1a edu
	replace			emp = s6q1_1 if emp == .
	rename			s6q8d_1 emp_hrs
	rename			s6q8e_1 emp_hrs_chg
	rename			s6q3a_1a find_job
	rename			s6q3a_2a find_job_do
	rename			s6q4_1 find_job_act
	rename 			working_last emp_last
	
 * same respondant employment
 	rename			s6q1b rtrn_when
	replace			emp_same = s6q4a_1b if s6q4a_1b != .
	replace			emp_chg_why = s6q4b if s6q4b != .
	replace			emp_act = s6q5 if s6q5 != .
	replace 		emp_act = -96 if emp_act == 96
	replace			emp_stat = s6q6 if s6q6 != .
	replace			emp_able = s6q7 if s6q7 != .
	replace			emp_unable = s6q8 if s6q8 != .
	replace			emp_unable_why = s6q8a if s6q8a != .
	replace			emp_hrs = s6q8b if s6q8b != .
	replace			emp_hrs_chg = s6q8c if s6q8c != .
	replace			emp_cont_1 = s6q8d__1 if s6q8d__1 != .
	replace			emp_cont_2 = s6q8d__2 if s6q8d__2 != .
	replace			emp_cont_3 = s6q8d__3 if s6q8d__3 != .
	replace			emp_cont_4 = s6q8d__4 if s6q8d__4 != .
	replace			contrct = s6q8e__1 if s6q8e__1 != . & contrct == .
	replace			emp_hh = s6q9 if s6q9 != .
	replace			find_job = s6q3a if s6q3a != .
	replace			find_job_do = s6q3b if s6q3b != .
	gen				rtrn_emp_why = 1 if s6q1c__1 == 1
	replace			rtrn_emp_why = 2 if s6q1c__2 == 1
	replace			rtrn_emp_why = 3 if s6q1c__3 == 1
	replace			rtrn_emp_why = 4 if s6q1c__4 == 1
	replace			rtrn_emp_why = 5 if s6q1c__5 == 1
	replace			rtrn_emp_why = 6 if s6q1c__6 == 1
	replace			rtrn_emp_why = 7 if s6q1c__7 == 1
	replace			rtrn_emp_why = 8 if s6q1c__8 == 1
	replace			rtrn_emp_why = 9 if s6q1c__9 == 1
	replace			rtrn_emp_why = 10 if s6q1c__10 == 1
	replace			rtrn_emp_why = 11 if s6q1c__11 == 1
	replace			rtrn_emp_why = 12 if s6q1c__12 == 1
	replace			rtrn_emp_why = 13 if s6q1c__13 == 1
	replace			rtrn_emp_why = 14 if s6q1c__96 == 1
	replace			rtrn_emp_why = 1 if s6q3__1 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 2 if s6q3__2 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 3 if s6q3__3 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 4 if s6q3__4 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 5 if s6q3__5 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 6 if s6q3__6 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 7 if s6q3__7 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 8 if s6q3__8 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 9 if s6q3__9 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 10 if s6q3__10 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 11 if s6q3__11 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 12 if s6q3__12 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 13 if s6q3__13 == 1 & rtrn_emp_why == .
	replace			rtrn_emp_why = 14 if s6q3__96 == 1 & rtrn_emp_why == .
	lab def			rtrn_emp_why 1 "Business closed due to legal restrictions" ///
								 2 "Business closed for other reasons" 3 "Laid off" ///
								 4 "Furloughed" 5 "Vacation" 6 "Ill/Quarantined" ///
								 7 "Caregiving" 8 "Seasonal worker" 9 "Retired" ///
								 10 "Unable to farm due to legal restrictions" ///
								 11 "Unable to farm due to lack of inputs" ///
								 12 "Not farming season" 13 "COVID rotation" ///
								 14 "Other"
	lab val			rtrn_emp_why rtrn_emp_why
	lab var 		rtrn_emp_why "Why did you not work last week"
	order			rtrn_emp_why, after(rtrn_when)

	rename			s6bq11a_1 bus_stat
	replace			bus_stat = s6bq11a_2 if bus_stat == .
	replace			bus_stat = s6bq11a_3 if bus_stat == .
	rename			s6bq11b bus_stat_why
	gen				bus_chlng_fce = 1 if s6qb15__1 == 1
	replace			bus_chlng_fce = 2 if s6qb15__2 == 1
	replace			bus_chlng_fce = 3 if s6qb15__3 == 1
	replace			bus_chlng_fce = 4 if s6qb15__4 == 1
	replace			bus_chlng_fce = 5 if s6qb15__5 == 1
	replace			bus_chlng_fce = 6 if s6qb15__6 == 1
	replace			bus_chlng_fce = 7 if s6qb15__7 == 1
	lab def			bus_chlng_fce 1 "Difficulty buying and receiving supplies and inputs" ///
								  2 "Difficulty raising money for the business" ///
								  3 "Difficulty repaying loans or other debt obligations" ///
								  4 "Difficulty paying rent for business location" ///
								  5 "Difficulty paying workers" ///
								  6 "Difficulty selling goods or services to customers" ///
								  7 "Other"
	lab val			bus_chlng_fce bus_chlng_fce
	order			bus_chlng_fce, after(bus_why)

	drop			s6bq11a_2 s6bq11a_3 s6q14b_os s6qb15__1 s6qb15__2 ///
						s6qb15__3 s6qb15__4 s6qb15__5 s6qb15__6 s6qb15__7 ///
						s6bq15_ot
	rename			s6bq15a bus_cndct
	gen				bus_cndct_how = 1 if s6bq15b__1 == 1
	replace			bus_cndct_how = 1 if s6bq15b__2 == 1
	replace			bus_cndct_how = 1 if s6bq15b__3 == 1
	replace			bus_cndct_how = 1 if s6bq15b__4 == 1
	replace			bus_cndct_how = 1 if s6bq15b__5 == 1
	replace			bus_cndct_how = 1 if s6bq15b__6 == 1
	replace			bus_cndct_how = 1 if s6bq15b__96 == 1
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
	drop			s6bq15b__1 s6bq15b__2 s6bq15b__3 s6bq15b__4 s6bq15b__5 ///
						s6bq15b__6 s6bq15b__96
	rename 			s6bq15c bus_oth_curr
	rename 			s6bq15d bus_num_curr
	rename			s6cq1 oth_inc_1
	lab var 		oth_inc_1 "Other Income: Remittances from abroad"
	rename			s6cq2 oth_inc_2
	lab var 		oth_inc_2 "Other Income: Remittances from family in the country"
	rename			s6cq3 oth_inc_3
	lab var 		oth_inc_3 "Other Income: Assistance from non-family"
	rename			s6cq4 oth_inc_4
	lab var 		oth_inc_4 "Other Income: Income from properties, investments, or savings"
	rename			s6cq5 oth_inc_5
	lab var 		oth_inc_5 "Other Income: Pension"
	
* concern 
	rename			s9q1 concern_1
	rename			s9q2 concern_2
	rename			s9q3 have_symp
	replace 		have_symp = cond(s9q3__1 == 1 | s9q3__2 == 1 | s9q3__3 == 1 | ///
						s9q3__4 == 1 | s9q3__5 == 1 | s9q3__6 == 1 | ///
						s9q3__7 == 1 | s9q3__8 == 1, 1, cond( ///
						s9q3__1 == 0 & s9q3__2 == 0 & s9q3__3 == 0 & ///
						s9q3__4 == 0 & s9q3__5 == 0 & s9q3__6 == 0 & ///
						s9q3__7 == 0 & s9q3__8 == 0, 2, .)) if have_symp !=.
		lab var			have_symp "Has anyone in your hh experienced covid symptoms?:cough/shortness of breath etc."
	drop			s9q3__1 s9q3__2 s9q3__3 s9q3__4 s9q3__5 s9q3__6 s9q3__7 s9q3__8
	rename 			s9q4 have_test
	rename 			s9q5 concern_3
	rename			s9q6 concern_4
	lab var			concern_4 "Response to the COVID-19 emergency will limit my rights and freedoms"
	rename			s9q7 concern_5
	lab var			concern_5 "Money and supplies allocated for the COVID-19 response will be misused and captured by powerful people in the country"
	rename			s9q8 concern_6
	lab var			concern_6 "Corruption in the government has lowered the quality of medical supplies and care"
	rename 			s9q9 symp_call
	
* agriculture
	rename			s13q1 ag_crop
	rename			s13q2a ag_crop_1
	rename			s13q2b ag_crop_2
	rename			s13q2c ag_crop_3
	rename			s13q3 ag_prog
	rename 			s13q4 ag_chg
	rename			s13q5__1 ag_chg_8
	lab var 		ag_chg_8 "activities affected - covid measures"
	rename			s13q5__2 ag_chg_9
	lab var 		ag_chg_9 "activities affected - could not hire"
	rename			s13q5__3 ag_chg_10
	lab var   		ag_chg_10 "activities affected - hired fewer workers"
	rename			s13q5__4 ag_chg_11
	lab var 		ag_chg_11 "activities affected - abandoned crops"
	rename			s13q5__5 ag_chg_7
	lab var 		ag_chg_7 "activities affected - delayed harvest"
	rename			s13q5__7 ag_chg_12
	lab var 		ag_chg_12 "activities affected - early harvest"
	rename			s13q6__1 ag_covid_chg_why_1
	rename 			s13q6__2 ag_covid_chg_why_2
	rename 			s13q6__3 ag_covid_chg_why_3
	rename			s13q6__4 ag_covid_chg_why_4
	rename			s13q6__5 ag_covid_chg_why_5
	rename 			s13q6__6 ag_covid_chg_why_6
	rename 			s13q6__7 ag_covid_chg_why_7
	rename 			s13q6__8 ag_covid_chg_why_8
	rename 			s13q7 ag_hire_chg_why
	rename 			s13q8 ag_ext_need
	rename 			s13q9 ag_ext
	rename			s13q10 ag_live
	replace 		ag_live = s6qf1 if ag_live == . & s6qf1 != .
	forval 			x = 1/11 {
		rename 		s6qf2__`x' ag_live_`x'
	}
	rename			s13q11 ag_live_chg
	replace 		ag_live_chg = s6qf3 if ag_live_chg == . & s6qf3 != . 
	rename			s13q12__1 ag_live_chg_1
	rename			s13q12__2 ag_live_chg_2
	rename			s13q12__3 ag_live_chg_3
	rename			s13q12__4 ag_live_chg_4
	rename			s13q12__5 ag_live_chg_5
	rename			s13q12__6 ag_live_chg_6
	rename			s13q12__7 ag_live_chg_7
	rename			s13q13 ag_sold
	rename			s13q14 ag_sell_wk
	rename 			s13q15 ag_price	
	rename			s6qe1 ag_sell_seas
	forval 			x = 1/12 {
		rename 		s6qe2__`x' ag_sold_`x'
	}
	rename 			s6qe3 ag_sold_why
	forval 			x = 1/4 {
		rename 		s6qe4__`x' ag_sold_where_`x'
	}
	rename 			s6qe5 ag_dimba
	forval 			x = 1/12 {
		rename 		s6qe6__`x' ag_crop_pl_`x'
	}
	rename 			s6qe7 ag_sell_rev
	forval 			x = 1/6 {
		rename 		s6qf4__`x' ag_live_chg2_`x'
	}
	forval 			x = 1/3 {
		rename 			s6qf5__`x' ag_live_chg2_1_cope`x'
	}
	forval 			x = 1/3 {
		rename 			s6qf6__`x' ag_live_chg2_2_cope`x'
	}
	forval 			x = 1/4 {
		rename 			s6qf7__`x' ag_live_chg2_3_cope`x'
	}
	rename 			s6qf8 ag_sell_live_want
	rename 			s6qf9 ag_sell_live_able
	forval 			x = 1/5 {
		rename 			s6qf10__`x' ag_sell_live_nowhy`x'
	}
	rename 			s6qf11 ag_sell_live_rev
	
* fies
	rename			s8q1 fies_4
	lab var			fies_4 "Worried about not having enough food to eat"
	rename			s8q2 fies_5
	lab var			fies_5 "Unable to eat healthy and nutritious/preferred foods"
	rename			s8q3 fies_6
	lab var			fies_6 "Ate only a few kinds of food"
	rename			s8q4 fies_7
	lab var			fies_7 "Skipped a meal"
	rename			s8q5 fies_8
	lab var			fies_8 "Ate less than you thought you should"
	rename			s8q6 fies_1
	lab var			fies_1 "Ran out of food"
	rename			s8q7 fies_2
	lab var			fies_2 "Hungry but did not eat"
	rename			s8q8 fies_3
	lab var			fies_3 "Went without eating for a whole day"	
	
* drop unnecessary variables
 	drop			s5q1c3__1 s5q1c3__2 s5q1c3__3 s5q1c3__4 s5q1c3__5 s5q1c3__6 ///
						s5q11_os s5q2c__1 s5q2c__2 s5q2c__3 s5q2c__4 s5q2c__5 s5q2c__6 ///
						s5q2c__7 s5q2c__99 s5q1b2__1 s5q1b2__1 s5q1b2__3 s5q1b2__5 ///
						s5q1b2__99 s5q1b2__4 s5q1b2__2 s6q1_1 s6q3_os_1 ///
						s6q4_ot_1 s6q4b_os_1 s6q4c_os_1 filter2_sec5 ///
						s6q5_os_1 s6q8a_os_1 s6q8c_1__2 s6q8c_1__99 s6q10_1__0 ///
						s6q10_1__1 s6q10_1__2 s6q10_1__3 s6q17_1_ot s6q4a_1b  ///
						s6q4a_2b s6q4b s6q5 s6q6 s6q7 s6q8 s6q8a s6q8a_os ///
						s6q8b s6q8c s6q8d__1 s6q8d__2 s6q8d__3 s6q8d__4 ///
						s6q8e__1 s6q8e__2 s6q8e__99 s6q9 s6q10__0 s6q10__1 ///
						s6q10__2 s6q10__3 s6q3a s6q3b s6q1c__1 s6q1c__2 s6q1c__3 ///
						s6q1c__4 s6q1c__5 s6q1c__6 s6q1c__7 s6q1c__8 s6q1c__9 ///
						s6q1c__10 s6q1c__11 s6q1c__12 s6q1c__13 s6q1c__96 s6q1c_os ///
						s6q3__1 s6q3__2 s6q3__3 s6q3__4 s6q3__5 s6q3__6 s6q3__7 ///
						s6q3__8 s6q3__9 s6q3__10 s6q3__11 s6q3__12 s6q3__13 ///
						s6q3__96 s6q3_os hh_a16 hh_a17 result s5q1c1__* ///
						s5q1c4__* s5q2c__* s5q1c3__* s5q5__*  *_os ///
						s13q5_* s13q6_* *details  s6q8c__2 s6q8c__99 s6q10__* ///
						s5q17a_ot s5q1a2_2_oth s5q1b2_oth s5q2_2c__95 s5q2_2c_ot ///
						s5q2_2f__95 s5q2_2f_ot s6q3a_2a_os s6q3b_os ///
						s6qb12_os s6qb15__95 s6qb15_os s6dq2_Ot s6dq3_Ot ///
						s6dq4_Ot s6dq5_Ot s6dq11_ot s6q5a s6dq4__95 s6qe2__95 ///
						s6qe6__95 s6qe6_ot s6qe2_ot s6qe3_ot s6qe4__95 s6qe4_ot ///
						s6qf1 s6qf2__95 s6qf2_ot s6qf3 s6qf6__95 s6qf6_ot s6qf7__95 ///
						s6qf7_ot s6qf10__95 s6qf10_ot s6qf4__95 s6qf4_ot s6qf5__95 ///
						s6qf5_ot s6dq10_ot weight s2q9

* regional and sector information
	gen				sector = 2 if urb_rural == 1
	replace			sector = 1 if urb_rural == 2
	lab var			sector "Sector"
	lab def			sector 1 "Rural" 2 "Urban"
	lab var			sector "sector - urban or rural"
	drop			urb_rural
	order			sector, after(wave)


	gen 			region = 2000 + hh_a01
	replace			region = 17 if region == 100
	replace			region = 18 if region == 200
	replace 		region = 19 if region == 300
	lab def			region 2101 "Chitipa" 2102 "Karonga" 2103 "Nkhata Bay" 2104 ///
						"Rumphi" 2105 "Mzimba" 2106 "Likoma" 2107 "Mzuzu City" 2201 ///
						"Kasungu" 2202 "Nkhotakota" 2203 "Ntchisi" 2204 ///
						"Dowa" 2205 "Salima" 2206 "Lilongwe" 2207 ///
						"Mchinji" 2208 "Dedza" 2209 "Ntcheu" 2210 ///
						"Lilongwe City" 2301 "Mangochi" 2302 "Machinga" 2303 ///
						"Zomba" 2304 "Chiradzulu" 2305 "Blantyre" 2306 ///
						"Mwanza" 2307 "Thyolo" 2308 "Mulanje" 2309 ///
						"Phalombe" 2310 "Chikwawa" 2311 "Nsanje" 2312 ///
						"Balaka" 2313 "Neno" 2314 "Zomba City" 2315 ///
						"Blantyre City", replace
						
	lab val			region region
	drop			hh_a00 hh_a01
	order			region, after(sector)
	lab var			region "Region"

/*
* **********************************************************************
* 4 - QC check 
* **********************************************************************

* compare numerical variables to other rounds & flag if 25+ percentage points different
	tostring 		wave, replace
	ds, 			has(type numeric)
	foreach 		var in `r(varlist)' {
		preserve
		keep 		`var' wave
		destring 	wave, replace
		gen 		counter = 1
		collapse 	(sum) counter, by(`var' wave)
		reshape 	wide counter, i(`var') j(wave)
		drop 		if `var' == .
		foreach 	x in "$waves" {
			egen 	tot_`x' = total(counter`x')
			gen 	per_`x' = counter`x' / tot_`x'
		}
		keep 		per*
		foreach 	x in "$waves"  {
			foreach q in "$waves"  {
				gen flag_`var'_`q'`x' = 1 if per_`q' - per_`x' > .25 & per_`q' != . & per_`x' != .
			}
		}	
		keep 		*flag*

	* drop if all missing	
		foreach 	v of varlist _all {
			capture assert mi(`v')
			if 		!_rc {
				drop `v'
			}
		}
		gen 		n = _n
		tempfile 	temp`var'
		save 		`temp`var''
		restore   
	}
		
* create dataset of flags
	preserve
	ds, 			has(type numeric)
	clear
	set 			obs 15
	gen 			n = _n
	foreach 		var in `r(varlist)' {
		merge 		1:1 n using `temp`var'', nogen
	}
	reshape 		long flag_, i(n) j(variables) string 
	drop 			if flag_ == .
	drop 			n
	sort 			variable	
	export 			excel using "$export/mwi_qc_flags.xlsx", first(var) sheetreplace sheet(flags)
	restore
	destring 		wave, replace
*/

* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************

	drop 			interviewDate PID Above_18 HHID
	compress
	describe
	summarize

	rename 			y4_hhid hhid_mwi
	lab var			hhid_mwi "household ID malawi"

* save file
		customsave , idvar(hhid_mwi) filename("mwi_panel.dta") ///
			path("$export") dofile(mwi_build) user($user)

* close the log
	log	close

/* END */
