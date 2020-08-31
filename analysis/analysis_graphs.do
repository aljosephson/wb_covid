* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edit: 27 August 2020 
* Stata v.16.1

* does
	* merges together all countries
	* renames variables
	* runs regression analysis

* assumes
	* cleaned country data
	* catplot
	* grc1leg2
	* palettes
	* colrspace

* TO DO:
	* make all labels size(medsmall)
	* make letter title larger


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


* graph A - look at government variables 
	graph bar		gov_01 gov_02 gov_04 gov_05 gov_06 gov_10 [pweight = phw], over(country) ///
						title("A", size(huge)) bar(1, color(khaki*1.5)) ///
						bar(2, color(cranberry*1.5)) bar(3, color(teal*1.5)) ///
						bar(4, color(lavender*1.5)) bar(5, color(brown*1.5)) ///
						bar(6, color(maroon*1.5)) ///
						ytitle("Knowledge of government actions to curb spread (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(label (1 "Advised to stay home") ///
						label (2 "Restricted travel") ///
						label (3 "Closed schools") label (4 "Curfew/lockdown") ///
						label (5 "Closed businesses") label (6 "Stopped social gatherings") ///
						pos (6) col(3) size(medsmall)) saving("$output/restriction", replace) 

	graph export 	"$output/restriction.emf", as(emf) replace	 
	
	
* graph B - look at knowledge variables by country
	graph bar		know_01 know_02 know_03 know_05 know_06 know_07 ///
						[pweight = phw], over(country) title("B", size(huge)) ///
						bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						ytitle("Knowledge of actions to reduce exposure (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(label (1 "Handwash with soap") ///
						label (2 "Avoid physical contact") label (3 "Use masks/gloves") ///
						label (4 "Stay at home") label (5 "Avoid crowds") ///
						label (6 "Socially distance") pos (6) col(3) ///
						size(medsmall)) saving("$output/knowledge", replace)  

	graph export 	"$output/knowledge.emf", as(emf) replace	
	
	
* graph C - look at behavior variables
	graph bar 		(mean) bh_01 bh_02 bh_03 if wave == 1 [pweight = phw], over(country) ///
						title("C", size(huge)) bar(1, color(maroon*1.5)) ///
						bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
						ytitle("Changes in Behavior to Reduce Exposure (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3) ///
						size(medsmall)) saving("$output/behavior", replace)

	graph export 	"$output/behavior.emf", as(emf) replace	

	
