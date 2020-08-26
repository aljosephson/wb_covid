* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj 
* Last edit: 26 August 2020 
* Stata v.16.1

* does
	* reads in first two rounds of Ethiopia data
	* builds panel
	* outputs panel data

* assumes
	* raw Ethiopia data
	* xfill.ado

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/ethiopia/raw"
	global	export	=	"$data/ethiopia/refined"
	global	logout	=	"$data/ethiopia/logs"
	global  fies 	= 	"$data/analysis/raw/Ethiopia"

* open log
	cap log 		close
	log using		"$logout/eth_build", append


* ***********************************************************************
* 1a - get household size
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/200610_WB_LSMS_HFPM_HH_Survey_Roster-Round1_Clean-Public", ///
						clear

* generate counting variables
	gen			hhsize = 1
	
* collapse data
	collapse	(sum) hhsize, by(household_id)
	lab var		hhsize "Household size"

* save temp file
	save			"$export/wave_01/hhsize_r1", replace						

* load round 2 of the data
	use				"$root/wave_02/200620_WB_LSMS_HFPM_HH_Survey_Roster-Round2_Clean-Public", ///
						clear

* generate counting variables
	gen			hhsize = 1
	
* collapse data
	collapse	(sum) hhsize, by(household_id)
	lab var		hhsize "Household size"

* save temp file
	save			"$export/wave_02/hhsize_r2", replace	
	
* load round 3 of the data
	use				"$root/wave_03/200729_WB_LSMS_HFPM_HH_Survey_Roster-Round3_Clean-Public", ///
						clear

* generate counting variables
	gen			hhsize = 1
	
* collapse data
	collapse	(sum) hhsize, by(household_id)
	lab var		hhsize "Household size"

* save temp file
	save			"$export/wave_03/hhsize_r3", replace
	
* ***********************************************************************
* 1b - FIES score - R2
* ***********************************************************************

* load data
	use				"$fies/ET_FIES_round2.dta", clear

	drop 			country round 
	rename 			HHID household_id

* save temp file
	save			"$export/wave_02/fies_r2", replace
	
* ***********************************************************************
* 1c - FIES score - R3
* ***********************************************************************

* load data
	use				"$fies/ET_FIES_round3.dta", clear

	drop 			country round
	rename 			HHID household_id

* save temp file
	save			"$export/wave_03/fies_r3", replace
						
* ***********************************************************************
* 2 - build ethiopia panel
* ***********************************************************************

* load round 1 of the data
	use				"$root/wave_01/200610_WB_LSMS_HFPM_HH_Survey-Round1_Clean-Public_Microdata", ///
						clear
						
* merge in other sections
	merge 1:1 		household_id using "$export/wave_01/hhsize_r1.dta", keep(match) nogenerate

* generate round variable
	gen				wave = 1
	lab var			wave "Wave number"
	
* save temp file
	save			"$export/wave_01/r1_sect_all", replace		
	
* load round 2 of the data
	use				"$root/wave_02/200620_WB_LSMS_HFPM_HH_Survey-Round2_Clean-Public_Microdata", ///
						clear
						
* merge in other sections
	merge 1:1 		household_id using "$export/wave_02/hhsize_r2.dta", keep(match) nogenerate
	merge 1:1 		household_id using "$export/wave_02/fies_r2.dta", keep(match) nogenerate

* generate round variable
	gen				wave = 2
	lab var			wave "Wave number"
	
* save temp file
	save			"$export/wave_02/r2_sect_all", replace	
	
* load round 3 of the data
	use				"$root/wave_03/200729_WB_LSMS_HFPM_HH_Survey-Round3_Clean-Public_Microdata", ///
						clear
						
* merge in other sections
	merge 1:1 		household_id using "$export/wave_03/hhsize_r3.dta", keep(match) nogenerate
	merge 1:1 		household_id using "$export/wave_03/fies_r3.dta", keep(match) nogenerate


* generate round variable
	gen				wave = 3
	lab var			wave "Wave number"
	
* save temp file
	save			"$export/wave_03/r3_sect_all", replace	

* load complete round 1 data
	use				"$export/wave_01/r1_sect_all", clear
	
* append round 2 of the data
	append 			using "$export/wave_02/r2_sect_all", force

* append round 3 of the data
	append 			using "$export/wave_03/r3_sect_all", force
		
						
* ***********************************************************************
* 3 - clean ethiopia panel
* ***********************************************************************

