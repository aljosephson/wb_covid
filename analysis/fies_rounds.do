* Project: WB COVID
* Created on: September 2020 
* Created by: alj
* Edited by: alj 
* Last edit: 12 january 2021
* Stata v.16.1

* does
	* anna's garbage code to check food insecurity stuff for book chapter 

* assumes
	* cleaned country data
	* palettes and colrspace installed	

* TO DO:
	* 


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$output_f/book_chapter/figures"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/fies_round-dif", append

* read in data
	use				"$ans/lsms_panel", clear

* waves to month number
	gen 			wave_orig = wave
	replace 		wave = 9 if wave == 5 & (country == 3 | country == 1)
	replace 		wave = 8 if wave == 4 & (country == 3 | country == 1)
	replace 		wave = 6 if wave == 3 & country == 1
	replace 		wave = 5 if wave == 2 & country == 1
	replace 		wave = 4 if wave == 1 & country == 1
	replace 		wave = 7 if wave == 3 & country == 3
	replace 		wave = 6 if wave == 2 & country == 3
	replace 		wave = 5 if wave == 1 & country == 3
	replace 		wave = 9 if wave == 4 & country == 2
	replace 		wave = 8 if wave == 3 & country == 2 
	replace 		wave = 7 if wave == 2 & country == 2
	replace 		wave = 6 if wave == 1 & (country == 2 | country == 4)
	replace 		wave = 8 if wave == 2 & country == 4
	replace 		wave = 9 if wave == 3 & country == 4

	lab def 		months 4 "April" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept"
	lab val			wave months
	
* **********************************************************************
* 1 - food insecurity differences by round
* **********************************************************************

* ethiopia 
preserve 
	keep			if country == 1
	bys 			wave: tabstat p_mod
	*** may, june, august, september 
	
	reg 			p_mod ib(5).wave [pweight = wt_18], vce(robust) 	
	test			6.wave = 8.wave
	test 			6.wave = 9.wave
	test 			8.wave = 9.wave
restore 

* malawi 
preserve 
	keep			if country == 2
	bys 			wave: tabstat p_mod
	*** june, july, august 
	
	reg 			p_mod ib(6).wave [pweight = wt_18], vce(robust) 	
	test			7.wave = 8.wave
restore 

* nigeria
preserve 
	keep			if country == 3
	bys 			wave: tabstat p_mod
	*** june, august
	
	reg 			p_mod ib(6).wave [pweight = wt_18], vce(robust) 	
restore 

* uganda 
preserve 
	keep			if country == 4
	bys 			wave: tabstat p_mod
	*** june, august, september 
	
	reg 			p_mod ib(6).wave [pweight = wt_18], vce(robust) 	
	test			8.wave = 9.wave
restore 

* **********************************************************************
* 2 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */