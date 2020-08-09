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
	gen				farm_hhw = hhw if farm_dwn == 1
	gen				bus_hhw = hhw if bus_dwn == 1
	gen				wage_hhw = hhw if wage_dwn == 1
	gen				remit_hhw = hhw if remit_dwn == 1
	gen				other_hhw = hhw if other_dwn == 1

	gen				farm_phw = phw if farm_dwn == 1
	gen				bus_phw = phw if bus_dwn == 1
	gen				wage_phw = phw if wage_dwn == 1
	gen				remit_phw = phw if remit_dwn == 1
	gen				other_phw = phw if other_dwn == 1
	

	gen				fies_01_hhw = hhw if fies_01 == 1
	gen				fies_02_hhw = hhw if fies_02 == 1
	gen				fies_03_hhw = hhw if fies_03 == 1
	gen				fies_04_hhw = hhw if fies_04 == 1
	gen				fies_05_hhw = hhw if fies_05 == 1
	gen				fies_06_hhw = hhw if fies_06 == 1
	gen				fies_07_hhw = hhw if fies_07 == 1
	gen				fies_08_hhw = hhw if fies_08 == 1
	
	graph bar		(sum) farm_hhw bus_hhw wage_hhw remit_hhw other_hhw, ///
						 over(country) ///
						ytitle("Households reporting decrease in income") ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" ///
						15000000 "15,000,000") ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") ///
						label (5 "All else")  pos(6) col(3)) saving("$export/income", replace)		
 
	graph bar		(sum) farm_hhw bus_hhw wage_hhw remit_hhw other_hhw, ///
						over(sector) over(country) ///
						ytitle("Households reporting decrease in income") ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" ///
						15000000 "15,000,000") ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") ///
						label (5 "All else")  pos(6) col(3)) saving("$export/income_sector", replace)
	*** there are xx people living in households who are reporting loss of income 

	graph 				bar fies_01 fies_02 fies_03 fies_04 fies_05 ///
							fies_06 fies_07 fies_08, over(country) /// 
							ytitle("Percent of households reporting food insecurities") ///
							legend( label (1 "Household ran out of food") label (2 "Adult hungry but did not eat") ///
							label (3 "Adult hungry but did not eat for full day") label (4 "Adult worried about food") ///
							label (5 "Adult unable to eat healthy food") label (6 "Adult ate only few kinds of foods") ///
							label (7 "Adult skpped meal") label (8 "Adult ate less") /// 
							pos(6) row(4)) saving("$export/fies", replace)	
								
	graph 				bar fies_count, over(sector) over(country) /// 
							ytitle("FIES score") saving("$export/fies_count", replace)	
							
	gr combine "$export/income.gph" "$export/income_sector.gph" "export/fies.gph" "export/fies_count.gph", col(2) iscale(.5) commonscheme
	graph export "$output/incomeimpacts.pdf", as(pdf) replace
	
				
						
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

	*reg 			dwn_count9 i.sex i.sector i.country 
	reg 			dwn_count4 i.sex i.sector i.country 
	*** no difference by gender
	*** urban areas associated with fewer losses of income, relative to urban areas 
	*** malawi, nigeria, and uganda all have more losses of income, relative to ethiopia 
	*** * possible measurement issues in ethiopia 


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