* graph D - myth variables
	preserve

	drop if			country == 1 | country == 3
	keep 			myth_01 myth_02 myth_03 myth_04 myth_05 country phw
	gen 			id=_n
	ren 			(myth_01 myth_02 myth_03 myth_04 myth_05) (size=)
	reshape long 	size, i(id) j(myth) string
	drop if 		size == .

	catplot 		size country myth [aweight = phw], percent(country myth) ///
						title("D", size(huge)) ytitle("Percent") var3opts( ///
						relabel (1 `""Lemon and alcohol are effective" "sanitizers against coronavirus""' ///
						2 `""Africans are immune" "to coronavirus"""' ///
						3 `""Coronavirus does not" "affect children"""' ///
						4 `""Coronavirus cannot survive" "warm weather""' ///
						5 `""Coronavirus is just" "common flu""')) ///
						bar(1, color(edkblue*1.5) ) ///
						bar(2, color(emerald*1.5) ) ///
						bar(3, color(khaki*1.5) ) ///
						legend( label (1 "True") label (2 "False") ///
						label (3 "Don't Know") pos(6) col(3) ///
						size(medsmall)) saving("$output/myth", replace)

	graph export 	"$output/myth.emf", as(emf) replace	
	
	restore

* figure 1 - combine graphs	
	gr 				combine "$output/restriction.gph" "$output/knowledge.gph" ///
						"$output/behavior.gph" "$output/myth.gph", ///
						col(2) iscale(.45) commonscheme
												
	graph export 	"$output/knowbehave.emf", as(emf) replace	
	graph export 	"$output/knowbehave.pdf", as(pdf) replace	

	
* **********************************************************************
* 2 - income and fies graphs
* **********************************************************************

	lab def 		dwn 0 "No loss" 1 "Loss" 	
	label val 		dwn dwn
	
	
* graph A - income loss by sector	
	graph bar		(sum) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn [pweight = hhw] ///
						if country == 1 & wave == 1, over(sector) over(country)  ///
						ytitle("Households reporting decrease in income") ///
						ylabel(0 "0" 1000000 "1,000,000" 2000000 "2,000,000" 3000000 "3,000,000" ///
						4000000 "4,000,000" 5000000 "5,000,000") bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) ///
						bar(3, color(khaki*1.5)) bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
						pos(6) col(3) size(medsmall)) saving("$output/income_eth", replace)
	
	graph bar		(sum) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn [pweight = hhw] ///
						if country == 2 & wave == 1, over(sector) over(country) ///
						ylabel(0 "0" 1000000 "1,000,000" 2000000 "2,0500,000" ///
						3000000 "3,000,000") bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) ///
						bar(3, color(khaki*1.5)) bar(4, color(cranberry*1.5)) ///
						bar(5, color(purple*1.5)) legend(off) saving("$output/income_mwi", replace)

	graph bar		(sum) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn [pweight = hhw] ///
						if country == 3 & wave == 1, over(sector) over(country) ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) ///
						bar(3, color(khaki*1.5)) bar(4, color(cranberry*1.5)) ///
						bar(5, color(purple*1.5)) legend(off) saving("$output/income_nga", replace)

	graph bar		(sum) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn [pweight = hhw] ///
						if country == 4 & wave == 1, over(sector) over(country) ///
						ylabel(0 "0" 1000000 "1,000,000" 2000000 "2,000,000" 3000000 "3,000,000" ///
						4000000 "4,000,000") bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) ///
						bar(3, color(khaki*1.5)) bar(4, color(cranberry*1.5)) ///
						bar(5, color(purple*1.5)) legend(off) saving("$output/income_uga", replace)
	
	grc1leg2 		"$output/income_eth.gph" "$output/income_mwi.gph" ///
						"$output/income_nga.gph" "$output/income_uga.gph", ///
						col(4) iscale(.5) commonscheme ///
						title("A", size(huge)) saving("$output/income.gph", replace)						
	
	graph export 	"$output/income.emf", as(emf) replace	

	
