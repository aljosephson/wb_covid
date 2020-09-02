* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edited: 26 August 2020 
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
* 1 - build nigeria panel
* ***********************************************************************


* ***********************************************************************
* 1a - build nigeria wave 1 panel 
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_a_3_4_5_6_8_9_12", ///
						clear
						
* merge in other sections
	merge 1:1 		hhid using "$export/wave_01/respond_r1.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_01/hhsize_r1.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_01/r1_sect_7w.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_01/r1_sect_10w.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_01/r1_sect_11w.dta", nogenerate

* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
* save temp file
	save			"$export/wave_01/r1_sect_all", replace	
	
	
* ***********************************************************************
* 1b - build nigeria wave 2 panel 
* ***********************************************************************

* load round 2 of the data
	use				"$root/wave_02/r2_sect_a_2_5_6_8_12", ///
						clear
						
* merge in other sections
	merge 1:1 		hhid using "$export/wave_02/respond_r2.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_02/hhsize_r2.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_02/r2_sect_7w.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_02/r2_sect_11w.dta", nogenerate
	merge 1:1		hhid using "$export/wave_02/fies_r2", nogenerate

	
* generate round variable
	gen				wave = 2
	lab var			wave "Wave number"
	
* save temp file
	save			"$export/wave_02/r2_sect_all", replace	

	
* ***********************************************************************
* 1c - build nigeria wave 2 panel 
* ***********************************************************************

* load round 2 of the data
	use				"$root/wave_03/r3_sect_a_2_5_5a_6_12", ///
						clear
						
* merge in other sections
	merge 1:1 		hhid using "$export/wave_03/respond_r3.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_03/hhsize_r3.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_03/r3_sect_7w.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_03/r3_sect_10w.dta", nogenerate
	merge 1:1 		hhid using "$export/wave_03/r3_sect_11w.dta", nogenerate

* generate round variable
	gen				wave = 3
	lab var			wave "Wave number"
	
* save temp file
	save			"$export/wave_03/r3_sect_all", replace	


* ***********************************************************************
* 1d - build nigeria panel 
* ***********************************************************************

* load round 1 of the data
	use				"$export/wave_01/r1_sect_all.dta", ///
						clear

* append round 2 of the data
	append 			using "$export/wave_02/r2_sect_all", ///
						force

* append round 3 of the data
	append 			using "$export/wave_03/r3_sect_all", ///
						force						
											
	order			wave, after(hhid)

* adjust household id
	recast 			long hhid
	format 			%12.0g hhid

* merge in baseline data 
	merge m:1		hhid using "$root/wave_00/Nigeria GHS-Panel 2018-19 Quintiles", nogenerate

* rename quintile variable
	rename 			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui	
	
* rationalize variables across waves
	gen				phw = wt_baseline if wt_baseline != . & wave == 1
	replace			phw = wt_round2 if wt_round2 != . & wave == 2
	replace			phw = wt_round3 if wt_round3 != . & wave == 3
	lab var			phw "sampling weights"
	order			phw, after(wt_baseline)
	drop			wt_baseline wt_round2 wt_round3 weight
	
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
	rename 			s5q3 ac_medserv
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
	
* round 2 access differs from round 1 employment 

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
						s12q5 s12q9 s12q10 s12q10_os s12q11 s12q14 baseline_date ///
						s12q10a s5*  
	drop if			wave ==  .
	
* create country variables
	gen				country = 3
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	

* reorder variables
	order			fies_02 fies_03 fies_04 fies_05 fies_06 fies_07 fies_08, after(fies_01)
	
* delete temp files 
	/*erase			"$root/wave_01/r1_sect_7w.dta"
	erase 			"$root/wave_02/r2_sect_7w.dta"
	erase 			"$root/wave_01/r1_sect_10w.dta"
	erase			"$root/wave_01/r1_sect_11w"
	erase			"$root/wave_02/r2_sect_11w"
	erase			"$root/wave_01/r1_sect_all"
	erase			"$root/wave_02/r2_sect_all"	*/
			
* **********************************************************************
* 3 - end matter, clean up to save
* **********************************************************************

	compress
	describe
	summarize 

	rename hhid hhid_nga 

* save file
		customsave , idvar(hhid_nga) filename("nga_panel.dta") ///
			path("$export") dofile(nga_build) user($user)

* close the log
	log	close

/* END */