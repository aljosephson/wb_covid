* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by : jdm
* Last edited: 29 September 2020
* Stata v.16.1

* does
	* merges together each section of Uganda data
	* renames variables
	* outputs single cross section data

* assumes
	* raw Uganda data

* TO DO:
	* clean agriculture and livestock


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	root	=	"$data/uganda/raw"
	global	fies	=	"$data/analysis/raw/Uganda"
	global	export	=	"$data/uganda/refined"
	global	logout	=	"$data/uganda/logs"

* open log
	cap log 		close
	log using		"$logout/uga_build", append


* **********************************************************************
* 5 - build uganda panel
* **********************************************************************

* load round 1 of the data
	use				"$root/wave_01/r1_sect_all.dta", ///
						clear

* append round 2 of the data
	append 			using "$root/wave_02/r2_sect_all", ///
						force

* merge in consumption aggregate
	merge m:1		baseline_hhid using "$export/wave_01/pov_r0.dta", nogenerate
	

	
	
	
	
	
* rename income variables
	rename 			s6q011 farm_inc
	lab	var			farm_inc "Income from farming, fishing, livestock in last 12 months"
	rename			s6q021 farm_chg
	lab var			farm_chg "Change in income from farming since covid"
	rename 			s6q012 bus_inc
	lab var			bus_inc "Income from non-farm family business in last 12 months"
	rename			s6q022 bus_chg
	lab var			bus_chg "Change in income from non-farm family business since covid"
	rename 			s6q013 wage_inc
	lab var			wage_inc "Income from wage employment in last 12 months"
	rename			s6q023 wage_chg
	lab var			wage_chg "Change in income from wage employment since covid"
	rename			s6q014 unemp_inc
	lab var			unemp_inc "Income from unemployment benefits in the last 12 months"
	rename			s6q024 unemp_chg
	lab var			unemp_chg "Change in income from unemployment benefits since covid"
	rename 			s6q015 rem_for
	label 			var rem_for "Income from remittances abroad in last 12 months"
	rename			s6q025 rem_for_chg
	label 			var rem_for_chg "Change in income from remittances abroad since covid"
	rename 			s6q016 rem_dom
	label 			var rem_dom "Income from remittances domestic in last 12 months"
	rename			s6q026 rem_dom_chg
	label 			var rem_dom_chg "Change in income from remittances domestic since covid"
	rename 			s6q017 asst_inc
	label 			var asst_inc "Income from assistance from non-family in last 12 months"
	rename			s6q027 asst_chg
	label 			var asst_chg "Change in income from assistance from non-family since covid"
	rename 			s6q018 isp_inc
	label 			var isp_inc "Income from properties, investment in last 12 months"
	rename			s6q028 isp_chg
	label 			var isp_chg "Change in income from properties, investment since covid"
	rename 			s6q019 pen_inc
	label 			var pen_inc "Income from pension in last 12 months"
	rename			s6q029 pen_chg
	label 			var pen_chg "Change in income from pension since covid"
	rename 			s6q0110 gov_inc
	label 			var gov_inc "Income from government assistance in last 12 months"
	rename			s6q0210 gov_chg
	label 			var gov_chg "Change in income from government assistance since covid"
	rename 			s6q0111 ngo_inc
	label 			var ngo_inc "Income from NGO assistance in last 12 months"
	rename			s6q0211 ngo_chg
	label 			var ngo_chg "Change in income from NGO assistance since covid"
	rename 			s6q0196 oth_inc
	label 			var oth_inc "Income from other source in last 12 months"
	rename			s6q0296 oth_chg
	label 			var oth_chg "Change in income from other source since covid"	
	
	
