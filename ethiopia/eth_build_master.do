* Project: WB COVID
* Created on: Oct 2020
* Created by: jdm
* Edited by: amf
* Last edit: Nov 2020 
* Stata v.16.1

* does
	* appends rounds of Ethiopia data
	* formats and cleans master dataset 
	* outputs panel data

* assumes
	* raw Ethiopia data
	* xfill.ado

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
	global 			waves "1" "2" "3" "4" "5"
	
* define 
	global			root	=	"$data/ethiopia/raw"
	global			export	=	"$data/ethiopia/refined"
	global			logout	=	"$data/ethiopia/logs"
	global  		fies 	= 	"$data/analysis/raw/Ethiopia"

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
	log using		"$logout/eth_build", append


* ***********************************************************************
* 1 - run do files for each round & generate variable comparison excel
* ***********************************************************************

* run do files for all rounds and create crosswalk of variables by wave
	foreach 		r in "$waves" {
		do 			"$code/ethiopia/eth_build_`r'"
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
	export 			excel using "$export/eth_variable_crosswalk.xlsx", first(var) replace
	
	
* ***********************************************************************
* 2 - create ethiopia panel 
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
	merge m:1		household_id using "$root/wave_00/Ethiopia ESS 2018-19 Quintiles.dta", nogenerate
	rename 			quintile quints
	lab var			quints "Quintiles based on the national population"
	lab def			lbqui 1 "Quintile 1" 2 "Quintile 2" 3 "Quintile 3" ///
						4 "Quintile 4" 5 "Quintile 5"
	lab val			quints lbqui
	drop 			if wave == .
	
* create country variable
	gen				country = 1
	
	
* ***********************************************************************
* 3 - clean ethiopia panel
* ***********************************************************************

* rationalize variables across waves
	gen 			phw = .
	foreach 		r in "$waves" {
		replace 	phw = phw`r' if phw`r' != . & wave == `r'
		drop 		phw`r'
	}
	lab var			phw "sampling weights"
	
* administrative variables 	
	rename			ii4_resp_id resp_id
	rename			cs4_sector sector
	rename			cs5_eaid ea
	rename			cs6_hhid hh_id
	rename			cs7_hhh_id hhh_id
	rename			cs1_region region
	rename			cs2_zoneid zone_id
	rename			cs3_woredaid county_id
	rename			cs3c_cityid city_id
	rename			cs3c_subcityid subcity_id
	rename			cs3b_kebeleid neighborhood_id
	rename			cs_startdate start_date
	rename			cs_submissiondate submission_date
	rename			cs7a_hhh_gender hhh_gender
	rename			cs7a_hhh_age hhh_age
	rename			cs12_round round
	rename			ii1_attempt attempt
	rename			bi_locchange loc_chg
	rename			bi_same_hhh same_hhh
	rename			ii4_resp_same same
	rename			ii4_resp_gender sex
	rename			ii4_resp_age age	
	rename			ii4_resp_relhhh relate_hoh

* covid variables (wave 1 only)
	rename			kn1_heard know
	rename			kn2_meas_handwash know_1
	rename			kn2_meas_handshake know_2
	rename			kn2_meas_maskglove know_3
	rename			kn2_meas_travel know_4
	rename			kn2_meas_stayhome know_5
	rename			kn2_meas_gatherings know_6
	rename			kn2_meas_distance know_7
	rename			kn2_meas_facetouch know_8
	rename			kn3_gov_1 gov_1
	rename			kn3_gov_2 gov_2
	rename			kn3_gov_3 gov_3
	rename			kn3_gov_4 gov_4
	rename			kn3_gov_5 gov_5
	rename			kn3_gov_6 gov_6
	rename			kn3_gov_7 gov_7
	rename			kn3_gov_8 gov_8
	rename			kn3_gov_9 gov_9
	rename			kn3_gov_10 gov_10
	rename			kn3_gov_11 gov_11
	rename			kn3_gov_12 gov_12
	rename			bh1_handwash bh_1
	rename			bh2_handshake bh_2
	rename			bh3_gatherings bh_3
	rename 			bh1_handwash_freq bh_7
	rename 			bh2_mask_freq bh_8 
	rename 			bh3_cov_fear concern_1 
	rename 			bh4_cov_fin concern_2 
	
* access variables 
	* staples & medical care & bank
		rename			ac1_atb_med ac_med
		rename			ac2_atb_med_why ac_med_why
		rename			ac1_atb_teff ac_teff
		rename			ac2_atb_teff_why ac_teff_why
		rename			ac1_atb_wheat ac_wheat
		rename			ac2_atb_wheat_why ac_wheat_why
		rename			ac1_atb_maize ac_maize
		rename			ac2_atb_maize_why ac_maize_why
		rename			ac1_atb_oil ac_oil
		rename			ac2_atb_oil_why ac_oil_why
		rename			ac6_med ac_medserv_need
		rename			ac7_med_access ac_medserv
		rename			ac8_med_access_reas ac_medserv_why
		rename			ac9_bank ac_bank_need
		
	* education 
		rename			ac3_sch_child sch_child
		rename 		 	ac3a_pri_sch_child sch_child_prim
		rename 		 	ac3b_sec_sch_child sch_child_sec
		rename			ac4_sch_girls sch_girl
		rename			ac4_sch_boys sch_boy
		rename			ac4_2_edu edu_act
		rename 			ac4a_pri_child edu_act_prim
		rename			ac5_edu_type_1 edu_1
		rename			ac5_edu_type_2 edu_2
		rename			ac5_edu_type_3 edu_3
		rename			ac5_edu_type_4 edu_4
		rename			ac5_edu_type_5 edu_5

		drop 			ac5a_pri_edu_type ac5a_pri_edu_type__98 ac5a_pri_edu_type__99 ///
						ac5a_pri_edu_type_other 
		rename 			ac5a_pri_edu_type_1 edu_1_prim 
		rename 			ac5a_pri_edu_type_2 edu_2_prim  
		rename 			ac5a_pri_edu_type_3 edu_3_prim 
		rename 			ac5a_pri_edu_type_4 edu_4_prim 
		rename 			ac5a_pri_edu_type_5 edu_5_prim 
		rename 			ac5a_pri_edu_type__96 edu_other_prim 	

		rename 			ac4b_sec_child edu_act_sec 
		drop 			ac5b_sec_edu_type ac5b_sec_edu_type__98 ac5b_sec_edu_type__99 ///
						ac5b_sec_edu_type_other
		rename 			ac5b_sec_edu_type_1 edu_1_sec 
		rename 			ac5b_sec_edu_type_2 edu_2_sec  
		rename 			ac5b_sec_edu_type_3 edu_3_sec 
		rename 			ac5b_sec_edu_type_4 edu_4_sec 
		rename 			ac5b_sec_edu_type_5 edu_5_sec 
		rename 			ac5b_sec_edu_type__96 edu_other_sec 

		drop 			ac5_edu_type__98 ac5_edu_type__99 ac5_edu_type__96 ///
							ac5_edu_type_other edu_other_sec
							
	* water and soap
	 * only in round 4
		rename 			wa1_water_drink ac_drink
		rename 			wa2_water_drink_why ac_drink_why
		lab def 		ac_drink_why 1 "water supply not available" 2 "water supply reduced" ///
						3 "unable to access communal supply" 4 "unable to access water tanks" ///
						5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
						8 "restriction to go out" 9 "increase in price" 10 "cannot afford"
		lab val 		ac_drink_why ac_drink_why
		lab var 		ac_drink "Had Enough Drinking Water in Last 7 Days"
		lab var 		ac_drink_why "Main Reason Not Enough Drinking Water in Last 7 Days"
		
		rename 			wa3_water_wash ac_water
		rename 			wa4_water_wash_why ac_water_why
		lab var 		ac_water "Had Enough Handwashing Water in Last 7 Days"
		lab var 		ac_water_why "Main Reason Not Enough Handwashing Water in Last 7 Days"

		rename 			wa5_soap_wash ac_soap		
		rename 			wa6_soap_wash_why ac_soap_why
		replace 		ac_soap_why = ac_soap_why - 4
		replace 		ac_soap_why = 8 if ac_soap_why == 7
		replace 		ac_soap_why = 7 if ac_soap_why == 6
		lab def 		ac_soap_why 1 "shops out" 2 "markets closed" 3 "lack of transportation" ///
						4 "restriction to go out" 5 "increase in price" 6 "lack of money" ///
						7 "cannot afford" 8 "afraid to get virus"
		lab val 		ac_soap_why ac_soap_why
		lab var 		ac_soap "Had Enough Handwashing Soap in Last 7 Day"
		lab var 		ac_soap_why "Main Reason Not Enough Handwashing Soap in Last 7 Days"
	*credit 
	 * first addition in R5
		rename 			cr1_since_loan ac_cr_loan 
		forval 			x = 1/11 {
			rename 		cr2_since_lender_`x' ac_cr_lend_`x'
		}
		replace 		ac_cr_lend_1 = 1 if ac_cr_lend_11 == 1
		drop 			ac_cr_lend_11
		lab var 		ac_cr_lend_1 "friend or relative"
		forval 			x = 1/11 {
			rename 		cr3_since_reas_`x' ac_cr_why_`x'
		}
		forval    		x = 1/12 {
			rename 		cr4_since_who_`x' ac_cr_who_`x'
		}
		rename 			cr5_since_duedate ac_cr_due
		rename 			cr6_before_loan ac_cr_bef
		forval 			x = 1/11 {
			rename 		cr7_before_reas_`x' ac_cr_bef_why_`x'
		}
		forval 			x = 1/12 {
			rename		cr8_before_who_`x' ac_cr_bef_who_`x'
		}
		rename 			cr9_worry ac_cr_worry
		rename 			cr10_missed_pay ac_cr_miss
		rename 			cr11_delay_chg ac_cr_delay	
		
* employment variables 	
	rename			em1_work_cur emp
	rename			em6_work_cur_act emp_act
	lab def 		emp_act -96 "Other" 1 "Agriculture" 2 "Industry/manufacturing" ///
						3 "Wholesale/retail" 4 "Transportation services" ///
						5 "Restaurants/hotels" 6 "Public Administration" ///
						7 "Personal Services" 8 "Construction" 9 "Education/Health" ///
						10 "Mining" 11 "Professional/scientific/technical activities" ///
						12 "Electic/water/gas/waste" 13 "Buying/selling" ///
						14 "Finance/insurance/real estate" 15 "Tourism" 16 "Food processing" 
	lab val 		emp_act emp_act
	rename			em6_work_cur_act_other emp_act_other
	rename			em7_work_cur_status emp_stat
	rename			em7_work_cur_status_other emp_stat_other
	rename			em8_work_cur_same emp_same
	rename			em9_work_change_why emp_chg_why
	rename			em2_work_pre emp_pre
	rename			em3_work_no_why emp_pre_why
	rename			em4_work_pre_act emp_pre_act
	rename			em5_work_pre_status emp_pre_stat
	rename			em12_work_cur_able emp_able
	rename			em13_work_cur_notable_paid emp_unable
	rename			em14_work_cur_notable_why emp_unable_why
	rename			em15_bus bus_emp
	rename			em15a_bus_prev bus_prev
	rename			em15b_bus_prev_closed bus_prev_close
	rename			em15c_bus_new bus_new
	rename			em16_bus_sector bus_sect
	rename			em17_bus_inc bus_emp_inc
	rename			em18_bus_inc_low_amt bus_amt
	rename			em20_farm farm_emp
	rename			em21_farm_norm farm_norm
	rename			em22_farm_norm_why farm_why
	forval 			x = 1/7 {
	    rename 		em22_farm_norm_why_`x' farm_why_`x'
	}
	rename			em23_we wage_emp
	rename			em24_we_layoff wage_off
	rename			em25_we_layoff_covid wage_off_covid
	
 /* Change pre-COVID employment to "yes" if the respondent is currently employed - interviewers in rounds 4 and 5 
 asked every respondent question 2 from the employment section (em2_work_pre), regardless of their answer to question 1 
 (em1_work_cur), whereas in rounds 1-3, respondents were only asked question 2 if they responded "no" to question 1 */
	replace emp_pre = 1 if emp == 1 & emp_pre == .

* income variables 	
	rename			lc1_farm farm_inc
	rename			lc2_farm_chg farm_chg
	rename			lc1_bus bus_inc
	rename			lc2_bus_chg bus_chg
	rename			lc1_we wage_inc
	rename			lc2_we_chg wage_chg
	rename			lc1_rem_dom rem_dom
	rename			lc2_rem_dom_chg rem_dom_chg
	rename			lc1_rem_for rem_for
	rename			lc2_rem_for_chg rem_for_chg
	rename			lc1_isp isp_inc
	rename			lc2_isp_chg isp_chg
	rename			lc1_pen pen_inc
	rename			lc2_pen_chg pen_chg
	rename			lc1_gov gov_inc
	rename			lc2_gov_chg gov_chg
	rename			lc1_ngo ngo_inc
	rename			lc2_ngo_chg ngo_chg
	rename			lc1_other oth_inc
	rename			lc2_other_chg oth_chg
	rename			lc3_total_chg tot_inc_chg
	
* coping variables 	
	forval 			x = 1/15 {
	    rename 		lc4_total_chg_cope_`x' cope_`x'
	}
	rename			lc4_total_chg_cope_0 cope_16
	rename			lc4_total_chg_cope__96 cope_17
	
* fies variables 	
	rename			fi7_outoffood fies_1
	replace 		fies_1 = fi1_outoffood if fies_1 ==. & fi1_outoffood != . 
	rename			fi8_hungrynoteat fies_2
	replace 		fies_2 = fi2_hungrynoteat if fies_2 ==. & fi2_hungrynoteat != .
	rename			fi6_noteatfullday fies_3
	replace 		fies_3 = fi3_noteatfullday if fies_3 == . & fi3_noteatfullday != .
	rename			fi1_enough fies_4
	rename			fi2_healthy fies_5
	rename			fi3_fewkinds fies_6
	rename			fi4_skipmeal fies_7
	rename			fi5_ateless fies_8
	lab def 		yn 1 "Yes" 2 "No"
	lab val			fies* yn
	
* assistance variables - updated via convo with Talip 9/1
	gen				asst_food = as1_assist_type_1
	replace			as3_forwork_value_food = . if as3_forwork_value_food < 0
	replace			asst_food = 1 if as1_assist_type_2 == 1 & as3_forwork_value_food > 0
	replace			asst_food = 0 if asst_food == .
	lab var			asst_food "Recieved food assistance"
	lab def			assist 0 "No" 1 "Yes"
	lab val			asst_food assist
	
	gen				asst_cash = as1_assist_type_3
	replace			as3_forwork_value_cash = . if as3_forwork_value_cash < 0
	replace			asst_cash = 1 if as1_assist_type_2 == 1 & as3_forwork_value_cash > 0
	replace			asst_cash = 0 if asst_cash == .
	lab var			asst_cash "Recieved cash assistance"
	lab val			asst_cash assist
	
	gen				asst_kind = 1 if as1_assist_type_other != ""
	replace			asst_kind = 0 if asst_kind == .
	lab var			asst_kind "Recieved in-kind assistance"
	lab val			asst_kind assist
	
	gen				asst_any = 1 if asst_food == 1 | asst_cash == 1 | ///
						asst_kind == 1
	replace			asst_any = 0 if asst_any == .
	lab var			asst_any "Recieved any assistance"
	lab val			asst_any assist
	
	drop			as1_assist_type as1_assist_type_1 as1_assist_type_2 ///
						as1_assist_type_3 as1_assist_type_0 as1_assist_type__98 ///
						as1_assist_type__99 as1_assist_type__96 ///
						as1_assist_type_other as3_food_value as2_food_psnp ///
						as4_food_source as4_food_source_other ///
						as3_forwork_value_food as3_forwork_value_cash ///
						as2_forwork_psnp as4_forwork_source ///
						as4_forwork_source_other as3_cash_value as2_cash_psnp ///
						as4_cash_source as4_cash_source_other as3_other_value ///
						as2_other_psnp as4_other_source as4_other_source_other

* replace missing round 1 values based on respondant id (NEW CODE - J&A TO CHECK)
* round 1 did not report respondant age, sex, or relation to hhh
	egen 			unique = group(household_id resp_id)
	xtset 			wave
	xfill 			sex, i(unique)
	bysort 			unique: egen min_age = min(age)
	replace 		age = min_age if age == . & wave == 1
	gen 			relate_temp = relate_hoh if wave == 2
	xfill 			relate_temp, i(unique)
	replace 		relate_hoh = relate_temp if relate_hoh == . & wave == 1 
	drop 			min_age unique relate_temp

* reformat bus_why variables
	gen				bus_why = .
	replace 		bus_why = 1 if em19_bus_inc_low_why_1 == 1
	replace			bus_why = 2 if em19_bus_inc_low_why_2 == 1
	replace 		bus_why = 3 if em19_bus_inc_low_why_3 == 1
	replace			bus_why = 4 if em19_bus_inc_low_why_4 == 1
	replace 		bus_why = 5 if em19_bus_inc_low_why_5 == 1
	replace			bus_why = 6 if em19_bus_inc_low_why_6 == 1
	replace 		bus_why = 7 if em19_bus_inc_low_why_7 == 1
	replace			bus_why = 8 if em19_bus_inc_low_why__98 == 1
	replace 		bus_why = 9 if em19_bus_inc_low_why__96 == 1
	lab def			bus_why 1 "markets closed - covid" 2 "markets closed - other" 3 "seasonal closure" /// 
								4 "no customers" 5 "unable to get inputs" 6 "unable to sell output" ///
								7 "illness in household" 8 "do not know" 9 "other"
	lab val 		bus_why bus_why 
	lab var 		bus_why "reason for family business less than usual"
	
* perceptions of distribution of aid etc. 
	rename 			as5_assist_fair perc_aidfair
	rename 			as6_assist_tension perc_aidten 
	
* agriculture 
 * first addition in R3
	rename			ag1_crops ag_crop
	rename			ag1a_crops_plan ag_plan
	rename 			ag2_crops_able ag_chg	
	rename			ag3_crops_reas_1 ag_nocrop_1 
	rename 			ag3_crops_reas_2 ag_nocrop_2
	rename 			ag3_crops_reas_3 ag_nocrop_3
	rename			ag3_crops_reas_4 ag_nocrop_10
	rename			ag3_crops_reas_5 ag_nocrop_4	 
	rename 			ag3_crops_reas_6 ag_nocrop_5
	rename 			ag3_crops_reas_7 ag_nocrop_6
	rename 			ag3_crops_reas_8 ag_nocrop_7	
	rename 			ag3_crops_reas_9 ag_nocrop_8
	rename 			ag3_crops_reas__96 ag_nocrop_9 

	generate		ag_seed_01 = 1 if ag5_crops_reas_seeds == 1
	generate		ag_seed_02 = 1 if ag5_crops_reas_seeds == 2 
	generate		ag_seed_03 = 1 if ag5_crops_reas_seeds == 3
	generate		ag_seed_05 = 1 if ag5_crops_reas_seeds == 4
	generate		ag_seed_06 = 1 if ag5_crops_reas_seeds == 5

	rename			ag4_crops_reas_fert ag_fert
	rename 			ag6_ext_need ag_ext_need 
	rename 			ag7_ext_receive ag_ext
	rename 			ag8_travel_norm ag_labor_normal
	rename 			ag9_travel_curr ag_labor 
  
* livestock 
	drop 			ls2_type ls4_covid_impact ls4_covid_impact__96 ls4_covid_impact_other ///
					ls12_sell_notable ls12_sell_notable__96 ls12_sell_notable_other 
	rename 			ls1_livestock ag_live
	rename 			ls2_type_5 ls2_type_7
	rename 			ls2_type* ag_live*
	rename 			ls3_covid ag_live_cov
	rename 			ls4_covid_impact_1 ag_live_chg_1
	rename 			ls4_covid_impact_2 ag_live_chg_3
	rename 			ls4_covid_impact_3 ag_live_chg_4
	rename 			ls4_covid_impact_4 ag_live_chg_5
	rename 			ls5_usual ag_live_sell
	rename 			ls6_revenue_chg ag_live_sell_chg
	rename 			ls7_since_covid ag_live_sell_want
	rename 			ls8_because_covid ag_live_sell_why
	rename 			ls9_sell_able ag_live_sell_able
	rename 			ls10* ag_live* 
	rename 			ls11_ ag_live_sell_pr
	rename 			ls12_sell_notable* ag_live_sell_nowhy*
	 
* locusts
 * first addition in R4 (only in r4)
	rename 			lo1_keb	any_loc_keb
	rename 			lo2_farm any_loc_farm
	rename			lo3_impact_1 loc_imp_1
	rename			lo3_impact_2 loc_imp_2
	rename			lo3_impact_3 loc_imp_3
	rename			lo3_impact_4 loc_imp_4
	rename 			lo4_destr loc_dam
	drop 			lo3_impact__99 
	rename 			lo5_sprayed	loc_sprayed
		
* generate any shock variable
	gen				shock_any = 1 if farm_inc == 1 & farm_chg == 3 | farm_chg == 4
	replace			shock_any = 1 if bus_inc == 1 & bus_chg == 3 | bus_chg == 4
	replace			shock_any = 1 if wage_inc == 1 & wage_chg == 3 | wage_chg == 4
	replace			shock_any = 1 if rem_dom == 1 & rem_dom_chg == 3 | rem_dom_chg == 4
	replace			shock_any = 1 if rem_for == 1 & rem_for_chg == 3 | rem_for_chg == 4
	replace			shock_any = 1 if isp_inc == 1 & isp_chg == 3 | isp_chg == 4
	replace			shock_any = 1 if pen_inc == 1 & pen_chg == 3 | pen_chg == 4
	replace			shock_any = 1 if gov_inc == 1 & gov_chg == 3 | gov_chg == 4
	replace			shock_any = 1 if ngo_inc == 1 & ngo_chg == 3 | ngo_chg == 4
	replace			shock_any = 1 if oth_inc == 1 & oth_chg == 3 | oth_chg == 4
	replace			shock_any = 0 if shock_any == .
	lab var			shock_any "Experience some shock"
	
* drop unnecessary variables
	drop			kn3_gov kn3_gov_0 kn3_gov__98 kn3_gov__99 kn3_gov__96 ///
						kn3_gov_other ac2_atb_med_why_other ac2_atb_teff_why_other ///
						ac2_atb_wheat_why_other ac2_atb_maize_why_other ///
						ac2_atb_oil_why_other ag3* ag5* ///
						ac8_med_access_reas_other em9_work_change_why_other ///
						em3_work_no_why_other em4_work_pre_act_other ///
						em5_work_pre_status_other em14_work_cur_notable_why_other ///
						em16_bus_sector_other em19_bus_inc_low_why ///
						em19_bus_inc_low_why__98 em19_bus_inc_low_why__99 ///
						em19_bus_inc_low_why__96 em19_bus_inc_low_why_other ///
						em22_farm_norm_why__98 em22_farm_norm_why__99 ///
						em22_farm_norm_why__96 em22_farm_norm_why_other ///
						lc1_other_source lc4_total_chg_cope lc4_total_chg_cope__98 ///
						lc4_total_chg_cope__99 lc4_total_chg_cope_other ///
						ir1_endearly ir1_whyendearly ir1_whyendearly_other ///
						ir_lang ir_understand ir_confident em15b_bus_prev_closed_other ///
						key em19_bus_inc_low_why__* em19_bus_inc_low_why hh_id hhh_id ///
						start_date hhh_gender hhh_age same loc_chg same_hhh ///			
						cr2_since_lender cr2_since_lender__96 cr2_since_lender_other ///
						cr3_since_reas cr3_since_reas__96 cr3_since_reas_other ///
						cr4_since_who cr4_since_who__96 cr4_since_who_other ///
						cr7_before_reas cr7_before_reas__96 cr7_before_reas_other ///
						cr8_before_who cr8_before_who__96 cr8_before_who_other ///
						fi1_outoffood fi2_hungrynoteat fi3_noteatfullday lo3_impact ///
						weight *why_other ea_id ac5_edu_type emp_act_other emp_stat_other ///
						farm_why ag_live_other submission_date round attempt em19_*
						
* rename regions
	replace 		region = 1001 if region == 1
	replace 		region = 1002 if region == 2
	replace 		region = 1003 if region == 3
	replace 		region = 1004 if region == 4
	replace 		region = 1005 if region == 5
	replace 		region = 1006 if region == 6
	replace 		region = 1007 if region == 7
	replace 		region = 1008 if region == 12
	replace			region = 1009 if region == 13
	replace			region = 1010 if region == 14
	replace			region = 1011 if region == 15
	
	lab def			region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
						"Oromia" 1005 "Somali" 1006 "Benishangul-Gumuz" 1007 ///
						"SNNPR" 1008 "Gambela" 1009 "Harar" 1010 ///
						"Addis Ababa" 1011 "Dire Dawa"
	lab val			region region
	 
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
	export 			excel using "$export/eth_qc_flags.xlsx", first(var) sheetreplace sheet(flags)
	restore
	destring 		wave, replace

*/
* **********************************************************************
* 5 - end matter, clean up to save
* **********************************************************************

* final clean 
	compress	
	describe
	summarize 
	rename 			household_id hhid_eth 
	label 			var hhid_eth "household id unique - ethiopia"
	
* save file
	customsave, 	idvar(hhid_eth) filename("eth_panel.dta") ///
					path("$export") dofile(eth_build) user($user)

* close the log
	log	close

/* END */