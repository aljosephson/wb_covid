* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edit: 6 August 2020 
* Stata v.16.1

* does
	* merges together all countries
	* renames variables
	* runs regression analysis

* assumes
	* cleaned country data
	* catplot

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
* 1 - create graphs on knowledge and behavior
* **********************************************************************

* read in data
	use				"$ans/lsms_panel", clear

* look at knowledge variables by country
	graph bar		know_01 know_02 know_03 know_04 know_05 know_06 know_07 know_08, over(country) ///
						title("A") ///
						ytitle("Knowledge of actions to reduce exposure (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(label (1 "Handwash with soap") ///
						label (2 "Avoid physical contact") label (3 "Use masks/gloves") ///
						label (4 "Avoid travel") label (5 "Stay at home") ///
						label (6 "Avoid crowds") label (7 "Socially distance") ///
						label (8 "Avoid face touching") pos (6) col(4)) ///
						saving("$export/knowledge", replace)

	graph export "$output/knowledge.pdf", as(pdf) replace		  
						  
* look at government variables 
	graph bar		gov_01 gov_02 gov_03 gov_04 gov_05 gov_06 gov_10, over(country) ///
						title("B") ///
						ytitle("Knowledge of government actions to curb spread (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(label (1 "Advised to stay home") ///
						label (2 "Restricted dom. travel") ///
						label (3 "Restricted int. travel") ///
						label (4 "Closed schools") label (5 "Curfew/lockdown") ///
						label (6 "Closed businesses") label (7 "Stopped social gatherings") ///
						pos (6) col(4)) saving("$export/restriction", replace)

	graph export "$output/restriction.pdf", as(pdf) replace		  
						  
* look at behavior variables
	graph bar 		(mean) bh_01 bh_02 bh_03, over(country) ///
						title("C") ///
						ytitle("Changes in Behavior to Reduce Exposure (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3)) ///
						saving("$export/behavior", replace)
						
	graph export "$output/behavior.pdf", as(pdf) replace	

* look at myth variables
	preserve

* need to drop values and reshape	
	drop if			country == 1 | country == 3
	keep 			myth_01 myth_02 myth_03 myth_04 myth_05 country
	gen 			id=_n
	ren 			(myth_01 myth_02 myth_03 myth_04 myth_05) (size=)
	reshape long 	size, i(id) j(myth) string
	drop if 		size == .

* generate graph
	catplot 		size country myth, percent(country myth) ///
						title("D") ytitle("Percent") var3opts( ///
						relabel (1 `""Lemon and alcohol are" "effective sanitizers""' ///
						2 "Africans are immune" 3 "Children are not affected" ///
						4 `""Virus cannot surive" "warm weather""' ///
						5 `""COVID-19 is just" "common flu""')) ///
						bar(1, color(orangebrown)) bar(2, color(reddish)) ///
						bar(3, color(ananas)) ///
						legend( label (1 "True") label (2 "False") ///
						label (3 "Don't Know") pos(6) col(3)) ///
						saving("$export/myth", replace)

	graph export "$output/myth.pdf", as(pdf) replace	
	
	restore

* combine graphs	
	gr 				combine "$export/knowledge.gph" "$export/restriction.gph" ///
						"$export/behavior.gph" "$export/myth.gph", ///
						col(2) iscale(.45) commonscheme

	graph export "$output/fig1.png", width(16000) as(png) replace
	
* **********************************************************************
* 2 - create graphs on concerns and access
* **********************************************************************
		
* concerns
	graph bar		concern_01 concern_02, over(country) ///
						legend(	label (1 "Health concerns") ///
						label (2 "Financial concerns") pos(6) col(3))
						
	graph bar		concern_01 concern_02, over(sector) ///
						legend(	label (1 "Health concerns") ///
						label (2 "Financial concerns") pos(6) col(3))

* access
	gen				ac_med_r = phw if sector == 1 & ac_med == 0
	gen				ac_med_u = phw if sector == 2 & ac_med == 0
	gen				ac_staple_r = phw if sector == 1 & ac_staple == 0
	gen				ac_staple_u = phw if sector == 2 & ac_staple == 0

	graph bar 		(sum) ac_med_r ac_med_u if ac_med_need == 1,  ///
						over(country, gap(*.1)) stack  ///
						ytitle("Population reporting inability to buy medicine") ///
						ylabel(0 "0" 5000000 "5,000,000" ///
						10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, color(sky)) bar(2, color(turquoise))  ///
						legend(	label (1 "Rural") label (2 "Urban") ///
						pos(6) col(3)) saving("$export/ac_med", replace)
	

	graph bar 		(sum) ac_staple_r ac_staple_u if ac_med_need == 1,  ///
						over(country, gap(*.1)) stack  ///
						ytitle("Population reporting inability to buy staple food") ///
						ylabel(0 "0" 5000000 "5,000,000" ///
						10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, color(sky)) bar(2, color(turquoise))  ///
						legend(	label (1 "Rural") label (2 "Urban") ///
						pos(6) col(3)) saving("$export/ac_staple", replace)
	
	gr combine "$export/ac_med.gph" "$export/ac_staple.gph", col(2) iscale(.5) commonscheme
		
	graph export "$output/access.pdf", as(pdf) replace
					
	
* change in income
	gen				farm_phw = hhw if farm_dwn == 1
	gen				bus_phw = hhw if bus_dwn == 1
	gen				wage_phw = hhw if wage_dwn == 1
	gen				remit_phw = hhw if remit_dwn == 1
	gen				other_phw = hhw if other_dwn == 1
			
	graph bar		(sum) farm_phw bus_phw wage_phw remit_phw other_phw, ///
						over(sector) over(country) ///
						ytitle("Households reporting decrease in income") ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" ///
						15000000 "15,000,000") ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") ///
						label (5 "All else")  pos(6) col(3))			

	graph export "$output/income.pdf", as(pdf) replace
					
						
* **********************************************************************
* 3 - basic regressions
* **********************************************************************


keep if ac_med_need == 1

collapse (sum) phw, by(country)


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