* graph B - income loss by wave
	preserve

	keep 			bus_emp_inc country wave hhw
	replace			bus_emp_inc = 3 if bus_emp_inc == 4
	gen 			id=_n
	ren 			(bus_emp_inc) (size=)
	reshape long 	size, i(id) j(bus_emp_inc) string
	drop if 		size == .	
	drop if			size == -98 | size == -99

	colorpalette 	stone maroon, ipolate(15, power(1)) locals

	catplot 		size wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
						var2opts( relabel (1 "May" 2 "June" 3 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend( ///
						label (1 "Higher than before") ///
						label (2 "Same as before") ///
						label (3 "Less than before") pos(6) col(3) ///
						size(medsmall)) saving("$output/eth_bus_inc", replace)
						
	catplot 		size wave country [aweight = hhw] if country == 2, percent(country wave) stack	 ///
						var2opts( relabel (1 "June" 2 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/mwi_bus_inc", replace)
						
	catplot 		size wave country [aweight = hhw] if country == 3, percent(country wave) stack	 ///
						var2opts( relabel (1 "May" 2 "June" 3 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/nga_bus_inc", replace)
						
	catplot 		size wave country [aweight = hhw] if country == 4, percent(country wave) stack	 ///
						var2opts( relabel (1 "June" 2 "July")) ///
						ytitle("Percent of households reporting change in business revenue") ///
						bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/uga_bus_inc", replace)

	restore 

	grc1leg2 		"$output/eth_bus_inc.gph" "$output/mwi_bus_inc.gph" ///
						"$output/nga_bus_inc.gph" "$output/uga_bus_inc.gph", ///
						col(1) iscale(.5) commonscheme imargin(0 0 0 0) title("B", size(huge)) ///
						saving("$output/bus_emp_inc", replace)

	graph export 	"$output/bus_emp_inc.emf", as(emf) replace	
	
	
* graph C - FIES score and consumption quntile
	preserve 
	drop if 		country == 1 & wave == 2 
	drop if 		country == 2 & wave == 1 
	
	gen				p_mod_01 = p_mod if quint == 1 
	gen				p_mod_02 = p_mod if quint == 2 
	gen				p_mod_03 = p_mod if quint == 3 
	gen				p_mod_04 = p_mod if quint == 4 
	gen				p_mod_05 = p_mod if quint == 5 
	
	gen				p_sev_01 = p_sev if quint == 1 
	gen				p_sev_02 = p_sev if quint == 2 
	gen				p_sev_03 = p_sev if quint == 3 
	gen				p_sev_04 = p_sev if quint == 4 
	gen				p_sev_05 = p_sev if quint == 5 
	
	colorpalette edkblue khaki, ipolate(15, power(1)) locals
	
	graph bar 		(mean) p_mod_01 p_mod_02 p_mod_03 p_mod_04 p_mod_05 ///
						[pweight = wt_18], over(country) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						ytitle("Probability of moderate or severe food insecurity")  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First")  ///
						label (2 "Second") label (3 "Third") label (4 "Fourth") ///
						label (5 "Fifth") order( 5 4 3 2 1) pos(3) col(1) size(medsmall)) /// 
						saving("$output/fies_modsev", replace)				 
							 
	graph bar 		(mean) p_sev_01 p_sev_02 p_sev_03 p_sev_04 p_sev_05 ///
						[pweight = wt_18], over(country)  ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						ytitle("Probability of severe food insecurity")  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/fies_sev", replace)						
	
	restore
	
	grc1leg2 		"$output/fies_modsev.gph" "$output/fies_sev.gph", ///
						col(2) iscale(.5) pos(3) commonscheme title("C", size(huge)) ///
						saving("$output/fies.gph", replace)						

	graph export 	"$output/fies.emf", as(emf) replace			
 	
	
* graph D - concerns with FIES
	preserve
	drop if			country == 2 & wave == 1

	graph hbar		(mean) p_mod p_sev [pweight = wt_18], over(concern_01) ///
						over(country) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100") ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(label (1 "Moderate or severe")  ///
						label (2 "Severe") pos(6) col(2) size(medsmall)) /// 
						title("Concerned that family or self will fall ill with COVID-19") ///
						saving("$output/concern_1", replace)				

	graph hbar		(mean) p_mod p_sev [pweight = wt_18], over(concern_02) ///
						over(country) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
						.8 "80" 1 "100") ytitle("Probability of food insecurity") ///
						bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
						legend(off) /// 
						title("Concerned about the financial threat of COVID-19") ///
						saving("$output/concern_2", replace)	

	restore 
	
	grc1leg2 		"$output/concern_1.gph" "$output/concern_2.gph", ///
						col(1) iscale(.5) pos(6) commonscheme title("D", size(huge)) ///
						saving("$output/concerns.gph", replace)		
	
	graph export 	"$output/concerns.emf", as(emf) replace			
 	
	
* figure 2 - combine graphs	
	gr combine 		"$output/income.gph" "$output/bus_emp_inc.gph" ///
						"$output/fies.gph" "$output/concerns.gph", ///
						col(2) iscale(.5) commonscheme
									
	graph export 	"$output/incomeimpacts.emf", as(emf) replace
	graph export 	"$output/incomeimpacts.pdf", as(pdf) replace

	
* **********************************************************************
* 3 - create graphs on concerns and access and education
* **********************************************************************
		
* graph A - access to med, food, soap
	gen				ac_med_01 = 1 if quint == 1 & ac_med == 0
	gen				ac_med_02 = 1 if quint == 2 & ac_med == 0
	gen				ac_med_03 = 1 if quint == 3 & ac_med == 0
	gen				ac_med_04 = 1 if quint == 4 & ac_med == 0
	gen				ac_med_05 = 1 if quint == 5 & ac_med == 0

	gen				ac_staple_01 = 1 if quint == 1 & ac_staple == 0
	gen				ac_staple_02 = 1 if quint == 2 & ac_staple == 0
	gen				ac_staple_03 = 1 if quint == 3 & ac_staple == 0
	gen				ac_staple_04 = 1 if quint == 4 & ac_staple == 0
	gen				ac_staple_05 = 1 if quint == 5 & ac_staple == 0

	gen				ac_soap_01 = 1 if quint == 1 & ac_soap == 0
	gen				ac_soap_02 = 1 if quint == 2 & ac_soap == 0
	gen				ac_soap_03 = 1 if quint == 3 & ac_soap == 0
	gen				ac_soap_04 = 1 if quint == 4 & ac_soap == 0
	gen				ac_soap_05 = 1 if quint == 5 & ac_soap == 0	

	colorpalette edkblue khaki, ipolate(15, power(1)) locals
		
	graph bar 		(sum) ac_med_01 ac_med_02 ac_med_03 ac_med_04 ac_med_05 ///
						[pweight = phw] if ac_med_need == 1 & wave == 1, ///
						over(country, gap(*.1) label(labsize(small))) stack  ///
						ytitle("Population reporting inability to buy medicine") ///
						ylabel(0 "0" 5000000 "5,000,000" ///
						10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First")  ///
						label (2 "Second") label (3 "Third") label (4 "Fourth") ///
						label (5 "Fifth") order( 5 4 3 2 1) pos(3) col(1) size(medsmall)) /// 
						saving("$output/ac_med", replace)
	
	graph bar 		(sum) ac_staple_01 ac_staple_02 ac_staple_03 ac_staple_04 ac_staple_05 ///
						[pweight = phw] if ac_staple_need == 1 & wave == 1,  ///
						over(country, gap(*.1) label(labsize(small))) stack  ///
						ytitle("Population reporting inability to buy staple food") ///
						ylabel(0 "0" 10000000 "10,000,000" ///
						20000000 "20,000,000" 30000000 "30,000,000") ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_staple", replace)		
	
	graph bar 		(sum) ac_soap_01 ac_soap_02 ac_soap_03 ac_soap_04 ac_soap_05 ///
						[pweight = phw] if ac_soap_need == 1 & wave == 1,  ///
						over(country, gap(*.1) label(labsize(small))) stack  ///
						ytitle("Population reporting inability to buy soap") ///
						ylabel(0 "0" 5000000 "5,000,000" ///
						10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_soap", replace)		
	
	grc1leg2		"$output/ac_med.gph" "$output/ac_staple.gph" "$output/ac_soap.gph", ///
						col(3) iscale(.5) pos(3) commonscheme title("A") ///
						saving("$output/access.gph", replace)						

	graph export 	"$output/access.emf", as(emf) replace
	
	
* graph B - coping mechanisms
	preserve 
	drop if country == 1 & wave == 1
	drop if country == 1 & wave == 2 
	drop if country == 3 & wave == 1 

	replace			cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace			cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1
	
	graph bar		(sum) cope_01 cope_03 cope_05 cope_09 cope_10 cope_11 ///
						[pweight = hhw] if country == 1, over(sector) over(country) ///
						bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						ytitle("Households reporting use of coping strategy") ///
						ylabel(0 "0" 500000 "500,000" 1000000 "1,000,000" ///
						1500000 "1,500,000" ) ///
						legend( label (1 "Sale of asset") label (2 "Help from family") ///
						label (3 "Accessed credit") label (4 "Reduced food cons.") ///
						label (5 "Reduced non-food cons.") ///
						label (6 "Relied on savings") size(medsmall) pos(6) col(3)) ///
						saving("$output/cope_eth.gph", replace)
	
	graph bar		(sum) cope_01 cope_03 cope_05 cope_09 cope_10 cope_11 ///
						[pweight = hhw] if country == 2, legend(off) over(sector) over(country) ///
						bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						bar(9, color(navy*1.5)) ///
						ylabel(0 "0" 100000 "100,000" 300000 "300,000" ///
						500000 "500,000") ///
						saving("$output/cope_mwi.gph", replace)
	
	graph bar		(sum) cope_01 cope_03 cope_05 cope_09 cope_10 cope_11 ///
						[pweight = hhw] if country == 3, legend(off) over(sector) over(country) ///
						bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						bar(7, color(eltgreen*1.5)) ylabel(0 "0" 3000000 ///
						"3,000,000" 6000000 "6,000,000" 9000000 "9,000,000" ///
						12000000 "12,000,000") ///
						saving("$output/cope_nga.gph", replace)
	
	graph bar		(sum) cope_01 cope_03 cope_05 cope_09 cope_10 cope_11 ///
						[pweight = hhw] if country == 4, legend(off) over(sector) over(country) ///
						bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						ylabel(0 "0" 500000 "500,000" 1000000 "1,000,000" ///
						1500000 "1,500,000" ) ///
						saving("$output/cope_uga.gph", replace)

	restore
						
	grc1leg2 		"$output/cope_eth.gph" "$output/cope_mwi.gph" "$output/cope_nga.gph" ///
						"$output/cope_uga.gph", col(4) iscale(.5) commonscheme ///
						title("B") saving("$output/cope.gph", replace)						
	
	graph export 	"$output/cope.emf", as(emf) replace
	
	
* graph C - education activities
	graph bar		edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 1 ///
						, over(wave) over(country) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") /// 
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend( size(medsmall) ///
						label (1 "Listened to educational radio programs") ///
						label (2 "Using mobile learning apps") ///
						label (3 "Watched education television") ///
						label (4 "Session with teacher") pos(6) col(2)) ///	
						ytitle("Percentage of households with children experiencing educational contact (%)")  ///
						saving("$output/educont_eth", replace)		
						 
	graph bar		 edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 2 ///
						, over(wave) over(country) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") /// 
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_mwi", replace)			
						 
	graph bar		 edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 3 ///
						, over(wave) over(country) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") /// 
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_nga", replace)		

	graph bar		edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 4 ///
						, over(wave) over(country) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") /// 
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_uga", replace)				

	grc1leg2  		 "$output/educont_eth.gph" "$output/educont_mwi.gph" ///
						"$output/educont_nga.gph" "$output/educont_uga.gph", ///
						col(4) iscale(.5) commonscheme imargin(0 0 0 0) legend() title("C") ///
						saving("$output/educont", replace)	

	graph export 	"$output/educont.emf", as(emf) replace
		
		
* graph D - education and food						
	*graph bar 		dwn, over(edu_act) over(sector) over (country) 
	gen				edu_act_01 = edu_act if quint == 1 
	gen				edu_act_02 = edu_act if quint == 2 
	gen				edu_act_03 = edu_act if quint == 3 
	gen				edu_act_04 = edu_act if quint == 4 
	gen				edu_act_05 = edu_act if quint == 5 

	colorpalette edkblue khaki, ipolate(15, power(1)) locals
	
	graph bar 		(mean) edu_act_01 edu_act_02 edu_act_03 edu_act_04 edu_act_05 ///
						[pweight = hhw], over(country) title("D") ///
						ytitle("Households with children engaged in learning activities (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") /// 
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First")  ///
						label (2 "Second") label (3 "Third") label (4 "Fourth") ///
						label (5 "Fifth") order( 5 4 3 2 1) pos(3) col(1) size(medsmall)) /// 
						saving("$output/edu_quint", replace)				 
	
	graph export "$output/edu_quint.emf", as(emf) replace
	
	

* figure 3 - combine graphs	
	gr combine 			"$output/access.gph" "$output/cope.gph" ///
							"$output/educont.gph" "$output/edu_quint.gph", ///
							col(2) iscale(.5) commonscheme
	
	graph export "$output/access_cope.emf", as(emf) replace
							
	graph export "$output/access_cope.pdf", as(pdf) replace
	
	
* **********************************************************************
* 4 - basic regressions
* **********************************************************************

* connect household roster to this household data in household panel
* then we can do by gender or age to see % of those people in household facing that issue
						
reg bh_01 i.farm_dwn i.sex i.sector i.country
reg bh_01 i.bus_dwn i.sex i.sector i.country
reg bh_01 i.bus_dwn age i.sex i.sector i.country
reg bh_02 i.bus_dwn age i.sex i.sector i.country
reg bh_03 i.bus_dwn age i.sex i.sector i.country


	reg 			dwn_count age i.sex i.sector i.country 
	** robust to different measures of dwn (e.g. dwn)
	*** urban areas associated with fewer losses of income, relative to urban areas 
	*** malawi, nigeria, and uganda all have more losses of income, relative to ethiopia 
	*** * possible measurement issues in ethiopia 

	reg 			edu_act i.sector i.sex i.country		
	reg 			edu_cont i.sector i.sex i.country
	reg 			edu_act fies_count i.sector i.sex i.country
	*** lower fies count - associated with educational activities 
						
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

