* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Edited by: jdm
* Last edited: 25 September 2020
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
	global  fies 	= 	"$data/analysis/raw/Malawi"

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
	use				"$root/wave_01/sect7_Income_Loss_r1", clear

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
	save			"$export/wave_01/sect7_Income_Loss_r1", replace

	
* ***********************************************************************
* 1b - reshape section on safety nets wide data - R1
* ***********************************************************************

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_01/sect11_Safety_Nets_r1", clear

* drop other
	drop 			s11q2 s11q3 s11q3_os

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safetyid)

* rename variables
	gen				asst_food = 1 if s11q11 == 1
	replace			asst_food = 0 if s11q11 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s11q12 == 1
	replace			asst_cash = 0 if s11q12 == 2
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s11q13 == 1
	replace			asst_kind = 0 if s11q13 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s11q11 s11q12 s11q13

* save new file
	save			"$export/wave_01/sect11_Safety_Nets_r1", replace


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

* load safety_net data - updated via convo with Talip 9/1
	use				"$root/wave_02/sect11_Safety_Nets_r2", clear

* reorganize difficulties variable to comport with section
	replace			s11q1 = 2 if s11q1 == .
	replace			s11q1 = 1 if s11q1 == .a

* drop other
	drop 			s11q2 s11q3 s11q3_os s11q4a s11q4b s11q5 s11q6__1 ///
						s11q6__2 s11q6__3 s11q6__4 s11q6__5 s11q6__6 ///
						s11q6__7 s11q7__1 s11q7__2 s11q7__3 s11q7__4 ///
						s11q7__5 s11q7__6 s11q7__7

* reshape
	reshape 		wide s11q1, i(y4_hhid HHID) j(social_safetyid)

* rename variables
	gen				asst_food = 1 if s11q11 == 1
	replace			asst_food = 0 if s11q11 == 2
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = 1 if s11q12 == 1 | s11q14 == 1 | s11q15 == 1
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if s11q13 == 1
	replace			asst_kind = 0 if s11q13 == 2
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist

* drop variables
	drop			s11q11 s11q12 s11q13 s11q14 s11q15

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

* generate any shock variable
	gen				shock_any = 1 if shock_05 == 1 | shock_06 == 1 | ///
						shock_07 == 1 | shock_16 == 1 | shock_10 == 1 | ///
						shock_11 == 1 | shock_12 == 1 | shock_03 == 1 | ///
						shock_14 == 1
	replace			shock_any = 0 if shock_any == .
	lab var			shock_any "Experience some shock"
	
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
* 1f - get respondant gender - R1
* ***********************************************************************

* load data
	use				"$root/wave_01/sect12_Interview_Result_r1", clear

* drop all but household respondant
	keep			HHID s12q9

	rename			s12q9 PID

	isid			HHID

* merge in household roster
	merge 1:1		HHID PID using "$root/wave_01/sect2_Household_Roster_r1.dta"

	keep if			_merge == 3

* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .

* drop all but gender and relation to HoH
	keep			HHID PID sex age relate_hoh

* save temp file
	save			"$export/wave_01/respond_r1", replace


* ***********************************************************************
* 1g - get respondant gender - R2
* ***********************************************************************

* load data
	use				"$root/wave_02/sect12_Interview_Result_r2", clear

* drop all but household respondant
	keep			HHID s12q9

	rename			s12q9 PID

	isid			HHID

* merge in household roster
	merge 1:1		HHID PID using "$root/wave_02/sect2_Household_Roster_r2.dta"

	keep if			_merge == 3

* rename variables and fill in missing values
	rename			s2q5 sex
	rename			s2q6 age
	rename			s2q7 relate_hoh
	replace			relate_hoh = s2q9 if relate_hoh == .

* drop all but gender and relation to HoH
	keep			HHID PID sex age relate_hoh

* save temp file
	save			"$export/wave_02/respond_r2", replace


* ***********************************************************************
* 1h - get household size and gender of HOH - R1
* ***********************************************************************

* load data
	use			"$root/wave_01/sect2_Household_Roster_r1.dta", clear

* rename other variables 
	rename 			PID ind_id 
	rename 			new_member new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
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
* 1i - get household size and gender of HOH - R2
* ***********************************************************************

* load data
	use			"$root/wave_02/sect2_Household_Roster_r2.dta", clear

* rename other variables 
	rename 			PID ind_id 
	rename 			new_member new_mem
	rename 			s2q3 curr_mem
	rename 			s2q5 sex_mem
	rename 			s2q6 age_mem
	rename 			s2q7 relat_mem	
	
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
* 1j - FIES score - R1
* ***********************************************************************

