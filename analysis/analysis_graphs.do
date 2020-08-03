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
	global	ans		=	"$data/analysis"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/analysis_graphs", append


* **********************************************************************
* 1 - build data set
* **********************************************************************

* read in data
	use				"$ans/lsms_panel", clear

* **********************************************************************
* 2 - graphs and stuff 
* **********************************************************************

* look at knowledge variables 
	graph 			bar know_01 know_02 know_03 know_04 know_05 know_06 know_07 know_08, over(country) ///
						  legend(label (1 "handwash with soap") label (2 "avoid physical contact") label (3 "use masks/gloves") ///
						  label (4 "avoid travel") label (5 "stay at home") label (6 "avoid crowds") label (7 "socially distance") ///
						  label (8 "avoid face touching") pos (6) col(2))

* look at government variables 
	graph 			bar gov_01 gov_02 know_03 gov_04 gov_05 gov_06 gov_07 gov_08 gov_09 gov_10, over(country) ///
						  legend(label (1 "advise citizens to stay home") label (2 "restricted travel in country") label (3 "restricted international travel") ///
						  label (4 "close schools") label (5 "curfew/lockdown") label (6 "close businesses") label (7 "create space for patients") ///
						  label (8 "provide food") label (9 "open clinics") label (10 "stop social gatherings") label (11 "disseminate information") ///
						  label (12 "create washing kiosks") pos (6) col(2))	
						  
* look at behavior variables 
	graph 			bar bh_01 bh_02 bh_03 bh_04 bh_05, over(country) ///
						  legend(label (1 "handwash more often") label (2 "avoid physical contact") label (3 "avoid crowds") ///
						  label (4 "stock up on groceries, etc.") label (5 "reduce trips out to grocery, etc.") pos (6) col(2))	
	*** omit _06 - _08 for now - only in malawi 
	
* deeper dive on relationship between behavior and knowledge 

* histogram between knowledge and behavior  
	histogram 		bh_01, by (know_01 country) bin(2)
	histogram 		bh_02, by (know_02 country) bin(2)
	histogram 		bh_03, by (know_06 country) bin(2)
	histogram 		bh_04, by (know_06 country) bin(2)
	histogram 		bh_05, by (know_04 country) bin(2)
	histogram 		bh_05, by (know_05 country) bin(2) 
* ttests between knowledge and behavior 
	ttest 			bh_01, by (know_01)
	ttest 			bh_02, by (know_02)
	ttest 			bh_03, by (know_06)
	ttest 			bh_04, by (know_06)
	ttest 			bh_05, by (know_04)
	ttest 			bh_05, by (know_05)
	*** so many people are doing these activities -- need to creatively think about ways to dig into this more
						  
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

