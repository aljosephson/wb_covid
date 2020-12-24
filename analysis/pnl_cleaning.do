* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edit: 28 September 2020 
* Stata v.16.1

* does
	* merges together all countries
	* renames variables
	* output cleaned panel data

* assumes
	* cleaned country data

* TO DO:
	* finish cleaning credit variables
	* clean access why variables
	* NOTE make sure add regions and labels  to countries 2-4

* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	eth		=	"$data/ethiopia/refined" 
	global	mwi		=	"$data/malawi/refined"
	global	nga		=	"$data/nigeria/refined" 
	global	uga		=	"$data/uganda/refined"
	global	export	=	"$data/analysis"
	global	logout	=	"$data/analysis/logs"

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
		
* open log
	cap log 		close
	log using		"$logout/analysis", append
	}

* **********************************************************************
* 1 - build data set
* **********************************************************************
/*
* run do files for each country (takes a little while to run)
	run				"$code/ethiopia/eth_build_master"
	run 			"$code/malawi/mwi_build_master"
	run				"$code/nigeria/nga_build_master"
	run 			"$code/uganda/uga_build_master"
*/
* read in data
	use				"$eth/eth_panel", clear	
	append using 	"$mwi/mwi_panel"	
	append using 	"$nga/nga_panel"
	append using	"$uga/uga_panel"
	
	order			country
	lab def			country 1 "Ethiopia" 2 "Malawi" 3 "Nigeria" 4 "Uganda", replace
	lab val			country country	
	lab var			country "Country"
	
	
* **********************************************************************
* 2 - revise ID variables as needed 
* **********************************************************************

* drop variables with open responses
	drop dis_gov* sup_cmpln_done sup_cmpln_who emp_safos

* drop if variable contains all missing values
	foreach var of varlist _all {
		 capture assert mi(`var')
		 if !_rc {
			drop `var'
		 }
	 }

* define yes/no label
	lab	def				yesno 0 "No" 1 "Yes", replace

* generate household id
	replace 		hhid_eth = "e" + hhid_eth if hhid_eth != ""
	replace 		hhid_mwi = "m" + hhid_mwi if hhid_mwi != ""	
	tostring		hhid_nga, replace
	replace 		hhid_nga = "n" + hhid_nga if hhid_nga != "."
	replace			hhid_nga = "" if hhid_nga == "."	
	rename 			hhid_uga hhid_uga1
	egen 			hhid_uga = group(hhid_uga1)
	tostring 		hhid_uga, replace 	
	replace 		hhid_uga = "" if country != 4
	replace 		hhid_uga = "u" + hhid_uga if hhid_uga != ""	
	gen				HHID = hhid_eth if hhid_eth != ""
	replace			HHID = hhid_mwi if hhid_mwi != ""
	replace			HHID = hhid_nga if hhid_nga != ""
	replace			HHID = hhid_uga if hhid_uga != ""	
	sort			HHID
	egen			hhid = group(HHID)
	drop			HHID hhid_eth hhid_mwi hhid_nga hhid_uga
	lab var			hhid "Unique household ID"
	order 			hhid resp_id hhid*, after(country)

* generate weights
	rename			phw hhw
	lab var			hhw "Household sampling weight"
	gen				phw = hhw * hhsize
	lab var			phw "Population weight"
	gen 			ahw = hhw * hhsize_adult
	lab var 		ahw "Household adult sampling weight"
	gen 			chw = hhw * hhsize_child 
	lab var 		chw "Household child sampling weight"
	gen 			shw = hhw * hhsize_schchild
	lab var 		shw "Household school child sampling weight"	
	order			phw ahw chw shw, after(hhw)
						