* load data
	use				"$fies/MW_FIES_round1.dta", clear

	drop 			country round

* save temp file
	save			"$export/wave_01/fies_r1", replace
	
* ***********************************************************************
* 1k - FIES score - R2
* ***********************************************************************


* load data
	use				"$fies/MW_FIES_round2.dta", clear

	drop 			country round 
	
* save temp file
	save			"$export/wave_02/fies_r2", replace

* ***********************************************************************
* 2 - build malawi panel R1 cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_01/secta_Cover_Page_r1", clear

* merge in other sections
	merge 1:1 		HHID using "$export/wave_01/respond_r1.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_01/hhsize_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect3_Knowledge_r1.dta",nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect4_Behavior_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect5_Access_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect6_Employment_r1.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_01/sect7_Income_Loss_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect8_food_security_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect9_Concerns_r1.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_01/sect11_Safety_Nets_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect12_Interview_Result_r1.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_01/sect13_Agriculture_r1.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_01/fies_r1.dta", nogenerate

* reformat HHID
	rename			HHID household_id_an
	label 			var household_id_an "32 character alphanumeric - str32"
	encode 			household_id_an, generate(HHID)
	label           var HHID "unique identifier of the interview"
	format 			%12.0f HHID
	order 			y4_hhid HHID household_id_an

* SEC 2: basic information
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

	gen 			region = 2000 + hh_a01
	replace			region = 17 if region == 100
	replace			region = 18 if region == 200
	replace 		region = 19 if region == 300
	lab def			region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
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
	lab val			region region
	drop			hh_a00 hh_a01
	order			region, after(sector)
	lab var			region "Region"

	rename			interviewDate start_date
	rename			Above_18 above18
	rename 			s3q1  know
	rename			s3q1a internet

* SEC 3: knowledge
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

* SEC 4: behavior
	rename			s4q1 bh_01
	rename			s4q2a bh_02
	rename			s4q3a bh_06
	rename 			s4q3b bh_06a
	rename 			s4q4 bh_03
	rename			s4q5 bh_04
	rename			s4q6 bh_05

* SEC 5: access
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
	lab var 		ac_soap_why "reason for unable to purchase soap"

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
	lab var 		ac_clean_why "reason for unable to purchase cleaning supplies"

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
	lab var 		ac_staple_why "reason for unable to purchase staple food"
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
	lab var 		ac_maize_why "reason for unable to purchase maize"
	lab var			ac_maize_need "Since 20th March, did you or anyone in your household need to buy maize?"
	lab var			ac_maize "Were you or someone in your household able to buy maize"

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
	lab var 		ac_med_why "reason for unable to purchase medicine"

	rename 			s5q3 ac_medserv_need
	rename 			s5q4 ac_medserv
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
	lab var 		ac_medserv_why "reason for unable to access medical services"


	order			ac_soap_need ac_soap ac_soap_why ac_water ac_water_why ///
						ac_clean_need ac_clean ac_clean_why ac_staple_def ///
						ac_staple_need ac_staple ac_staple_why ac_maize_need ///
						ac_maize ac_maize_why ac_med_need ac_med ac_med_why ///
						ac_medserv_need ac_medserv ac_medserv_why, after(bh_05)

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

* SEC 6A: employment
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

* SEC 8: fies
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

* SEC 9: concerns
	rename			s9q1 concern_01
	rename			s9q2 concern_02
	rename			s9q3 have_symp
	rename 			s9q4 have_test
	rename 			s9q5 concern_03

* SEC 6B: agriculture
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
	lab var			country "Country"

* drop unneeded variables
	drop 			hh_a16 hh_a17 result s5q1c1__* s5q1c4__* s5q2c__* s5q1c3__* ///
					s5q5__*  *_os s13q5_* s13q6_* *details  s6q8c__2 s6q8c__99 ///
					s6q10__*  interview__key nbrbst s12q2 s12q3__0 s12q3__* ///
					 s12q4__* s12q5 s12q6 s12q7 s12q8 s12q9 s12q10 s12q11 ///
					 s12q12 s12q13 s12q14

* save temp file
	save			"$root/wave_01/r1_sect_all", replace


* ***********************************************************************
* 3 - build malawi R2 cross section
* ***********************************************************************

* load cover data
	use				"$root/wave_02/secta_Cover_Page_r2", clear

