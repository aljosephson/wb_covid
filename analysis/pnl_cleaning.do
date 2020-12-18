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
	* need to revist access for some variables - done?
	* change new ethiopia access data to match other rounds (yes to no, etc)
	* NOTE make sure add regions and labels  to countries 2-4
	* make sure credit variables match

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
	tostring		hhid_uga, replace u force
	replace 		hhid_uga = "u" + hhid_uga if hhid_uga != "."
	replace			hhid_uga = "" if hhid_uga == "."	
	gen				HHID = hhid_eth if hhid_eth != ""
	replace			HHID = hhid_mwi if hhid_mwi != ""
	replace			HHID = hhid_nga if hhid_nga != ""
	replace			HHID = hhid_uga if hhid_uga != ""	
	sort			HHID
	egen			hhid = group(HHID)
	drop			HHID hhid_eth hhid_mwi hhid_nga hhid_uga
	lab var			hhid "Unique household ID"

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
	order			hhsize, before(sex)
						
* know 
	replace			know = 0 if know == 2 
	replace			know_1 = 0 if know_1 == 2
	replace			know_2 = 0 if know_2 == 2
	replace 		know_3 = 0 if know_3 == 2
	replace 		know_4 = 0 if know_4 == 2
	replace 		know_5 = 0 if know_5 == 2
	replace 		know_6 = 0 if know_6 == 2
	replace			know_7 = 0 if know_7 == 2
	replace 		know_8 = 0 if know_8 == 2 
	order			know_9 know_11 know_10, after(know_8)
	