* know 
	forval 			x = 1/11 {
		replace 	know_`x' = 0 if know_`x' == 2
		lab val 	know_`x' yesno
	}

* behavior (QC THIS - double check)
	replace 		bh_1 = 0 if bh_1 > 1 & bh_1 != .
	replace 		bh_2 = 0 if bh_2 < 3 & country == 2
	replace 		bh_2 = 1 if bh_2 > 0 & country == 2 & bh_2 != .
	replace 		bh_2 = 0 if bh_2 == 2
	replace 		bh_2 = . if bh_2 == 3
	replace 		bh_3 = . if bh_3 == 3 | bh_3 < 0
	replace 		bh_3 = 0 if bh_3 == 2
	replace 		bh_4 = 0 if bh_4 == 2
	replace 		bh_5 = 0 if bh_5 == 2
	replace 		bh_7 = . if bh_7 < 0
	replace 		bh_8 = . if bh_7 < 0
	order 			bh_2 bh_3 bh_4 bh_5 bh_6* bh_7 bh_8* bh_9, after(bh_1)
	* NOTE: there were errors in recoding here, corrected
	order			gov_13 gov_14 gov_15 gov_16 gov_none gov_dnk, after(gov_12)
	order			edu hhsize, after(relate_hoh)

* coping (create cope_any = 1 if any coping used, 0 if not, . if no data for that wave)
	egen 			tempgrp = group(country wave)
	levelsof		(tempgrp), local(countrywave)
	foreach 		cw in `countrywave' {
		preserve 
		keep 		if tempgrp == `cw' 
		gen			cope_any = 1 if cope_1 == 1 | cope_2 == 1 | cope_3 == 1 | ///
					cope_4 == 1 | cope_5 == 1 | cope_6 == 1 | ///
					cope_7 == 1 | cope_8 == 1 | cope_9 == 1 | ///
					cope_10 == 1 | cope_11 == 1 | cope_12 == 1 | ///
					cope_13 == 1 | cope_14 == 1 | cope_15 == 1
		egen 		cope_tot = total(cope_any)
		replace 	cope_any = 0 if cope_any == . & cope_tot != 0
		tempfile 	temp`cw'
		save 		`temp`cw''
		restore
	}
	clear
	foreach 		cw in `countrywave' {
		append 		using `temp`cw''
	}
	drop 			tempgrp cope_tot cope_16 cope_17
	lab var			cope_any "Adopted any coping strategy"
	lab val 		cope_any yesno
	
	gen				cope_none = 1 if cope_any == 0
	replace			cope_none = 0 if cope_any == 1
	lab var			cope_none "Did nothing"

	order 			cope_none cope_any, before(cope_1)
	
	lab def			myth 0 "No" 1 "Yes" 3 "Don't Know"
	
	local myth		 myth_1 myth_2 myth_3 myth_4 myth_5
	foreach v in `myth' {
	    replace `v' = 3 if `v' == -98
		replace `v' = 0 if `v' == 2
		lab val	`v' myth
	}	
	

* **********************************************************************
* 3- revise access variables as needed 
* **********************************************************************
	order			ac_med_need ac_med ac_med_why ///
						ac_medserv_need ac_medserv ac_medserv_why ///
						ac_soap_need ac_soap ac_soap_why ///
						ac_staple_def ac_staple_need ac_staple ac_staple_why ///
						ac_oil ac_oil_why  ///
						ac_teff ac_teff_why ac_wheat ac_wheat_why ///
						ac_maize_need ac_maize ac_maize_why ///
						ac_rice_need ac_rice ac_rice_why ///
						ac_beans_need ac_beans ac_beans_why ///
						ac_cass_need ac_cass ac_cass_why ///
						ac_yam_need ac_yam ac_yam_why ///
						ac_sorg_need ac_sorg ac_sorg_why ///
						ac_clean_need ac_clean ac_clean_why ///
						ac_water ac_water_why ///
						ac_bank ac_bank_why, after(bh_8)	
	
* access to medicine 
	replace				ac_med = . if ac_med < 0 & country == 1	
	replace				ac_med = 0 if ac_med == 2 
	replace				ac_med = . if ac_med == 3
	replace 			ac_med_why = . if ac_med_why < 0
	* note "decrease in reg income" and "no money" both coded as 6
 	
* access to medical services
	replace				ac_medserv_need = . if ac_medserv_need < 0 | ac_medserv_need == 99
	replace 			ac_medserv_need = 0 if ac_medserv_need == 2
	
	replace				ac_medserv = . if ac_medserv == 99
	replace 			ac_medserv = 0 if ac_medserv == 2
	
	replace 			ac_medserv_why = . if ac_medserv_why < 0
	lab def				ac_medserv_why 1 "lack of money" 2 "no med personnel" ///
								3 "facility full" 4 "facility closed" ///
								5 "not enough supplies" 6 "lack of transportation" ///
								7 "restriction to go out" 8 "afraid to get virus", replace
	lab val 			ac_medserv_why ac_medserv_why
	
* access to pre-natal care
	replace 			ac_nat_filter = 0 if ac_nat_filter == 2
	replace 			ac_nat_need = 0 if ac_nat_need == 2
	replace 			ac_nat_need = . if ac_nat_need > 97
	
	replace 			ac_nat = 0 if ac_nat == 2
 
* access to preventative care 
	replace 			ac_prev_app = 0 if ac_prev_app == 2

* access to vaccines	
	replace 			ac_vac = 0 if ac_vac == 2
	replace 			ac_vac_need = 0 if ac_vac_need == 2
	
* access to soap
	replace 			ac_soap = 0 if ac_soap == 2
	replace 			ac_soap_why = . if ac_soap_why == 96 | ac_soap_why == 9	
	
* access to staples
	* Ethiopia
		foreach 		var in ac_oil ac_teff ac_wheat ac_maize {
			replace 	`var' = . if `var' < 0
		}
		// change not applicable/did not need to buy to not needed (2)
		replace			ac_staple_need = 2 if country == 1 & (ac_oil == . & ac_teff == . & ///
						ac_wheat == . & ac_maize == .)
		// change missing ac_staple_need (needed to buy) to 1 
		replace			ac_staple_need = 1 if ac_staple_need == . & country == 1	
		replace			ac_staple = 1 if ac_staple_need == 1 & country == 1 & ///
						(ac_oil == 1 | ac_teff == 1 | ac_wheat == 1 | ac_maize == 1) 	
		replace			ac_staple = 0 if ac_staple == . & ac_staple_need == 1 & ///
						country == 1	
	* Malawi 
		replace 		ac_maize_why = . if ac_maize_why < 0 | ac_maize_why == 7
		replace 		ac_maize = 0 if ac_maize == 2
		replace 		ac_maize_need = 0 if ac_maize_need == 2
		replace 		ac_staple = 0 if ac_staple == 2 & country == 2
		replace 		ac_staple_need = 0 if ac_staple_need == 2
	* Nigeria
		foreach 		s in rice beans cass yam sorg  {
			replace 	ac_`s' = 0 if ac_`s' == 2
			replace 	ac_`s'_need = 0 if ac_`s'_need == 2
		}
		replace 		ac_staple_need = 1 if country == 3 & (ac_rice_need == 1 | ///
						ac_beans_need == 1 | ac_cass_need == 1 | ac_yam_need == 1 | ///
						ac_sorg_need == 1)
		replace 		ac_staple_need = 0 if country == 3 & ac_rice_need == 0 & ///
						ac_beans_need == 0 & ac_cass_need == 0 & ac_yam_need == 0 & ///
						ac_sorg_need == 0
		replace 		ac_staple = 1 if country == 3 & (ac_rice == 1 | ac_beans == 1 | ///
						ac_cass == 1 | ac_yam == 1 | ac_sorg == 1)
		replace 		ac_staple = 0 if country == 3 & ((ac_rice == 0 & ac_rice_need == 1 ) ///
						| (ac_beans == 0 & ac_beans_need == 1) | (ac_cass == 0 & ac_cass_need == 1) ///
						| (ac_yam == 0 & ac_yam_need == 1)  | (ac_sorg == 0 & ac_sorg_need == 1))
	* Uganda
		replace 		ac_staple_need = 0 if ac_staple == 3 & country == 4
		replace 		ac_staple_need = 1 if ac_staple == 1 | ac_staple == 2
		replace 		ac_staple = . if ac_staple == 3 & country == 4
		replace 		ac_staple = 0 if ac_staple == 1 & country == 4
		replace 		ac_staple = 1 if ac_staple == 2 & country == 4
		replace 		ac_sauce = . if ac_sauce == 3
		replace 		ac_sauce = 0 if ac_sauce == 2
	
