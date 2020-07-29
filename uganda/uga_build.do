* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Stata v.16.1

* does
	* merges together each section of uganda data
	* renames variables
	* outputs single cross section data

* assumes
	* raw Ethiopia data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/uganda/raw"
	global	export	=	"$data/uganda/refined"
	global	logout	=	"$data/uganda/logs"

* open log
	cap log 		close
	log using		"$logout/uga_build", append

	

* ***********************************************************************
* 1 - build ethiopia panel
* ***********************************************************************

* load cover data
	use				"$root/wave_01/Cover", clear

* merge in other sections
	merge 1:1 		HHID using "$root/wave_01/SEC2.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC3.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC4.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC5.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC7.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC8.dta", keep(match) nogenerate
	merge 1:1 		HHID using "$root/wave_01/SEC9A.dta", keep(match) nogenerate
	*** sections 6, 9, and 10 did not merges
	*** will have to reformat them and then merge
	
* reformat HHID
	format 			%12.0f HHID
	
	
* ***********************************************************************
* 2 - rationalize variable names
* ***********************************************************************

* rename basic information
	rename			wfinal phw
	lab var			phw "sampling weights"
	
	rename			HHID household_id
	lab var			household_id "Household ID (Full)"
	
	gen				wave = 1
	lab var			wave "Wave number"
	order			baseline_hhid wave phw, after(household_id)
	
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

	rename			DistrictCode zone_id
	rename			CountyCode county_id
	rename			SubcountyCode city_id
	rename			ParishCode subcity_id
	rename			EaCode ea
	rename			VillageCode neighborhood_id
	
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

* behavioral changes
	rename			s3q01 bh_01
	rename			s3q02 bh_02
	rename			s3q03 bh_03
	rename			s3q05 bh_04
	rename			s3q06 bh_05

* access
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
	drop			interview__id interview__key BSEQNO DistrictName ///
						CountyName SubcountyName ParishName EaName VillageName ///
						subreg s2q01b__n96 s2q01b_Other

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
		customsave , idvar(household_id) filename("eth_panel.dta") ///
			path("$export") dofile(eth_build) user($user)

* close the log
	log	close

/* END */