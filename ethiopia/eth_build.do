* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Stata v.16.1

* does
	* reads in first two rounds of Ethiopia data
	* builds panel
	* outputs panel data

* assumes
	* raw Ethiopia data

* TO DO:
	* complete


* **********************************************************************
* 0 - setup
* **********************************************************************

* define 
	global	root	=	"$data/ethiopia/raw"
	global	export	=	"$data/ethiopia/refined"
	global	logout	=	"$data/ethiopia/logs"

* open log
	cap log 		close
	log using		"$logout/eth_build", append

	

* ***********************************************************************
* 1 - build ethiopia panel
* ***********************************************************************