* rationalize variables across waves
	gen				phw = phw1 if phw1 != .
	replace			phw = phw2 if phw2 != .
	lab var			phw "sampling weights"
	order			phw, after(phw1)
	drop			phw1 phw2
	
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


* covid variables
	rename			kn1_heard know
	rename			kn2_meas_handwash know_01
	rename			kn2_meas_handshake know_02
	rename			kn2_meas_maskglove know_03
	rename			kn2_meas_travel know_04
	rename			kn2_meas_stayhome know_05
	rename			kn2_meas_gatherings know_06
	rename			kn2_meas_distance know_07
	rename			kn2_meas_facetouch know_08
	rename			kn3_gov_1 gov_01
	rename			kn3_gov_2 gov_02
	rename			kn3_gov_3 gov_03
	rename			kn3_gov_4 gov_04
	rename			kn3_gov_5 gov_05
	rename			kn3_gov_6 gov_06
	rename			kn3_gov_7 gov_07
	rename			kn3_gov_8 gov_08
	rename			kn3_gov_9 gov_09
	rename			kn3_gov_10 gov_10
	rename			kn3_gov_11 gov_11
	rename			kn3_gov_12 gov_12
	rename			bh1_handwash bh_01
	rename			bh2_handshake bh_02
	rename			bh3_gatherings bh_03
	rename 			bh1_handwash_freq bh_07
	rename 			bh2_mask_freq bh_08 
	rename 			bh3_cov_fear concern_01 
	rename 			bh4_cov_fin concern_02 
	
* access variables 
	rename			ac1_atb_med ac_med
	rename			ac2_atb_med_why ac_med_why
	rename			ac1_atb_teff ac_teff
	rename			ac2_atb_teff_why ac_teff_why
	rename			ac1_atb_wheat ac_wheat
	rename			ac2_atb_wheat_why ac_wheat_why
	rename			ac1_atb_maize ac_maize
	rename			ac2_atb_maize_why  ac_maize_why
	rename			ac1_atb_oil ac_oil
	rename			ac2_atb_oil_why ac_oil_why
	rename			ac3_sch_child sch_child
	rename			ac4_sch_girls sch_girl
	rename			ac4_sch_boys sch_boy
	rename			ac4_2_edu edu_act
	rename			ac5_edu_type_1 edu_01
	rename			ac5_edu_type_2 edu_02
	rename			ac5_edu_type_3 edu_03
	rename			ac5_edu_type_4 edu_04
	rename			ac5_edu_type_5 edu_05
	rename			ac6_med med
	rename			ac7_med_access med_access
	rename			ac8_med_access_reas med_access_why
	rename			ac9_bank bank 

* employment variables 	
	rename			em1_work_cur emp
	rename			em6_work_cur_act emp_act
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
	rename			em16_bus_sector bus_sect
	rename			em17_bus_inc bus_emp_inc
	rename			em18_bus_inc_low_amt bus_amt
	rename			em20_farm farm_emp
	rename			em21_farm_norm farm_norm
	rename			em22_farm_norm_why farm_why
	rename			em22_farm_norm_why_1 farm_why_01
	rename			em22_farm_norm_why_2 farm_why_02
	rename			em22_farm_norm_why_3 farm_why_03
	rename			em22_farm_norm_why_4 farm_why_04
	rename			em22_farm_norm_why_5 farm_why_05
	rename			em22_farm_norm_why_6 farm_why_06
	rename			em22_farm_norm_why_7 farm_why_07
	rename			em23_we wage_emp
	rename			em24_we_layoff wage_off
	rename			em25_we_layoff_covid wage_off_covid
	
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
	rename			lc4_total_chg_cope_1 cope_01
	rename			lc4_total_chg_cope_2 cope_02
	rename			lc4_total_chg_cope_3 cope_03
	rename			lc4_total_chg_cope_4 cope_04
	rename			lc4_total_chg_cope_5 cope_05
	rename			lc4_total_chg_cope_6 cope_06
	rename			lc4_total_chg_cope_7 cope_07
	rename			lc4_total_chg_cope_8 cope_08
	rename			lc4_total_chg_cope_9 cope_09
	rename			lc4_total_chg_cope_10 cope_10
	rename			lc4_total_chg_cope_11 cope_11
	rename			lc4_total_chg_cope_12 cope_12
	rename			lc4_total_chg_cope_13 cope_13
	rename			lc4_total_chg_cope_14 cope_14
	rename			lc4_total_chg_cope_15 cope_15
	rename			lc4_total_chg_cope_0 cope_16
	rename			lc4_total_chg_cope__96 cope_17
	