* merge in other sections
	merge 1:1 		HHID using "$export/wave_02/respond_r2.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/hhsize_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect3_Knowledge_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect4_Behavior_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect5_Access_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect6_Employment_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect6b_NFE_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect6c_OtherIncome_r2.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/sect7_Income_Loss_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect8_food_security_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect9_Concerns_r2.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/sect10_Coping_r2.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/sect11_Safety_Nets_r2.dta", nogenerate
	merge 1:1 		HHID using "$root/wave_02/sect12_Interview_Result_r2.dta", nogenerate
	merge 1:1 		HHID using "$export/wave_02/fies_r2.dta", nogenerate

* generate round variable
	gen				wave = 2
	lab var			wave "Wave number"

	rename			wt_round2 phw
	label var		phw "sampling weights"
	
* reformat HHID
	rename			HHID household_id_an
	label 			var household_id_an "32 character alphanumeric - str32"
	encode 			household_id_an, generate(HHID)
	label           var HHID "unique identifier of the interview"
	format 			%12.0f HHID
	order 			y4_hhid HHID household_id_an

* drop meta data
	drop			interview__key nbrbst s12q2 s12q3__0 s12q3__1 s12q3__2 ///
						s12q3__3 s12q3__4 s12q3__5 s12q3__6 s12q3__7 s12q4__0 ///
						s12q4__1 s12q4__2 s12q4__3 s12q5 s12q6 s12q7 s12q8 ///
						s12q9 s12q10 s12q10_os s12q11 s12q12 s12q13 s12q14

* rename basic information
	rename			HHID household_id
	lab var			household_id "Household ID (Full)"

	order			y4_hhid wave, after(household_id)

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
	lab def			region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
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
	lab val			region region
	drop			hh_a00 hh_a01
	order			region, after(sector)
	lab var			region "Region"

	rename			interviewDate start_date
	rename			Above_18 above18

* SEC 3: knowledge

* rename myths
	rename			s3q2_1 myth_01
	rename			s3q2_2 myth_02
	rename			s3q2_3 myth_03
	rename			s3q2_4 myth_04
	rename			s3q2_5 myth_05

* gov / response agreement
	rename 			s3q8_1 gov_pers_01
	rename 			s3q8_2 gov_pers_02
	rename 			s3q8_3 gov_pers_03
	rename 			s3q8_4 gov_pers_04
	rename 			s3q8_5 gov_pers_05
	rename 			s3q8_6 gov_pers_06
	rename 			s3q8_7 ngo_pers_01
	rename 			s3q8_8 gov_pers_07

	rename			s3q9 sup_rcvd
	rename			s3q10 sup_cmpln
	rename			s3q11 sup_cmpln_who
	rename			s3q12 sup_cmpln_done

	rename 			s3q13 bribe
	rename 			s3q14__0 dis_gov_act_01
	rename 			s3q14__1 dis_gov_act_02
	rename 			s3q14__2 dis_gov_act_03
	rename 			s3q14__3 dis_gov_act_04
	rename 			s3q14__4 dis_gov_act_05
	rename 			s3q15 comm_lead

* SEC 4: behavior
	rename			s4q1 bh_01
	rename			s4q2a bh_02
	rename			s4q3a bh_06
	rename 			s4q4 bh_03
	rename			s4q5 bh_04
	rename			s4q6 bh_05
	rename			s4q7 bh_07
	rename			s4q8 bh_08

