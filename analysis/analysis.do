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
	
	append using	"$uga/uga_panel", force
	
	append using 	"$mwi/mwi_panel", force
	
	append using 	"$nga/nga_panel", force

* save file	
	save			"$export/lsms_panel_int", replace

* **********************************************************************
* 2 - revise variables as needed 
* **********************************************************************

	replace			know = 0 if know == 2 
	replace			know_01 = 0 if know_01 == 2
	replace			know_02 = 0 if know_02 == 2
	replace 		know_03 = 0 if know_03 == 2
	replace 		know_04 = 0 if know_04 == 2
	replace 		know_05 = 0 if know_05 == 2
	replace 		know_06 = 0 if know_06 == 2
	replace			know_07 = 0 if know_07 == 2
	replace 		know_08 = 0 if know_08 == 2 
	
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