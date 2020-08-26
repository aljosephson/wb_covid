* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Edited by: alj
* Last edit: 16 August 2020 
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


* graph A - look at knowledge variables by country
	graph bar		know_01 know_02 know_03 know_04 know_05 know_06 know_07 know_08, over(country) ///
						title("A") bar(1, color(edkblue*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(eltblue*1.5)) bar(4, color(emerald*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) ///
						bar(7, color(eltgreen*1.5)) bar(8, color(stone*1.5)) ///
						ytitle("Knowledge of actions to reduce exposure (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(label (1 "Handwash with soap") ///
						label (2 "Avoid physical contact") label (3 "Use masks/gloves") ///
						label (4 "Avoid travel") label (5 "Stay at home") ///
						label (6 "Avoid crowds") label (7 "Socially distance") ///
						label (8 "Avoid face touching") pos (6) col(4)) ///
						saving("$output/knowledge", replace)  

	graph export "$output/knowledge.png", as(png) replace	
	
* graph B - look at government variables 
	graph bar		gov_01 gov_02 gov_03 gov_04 gov_05 gov_06 gov_10, over(country) ///
						title("B") bar(1, color(khaki*1.5)) ///
						bar(2, color(cranberry*1.5)) bar(3, color(teal*1.5)) ///
						bar(4, color(lavender*1.5)) bar(5, color(brown*1.5)) ///
						bar(6, color(maroon*1.5)) bar(7, color(eltgreen*1.5) ) ///
						ytitle("Knowledge of government actions to curb spread (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(label (1 "Advised to stay home") ///
						label (2 "Restricted dom. travel") ///
						label (3 "Restricted int. travel") ///
						label (4 "Closed schools") label (5 "Curfew/lockdown") ///
						label (6 "Closed businesses") label (7 "Stopped social gatherings") ///
						pos (6) col(4)) saving("$output/restriction", replace) 

	graph export "$output/restriction.png", as(png) replace	 
						  
* graph C - look at behavior variables
	graph bar 		(mean) bh_01 bh_02 bh_03 if wave == 1, over(country) ///
						title("C") bar(1, color(maroon*1.5)) ///
						bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
						ytitle("Changes in Behavior to Reduce Exposure (%)") ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100") ///
						legend(	label (1 "Increased hand washing") ///
						label (2 "Avoided physical contact") ///
						label (3 "Avoided crowds") pos(6) col(3)) ///
						saving("$output/behavior", replace)

	graph export "$output/behavior.png", as(png) replace	

* graph D - myth variables
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
						bar(1, color(edkblue*1.5) ) ///
						bar(2, color(emerald*1.5) ) ///
						bar(3, color(khaki*1.5) ) ///
						legend( label (1 "True") label (2 "False") ///
						label (3 "Don't Know") pos(6) col(3)) ///
						saving("$output/myth", replace)

	graph export "$output/myth.png", as(png) replace	
	
	restore

* Figure 1 - combine graphs	
	gr 				combine "$output/knowledge.gph" "$output/restriction.gph" ///
						"$output/behavior.gph" "$output/myth.gph", ///
						col(2) iscale(.45) commonscheme

	graph export "$output/knowbehave.png", as(png) replace	

	graph export "$output/knowbehave.pdf", as(pdf) replace	

	
* **********************************************************************
* 2 - income and fies graphs
* **********************************************************************

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
	

	lab def 			dwn 0 "No loss" 1 "Loss" 	
	label val 			dwn dwn 
	
* graph A - income loss by sector
	graph bar		(sum) farm_hhw bus_hhw wage_hhw remit_hhw other_hhw ///
						if wave == 1, over(sector) over(country) title("A")  ///
						ytitle("Population reporting decrease in income") ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" ///
						15000000 "15,000,000") bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) ///
						bar(3, color(khaki*1.5)) bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
						legend( label (1 "Farm income") label (2 "Business income") ///
						label (3 "Wage income") label (4 "Remittances") ///
						label (5 "All else")  pos(6) col(3)) saving("$output/income_sector", replace)
	*** there are xx people living in households who are reporting loss of income 


	graph export "$output/income.png", as(png) replace	
						
* graph B - income loss by wave
	preserve