* SEC 5: access
	rename 			s5q1a1 ac_soap_need
	generate		ac_soap_why = .
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
	lab var 		ac_soap_why "Reason for unable to purchase soap"
	order			ac_soap_why, after(ac_soap_need)

	drop			s5q1b1__1 s5q1b1__2 s5q1b1__3 s5q1b1__4 s5q1b1__5 ///
						s5q1b1__6 s5q1b1__7 s5q1b1__8 s5q1b1__9 s5q1b1__99

	rename 			s5q1a2 ac_water
	generate		ac_water_why = .
	replace			ac_water_why = 1 if s5q1b2__1 == 1
	replace 		ac_water_why = 2 if s5q1b2__2 == 1
	replace 		ac_water_why = 3 if s5q1b2__3 == 1
	replace 		ac_water_why = 4 if s5q1b2__4 == 1
	replace 		ac_water_why = 5 if s5q1b2__5 == 1
	lab def			ac_water_why 1 "Water source too far " 2 "Too many people at the water source " ///
								 3 "Large household size" 4 "Restriction to go out" ///
								 5 "No money"
	lab var 		ac_water_why "Reason unable to access water for washing hands"
	order			ac_water_why, after(ac_water)

	drop			s5q1b2__1 s5q1b2__1 s5q1b2__3 s5q1b2__5 s5q1b2__99 ///
						s5q1b2__4 s5q1b2__2

	rename			s5q1a2_1 ac_drink
	rename			s5q1a2_2 ac_drink_why

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
	lab var 		ac_staple_why "Reason for unable to purchase staple food"
	order			ac_staple_why, after(ac_staple)

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
	lab var 		ac_maize_why "Reason for unable to purchase maize"
	lab var			ac_maize_need "Since 20th March, did you or anyone in your household need to buy maize?"
	lab var			ac_maize "Were you or someone in your household able to buy maize"
	order			ac_maize_need ac_maize ac_maize_why, after(ac_staple_why)

	drop			s5q2c__1 s5q2c__2 s5q2c__3 s5q2c__4 s5q2c__5 s5q2c__6 ///
						s5q2c__7 s5q2c__99

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
	lab var 		ac_med_why "Reason for unable to purchase medicine"
	order			ac_med_why, after(ac_med)

	drop			s5q1c3__1 s5q1c3__2 s5q1c3__3 s5q1c3__4 s5q1c3__5 s5q1c3__6 ///
						s5q11_os

	rename 			s5q3 ac_medserv_need
	rename 			s5q4 ac_medserv
	rename 			s5q5 ac_medserv_why
	lab var 		ac_med_why "Reason for unable to access medical services"

* education
	rename 			filter1 children618
	rename 			s5q6a sch_child
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
	rename 			s5q8__8 edu_cont_08

	rename 			s5q9 bank
	rename 			s5q10 ac_bank
	rename 			s5q11 ac_bank_why

	rename 			s5q12 internet7
	rename 			s5q13 internet7_diff

* SEC 6A: employment
	rename			s6q1 emp
	replace			emp = s6q1_1 if emp == .
	gen				emp_pre = s6q2_1 if s6q2_1 != .
	rename			s6q3a_1 emp_pre_why
	rename			s6q3b_1 emp_pre_act
	rename			s6q4a_1 emp_same
	rename			s6q4b_1 emp_chg_why
	rename			s6q4c_1 emp_pre_actc
	rename			s6q5_1 emp_act
	rename			s6q6_1 emp_stat
	rename			s6q7_1 emp_able
	rename			s6q8_1 emp_unable
	rename			s6q8a_1 emp_unable_why
	rename			s6q8b_1__1 emp_cont_01
	rename			s6q8b_1__2 emp_cont_02
	rename			s6q8b_1__3 emp_cont_03
	rename			s6q8b_1__4 emp_cont_04
	rename			s6q8c_1__1 contrct
	rename			s6q9_1 emp_hh
	rename			s6q15_1 farm_emp
	rename			s6q16_1 farm_norm
	rename			s6q17_1__1 farm_why_01
	rename			s6q17_1__2 farm_why_02
	rename			s6q17_1__3 farm_why_03
	rename			s6q17_1__4 farm_why_04
	rename			s6q17_1__5 farm_why_05
	rename			s6q17_1__6 farm_why_06
	rename			s6q17_1__96 farm_why_07
	rename			s6q17_1__7 farm_why_08

	rename			s6q8d_1 emp_hours
	rename			s6q8e_1 emp_hours_chg
	rename			s6q3a_1a find_job
	rename			s6q3a_2a find_job_do
	rename			s6q4_1 find_job_act

	drop			s6q1_1 s6q2_1 s6q3_os_1 s6q4_ot_1 s6q4b_os_1 s6q4c_os_1 ///
						s6q5_os_1 s6q8a_os_1 s6q8c_1__2 s6q8c_1__99 s6q10_1__0 ///
						s6q10_1__1 s6q10_1__2 s6q10_1__3 s6q17_1_ot

