* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: jdm
* Last edit: 1 September 2020 
* Stata v.16.1

* does
	* merges together all countries
	* renames variables
	* output cleaned panel data

* assumes
	* cleaned country data

* TO DO:
	* complete


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

* open log
	cap log 		close
	log using		"$logout/analysis", append


* **********************************************************************
* 1 - build data set
* **********************************************************************

* read in data
	use				"$eth/eth_panel", clear
	
	append using 	"$mwi/mwi_panel", force
	
	append using 	"$nga/nga_panel", force

	append using	"$uga/uga_panel", force
	
	
* **********************************************************************
* 2 - revise ID variables as needed 
* **********************************************************************

* order variables
	order			country hhid_eth hhid_mwi hhid_nga hhid_uga wave
	drop			submission_date round attempt
	
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
	order			hhid, after(country)
	lab var			hhid "Unique household ID"

	drop 			start_date hh_a16 hh_a17 result shock_16 hhleft hhjoin PID ///
						baseline_hhid

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
	replace			know_01 = 0 if know_01 == 2
	replace			know_02 = 0 if know_02 == 2
	replace 		know_03 = 0 if know_03 == 2
	replace 		know_04 = 0 if know_04 == 2
	replace 		know_05 = 0 if know_05 == 2
	replace 		know_06 = 0 if know_06 == 2
	replace			know_07 = 0 if know_07 == 2
	replace 		know_08 = 0 if know_08 == 2 
	order			know_09 know_11 know_10, after(know_08)
	
* behavior 
	replace 		bh_01 = 1 if bh_01 == 4 & country == 2
	replace			bh_01 = 0 if bh_01 >= 2 & bh_01 < . 	
	replace 		bh_02 = 1 if bh_02 == 4 & country == 2
	replace			bh_02 = 0 if bh_02 >= 2 & bh_02 < . 	
	replace 		bh_03 = 1 if bh_03 == 4 & country == 2
	replace			bh_03 = 0 if bh_03 >= 2 & bh_03 < . 	
	replace			bh_03 = . if bh_03 == -97
	replace 		bh_04 = 1 if bh_04 == 4 & country == 2
	replace			bh_04 = 0 if bh_04 >= 2 & bh_04 < . 	
	replace 		bh_05 = 1 if bh_05 == 4 & country == 2
	replace			bh_05 = 0 if bh_05 >= 2 & bh_05 < . 	
	replace 		bh_06 = 1 if bh_06 == 4 & country == 2
	replace			bh_06 = 0 if bh_06 >= 2 & bh_06 < . 	
	replace 		bh_06a = 1 if bh_06a == 4 & country == 2
	replace			bh_06a = 0 if bh_06a >= 2 & bh_06a < . 	
	replace 		bh_07 = 1 if bh_07 == 4 & country == 2
	replace			bh_07 = 0 if bh_07 >= 2 & bh_07 < . 	
	replace 		bh_08 = 1 if bh_08 == 4 & country == 2
	replace			bh_08 = 0 if bh_08 >= 2 & bh_08 < . 
	order 			bh_02 bh_03 bh_04 bh_05 bh_06 bh_07 bh_08, after(bh_01)
	
	drop			bh_06a
	
	order			gov_13 gov_14 gov_15 gov_16 gov_none gov_dnk, after(gov_12)
	order			edu hhsize, after(relate_hoh)

	gen				cope_any = 1 if cope_01 == 1 | cope_02 == 1 | cope_03 == 1 | ///
						cope_04 == 1 | cope_05 == 1 | cope_06 == 1 | ///
						cope_07 == 1 | cope_08 == 1 | cope_09 == 1 | ///
						cope_10 == 1 | cope_11 == 1 | cope_12 == 1 | ///
						cope_13 == 1 | cope_14 == 1 | cope_15 == 1
	replace			cope_any = 0 if cope_any == . & country == 1
	replace			cope_any = 0 if cope_any == . & country == 2 & wave == 2
	replace			cope_any = 0 if cope_any == . & country == 3 & wave != 2
	replace			cope_any = 0 if cope_any == . & country == 4 & wave == 1
	lab var			cope_any "Adopted any coping strategy"
	
	
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
						ac_bank ac_bank_why, after(bh_08)		

* access to medicine						
	lab	def				yesno 0 "No" 1 "Yes"
	lab val				ac_med_need yesno 

	replace				ac_med_need = 0 if ac_med == -97 & country == 1		
	replace				ac_med_need = 1 if ac_med_need == . & country == 1
	replace				ac_med = 1 if ac_med == -98 & country == 1
	replace				ac_med = 1 if ac_med == -99 & country == 1
	
	replace				ac_med_need = 0 if ac_med_need == 2
	replace				ac_med = -97 if ac_med_need == 0 & ac_med == .
	replace				ac_med = 0 if ac_med == 2
	
	replace				ac_med_need = . if country == 3 & wave == 2
	replace				ac_med = . if country == 3 & wave == 2
	replace				ac_med_why = . if country == 3 & wave == 2
	
	replace				ac_med = . if ac_med == -97

	replace				ac_med_need = 0 if ac_med == 3 & country == 4
	replace				ac_med_need = 1 if ac_med_need == . & country == 4
	replace				ac_med = . if ac_med == 3 & country == 4
	replace				ac_med = 2 if ac_med == 0 & country == 4
	replace				ac_med = 0 if ac_med == 1 & country == 4
	replace				ac_med = 1 if ac_med == 2 & country == 4
	
