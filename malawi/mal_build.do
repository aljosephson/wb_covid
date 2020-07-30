* Project: WB COVID
* Created on: July 2020
* Created by: alj
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
* 1 - build malawi panel
* ***********************************************************************

* reshape files which are currently long 

* income_loss 
	use				"$root/wave_01/sect7_Income_Loss", clear
	drop 			income_source_os
	tab 			income_source
	*** for renaming convention 
	reshape 		wide s7q1 s7q2, i(y4_hhid HHID) j(income_source)
* rename new variables	
	rename 			s7q11 income_farm
	label 			var income_farm "income from farming, fishing, livestock in last 12 months"
	rename			s7q21 change_income_farm 
	label 			var change_income_farm "change in income from farming since covid"
	rename 			s7q12 income_fambiz
	label 			var income_fambiz "income from non-farm family business in last 12 months"
	rename			s7q22 change_income_fambiz
	label 			var change_income_fambiz "change in income from non-farm family business since covid"	
	rename 			s7q13 income_wage
	label 			var income_wage "income from wage employment in last 12 months"
	rename			s7q23 change_income_wage
	label 			var change_income_wage "change in income from wage employment since covid"	
	rename 			s7q14 income_remitab
	label 			var income_remitab "income from remittances abroad in last 12 months"
	rename			s7q24 change_income_remitab
	label 			var change_income_remitab "change in income from remittances abroad since covid"	
	rename 			s7q15 income_remitdom
	label 			var income_remitdom "income from remittances domestic in last 12 months"
	rename			s7q25 change_income_remitdom
	label 			var change_income_remitdom "change in income from remittances domestic since covid"	
	rename 			s7q16 income_asst
	label 			var income_asst "income from assistance from non-family in last 12 months"
	rename			s7q26 change_income_asst
	label 			var change_income_asst "change in income from assistance from non-family since covid"
	rename 			s7q17 income_invest
	label 			var income_invest "income from properties, investment in last 12 months"
	rename			s7q27 change_income_invest
	label 			var change_income_invest "change in income from properties, investment since covid"
	rename 			s7q18 income_pension
	label 			var income_pension "income from pension in last 12 months"
	rename			s7q28 change_income_pension
	label 			var change_income_pension "change in income from pension since covid"
	rename 			s7q19 income_gov
	label 			var income_gov "income from government assistance in last 12 months"
	rename			s7q29 change_income_gov
	label 			var change_income_gov "change in income from government assistance since covid"	
	rename 			s7q110 income_ngo
	label 			var income_ngo "income from NGO assistance in last 12 months"
	rename			s7q210 change_income_ngo
	label 			var change_income_ngo "change in income from NGO assistance since covid"
	rename 			s7q196 income_other
	label 			var income_other "income from other source in last 12 months"
	rename			s7q296 change_income_other
	label 			var change_income_other "change in income from other source since covid"	
	rename 			s7q199 income_total
	label 			var income_total "income total last 12 months - unclear"
	rename			s7q299 change_income_total
	label 			var change_income_total "change in total income since covid"	
* save new file 
	save			"$export/wave_01/sect7_Income_Loss", replace

*** REDO SAFETY NETS *** 	
	
* safety_nets 
	use				"$root/wave_01/sect11_Safety_Nets", clear	
	drop 			s11q3_os
	tab 			social_safetyid
	*** for renaming convention 
	reshape 		wide s11q1 s11q2 s11q3, i(y4_hhid HHID) j(social_safetyid)
* rename new variables
	rename 			s11q11 asst_01 
	rename 			s11q21 food_val_cov
	rename 			s11q31 food_source
	rename 			s11q12 asst_03 
	rename 			s11q22 cash_value_cov
	rename 			s11q32 cash_source
	rename 			s11q13 asst_05 
	rename 			s11q23 other_value_cov
	rename 			s11q33 other_source
* save new file 
	save			"$export/wave_01/sect11_Safety_Nets", replace
	
	
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
	
* reformat HHID
	rename			HHID HHID_an
	label 			var HHID_an "32 character alphanumeric - str32"
	encode 			HHID_an, generate(HHID)
	label           var HHID "unique identifier of the interview"
	format 			%12.0f HHID
	order 			y4_hhid HHID HHID_an
	