* access to drinking water
	replace 			ac_drink = . if ac_drink == 3 & country == 2
	replace 			ac_drink = 0 if ac_drink == 1 & (country == 2 | country == 4)
	replace 			ac_drink = 1 if ac_drink == 2 & (country == 2 | country == 4)
	replace 			ac_drink = 0 if ac_drink == 2 & country == 3

	replace 			ac_drink_why = . if (ac_drink_why == -96 | ac_drink_why > 94)
	lab def 			ac_drink_why 1 "water supply not available" 2 "water supply reduced" ///
						3 "unable to access communal supply" 4 "unable to access water tanks" ///
						5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
						8 "restriction to go out" 9 "increase in price" 10 "cannot afford", replace
	lab val 			ac_drink_why ac_drink_why 	

* access to water for handwashing	
	replace 			ac_water = 0 if ac_water == 2
	
	replace 			ac_water_why = . if (ac_water_why < 0 | ac_water_why > 94)
	lab def 			ac_water_why 1 "water supply not available" 2 "water supply reduced" ///
						3 "unable to access communal supply" 4 "unable to access water tanks" ///
						5 "shops ran out" 6 "markets not operating" 7 "no transportation" ///
						8 "restriction to go out" 9 "increase in price" 10 "cannot afford" ///
						11 "afraid to get viurs" 12 "water source too far" ///
						13 "too many people at water source" 14 "large household size" ///
						15 "lack of money", replace
	lab val 			ac_water_why ac_water_why
	