* need to drop values and reshape
	keep 			bus_emp_inc country wave
	replace			bus_emp_inc = 3 if bus_emp_inc == 4
	gen 			id=_n
	ren 			(bus_emp_inc) (size=)
	reshape long 	size, i(id) j(bus_emp_inc) string
	drop if 		size == .	
	drop if			size == -98 | size == -99

	colorpalette stone maroon, ipolate(15, power(1)) locals

	catplot 		size wave country if country == 1, percent(country wave) stack ///
						var2opts( relabel (1 "May" 2 "June" 3 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/eth_bus_inc", replace)
						
	catplot 		size wave country if country == 2, percent(country wave) stack	 ///
						var2opts( relabel (1 "June" 2 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/mwi_bus_inc", replace)
						
	catplot 		size wave country if country == 3, percent(country wave) stack	 ///
						var2opts( relabel (1 "May" 2 "June" 3 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/nga_bus_inc", replace)
						
	catplot 		size wave country if country == 2, percent(country wave) stack	 ///
						var2opts( relabel (1 "June" 2 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/mwi_bus_inc", replace)
						
	catplot 		size wave country if country == 3, percent(country wave) stack	 ///
						var2opts( relabel (1 "May" 2 "June" 3 "July")) ///
						ytitle("") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend(off) ///
						saving("$output/nga_bus_inc", replace)
						
	catplot 		size wave country if country == 4, percent(country wave) stack	 ///
						var2opts( relabel (1 "June" 2 "July")) ///
						ytitle("Percent") bar(1, fcolor(`1') lcolor(none)) ///
						bar(2, fcolor(`7') lcolor(none))  ///
						bar(3, fcolor(`15') lcolor(none)) legend( ///
						label (1 "Higher than beforeh") ///
						label (2 "Same as before") ///
						label (3 "Less than before") ///
						pos(6) col(3)) saving("$output/uga_bus_inc", replace)

	restore 

	gr 				combine "$output/eth_bus_inc.gph" "$output/mwi_bus_inc.gph" ///
						"$output/nga_bus_inc.gph" "$output/uga_bus_inc.gph", ///
						col(1) iscale(.5) commonscheme imargin(0 0 0 0) title("B") ///
						 saving("$output/bus_emp_inc", replace)

	graph export "$output/bus_emp_inc.png", as(png) replace	
	
* graph C - FIES population

* adjust weights 
	
	gen 				ahw18 = hhsize_adult * wt_18
	gen					ap_mod = p_mod * ahw18 
	gen 				ap_sev = p_sev * ahw18 
	
	gen				fies_01_ahw = ahw18 if fies_01 == 1
	gen				fies_02_ahw = ahw18 if fies_02 == 1
	gen				fies_03_ahw = ahw18 if fies_03 == 1
	gen				fies_04_ahw = ahw18 if fies_04 == 1
	gen				fies_05_ahw = ahw18 if fies_05 == 1
	gen				fies_06_ahw = ahw18 if fies_06 == 1
	gen				fies_07_ahw = ahw18 if fies_07 == 1
	gen				fies_08_ahw = ahw18 if fies_08 == 1
	

	graph bar			(sum) fies_01_ahw fies_02_ahw fies_03_ahw fies_04_ahw fies_05_ahw ///
							fies_06_ahw fies_07_ahw fies_08_ahw, over(country) /// 
							ytitle("Adult population reporting food insecurities") title("C") ///	
							ylabel(0 "0" 50000000 "50,000,000" /// 
							150000000 "150,000,000" 250000000 "250,000,000") ///
							legend( label (1 "Household ran out of food") label (2 "Adult hungry but did not eat") ///
							label (3 "Adult hungry but did not eat for full day") label (4 "Adult worried about food") ///
							label (5 "Adult unable to eat healthy food") label (6 "Adult ate only few kinds of foods") ///
							label (7 "Adult skipped meal") label (8 "Adult ate less") /// 
							pos(6) row(4)) saving("$output/fies", replace)				
	*** do we want to break this out into multiple graphs + then pin together? 
							
							
* graph D - FIES score and income loss
	/*graph 				bar ap_mod ap_sev, over(dwn)  over(country) /// 
							ytitle("FIES score") title("D")   bar(1, color(turquoise)) ///
							saving("$output/fies_count", replace)	*/
	*** this isn't coming out as expected
							
	graph 				bar p_mod p_sev, over(dwn)  over(country) /// 
							ytitle("FIES: Food insecurity prevalence estimates") title("D")   bar(1, color(turquoise)) ///
							legend( label (1 "Moderate food insecurity") label (2 "Severe food insecurity") ///
							pos(6)) saving("$output/fies_modsev", replace)	
	*** change this to be over income quartiles / income information 

* Figure 2 - combine graphs	
	gr combine 			"$output/income_sector.gph" "$output/bus_emp_inc.gph" ///
							"$output/fies.gph" "$output/fies_count.gph", ///
							col(2) iscale(.5) commonscheme
	
	graph export "$output/incomeimpact.png", width(1920) as(png) replace
							
	graph export "$output/incomeimpacts.pdf", as(pdf) replace

	
* **********************************************************************
* 4 - create graphs on concerns and access and education
* **********************************************************************
		
* graph A - access to med, food, soap
	gen				ac_med_01 = phw if quint == 1 & ac_med == 0
	gen				ac_med_02 = phw if quint == 2 & ac_med == 0
	gen				ac_med_03 = phw if quint == 3 & ac_med == 0
	gen				ac_med_04 = phw if quint == 4 & ac_med == 0
	gen				ac_med_05 = phw if quint == 5 & ac_med == 0

	gen				ac_staple_01 = phw if quint == 1 & ac_staple == 0
	gen				ac_staple_02 = phw if quint == 2 & ac_staple == 0
	gen				ac_staple_03 = phw if quint == 3 & ac_staple == 0
	gen				ac_staple_04 = phw if quint == 4 & ac_staple == 0
	gen				ac_staple_05 = phw if quint == 5 & ac_staple == 0

	gen				ac_soap_01 = phw if quint == 1 & ac_soap == 0
	gen				ac_soap_02 = phw if quint == 2 & ac_soap == 0
	gen				ac_soap_03 = phw if quint == 3 & ac_soap == 0
	gen				ac_soap_04 = phw if quint == 4 & ac_soap == 0
	gen				ac_soap_05 = phw if quint == 5 & ac_soap == 0	

	colorpalette edkblue khaki, ipolate(15, power(1)) locals
		
	graph bar 		(sum) ac_med_01 ac_med_02 ac_med_03 ac_med_04 ac_med_05 if ac_med_need == 1 & wave == 1,  ///
						over(country, gap(*.1)) stack  ///
						ytitle("Population reporting inability to buy medicine") ///
						ylabel(0 "0" 5000000 "5,000,000" ///
						10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_med", replace)
	
	graph bar 		(sum) ac_staple_01 ac_staple_02 ac_staple_03 ac_staple_04 ac_staple_05 if ac_staple_need == 1 & wave == 1,  ///
						over(country, gap(*.1)) stack  ///
						ytitle("Population reporting inability to buy staple food") ///
						ylabel(0 "0" 10000000 "10,000,000" ///
						20000000 "20,000,000" 30000000 "30,000,000") ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/ac_staple", replace)		

		
	graph bar 		(sum) ac_soap_01 ac_soap_02 ac_soap_03 ac_soap_04 ac_soap_05 if ac_soap_need == 1 & wave == 1,  ///
						over(country, gap(*.1)) stack  ///
						ytitle("Population reporting inability to buy soap") ///
						ylabel(0 "0" 5000000 "5,000,000" ///
						10000000 "10,000,000" 15000000 "15,000,000") ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(label (1 "First")  ///
						label (2 "Second") label (3 "Third") label (4 "Fourth") ///
						label (5 "Fifth") order( 5 4 3 2 1) pos(3) col(1)) ///
						saving("$output/ac_soap", replace)		
	
	graph combine "$output/ac_med.gph" "$output/ac_staple.gph" "$output/ac_soap.gph", ///
		col(3) iscale(.5) commonscheme title("A") saving("$output/access.gph", replace)						

		graph export "$output/access.png", as(png) replace
						
* graph B - coping mechanisms
	gen				cope_01_phw = phw if cope_01 == 1
	gen				cope_02_phw = phw if cope_02 == 1
	gen				cope_03_phw = phw if cope_03 == 1
	gen				cope_04_phw = phw if cope_04 == 1
	gen				cope_05_phw = phw if cope_05 == 1 | cope_06 == 1 | cope_07 == 1
	gen				cope_08_phw = phw if cope_08 == 1
	gen				cope_09_phw = phw if cope_09 == 1
	gen				cope_10_phw = phw if cope_10 == 1
	gen				cope_11_phw = phw if cope_11 == 1	
	
	graph bar		(sum) cope_01_phw cope_02_phw cope_03_phw cope_04_phw ///
						cope_05_phw cope_08_phw cope_09_phw cope_10_phw ///
						cope_11_phw if country == 1, over(country) ///
						ytitle("Population reporting use of coping strategy") ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" ///
						15000000 "15,000,000" 20000000 "20,000,000") ///
						legend( label (1 "Sale of asset") label (2 "Worked more") ///
						label (3 "Help from family") label (4 "Loan from family") ///
						label (5 "Accessed credit") label (6 "Sold crop early") ///
						label (7 "Reduced food cons.") label (8 "Reduced non-food cons.") ///
						label (9 "Relied on savings") pos(6) col(3)) ///
						saving("$output/cope_eth.gph", replace)
	
	graph bar		(sum) cope_01_phw cope_02_phw cope_03_phw cope_04_phw ///
						cope_05_phw cope_08_phw cope_09_phw cope_10_phw ///
						cope_11_phw if country == 3, legend(off)  over(country) ///
						ylabel(0 "0" 20000000 "20,000,000" 40000000 "40,000,000" ///
						60000000 "60,000,000" 80000000 "80,000,000") ///
						saving("$output/cope_nga.gph", replace)
	
	graph bar		(sum) cope_01_phw cope_02_phw cope_03_phw cope_04_phw ///
						cope_05_phw cope_08_phw cope_09_phw cope_10_phw ///
						cope_11_phw if country == 4, legend(off) over(country) ///
						ylabel(0 "0" 5000000 "5,000,000" 10000000 "10,000,000" ///
						15000000 "15,000,000") //////
						saving("$output/cope_uga.gph", replace)
						
	
	grc1leg2 "$output/cope_eth.gph" "$output/cope_nga.gph" "$output/cope_uga.gph", ///
		col(3) iscale(.5) commonscheme title("B") saving("$output/cope.gph", replace)						
	
* graph C - education activities
	gen				edu_cont_hhw = hhw if edu_cont == 1
	gen 			edu_act_phw = phw if edu_act == 1
	gen 			edu_act_hhw = hhw if edu_act == 1
	gen 			edu_01_hhw = hhw if edu_01 == 1 
	gen 			edu_02_hhw = hhw if edu_02 == 1 
	gen 			edu_03_hhw = hhw if edu_03 == 1 
	gen 			edu_04_hhw = hhw if edu_04 == 1 
	gen 			edu_05_hhw = hhw if edu_05 == 1 

	graph bar		(sum) edu_01_hhw edu_02_hhw edu_03_hhw edu_04_hhw edu_05_hhw if country == 1, ///
						over(sector) over(country) legend(off) ///
						ylabel(0 "0" 500000 "500,000" 1500000 "1,500,000" ///
						 2500000 "2,500,000") /// 
						 legend( ///
						label (1 "Completed assignments provided by teacher") ///
						label (2 "Using mobile learning apps") ///
						label (3 "Watched education television") ///
						label (4 "Listened to educational radio programs") ///
						label (5 "Session with teacher") pos(6) col(2)) ///	
						ytitle("Population experiencing various types of educational contact")  ///
						 saving("$output/educont_eth", replace)		
						 
	graph bar		(sum) edu_01_hhw edu_02_hhw edu_03_hhw edu_04_hhw edu_05_hhw if country == 2, ///
						over(sector) over(country) legend(off) /// 
						ylabel(0 "0" 20000 "20,000" 60000 "60,000" ///
						 100000 "100,000") /// 
						 saving("$output/educont_mwi", replace)			
						 
	graph bar		(sum) edu_01_hhw edu_02_hhw edu_03_hhw edu_04_hhw edu_05_hhw if country == 3, ///
						over(sector) over(country) legend(off) /// 
						ylabel(0 "0" 2000000 "2,000,000" 4000000 "4,000,000" ///
						 6000000 "6,000,000") ///
						 saving("$output/educont_nga", replace)		

	graph bar		(sum) edu_01_hhw edu_02_hhw edu_03_hhw edu_04_hhw edu_05_hhw if country == 4, ///
						over(sector) over(country) legend(off) ///
						ylabel(0 "0" 350000 "350,000" 700000 "700,000" ///
						 1100000 "1,100,000") ///		
						 saving("$output/educont_uga", replace)				

* combine into graph C
	grc1leg2  		 "$output/educont_eth.gph" "$output/educont_mwi.gph" ///
						"$output/educont_nga.gph" "$output/educont_uga.gph", ///
						col(4) iscale(.5) commonscheme imargin(0 0 0 0) legend() title("C") ///
						saving("$output/educont", replace)	

* graph D - education and food						
	*graph bar 		dwn, over(edu_act) over(sector) over (country) 
	
	lab def 			edu_act 0 "No learning" 1 "Learning" 	
	label val 			edu_act edu_act  

	graph bar 		p_mod p_sev, over(edu_act) over (country) /// 
							ytitle("FIES: Food insecurity prevalence estimates") title("D")  bar(1, color(turquoise)) ///
							legend( label (1 "Moderate food insecurity") label (2 "Severe food insecurity") ///
							pos(6)) saving("$output/fies_edu", replace)	
	

* Figure 3 - combine graphs	
	gr combine 			"$output/access.gph" "$output/cope.gph" ///
							"$output/educont.gph" "$output/fies_edu.gph", ///
							col(2) iscale(.5) commonscheme
	
	graph export "$output/access_cope.png", width(1920) as(png) replace
							
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

