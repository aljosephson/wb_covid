* Project: WB COVID
* Created on: July 2020
* Created by: jdm
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