* access to cleaning supllies
	replace 			ac_clean_need = 0 if ac_clean_need == 2
	replace 			ac_clean = 0 if ac_clean == 2

* access to bank 
	replace 			ac_bank = 0 if ac_bank == 2
	replace 			ac_bank_why = . if ac_bank_why < 0 | ac_bank_why > 95

* access to credit
	replace 			ac_cr_need = 0 if ac_cr_need == 2
	
	replace 			ac_cr_loan = . if ac_cr_loan < 0
	replace 			ac_cr_loan = 0 if ac_cr_loan == 2
	lab def 			ac_cr_loan 0 "Unable or did not try" 1 "Yes"
	lab val 			ac_cr_loan ac_cr_loan 
	* NOTE: Uganda data seems off, missing instead of "no"

	lab var 			ac_cr_lend_1 "Lender: friend or relative"
	lab var 			ac_cr_lend_2 "Lender: neighbour"
	lab var 			ac_cr_lend_3 "Lender: local merchant"
	lab var 			ac_cr_lend_4 "Lender: money lender"
	lab var 			ac_cr_lend_5 "Lender: employer"
	lab var 			ac_cr_lend_6 "Lender: religious institution"
	lab var 			ac_cr_lend_7 "Lender: microfinance institution"
	lab var 			ac_cr_lend_8 "Lender: bank"
	lab var 			ac_cr_lend_9 "Lender: NGO"
	lab var 			ac_cr_lend_10 "Lender: saccos"	
	lab var 			ac_cr_lend_11 "Lender: cooperative society"
	lab var 			ac_cr_lend_12 "Lender: saving association"
	lab var 			ac_cr_lend_13 "Lender: hire purchase"
	lab var 			ac_cr_lend_14 "Lender: womens group"

	drop 				ac_cr_why* ac_cr_who* ac_cr_bef_why* ac_cr_bef_who* ///
						ac_cr_slc_why* ac_cr_slc_who*
	* NOTE: dropped because very inconsistent across countries - can add back and clean if needed
	
	replace 			ac_cr_due = 7 if ac_cr_due == -97
	lab def 			ac_cr_due 1 "Already Due" 2 "Within One Month" 3 "Within 2-3 Months" ///
						4 "Within 4-6 Months" 5 "Within 7-12 Months" 6 "More Than 12 Months" ///
						7 "Already Repaid"
	lab val 			ac_cr_due ac_cr_due 
	
	replace 			ac_cr_bef = . if ac_cr_bef < 0
	replace 			ac_cr_bef = 0 if ac_cr_bef ==2
	
	replace 			ac_cr_worry = . if ac_cr_worry == -99
	replace 			ac_cr_worry =  5 if ac_cr_worry == -97
	lab def 			ac_cr_worry 1 "very worried" 2 "somewhat worried" 3 "not too worried" ///
						4 "not worried at all" 5 "already repaid"
	lab val 			ac_cr_worry ac_cr_worry 
	
	replace 			ac_cr_miss = . if ac_cr_miss < 0
	replace 			ac_cr_miss = 0 if ac_cr_miss == 2
	
	replace 			ac_cr_delay = . if ac_cr_delay < 0 | ac_cr_delay > 97
	replace 			ac_cr_delay = 0 if ac_cr_delay == 2
	
	replace 			ac_cr_att = 0 if ac_cr_att == 2
	replace 			ac_cr_slc = 0 if ac_cr_slc == 2	
	