* shock variables
	lab var			shock_01 "Death of disability of an adult working member of the household"
	lab var			shock_02 "Death of someone who sends remittances to the household"
	lab var			shock_03 "Illness of income earning member of the household"
	lab var			shock_04 "Loss of an important contact"
	lab var			shock_05 "Job loss"
	lab var			shock_06 "Non-farm business failure"
	lab var			shock_07 "Theft of crops, cash, livestock or other property"
	lab var			shock_08 "Destruction of harvest by insufficient labor"
	lab var			shock_09 "Disease/Pest invasion that caused harvest failure or storage loss"
	lab var			shock_10 "Increase in price of inputs"
	lab var			shock_11 "Fall in the price of output"
	lab var			shock_12 "Increase in price of major food items c"
	lab var			shock_13 "Floods"
	lab var			shock_14 "Other shock"

	lab def			shock 0 "None" 1 "Severe" 2 "More Severe" 3 "Most Severe"

	foreach var of varlist shock_01-shock_14 {
		lab val		`var' shock
		}

* generate any shock variable
	gen				shock_any = 1 if shock_01 == 1 | shock_02 == 1 | ///
						shock_03 == 1 | shock_04 == 1 | shock_05 == 1 | ///
						shock_06 == 1 | shock_07 == 1 | shock_08 == 1 | ///
						shock_09 == 1 | shock_10 == 1 | shock_11 == 1 | ///
						shock_12 == 1 | shock_13 == 1 | shock_14== 1
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
	
drop			BSEQNO start_date sec0_endtime						
	
* rename government contribution to spread
	rename			s2gq02__1 spread_01
	rename			s2gq02__2 spread_02
	rename			s2gq02__3 spread_03
	rename			s2gq02__4 spread_04
	rename			s2gq02__5 spread_05
	rename			s2gq02__6 spread_06
	

* rename access
	rename			s4q01e ac_drink
	rename			s4q01f ac_drink_why

	rename 			s4q01 ac_soap
	rename			s4q02 ac_soap_why
	replace			ac_soap_why = 9 if ac_soap_why == -96
	replace			ac_soap_why = . if ac_soap_why == 99
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "cannot afford it" 8 "afraid to go out" 9 "other"
	lab var 		ac_soap_why "reason for unable to purchase soap"

	rename 			s4q03 ac_water
	rename 			s4q04 ac_water_why
	
	rename 			s4q05 ac_staple_def
	rename 			s4q06 ac_staple
	rename			s4q07 ac_staple_why
	replace			ac_staple_why = 7 if ac_staple_why == -96
	lab def			ac_staple_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	lab var 		ac_staple_why "reason for unable to purchase staple food"
	
	rename 			s4q07a ac_sauce_def
	rename 			s4q07b ac_sauce
	rename			s4q07c ac_sauce_why
	replace			ac_sauce_why = 7 if ac_sauce_why == -96
	lab def			ac_sauce_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "other"
	lab var 		ac_sauce_why "reason for unable to purchase staple food"
	
	rename 			s4q08 ac_med

	rename 			s4q09 ac_medserv_need
	rename 			s4q10 ac_medserv
	rename 			s4q11 ac_medserv_why
	replace			ac_medserv_why = 3 if ac_medserv_why == 5
	replace			ac_medserv_why = 5 if ac_medserv_why == 7
	replace 		ac_medserv_why = 7 if ac_medserv_why == 4
	replace			ac_medserv_why = 4 if ac_medserv_why == -96
	lab def			ac_medserv_why 1 "no money" 2 "no med personnel" 3 "facility full / closed" ///
								4 "other" 5 "no transportation" 6 "restrictions to go out" ///
								7 "afraid of virus" 8 "facility closed "
	lab var 		ac_medserv_why "reason for unable to access medical services"

* rename assets 
	rename			s4q12__1 asset_1
	rename			s4q12__2 asset_2
	rename			s4q12__3 asset_3
	rename			s4q12__4 asset_4
	rename			s4q12__5 asset_5

	drop			s4q01f_Other s4q02_Other s4q04_Other s4q11_Other case_filter	
	
* rename symptoms
	rename			s2q01b__1 symp_1
	rename			s2q01b__2 symp_2
	rename			s2q01b__3 symp_3
	rename			s2q01b__4 symp_4
	rename			s2q01b__5 symp_5
	rename			s2q01b__6 symp_6
	rename			s2q01b__7 symp_7
	rename			s2q01b__8 symp_8
	rename			s2q01b__9 symp_9
	rename			s2q01b__10 symp_10
	rename			s2q01b__11 symp_11
	rename			s2q01b__12 symp_12
	rename			s2q01b__13 symp_13
	rename			s2q01b__14 symp_14
	rename			s2q01b__n98 symp_15	
	
* rename knowledge
	rename			s2q02__1 know_1
	lab var			know_1 "Handwashing with Soap Reduces Risk of Coronavirus Contraction"
	rename			s2q02__2 know_9
	lab var			know_9 "Use of Sanitizer Reduces Risk of Coronavirus Contraction"
	rename			s2q02__3 know_2
	lab var			know_2 "Avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract"
	rename			s2q02__4 know_3
	lab var			know_3 "Using Masks and/or Gloves Reduces Risk of Coronavirus Contraction"
	rename			s2q02__5 know_10
	lab var			know_10 "Using Gloves Reduces Risk of Coronavirus Contraction"
	rename			s2q02__6 know_4
	lab var			know_4 "Avoiding Travel Reduces Risk of Coronavirus Contraction"
	rename			s2q02__7 know_5
	lab var			know_5 "Staying at Home Reduces Risk of Coronavirus Contraction"
	rename			s2q02__8 know_6
	lab var			know_6 "Avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction"
	rename			s2q02__9 know_7
	lab var			know_7 "Mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Contraction"
	rename			s2q02__10 know_8
	lab var			know_8 "Avoiding Face Touching Reduces Risk of Coronavirus Contraction"	
	
* rename myths
	rename			s2q02a_1 myth_1
	rename			s2q02a_2 myth_2
	rename			s2q02a_3 myth_3
	rename			s2q02a_4 myth_4
	rename			s2q02a_5 myth_5
	rename			s2q02a_6 myth_6
	rename			s2q02a_7 myth_7	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
* rename basic information
	rename			wfinal phw
	lab var			phw "sampling weights"
	
	gen				sector = 2 if urban == 1
	replace			sector = 1 if sector == .
	lab var			sector "Sector"
	lab def			sector 1 "Rural" 2 "Urban"
	lab val			sector sector
	drop			urban
	order			sector, after(phw)

	gen				Region = 4012 if region == "Central"
	replace			Region = 4013 if region == "Eastern"
	replace			Region = 4014 if region == "Kampala"
	replace			Region = 4015 if region == "Northern"
	replace			Region = 4016 if region == "Western"
	lab define		region 1001 "Tigray" 1002 "Afar" 1003 "Amhara" 1004 ///
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
	lab val			Region region
	drop			region
	rename			Region region
	order			region, after(sector)
	lab var			region "Region"
	
	rename			DistrictCode zone_id
	rename			CountyCode county_id
	rename			SubcountyCode city_id
	rename			ParishCode subcity_id

	rename			Sq02 start_date
	rename			s2q01 know
	rename			s2gq01 revised
	
* **********************************************************************
* 6 - end matter, clean up to save
* **********************************************************************

	compress
	describe
	summarize

	rename HHID hhid_uga
	drop if hhid_uga == .

* save file
		customsave , idvar(hhid_uga) filename("uga_panel.dta") ///
			path("$export") dofile(uga_build) user($user)

* close the log
	log	close

/* END */