* fies variables 	
	rename			fi7_outoffood fies_01
	rename			fi8_hungrynoteat fies_02
	rename			fi6_noteatfullday fies_03
	rename			fi1_enough fies_04
	rename			fi2_healthy fies_05
	rename			fi3_fewkinds fies_06
	rename			fi4_skipmeal fies_07
	rename			fi5_ateless fies_08
	
* assistance variables 	
	rename			as1_assist_type_1 asst_01
	rename			as1_assist_type_2 asst_02
	rename			as1_assist_type_3 asst_03
	rename			as1_assist_type_0 asst_04
	rename			as3_food_value food_val
	rename			as2_food_psnp food_psnp
	rename			as4_food_source food_source
	rename			as3_forwork_value_food work_food_val
	rename			as3_forwork_value_cash work_cash_val
	rename			as2_forwork_psnp work_psnp
	rename			as4_forwork_source work_source 
	rename			as3_cash_value cash_val
	rename			as2_cash_psnp cash_psnp
	rename			as4_cash_source cash_source
	rename			as3_other_value other_val
	rename			as2_other_psnp other_psnp
	rename			as4_other_source other_source
	rename			ii4_resp_same resp_same
	rename			ii4_resp_gender resp_gender
	rename			ii4_resp_age resp_age
	rename			ii4_resp_relhhh resp_hhh
	rename			em15a_bus_prev bus_prev
	rename			em15b_bus_prev_closed bus_prev_close
	rename			em15c_bus_new bus_new
	rename 			resp_age age
	rename 			resp_hhh relate_hoh
	rename			resp_gender	sex 
	rename 			resp_same same 
	
* replace resp for r1 based on r2
* only 27 not the same 
	encode 			household_id, generate (household_id_d)
	xtset 			wave 
	xfill			same,  i (household_id_d)
	xfill 			age relate_hoh sex if same == 1, i (household_id_d)
	
	replace			age = hhh_age if age == .
	replace			sex = hhh_gender if sex == .
	replace			relate_hoh = 1 if relate_hoh == .

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
	label var 		bus_why "reason for family business less than usual"
	
* education variables 

	rename 			ac3a_pri_sch_child sch_child_prim
	rename 			ac4a_pri_child edu_act_prim 
	drop 			ac5a_pri_edu_type ac5a_pri_edu_type__98 ac5a_pri_edu_type__99 ac5a_pri_edu_type_other 
	rename 			ac5a_pri_edu_type_1 edu_01_prim 
	rename 			ac5a_pri_edu_type_2 edu_02_prim  
	rename 			ac5a_pri_edu_type_3 edu_03_prim 
	rename 			ac5a_pri_edu_type_4 edu_04_prim 
	rename 			ac5a_pri_edu_type_5 edu_05_prim 
	rename 			ac5a_pri_edu_type__96 edu_other_prim 
		
	rename 			ac3b_sec_sch_child sch_child_sec
	rename 			ac4b_sec_child edu_act_sec 
	drop 			ac5b_sec_edu_type ac5b_sec_edu_type__98 ac5b_sec_edu_type__99 ac5b_sec_edu_type_other
	rename 			ac5b_sec_edu_type_1 edu_01_sec 
	rename 			ac5b_sec_edu_type_2 edu_02_sec  
	rename 			ac5b_sec_edu_type_3 edu_03_sec 
	rename 			ac5b_sec_edu_type_4 edu_04_sec 
	rename 			ac5b_sec_edu_type_5 edu_05_sec 
	rename 			ac5b_sec_edu_type__96 edu_other_sec 
	
	replace 		sch_child = sch_child_prim if sch_child == 0 & wave == 3
	replace 		sch_child = sch_child_sec if sch_child == 0 & wave == 3 
	replace 		edu_act = edu_act_prim if edu_act == 0 & wave == 3
	replace 		edu_act = edu_act_sec if edu_act == 0 & wave == 3
	replace 		edu_01 = edu_01_prim if edu_01 == 0 & wave == 3
	replace			edu_01 = edu_01_sec if edu_01 == 0 & wave == 3
	replace 		edu_02 = edu_02_prim if edu_02 == 0 & wave == 3
	replace			edu_02 = edu_02_sec if edu_02 == 0 & wave == 3
	replace 		edu_03 = edu_03_prim if edu_03 == 0 & wave == 3
	replace			edu_03 = edu_03_sec if edu_03 == 0 & wave == 3
	replace 		edu_04 = edu_04_prim if edu_04 == 0 & wave == 3
	replace			edu_04 = edu_04_sec if edu_04 == 0 & wave == 3
	replace 		edu_05 = edu_05_prim if edu_05 == 0 & wave == 3
	replace			edu_05 = edu_05_sec if edu_05 == 0 & wave == 3
	generate 		edu_other = edu_other_prim if wave == 3
	replace			edu_other = edu_other_sec if edu_other == 0 & wave == 3
	