***Uganda asks credit by loan number, need to clean to match format of other countries


* negate questions (unable to access) 
 /* NOTE: cannot negate preventative care and credit (only mwi & nga ask if needed loan, 
	others just ask if took out loan, not if able to access loan) */
	foreach 			var in ac_soap ac_med ac_medserv ac_nat ac_vac ac_oil ac_teff ///
						ac_wheat ac_maize ac_rice ac_beans ac_cass ac_yam ac_sorg ///
						ac_staple ac_sauce ac_clean ac_nat ac_bank ac_water ac_drink {
		replace 		`var' = 2 if `var' == 1
		replace 		`var' = 1 if `var' == 0
		replace 		`var' = 0 if `var' == 2
		lab val 		`var' yesno
	}

	lab var				ac_med "Unable to access medicine"
	lab var 			ac_medserv "Unable to access medical services"
	lab var 			ac_nat "Unable to access pre/post-natal care"
	lab var 			ac_vac "Unable to access vaccines"
	lab var				ac_soap "Unable to access soap"
	lab var				ac_oil "Unable to access oil"
	lab var				ac_teff "Unable to access teff"
	lab var				ac_wheat "Unable to access wheat"
	lab var				ac_maize "Unable to access maize"
	lab var				ac_rice "Unable to access rice"
	lab var				ac_beans "Unable to access beans"
	lab var				ac_cass "Unable to access cassava"
	lab var				ac_yam "Unable to access yam"
	lab var				ac_sorg "Unable to access sorghum"
	lab var				ac_staple "Unable to access staple"
	lab var				ac_sauce "Unable to access sauce"
	lab var				ac_clean "Unable to access cleaning supplies"
	lab var				ac_nat "Unable to access pre-natal care"
	lab var				ac_bank "Unable to access bank"
	lab var				ac_water "Unable to access water for handwashing"
	lab var				ac_drink "Unable to access drinking water"

 * access to masks (already asks "unable")
	replace 			ac_mask = . if ac_mask == 3
	replace 			ac_mask = 0 if ac_mask == 2
	lab val 			ac_mask yesno
	
	lab var 		ac_soap_why "Reason unable to purchase soap"
	lab var 		ac_water_why "Reason unable to access water for washing hands"		
	lab var 		ac_drink_why "Reason unable to access water for drinking"
*** clean access why variables for consistencty and add labels here


* **********************************************************************
* 4 - clean concerns and income changes
* **********************************************************************
	
* turn concerns 1 and 2 into binary
	replace				concern_1 = 0 if concern_1 == 3 | concern_1 == 4
	replace				concern_1 = 1 if concern_1 == 2
	lab val				concern_1 yesno
	
	replace				concern_2 = 0 if concern_2 == 3 | concern_2 == 4
	replace				concern_2 = 1 if concern_2 == 2
	lab val				concern_2 yesno

	loc inc				farm_inc bus_inc wage_inc isp_inc pen_inc gov_inc ngo_inc oth_inc asst_inc
	foreach 			var of varlist `inc' {
		replace			`var' = 0 if `var' == 2
		replace			`var' = 0 if `var' == -99
		lab val			`var' yesno
		replace			`var' = . if country == 3 & (wave == 2 | wave == 3)
	}	
	* NOTE: this was an error, was replacing with missing for all variables in round 3
