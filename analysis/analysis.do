* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edit: 3 August 2020 
* Stata v.16.1

* does
	* merges together all countries
	* renames variables
	* runs regression analysis

* assumes
	* cleaned country data

* TO DO:
	* analysis


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
	
* save file	
	save			"$export/lsms_panel_int", replace

* **********************************************************************
* 2 - revise variables as needed 
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
	
	tostring		hhid_uga, replace u
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

	drop 				start_date
	
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
	
	order			gov_13 gov_14 gov_15 gov_16 gov_none gov_dnk, after(gov_12)
	order			hhsize, after(relate_hoh)
	
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
	
	replace				ac_med_need = 0 if ac_med_need == 2
	replace				ac_med = -97 if ac_med_need == 0 & ac_med == .
	replace				ac_med = 0 if ac_med == 2
	
	replace				ac_med_need = . if country == 3 & wave == 2
	replace				ac_med = . if country == 3 & wave == 2
	replace				ac_med_why = . if country == 3 & wave == 2
	
	replace				ac_med = . if ac_med == -97

* access to medical services
	replace				ac_medserv_need = . if country == 1
	replace				ac_medserv = . if country == 1
	replace				ac_medserv_why = . if country == 1
	
	replace				ac_medserv_need = 0 if ac_medserv == . & country == 2
	replace				ac_medserv_need = 1 if ac_medserv_need == . & country == 2
	lab val				ac_medserv_need yesno
	
	replace				ac_medserv_need = 0 if ac_medserv == . & country == 3
	replace				ac_medserv_need = 1 if ac_medserv_need == . & country == 3
	replace				ac_medserv = 0 if ac_medserv == 2
	lab val				ac_medserv yesno

* access to soap
	replace				ac_soap_need = . if country == 1
	replace				ac_soap = . if country == 1
	replace				ac_soap_why = . if country == 1
	
	replace				ac_soap_need = 0 if ac_soap == . & country == 2
	replace				ac_soap_need = 1 if ac_soap_need == . & country == 2
	lab val				ac_soap_need yesno
	
	replace				ac_soap_need = 0 if ac_soap == . & country == 3
	replace				ac_soap_need = 1 if ac_soap_need == . & country == 3
	replace				ac_soap = 0 if ac_soap == 2
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
	
	replace				ac_water_need = 0 if ac_water_need == 2 & country == 2
	lab val				ac_water_need yesno
	replace				ac_water = 0 if ac_water == 2 & country == 2
	lab val				ac_water yesno
	

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
	
	
	
	
	
	
	
	
	
	
	
* **********************************************************************
* 3 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 
	
* save file 	
	save			"$export/lsms_panel", replace

* close the log
	log	close	