* Project: WB COVID
* Created on: July 2020
* Created by: alj
* Last edit: 28 September 2020 
* Stata v.16.1

* does
	* merges together all countries at individual level 

* assumes
	* cleaned country data
	* household rosters 

* TO DO:
	* done 


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
	log using		"$logout/ind_clean", append

* **********************************************************************
* 1 - append all files 
* **********************************************************************

* read in data
	use				"$eth/eth_panelroster", clear
	
	append using 	"$mwi/mwi_panelroster", force
	
	append using 	"$nga/nga_panelroster", force

	append using	"$uga/uga_panelroster", force

	
* *********************************************************************
* 7 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 
	
* save file 	
	save			"$export/lsms_panelroster", replace

* close the log
	log	close	