lksdjf 
		*** omit nigeria wave 2 and 3 due to incomplete questions 

	gen 				other_inc = 1 if isp_inc == 1 | pen_inc == 1 | gov_inc == 1 | ngo_inc == 1 | oth_inc == 1 | asst_inc == 1 
	replace 			other_inc = 0 if other_inc == . 
	lab var 			other_inc "other income sources (isp, pen, gov, ngo, oth, asst)"

	replace				farm_chg = . if farm_inc == 0
	replace				bus_chg = . if bus_inc == 0 
	replace				wage_chg = . if wage_inc == 0 
	replace				isp_chg = . if isp_inc == 0 
	replace				pen_chg = . if pen_inc == 0 
	replace				gov_chg  = . if gov_inc == 0 
	replace				ngo_chg  = . if ngo_inc == 0 
	replace				oth_chg  = . if oth_inc == 0 
	replace				asst_chg  = . if asst_inc == 0 

	lab def				change -1 "Reduce" 0 "Stayed the same" 1 "Increased"
	
	loc chg				farm_chg bus_chg wage_chg isp_chg pen_chg gov_chg ngo_chg oth_chg asst_chg rem_dom_chg rem_for_chg

	foreach var of varlist `chg' {
		replace				`var' = 0 if `var' == 2
		replace				`var' = 0 if `var' == -98
		replace				`var' = -1 if `var' == 3
		replace				`var' = -1 if `var' == 4
		lab val				`var' change
		}				

	gen 				remit_chg = 1 if rem_dom_chg == 1 | rem_for_chg == 1 
	replace 			remit_chg = 0 if remit_chg == .
	lab var 			remit_chg "change in remittances (foreign, domestic)"
	gen 				other_chg = 1 if isp_chg == 1 | pen_chg == 1 | ngo_chg == 1 | gov_chg == 1 | oth_chg == 1 | asst_chg == 1 
	replace				other_chg = 0 if other_chg == .
	lab var 			other_chg "change in other income sources (isp, pen, gov, ngo, oth, asst)"	
	
	gen					farm_dwn = 1 if farm_chg == -1
	replace				farm_dwn = 0 if farm_chg == 0 | farm_chg == 1
	gen					bus_dwn = 1 if bus_chg == -1
	replace				bus_dwn = 0 if bus_chg == 0 | bus_chg == 1
	gen					wage_dwn = 1 if wage_chg == -1
	replace				wage_dwn = 0 if wage_chg == 0 | wage_chg == 1
	gen					isp_dwn = 1 if isp_chg == -1
	replace				isp_dwn = 0 if isp_chg == 0 | isp_chg == 1
	gen					pen_dwn = 1 if pen_chg == -1
	replace				pen_dwn = 0 if pen_chg == 0 | pen_chg == 1
	gen					gov_dwn = 1 if gov_chg == -1
	replace				gov_dwn = 0 if gov_chg == 0 | gov_chg == 1
	gen					ngo_dwn = 1 if ngo_chg == -1
	replace				ngo_dwn = 0 if ngo_chg == 0 | ngo_chg == 1
	gen					rem_dom_dwn = 1 if rem_dom_chg == -1
	replace				rem_dom_dwn = 0 if rem_dom_chg == 0 | rem_dom_chg == 1
	gen					rem_for_dwn = 1 if rem_for_chg == -1
	replace				rem_for_dwn = 0 if rem_for_chg == 0 | rem_for_chg == 1

	lab var				farm_dwn "Farm income reduced"
	lab var				bus_dwn "Business income reduced"
	lab var				wage_dwn "Wage income reduced"
	lab var				isp_dwn "Investment income reduced"
	lab var				pen_dwn "Pension income reduced"
	lab var				gov_dwn "Gov. assistance reduced"
	lab var				ngo_dwn "NGO assistance reduced"
	lab var				rem_dom_dwn "Remittances (dom) reduced"
	lab var				rem_for_dwn "Remittances (for) reduced"		
	
	*egen 				dwn_count9 = rsum (farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ngo_dwn rem_dom_dwn rem_for_dwn)	
	*lab var 			dwn_count9 "count of income sources which are down - total of nine"
	*gen 				dwn_percent9 = dwn_count9 / 9
	*label var 			dwn_percent9 "percent of income sources which had losses - total of nine"
							
	loc dwn				farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ngo_dwn rem_dom_dwn rem_for_dwn		

	foreach var of varlist `dwn' {
		lab val				`var' yesno
		}				
		
	gen					work_dwn = 1 if farm_dwn == 1 | bus_dwn == 1
	replace				work_dwn = 0 if farm_dwn == 0 & work_dwn == .
	replace				work_dwn = 0 if bus_dwn == 0 & work_dwn == .
	lab var 			work_dwn "Farm/firm income reduced"
	lab val				work_dwn yesno

	gen 				remit_dwn = 1 if rem_for_dwn == 1 | rem_dom_dwn == 1
	replace 			remit_dwn = 0 if rem_for_dwn == 0 & remit_dwn == .
	replace				remit_dwn = 0 if rem_dom_dwn == 0 & remit_dwn == .
	lab var 			remit_dwn "Remittances (foreign, domestic) reduced"
	lab val				remit_dwn yesno
	
	gen 				other_dwn = 1 if isp_dwn == 1| pen_dwn == 1 | gov_dwn == 1 | ngo_dwn == 1 
	replace				other_dwn = 0 if isp_dwn == 0 & other_dwn == .
	replace				other_dwn = 0 if pen_dwn == 0 & other_dwn == .
	replace				other_dwn = 0 if gov_dwn == 0 & other_dwn == .
	replace				other_dwn = 0 if ngo_dwn == 0 & other_dwn == .
	lab var 			other_dwn "Other income sources (isp, pen, gov, ngo) reduced"
	lab val				other_dwn yesno
	
	egen 				dwn_count = rsum(work_dwn wage_dwn remit_dwn other_dwn)
	lab var 			dwn_count "count of income sources which are down"
	replace				dwn_count = . if farm_dwn == . & bus_dwn == . & ///
							wage_dwn == . & remit_dwn == . & other_dwn == .
	
	gen 				dwn_percent = dwn_count / 4
	label var 			dwn_percent "percent of income sources which had losses"
	
	
	gen					dwn = 1 if dwn_count != 0 | dwn_count != . 
	replace 			dwn = 0 if dwn_count == 0 
	lab var 			dwn "=1 if household experience any type of income loss"
	
	order 				farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ///
							ngo_dwn rem_dom_dwn rem_for_dwn remit_dwn other_dwn dwn dwn_count  ///
							 dwn_percent, after(rem_for_chg)
		
	replace				edu_cont = 0 if edu_cont == 2
	lab val				edu_cont yesno
		
		
* **********************************************************************
* 5 - revise access variables as needed 
* **********************************************************************

	order			myth_1 myth_2 myth_3 myth_4 myth_5 myth_6 myth_7, ///
						after(ac_clean_why)
	order			shock_1 shock_2 shock_3 shock_4 shock_5 shock_6 ///
						shock_7 shock_8 shock_9 shock_10 shock_11 ///
						shock_12 shock_13 shock_14, after(ac_clean_why)
	order			cope_1 cope_2 cope_3 cope_4 cope_5 cope_6 cope_7 ///
						cope_08 cope_09 cope_10 cope_11 cope_12 cope_13 ///
						cope_14 cope_15 cope_16 cope_17 fies_1 fies_2 ///
						fies_3 fies_4 fies_5 fies_6 fies_7 fies_8, ///
						after(myth_7)
		
	rename			satisf_06 satis_06
	
	order			children318 children618, before(sch_child)
	order			sch_child_meal sch_child_mealskip, after(sch_child)
	order			edu_6 edu_7, after(edu_5)
	order			edu_other edu_cont edu_cont_1 edu_cont_2 edu_cont_3 ///
						edu_cont_4 edu_cont_5 edu_cont_6 edu_cont_7 edu_cont_8, ///
						after(edu_5)
	
	replace			edu_cont_8 = educ_cont_8 if edu_cont_8 == .
	drop			educ_cont_8
		
	order			asst_food asst_cash asst_kind asst_any, after(tot_inc_chg)
	
	order			ag_prep- ag_price ag_chg_1- ag_seed_7 ag_plan- ag_graze, ///
						after(concern_3)
						
	order			concern_1 concern_2 concern_3 concern_4 concern_5 ///
						concern_6, after(myth_7)
	
	
* **********************************************************************
* 6 - clean food security information 
* **********************************************************************

	loc fies				fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 fies_7 fies_8

	foreach var of varlist `fies' {
		replace 			`var' = 2 if `var' == 0
		replace				`var' = . if `var' == -99
		replace				`var' = . if `var' == -98

		}				

	egen 					fies_count = rsum(fies_1 fies_2 fies_3 fies_4 fies_5 fies_6 fies_07 fies_8)				
	gen 					fies_percent = fies_count / 8 
	