* same respondant employment
	rename			s6q1a rtrn_emp
	rename			s6q1b rtrn_when

	replace			emp_same = s6q4a_1b if s6q4a_1b != .
	replace			emp_chg_why = s6q4b if s6q4b != .
	replace			emp_act = s6q5 if s6q5 != .
	replace			emp_stat = s6q6 if s6q6 != .
	replace			emp_able = s6q7 if s6q7 != .
	replace			emp_unable = s6q8 if s6q8 != .
	replace			emp_unable_why = s6q8a if s6q8a != .
	replace			emp_hours = s6q8b if s6q8b != .
	replace			emp_hours_chg = s6q8c if s6q8c != .
	replace			emp_cont_01 = s6q8d__1 if s6q8d__1 != .
	replace			emp_cont_02 = s6q8d__2 if s6q8d__2 != .
	replace			emp_cont_03 = s6q8d__3 if s6q8d__3 != .
	replace			emp_cont_04 = s6q8d__4 if s6q8d__4 != .
	replace			contrct = s6q8e__1 if s6q8e__1 != .
	replace			emp_hh = s6q9 if s6q9 != .
	replace			find_job = s6q3a if s6q3a != .
	replace			find_job_do = s6q3b if s6q3b != .

	drop			s6q4a_1b s6q4a_2b s6q4b s6q5 s6q6 s6q7 s6q8 s6q8a s6q8a_os ///
						s6q8b s6q8c s6q8d__1 s6q8d__2 s6q8d__3 s6q8d__4 ///
						s6q8e__1 s6q8e__2 s6q8e__99 s6q9 s6q10__0 s6q10__1 ///
						s6q10__2 s6q10__3 s6q3a s6q3b

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

	drop			s6q1c__1 s6q1c__2 s6q1c__3 s6q1c__4 s6q1c__5 s6q1c__6 ///
						s6q1c__7 s6q1c__8 s6q1c__9 s6q1c__10 s6q1c__11 ///
						s6q1c__12 s6q1c__13 s6q1c__96 s6q1c_os

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

	drop			s6q3__1 s6q3__2 s6q3__3 s6q3__4 s6q3__5 s6q3__6 s6q3__7 ///
						s6q3__8 s6q3__9 s6q3__10 s6q3__11 s6q3__12 s6q3__13 ///
						s6q3__96 s6q3_os

	rename			s6bq11 bus_emp
	rename			s6bq11a_1 bus_stat
	replace			bus_stat = s6bq11a_2 if bus_stat == .
	replace			bus_stat = s6bq11a_3 if bus_stat == .
	rename			s6bq11b bus_stat_why
	rename			s6qb12 bus_sect
	rename			s6qb13 bus_emp_inc
	rename			s6qb14 bus_why

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

	rename			s6cq1 oth_inc_01
	rename			s6cq2 oth_inc_02
	rename			s6cq3 oth_inc_03
	rename			s6cq4 oth_inc_04
	rename			s6cq5 oth_inc_05

* SEC 8: fies
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

* SEC 9: concerns
	rename			s9q1 concern_01
	rename			s9q2 concern_02
	gen				have_symp = 1 if s9q3__1 == 1 | s9q3__2 == 1 | s9q3__3 == 1 | ///
						s9q3__4 == 1 | s9q3__5 == 1 | s9q3__6 == 1 | ///
						s9q3__7 == 1 | s9q3__8 == 1
	replace			have_symp = 2 if have_symp == .
	lab var			have_symp "Has anyone in your hh experienced covid symptoms?:cough/shortness of breath etc."
	order			have_symp, after(concern_02)

	drop			s9q3__1 s9q3__2 s9q3__3 s9q3__4 s9q3__5 s9q3__6 s9q3__7 s9q3__8

	rename 			s9q4 have_test
	rename 			s9q5 concern_03
	rename			s9q6 concern_04
	lab var			concern_04 "Response to the COVID-19 emergency will limit my rights and freedoms"
	rename			s9q7 concern_05
	lab var			concern_05 "Money and supplies allocated for the COVID-19 response will be misused and captured by powerful people in the country"
	rename			s9q8 concern_06
	lab var			concern_06 "Corruption in the government has lowered the quality of medical supplies and care"

* create country variables
	gen				country = 2
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country
	lab var			country "Country"

* save temp file
	save			"$root/wave_02/r2_sect_all", replace


* ***********************************************************************
* 4 - build malawi panel
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_all.dta", ///
						clear

* append round 2 of the data
	append 			using "$root/wave_02/r2_sect_all", ///
						force

* merge in consumption aggregate
	merge m:1		y4_hhid using "$root/wave_00/Malawi IHPS 2019 Quintiles.dta"
	
	keep if			_merge == 3
	drop			_merge
	
* define labels
	rename			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui
	
* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************

	drop 			household_id household_id_an start_date PID above18

	compress
	describe
	summarize

	rename 			y4_hhid hhid_mwi

* save file
		customsave , idvar(hhid_mwi) filename("mwi_panel.dta") ///
			path("$export") dofile(mwi_build) user($user)

* close the log
	log	close

/* END */
