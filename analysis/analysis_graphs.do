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
	global	output	=	"$data/analysis/figures"
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

* look at knowledge variables by country
	graph bar		know_01 know_02 know_03 know_04 know_05 know_06 know_07 know_08, over(country) ///
						  legend(label (1 "handwash with soap") ///
						  label (2 "avoid physical contact") label (3 "use masks/gloves") ///
						  label (4 "avoid travel") label (5 "stay at home") ///
						  label (6 "avoid crowds") label (7 "socially distance") ///
						  label (8 "avoid face touching") pos (6) col(2))

	graph export "$output/knowledge.pdf", as(pdf) replace		  
						  
* look at government variables 
	graph bar		gov_01 gov_02 gov_03 gov_04 gov_05 gov_06 gov_10, over(country) ///
						  legend(label (1 "advise citizens to stay home") ///
						  label (2 "restricted travel in country") ///
						  label (3 "restricted international travel") ///
						  label (4 "close schools") label (5 "curfew/lockdown") ///
						  label (6 "close businesses") label (7 "stop social gatherings") ///
						  pos (6) col(2))	

	graph export "$output/restriction.pdf", as(pdf) replace		  
						  
* look at behavior variables
	graph bar 		(mean) bh_01 bh_02 bh_03, over(country) ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3))

	graph export "$output/behavior.pdf", as(pdf) replace	
	
	
* concerns
	graph bar		concern_01 concern_02, over(country) ///
						legend(	label (1 "Health concerns") ///
						label (2 "Financial concerns") pos(6) col(3))
						
	graph bar		concern_01 concern_02, over(sector) ///
						legend(	label (1 "Health concerns") ///
						label (2 "Financial concerns") pos(6) col(3))

* access
	gen				ac_med_r = ac_med if sector == 1
	gen				ac_med_u = ac_med if sector == 2
	gen				ac_staple_r = ac_staple if sector == 1
	gen				ac_staple_u = ac_staple if sector == 2

	graph bar		(count) [aweight = phw] if ac_med_need == 1, over(country, sort(ac_med)) stack asyvar
	
	graph bar 		(count) ac_med_r ac_med_u [aweight = phw] if ac_med_need == 1,  ///
						over(country, sort(ac_med) gap(*.1)) stack ///
						legend(	label (1 "Rural") label (2 "Urban") ///
						pos(6) col(3))

* access
	graph bar		ac_med ac_staple, over(sex) ///
						legend(	label (1 "Access to medicine") ///
						label (2 "Access to staple food") pos(6) col(3))	
						
* access and concern 						
	graph bar		ac_med ac_staple, over(concern_02) over(country) ///
						legend(	label (1 "Access to medicine") ///
						label (2 "Access to staple food") pos(6) col(3))							
	
* change in income						
	graph bar		farm_chg bus_chg wage_chg rem_dom_chg rem_for_chg isp_chg ///
						pen_chg gov_chg ngo_chg, over(country) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances (dom)") ///
						label (5 "Remittances (for)") label (6 "Investments") ///
						label (7 "Pension") label (8 "Gov. assistance") ///
						label (9 "NGO assistance") pos(6) col(3))			
					
	graph bar		farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ngo_dwn ///
						rem_dom_dwn rem_for_dwn, over(country) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances (dom)") ///
						label (5 "Remittances (for)") label (6 "Investments") ///
						label (7 "Pension") label (8 "Gov. assistance") ///
						label (9 "NGO assistance") pos(6) col(3))			
					
	graph bar		farm_dwn bus_dwn wage_dwn isp_dwn pen_dwn gov_dwn ngo_dwn ///
						rem_dom_dwn rem_for_dwn, over(sector) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances (dom)") ///
						label (5 "Remittances (for)") label (6 "Investments") ///
						label (7 "Pension") label (8 "Gov. assistance") ///
						label (9 "NGO assistance") pos(6) col(3))			
						
						
* **********************************************************************
* 3 - basic regressions
* **********************************************************************

*access by household weight
gen count = 1

bysort country: sum acc_1 [aweight = phw] if ac_med_need == 1 & ac_med == 0

*can multiple phw by hhsize and use it to get individual population
* connect household roster to this household data in household panel
* then we can do by gender or age to see % of those people in household facing that issue
						
reg bh_01 i.farm_dwn i.sex i.sector i.country
reg bh_01 i.bus_dwn i.sex i.sector i.country
reg bh_01 i.bus_dwn age i.sex i.sector i.country
reg bh_02 i.bus_dwn age i.sex i.sector i.country
reg bh_03 i.bus_dwn age i.sex i.sector i.country

reg edu_cont i.sector i.sex i.country					
						
* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

compress
describe
summarize 
	
* save file 	
	save			"$export/lsms_panel", replace

* close the log
	log	close	