* access to medical services
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

* access to soap
	replace				ac_soap_need = . if country == 1
	replace				ac_soap = . if country == 1
	replace				ac_soap_why = . if country == 1
	
	replace				ac_soap_need = 0 if ac_soap == . & country == 2
	replace				ac_soap_need = 1 if ac_soap_need == . & country == 2
	
	replace				ac_soap_need = 0 if ac_soap == . & country == 3
	replace				ac_soap_need = 1 if ac_soap_need == . & country == 3
	replace				ac_soap = 0 if ac_soap == 2

	replace				ac_soap_need = 0 if ac_soap == . & country == 4
	replace				ac_soap_need = 1 if ac_soap_need == . & country == 4
	replace				ac_soap =0 if ac_soap == 2 & country == 4
	
	lab val				ac_soap_need yesno
	lab val				ac_soap yesno
	
* access oil/teff/wheat in Ethiopia
	gen					ac_oil_need = 0 if ac_oil == -97 & country == 1
	replace				ac_oil_need = 1 if ac_oil_need == . & country == 1
	replace				ac_oil = . if ac_oil == -97
	lab val				ac_oil_need yesno
	lab val				ac_oil yesno
	order				ac_oil_need, before(ac_oil)
	
	gen					ac_teff_need = 0 if ac_teff == -97 & country == 1
	replace				ac_teff_need = 1 if ac_teff_need == . & country == 1
	replace				ac_teff = . if ac_teff == -97
	lab val				ac_teff_need yesno
	lab val				ac_teff yesno
	order				ac_teff_need, before(ac_teff)
	
	gen					ac_wheat_need = 0 if ac_wheat == -97 & country == 1
	replace				ac_wheat_need = 1 if ac_wheat_need == . & country == 1
	replace				ac_wheat = . if ac_wheat == -97
	lab val				ac_wheat_need yesno
	lab val				ac_wheat yesno
	order				ac_wheat_need, before(ac_wheat)
	
	replace				ac_maize_need = 0 if ac_maize == -97 & country == 1
	replace				ac_maize_need = 1 if ac_maize_need == . & country == 1
	replace				ac_maize = . if ac_maize == -97 & country == 1

* access to maize/clean/water in Malawi
	replace				ac_maize_need = 0 if ac_maize_need == 2 & country == 2
	lab val				ac_maize_need yesno
	replace				ac_maize = 0 if ac_maize == 2 & country == 2
	lab val				ac_maize yesno
	
	replace				ac_clean_need = 0 if ac_clean_need == 2 & country == 2
	lab val				ac_clean_need yesno
	replace				ac_clean = 0 if ac_clean == 2 & country == 2
	lab val				ac_clean yesno
	
	drop				ac_water ac_water_why ac_staple_def

* access to staples in Nigeria
	replace				ac_rice_need = 0 if ac_rice_need != 1 & country == 3 & wave == 1
	lab val				ac_rice_need yesno
	replace				ac_rice = 0 if ac_rice == 2 & country == 3 & wave == 1
	lab val				ac_rice yesno
	
	replace				ac_beans_need = 0 if ac_beans_need != 1 & country == 3 & wave == 1
	lab val				ac_beans_need yesno
	replace				ac_beans = 0 if ac_beans == 2 & country == 3 & wave == 1
	lab val				ac_beans yesno
	
	replace				ac_cass_need = 0 if ac_cass_need != 1 & country == 3 & wave == 1
	lab val				ac_cass_need yesno
	replace				ac_cass = 0 if ac_cass == 2 & country == 3 & wave == 1
	lab val				ac_cass yesno
	
	replace				ac_yam_need = 0 if ac_yam_need != 1 & country == 3 & wave == 1
	lab val				ac_yam_need yesno
	replace				ac_yam = 0 if ac_yam == 2 & country == 3 & wave == 1
	lab val				ac_yam yesno
	
	replace				ac_sorg_need = 0 if ac_sorg_need != 1 & country == 3 & wave == 1
	lab val				ac_sorg_need yesno
	replace				ac_sorg = 0 if ac_sorg == 2 & country == 3 & wave == 1
	lab val				ac_sorg yesno
	
	replace				ac_clean_need = 0 if ac_clean_need != 1 & country == 3 & wave == 1
	replace				ac_clean = 0 if ac_clean == 2 & country == 3 & wave == 1
	
	drop				ac_bank ac_bank_why
	
