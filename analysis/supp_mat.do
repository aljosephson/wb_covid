* Project: WB COVID
* Created on: September 2020 
* Created by: jdm
* Edited by: alj
* Last edit: 3 September 2020 
* Stata v.16.1

* does
	* runs regressions and produces tables for supplemental material

* assumes
	* cleaned country data

* TO DO:
	* everything


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$data/analysis/tables"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/supp_mat", append


* **********************************************************************
* 1 - create graphs on knowledge and behavior
* **********************************************************************

* read in data
	use				"$ans/lsms_panel", clear