* rationalize variables across waves
	
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
	rename			kn1_heard know
	rename			kn2_meas_handwash know_01
	rename			kn2_meas_handshake know_02
	rename			kn2_meas_maskglove know_03
	rename			kn2_meas_travel know_04
	rename			kn2_meas_stayhome know_05
	rename			kn2_meas_gatherings know_06
	rename			kn2_meas_distance know_07
	rename			kn2_meas_facetouch know_08
	rename			kn3_gov gov
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
	rename			ac5_edu_type edu
	rename			ac5_edu_type_1 edu_01
	rename			ac5_edu_type_2 edu_02
	rename			ac5_edu_type_3 edu_03
	rename			ac5_edu_type_4 edu_04
	rename			ac5_edu_type_5 edu_05
	rename			ac6_med med
	rename			ac7_med_access med_access
	rename			ac8_med_access_reas med_access_why
	rename			ac9_bank bank 
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
	rename			em19_bus_inc_low_why bus_why
	rename			em19_bus_inc_low_why_1 bus_why_01
	rename			em19_bus_inc_low_why_2 bus_why_02
	rename			em19_bus_inc_low_why_3 bus_why_03
	rename			em19_bus_inc_low_why_4 bus_why_04
	rename			em19_bus_inc_low_why_5 bus_why_05
	rename			em19_bus_inc_low_why_6 bus_why_06
	rename			em19_bus_inc_low_why_7 bus_why_07
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
	rename			lc3_total_chg tot_inc_chg
	rename			lc4_total_chg_cope cope
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
	rename			fi7_outoffood fies_01
	rename			fi8_hungrynoteat fies_02
	rename			fi6_noteatfullday fies_03
	rename			as1_assist_type asst
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
	rename			fi1_enough fies_04
	rename			fi2_healthy fies_05
	rename			fi3_fewkinds fies_06
	rename			fi4_skipmeal fies_07
	rename			fi5_ateless fies_08
	
* drop unnecessary variables
	drop			kn3_gov_0 kn3_gov__98 kn3_gov__99 kn3_gov__96 kn3_gov_other ///
						ac2_atb_med_why_other ac2_atb_teff_why_other ///
						ac2_atb_wheat_why_other ac2_atb_maize_why_other ///
						ac2_atb_oil_why_other ac5_edu_type__98 ac5_edu_type__99 ///
						ac5_edu_type__96 ac5_edu_type_other ac8_med_access_reas_other ///
						em9_work_change_why_other em5_work_pre_status_other ///
						em3_work_no_why_other em4_work_pre_act_other ///
						em16_bus_sector_other em14_work_cur_notable_why_other ///
						em19_bus_inc_low_why__98 em19_bus_inc_low_why__99 ///
						em19_bus_inc_low_why__96 em19_bus_inc_low_why_other ///
						em22_farm_norm_why__98 em22_farm_norm_why__99 ///
						em22_farm_norm_why__96 em22_farm_norm_why_other ///
						lc1_other lc1_other_source lc2_other_chg ///
						as1_assist_type__98 as1_assist_type__99 ///
						as1_assist_type__96 as1_assist_type_other ///
						as4_food_source_other as4_forwork_source_other ///
						as4_cash_source_other as4_other_source_other ///
						ir1_endearly ir1_whyendearly ir1_whyendearly_other ///
						ir_lang ir_understand ir_confident key ///
						em15b_bus_prev_closed_other lc4_total_chg_cope__98 ///
						lc4_total_chg_cope__99 lc4_total_chg_cope__96 ///
						lc4_total_chg_cope_other

* reorder variables
	order			fies_04 fies_05 fies_06 fies_07 fies_08, after(fies_03)
	order 			resp_same resp_gender resp_age resp_hhh, after(hhh_age)
	order			bus_prev bus_prev_close bus_new, after(bus_why_07)
	

* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 

* save file
		customsave , idvar(HHID) filename("mal_panel.dta") ///
			path("$export") dofile(mal_build) user($user)

* close the log
	log	close

/* END */