* access to staple	
	replace				ac_staple_need = 0 if ac_staple_need == 2
	lab val				ac_staple_need yesno
	replace				ac_staple = 0 if ac_staple == 2
	lab val				ac_staple yesno
	
	replace				ac_staple_need = 1 if ac_oil_need == 1 | ac_teff_need == 1 | ///
							ac_wheat_need == 1 | ac_maize_need == 1 | ///
							ac_rice_need == 1 | ac_beans_need == 1 | ///
							ac_cass_need == 1 | ac_yam_need == 1 | ///
							ac_sorg_need == 1
	replace				ac_staple_need = 0 if ac_staple_need == .
	replace				ac_staple_need = . if country == 3 & wave == 2
	
	replace				ac_staple = 1 if ac_oil == 1 | ac_teff == 1 | ///
							ac_wheat == 1 | ac_maize == 1 | ///
							ac_rice== 1 | ac_beans == 1 | ///
							ac_cass == 1 | ac_yam == 1 | ///
							ac_sorg == 1	
	replace				ac_staple = 0 if ac_staple == . & ac_staple_need == 1
	replace				ac_staple = . if country == 3 & wave == 2
	drop				ac_staple_why ac_sauce_def ac_sauce ac_sauce_why ///
							ac_drink ac_drink_why

	replace				ac_staple_need = 1 if ac_staple != 3 & country == 4
	replace				ac_staple = . if ac_staple == 3 & country == 4
	replace				ac_staple = 2 if ac_staple == 0 & country == 4
	replace				ac_staple = 0 if ac_staple == 1 & country == 4
	replace				ac_staple = 1 if ac_staple == 2 & country == 4
	
	lab var				ac_oil_need "Did you or anyone in your household need to buy oil"
	lab var				ac_teff_need "Did you or anyone in your household need to buy teff"
	lab var				ac_wheat_need "Did you or anyone in your household need to buy wheat"

	
* **********************************************************************
* 4 - clean concerns and income changes
* **********************************************************************
	
* turn concern into binary
	replace				concern_01 = 0 if concern_01 == 3 | concern_01 == 4
	replace				concern_01 = 1 if concern_01 == 2
	lab val				concern_01 yesno
	
	replace				concern_02 = 0 if concern_02 == 3 | concern_02 == 4
	replace				concern_02 = 1 if concern_02 == 2
	lab val				concern_02 yesno


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

	order			myth_01 myth_02 myth_03 myth_04 myth_05 myth_06 myth_07, ///
						after(ac_clean_why)
	order			shock_01 shock_02 shock_03 shock_04 shock_05 shock_06 ///
						shock_07 shock_08 shock_09 shock_10 shock_11 ///
						shock_12 shock_13 shock_14, after(ac_clean_why)
	order			cope_01 cope_02 cope_03 cope_04 cope_05 cope_06 cope_07 ///
						cope_08 cope_09 cope_10 cope_11 cope_12 cope_13 ///
						cope_14 cope_15 cope_16 cope_17 fies_01 fies_02 ///
						fies_03 fies_04 fies_05 fies_06 fies_07 fies_08, ///
						after(myth_07)
		
	rename			satisf_06 satis_06
	
	order			children318 children618, before(sch_child)
	order			sch_child_meal sch_child_mealskip, after(sch_child)
	order			edu_06 edu_07, after(edu_05)
	order			edu_other edu_cont edu_cont_01 edu_cont_02 edu_cont_03 ///
						edu_cont_04 edu_cont_05 edu_cont_06 edu_cont_07 edu_cont_08, ///
						after(edu_05)
	
	replace			edu_cont_08 = educ_cont_08 if edu_cont_08 == .
	drop			educ_cont_08
		
	order			asst_food asst_cash asst_kind asst_any, after(tot_inc_chg)
	
	order			ag_prep- ag_price ag_chg_01- ag_seed_07 ag_plan- ag_graze, ///
						after(concern_03)
						
	order			concern_01 concern_02 concern_03 concern_04 concern_05 ///
						concern_06, after(myth_07)
	
	
* **********************************************************************
* 6 - clean food security information 
* **********************************************************************

	loc fies				fies_01 fies_02 fies_03 fies_04 fies_05 fies_06 fies_07 fies_08

	foreach var of varlist `fies' {
		replace				`var' = 0 if `var' == 2
		replace				`var' = . if `var' == -99
		replace				`var' = . if `var' == -98

		}				

	egen 					fies_count = rsum (fies_01 fies_02 fies_03 fies_04 fies_05 fies_06 fies_07 fies_08)				
	gen 					fies_percent = fies_count / 8 
	
* **********************************************************************
* 7 - clean myth questions
* **********************************************************************

	loc myth				myth_01 myth_02 myth_03 myth_04 myth_05

	foreach var of varlist `myth' {
		replace				`var' = 3 if `var' == -98
		}				

* **********************************************************************
* 8 - education questions
* **********************************************************************

	replace 				edu_act = 0 if edu_act == 2
	replace					edu_act = . if edu_act == -99 
	replace 				edu_act = . if edu_act == -98 
	
	replace 				sch_child = 0 if sch_child == 2
	replace					sch_child = . if sch_child == -99 
	

* *********************************************************************
* 9 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 
	
* save file 	
	save			"$export/lsms_panel", replace

* close the log
	log	close	