* **********************************************************************
* 7 - clean myth questions
* **********************************************************************

	loc myth				myth_1 myth_2 myth_3 myth_4 myth_5

	foreach var of varlist `myth' {
		replace				`var' = 3 if `var' == -98
		}				

* **********************************************************************
* 8 - education questions
* **********************************************************************

	replace 				edu_act = 0 if edu_act == 2
	replace					edu_act = . if edu_act == -99 
	replace 				edu_act = . if edu_act == -98 
	
	gen						edu_none = 1 if edu_act == 0
	replace					edu_none = 0 if edu_act == 1
	lab var					edu_none "Child not engaged in any learning activity"
	
	replace 				sch_child = 0 if sch_child == 2
	replace					sch_child = . if sch_child == -99 
	
	
* **********************************************************************
* 9 - clean up education receipts 
* **********************************************************************

* generate remittance income variable 
	gen 					remit_inc = 1 if rem_dom == 2
	replace					remit_inc = 1 if rem_for == 2 
	replace					remit_inc = 0 if remit_inc == .
	replace 				remit_inc = . if rem_dom == -99 & remit_inc == .
	replace 				remit_inc = . if rem_for == -99 & remit_inc == .

* others fine as is: bus_inc farm_inc wage_inc 
	
* **********************************************************************
* 10 - merge in covid data
* **********************************************************************	

* merge in covid data
	merge m:1 				country region using "$export\covid_data"
	
	drop if					_merge == 2
	drop 					_merge

* *********************************************************************
* 11 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 
	
* save file 	
	save			"$export/lsms_panel", replace

* close the log
	log	close	
	
/* END */

















/* VARIABLE CROSSWALK


gen country_s = cond(country == 1, "eth", cond(country == 2, "mwi", cond(country == 3, "nga", "uga")))
drop country
levelsof country_s, local(countries)
levelsof wave, local(waves)

ds
foreach var in `r(varlist)' {
    foreach c in `countries' {
	    foreach w in `waves' {
		    collapse (sum) `var', by(country wave)
			capture confirm numeric variable `var' 
			gen `c'_w`w'_`var' = 1 if `var' != .
			if !_rc {
				 gen `c'_w`w'_`var' = 1 if `var' != ""
			}
		}

	}
}