* behavior 
	replace 		bh_1 = 1 if bh_1 == 4 & country == 2
	replace			bh_1 = 0 if bh_1 >= 2 & bh_1 < . 	
	replace 		bh_2 = 1 if bh_2 == 4 & country == 2
	replace			bh_2 = 0 if bh_2 >= 2 & bh_2 < . 	
	replace 		bh_3 = 1 if bh_3 == 4 & country == 2
	replace			bh_3 = 0 if bh_3 >= 2 & bh_3 < . 	
	replace			bh_3 = . if bh_3 == -97
	replace 		bh_4 = 1 if bh_4 == 4 & country == 2
	replace			bh_4 = 0 if bh_4 >= 2 & bh_4 < . 	
	replace 		bh_5 = 1 if bh_5 == 4 & country == 2
	replace			bh_5 = 0 if bh_5 >= 2 & bh_5 < . 	
	replace 		bh_6 = 1 if bh_6 == 4 & country == 2
	replace			bh_6 = 0 if bh_6 >= 2 & bh_6 < . 	
	replace 		bh_6a = 1 if bh_6a == 4 & country == 2
	replace			bh_6a = 0 if bh_6a >= 2 & bh_6a < . 	
	replace 		bh_7 = 1 if bh_7 == 4 & country == 2
	replace			bh_7 = 0 if bh_7 >= 2 & bh_7 < . 	
	replace 		bh_8 = 1 if bh_8 == 4 & country == 2
	replace			bh_8 = 0 if bh_8 >= 2 & bh_8 < . 
	order 			bh_2 bh_3 bh_4 bh_5 bh_6 bh_7 bh_8, after(bh_1)
	
	drop			bh_6a
	
	order			gov_13 gov_14 gov_15 gov_16 gov_none gov_dnk, after(gov_12)
	order			edu hhsize, after(relate_hoh)

	gen				cope_any = 1 if cope_1 == 1 | cope_2 == 1 | cope_3 == 1 | ///
						cope_4 == 1 | cope_5 == 1 | cope_6 == 1 | ///
						cope_7 == 1 | cope_8 == 1 | cope_9 == 1 | ///
						cope_10 == 1 | cope_11 == 1 | cope_12 == 1 | ///
						cope_13 == 1 | cope_14 == 1 | cope_15 == 1
	replace			cope_any = 0 if cope_any == . & country == 1
	replace			cope_any = 0 if cope_any == . & country == 2 & wave == 2
	replace			cope_any = 0 if cope_any == . & country == 3 & wave != 2
	replace			cope_any = 0 if cope_any == . & country == 4 & wave == 1
	lab var			cope_any "Adopted any coping strategy"
	
	gen				cope_none = 1 if cope_any == 0
	replace			cope_none = 0 if cope_any == 1
	lab var			cope_none "Did nothing"
	
	lab def			myth 0 "No" 1 "Yes" 3 "Don't Know"
	
	local myth		 myth_1 myth_2 myth_3 myth_4 myth_5
	foreach v in `myth' {
	    replace `v' = 3 if `v' == -98
		replace `v' = 0 if `v' == 2
		lab val	`v' myth
	}	
	
adsf 	
* **********************************************************************
* 3- revise access variables as needed 
* **********************************************************************
	
* access
	replace			ac_medserv = med_access if ac_medserv == .
	replace			ac_medserv_need = med if med == .
	replace			ac_medserv_why = med_access_why if med_access_why == .
	drop			med_access med med_access_why
	
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
	lab val				ac_med .
	lab var				ac_med "Unable to access medicine"

	replace				ac_med = . if ac_med == -97 & country == 1
	replace				ac_med = . if ac_med == -98 & country == 1
	replace				ac_med = 1 if ac_med == -99 & country == 1
	replace				ac_med = 2 if ac_med == 1 & country == 1
	replace				ac_med = 1 if ac_med == 0 & country == 1
	replace				ac_med = 0 if ac_med == 2 & country == 1
	
	replace				ac_med = 0 if ac_med == 1 & country == 2
	replace				ac_med = 1 if ac_med == 2 & country == 2
	
	replace				ac_med = 0 if ac_med == 1 & country == 3
	replace				ac_med = 1 if ac_med == 2 & country == 3

	replace				ac_med = . if ac_med == 3 & country == 4
	replace				ac_med = 0 if ac_med == 2 & country == 4
	
	lab val				ac_med yesno
	
/* access to medical services
	replace				ac_medserv_need = . if country == 1
	replace				ac_medserv = . if country == 1
	replace				ac_medserv_why = . if country == 1
	
	replace				ac_medserv_need = 0 if ac_medserv == . & country == 2
	replace				ac_medserv_need = 1 if ac_medserv_need == . & country == 2
	
	replace				ac_medserv_need = 0 if ac_medserv == . & country == 3
	replace				ac_medserv_need = 1 if ac_medserv_need == . & country == 3
	replace				ac_medserv = 0 if ac_medserv == 2

	replace				ac_medserv_need = 0 if ac_medserv == . & country == 4
	replace				ac_medserv_need = 1 if ac_medserv_need == . & country == 4
	replace				ac_medserv = . if ac_medserv == 3 & country == 4
	
	lab val				ac_medserv yesno
	lab val				ac_medserv_need yesno	
*/
* access to soap
	lab val				ac_soap .
	lab var				ac_soap "Unable to access soap"
	
	replace				ac_soap = 0 if ac_soap == 1
	replace				ac_soap = 1 if ac_soap == 2
	
/*added in from ethiopia - numbers dif - check all for consistency
	* Note - only available round 4 and numbers in data do not match survey instument, corrected below
	gen ac_soap_why = .
	replace ac_soap_why = 1 if wa6_soap_wash_why == 5
	replace ac_soap_why = 2 if wa6_soap_wash_why == 6 
	replace ac_soap_why = 4 if wa6_soap_wash_why == 8
	replace ac_soap_why = 5 if wa6_soap_wash_why == 9
	replace ac_soap_why = 7 if wa6_soap_wash_why == 10
	replace ac_soap_why = 8 if wa6_soap_wash_why == 11
	lab def			ac_soap_why 1 "shops out" 2 "markets closed" 3 "no transportation" ///
								4 "restrictions to go out" 5 "increase in price" 6 "no money" ///
								7 "cannot afford" 8 "afraid to go out" 9 "other"
	lab val			ac_soap_why ac_soap_why	
*/
	
	
	lab val				ac_soap yesno
	
* access oil/teff/wheat in Ethiopia
	replace				ac_oil = . if ac_oil == -97
	replace				ac_oil = . if ac_oil == -98
	replace				ac_oil = 2 if ac_oil == 1
	replace				ac_oil = 1 if ac_oil == 0
	replace				ac_oil = 0 if ac_oil == 2
	lab var				ac_oil "Unable to access oil"
	lab val				ac_oil yesno
	
	replace				ac_teff = . if ac_teff == -99
	replace				ac_teff = . if ac_teff == -97
	replace				ac_teff = . if ac_teff == -98
	replace				ac_teff = 2 if ac_teff == 1
	replace				ac_teff = 1 if ac_teff == 0
	replace				ac_teff = 0 if ac_teff == 2
	lab var				ac_teff "Unable to access teff"
	lab val				ac_teff yesno
	
	replace				ac_wheat = . if ac_wheat == -99
	replace				ac_wheat = . if ac_wheat == -97
	replace				ac_wheat = . if ac_wheat == -98
	replace				ac_wheat = 2 if ac_wheat == 1
	replace				ac_wheat = 1 if ac_wheat == 0
	replace				ac_wheat = 0 if ac_wheat == 2
	lab var				ac_wheat "Unable to access wheat"
	lab val				ac_wheat yesno
	
	replace				ac_maize = . if ac_maize == -99 & country == 1
	replace				ac_maize = . if ac_maize == -97 & country == 1
	replace				ac_maize = . if ac_maize == -98 & country == 1
	replace				ac_maize = 2 if ac_maize == 1 & country == 1
	replace				ac_maize = 1 if ac_maize == 0 & country == 1
	replace				ac_maize = 0 if ac_maize == 2 & country == 1
	lab var				ac_maize "Unable to access maize"
	lab val				ac_maize yesno

* access to maize/clean/water in Malawi
	replace				ac_maize = 0 if ac_maize == 1 & country == 2
	replace				ac_maize = 1 if ac_maize == 2 & country == 2

	lab val				ac_clean .
	replace				ac_clean = 0 if ac_clean == 1 & country == 2
	replace				ac_clean = 1 if ac_clean == 2 & country == 2
	lab val				ac_clean yesno

* access to staples in Nigeria
	replace				ac_rice = 0 if ac_rice == 1 & country == 3
	replace				ac_rice = 1 if ac_rice == 2 & country == 3
	lab var				ac_rice "Unable to access rice"
	lab val				ac_rice yesno
	
	replace				ac_beans = 0 if ac_beans == 1 & country == 3
	replace				ac_beans = 1 if ac_beans == 2 & country == 3
	lab var				ac_beans "Unable to access beans"
	lab val				ac_beans yesno
	
	replace				ac_cass = 0 if ac_cass == 1 & country == 3
	replace				ac_cass = 1 if ac_cass == 2 & country == 3
	lab var				ac_cass "Unable to access cassava"
	lab val				ac_cass yesno

	replace				ac_yam = 0 if ac_yam == 1 & country == 3
	replace				ac_yam = 1 if ac_yam == 2 & country == 3
	lab var				ac_yam "Unable to access yam"
	lab val				ac_yam yesno
	
	replace				ac_sorg = 0 if ac_sorg == 1 & country == 3
	replace				ac_sorg = 1 if ac_sorg == 2 & country == 3
	lab var				ac_sorg "Unable to access sorghum"
	lab val				ac_sorg yesno	
	
	replace				ac_clean = 0 if ac_clean == 1 & country == 3
	replace				ac_clean = 1 if ac_clean == 2 & country == 3	
	
	drop				ac_bank ac_bank_why
	
* access to staple	
	lab val				ac_staple .
	replace				ac_staple = 0 if ac_staple == 1 & country == 2
	replace				ac_staple = 1 if ac_staple == 2 & country == 2

	replace				ac_staple = . if ac_staple == 3 & country == 4
	replace				ac_staple = 0 if ac_staple == 2 & country == 4	
	lab var				ac_staple "Unable to access staple"
	lab val				ac_staple yesno
	
	replace				ac_staple_need = 2 if ac_oil == . & ac_teff == . & ///
							ac_wheat == . & ac_maize == . & country == 1
	
	replace				ac_staple_need = 2 if  ac_rice== . & ac_beans == . & ///
							ac_cass == . & ac_yam == . & ac_sorg == . & ///
							country == 3
	
	replace				ac_staple_need = 1 if ac_staple_need == . & country == 1
	replace				ac_staple_need = 1 if ac_staple_need == . & country == 3 & wave != 2
							
	replace				ac_staple = 1 if ac_oil == 1 | ac_teff == 1 | ///
							ac_wheat == 1 | ac_maize == 1 & ac_staple_need == 1
	replace				ac_staple = 0 if ac_staple == . & ac_staple_need == 1 & ///
							country == 1					
							
	replace				ac_staple = 1 if ac_rice== 1 | ac_beans == 1 | ///
							ac_cass == 1 | ac_yam == 1 | ///
							ac_sorg == 1 & ac_staple_need == 1
	replace				ac_staple = 0 if ac_rice== 0 | ac_beans == 0 | ///
							ac_cass == 0 | ac_yam == 0 | ///
							ac_sorg == 0 & ac_staple == . & ac_staple_need == 1 & ///
							country == 3
		
* label variables 
	lab var 		ac_soap_why "Reason for unable to purchase soap"
	lab var 		ac_water_why "Reason unable to access water for washing hands"		
	lab var 		ac_drink_why "Reason unable to access water for drinking"
		
* **********************************************************************
* 4 - clean concerns and income changes
* **********************************************************************
	
* turn concern into binary
	replace				concern_1 = 0 if concern_1 == 3 | concern_1 == 4
	replace				concern_1 = 1 if concern_1 == 2
	lab val				concern_1 yesno
	
	replace				concern_2 = 0 if concern_2 == 3 | concern_2 == 4
	replace				concern_2 = 1 if concern_2 == 2
	lab val				concern_2 yesno


	replace				oth_inc = other_inc if other_inc != . & oth_inc == .
	replace				oth_chg = other_chg if other_chg != . & oth_chg == .
	drop				other_inc other_chg
	
	loc inc				farm_inc bus_inc wage_inc isp_inc pen_inc gov_inc ngo_inc oth_inc asst_inc
	foreach var of varlist `inc' {
		replace				`var' = 0 if `var' == 2
		replace				`var' = 0 if `var' == -99
		*replace				`var' = 0 if `var' == . 
		lab val				`var' yesno
		replace				`var' = . if country == 3 & wave == 2 | wave == 3
		}	
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