* perceptions of distribution of aid etc. 

	rename 			as5_assist_fair perc_aidfair
	rename 			as6_assist_tension perc_aidten 
	
* agriculture 
* first addition in R3 

	rename			ag1_crops farm_act
	rename			ag1a_crops_plan ag_prep
	rename 			ag2_crops_able ag_chg	
	rename			ag3_crops_reas_1 ag_nocrop_01 
	rename 			ag3_crops_reas_2 ag_nocrop_02
	rename 			ag3_crops_reas_3 ag_nocrop_03
	rename			ag3_crops_reas_4 ag_nocrop_10
	rename			ag3_crops_reas_5 ag_nocrop_04	 
	rename 			ag3_crops_reas_6 ag_nocrop_05
	rename 			ag3_crops_reas_7 ag_nocrop_06
	rename 			ag3_crops_reas_8 ag_nocrop_07	
	rename 			ag3_crops_reas_9 ag_nocrop_08
	rename 			ag3_crops_reas__96 ag_nocrop_09 

	generate		ag_seed_01 = 1 if ag5_crops_reas_seeds == 1
	generate		ag_seed_02 = 1 if ag5_crops_reas_seeds == 2 
	generate		ag_seed_03 = 1 if ag5_crops_reas_seeds == 3
	generate		ag_seed_05 = 1 if ag5_crops_reas_seeds == 4
	generate		ag_seed_06 = 1 if ag5_crops_reas_seeds == 5

	rename			ag4_crops_reas_fert ag_fert
	rename 			ag6_ext_need ag_ext_need 
	rename 			ag7_ext_receive ag_ext
	rename 			ag8_travel_norm aglabor_normal
	rename 			ag9_travel_curr aglabor 
                   
* drop unnecessary variables
	drop			kn3_gov kn3_gov_0 kn3_gov__98 kn3_gov__99 kn3_gov__96 ///
						kn3_gov_other ac2_atb_med_why_other ac2_atb_teff_why_other ///
						ac2_atb_wheat_why_other ac2_atb_maize_why_other ///
						ac2_atb_oil_why_other ac5_edu_type ac5_edu_type__98 ///
						ac5_edu_type__99 ac5_edu_type__96 ac5_edu_type_other ///
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
						as1_assist_type as1_assist_type__98 as1_assist_type__99 ///
						as1_assist_type__96 as1_assist_type_other ///
						as4_food_source_other as4_forwork_source_other ///
						as4_cash_source_other as4_other_source_other ///
						ir1_endearly ir1_whyendearly ir1_whyendearly_other ///
						ir_lang ir_understand ir_confident em15b_bus_prev_closed_other ///
						key em19_bus_inc_low_why__* em19_bus_inc_low_why hh_id hhh_id ///
						ag*  
						

* reorder variables
	order			fies_04 fies_05 fies_06 fies_07 fies_08, after(fies_03)
	order 			same sex relate_hoh, after(hhh_age)
	order			bus_prev bus_prev_close bus_new, after(bus_why)
	
* create country variables
	gen				country = 1
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda"
	lab val			country country	
	lab var			country "Country"
			
	drop			resp_id start_date hhh_gender hhh_age same loc_chg same_hhh
	
* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

	compress	
	describe
	summarize 

	rename 			household_id hhid_eth 
	label 			var hhid_eth "household id unique - ethiopia (string)"
	rename 			household_id_d hhid_eth_d
	label 			var hhid_eth_d "household id unique - ethiopia (encoded)"

* save file
		customsave , idvar(hhid_eth) filename("eth_panel.dta") ///
			path("$export") dofile(eth_build) user($user)

* close the log
	log	close

/* END */