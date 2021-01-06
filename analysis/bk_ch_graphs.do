* Project: WB COVID
* Created on: Jan 2020
* Created by: amf
* Edited by: 
* Last edit: January 2020
* Stata v.16.1

* does
	* produces graphs for paper chapter
	
* assumes
	* cleaned country data
	* catplot
	* grc1leg2
	* palettes
	* colrspace

* TO DO:
	* change waves to months


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$output_f/book_chapter/figures"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/presentation_graphs", append

* read in data
	use				"$ans/lsms_panel", clear


* **********************************************************************
* 1 - behavior
* **********************************************************************

/* ethiopia and nigeria only have wave 1, suggest keeping wave one graph from below and then 
   have trend graph of malawi and uganda below. For mwi, wave 3 changes the question from 
   "avoided crowds" to "did you attend funerals", "did you attend church" and "did you attend
   family gatherings" with responses of same as usual, less than usual, and not at all. We could 
   try to fit this into the "avoided"  format and see it it looks consistent? */

	lab def 			wave 1 "Wave 1" 2 "Wave 2" 3 "Wave 3" 4 "Wave 4" 5 "Wave 5" 6 "Wave 6", replace
	lab val 			wave wave 
	
	graph bar 			(mean) bh_1 bh_2 bh_3 bh_8 if country == 1 [pweight = phw], ///
							over(wave, lab(labs(vlarge))) title("Ethiopia", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Increased hand washing") label (2 "Avoided physical contact") ///
							label (3 "Avoided crowds") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_eth", replace)

	graph bar 			(mean) bh_1 bh_2 bh_3 bh_8 if country == 2 [pweight = phw], ///
							over(wave, lab(labs(vlarge)))  title("Malawi", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin(0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Increased hand washing") label (2 "Avoided physical contact") ///
							label (3 "Avoided crowds") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_mwi", replace)
	
	graph bar 			(mean) bh_1 bh_2 bh_3 bh_8 if country == 3 [pweight = phw], ///
							over(wave, lab(labs(vlarge))) title("Nigeria", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Increased hand washing") label (2 "Avoided physical contact") ///
							label (3 "Avoided crowds") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_nga", replace)
		
	graph bar 			(mean) bh_1 bh_2 bh_3 bh_8 if country == 4 [pweight = phw], ///
							over(wave, lab(labs(vlarge))) title("Uganda", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Increased hand washing") label (2 "Avoided physical contact") ///
							label (3 "Avoided crowds") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_uga", replace)

	grc1leg2   			"$output/stata_graphs/behavior_eth.gph" "$output/stata_graphs/behavior_mwi.gph" ///
							"$output/stata_graphs/behavior_nga.gph" "$output/stata_graphs/behavior_uga.gph", ///
							col(2) iscale(.5) commonscheme title("Individual's change in behavior to reduce exposure", ///
							size(large)) imargin(0 0 0 0) legend()
					
	graph export 		"$output/behavior_wave.png", as(png) replace
	
	
* **********************************************************************
* 2 - myths (wave 1 only)
* **********************************************************************

	preserve

	drop if			country == 1 | country == 3
	keep 			myth_2 myth_3 myth_4 myth_5 country phw
	gen 			id=_n
	ren 			(myth_2 myth_3 myth_4 myth_5) (size=)
	reshape long 	size, i(id) j(myth) string
	drop if 		size == .
	drop if			size == 3

	catplot 		size country myth [aweight = phw], percent(country myth) ///
						ytitle("Percent", size(vlarge)) var1opts(label(labsize(vlarge))) ///
						var2opts(label(labsize(vlarge))) var3opts(label(labsize(large)) ///
						relabel (1 `""Africans are immune" "to coronavirus"""' ///
						2 `""Coronavirus does not" "affect children"""' ///
						3 `""Coronavirus cannot survive" "warm weather""' ///
						4 `""Coronavirus is just" "common flu""'))  ///
						ylabel(, labs(vlarge)) ///
						bar(1, color(khaki*1.5) ) ///
						bar(2, color(emerald*1.5) ) ///
						legend( label (2 "True") label (1 "False") pos(6) col(2) ///
						size(medsmall)) saving("$output/stata_graphs/myth", replace)

	restore
	
	grc1leg2  		 "$output/stata_graphs/myth.gph", col(3) iscale(.5) commonscheme ///
						title("", size(huge)) imargin(0 0 0 0) legend()	
						
	graph export 	"$output/myth.png", as(png) replace


* **********************************************************************
* 3 - income 
* **********************************************************************

* BAR OPTION
	graph bar			(mean) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn if country == 1 [pweight = hhw] , ///
							over(wave, lab(labs(large))) title("Ethiopia", size(large)) ///
							ytitle("Percent of households", size(vlarge) ) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) saving("$output/stata_graphs/income_eth_waves", replace)
	
	graph bar			(mean) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn if country == 2 [pweight = hhw], ///
							over(wave, lab(labs(large))) title("Malawi", size(large))  ///
							ytitle("Percent of households", size(vlarge) ) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) saving("$output/stata_graphs/income_mwi_waves", replace)
							
	graph bar			(mean) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn if country == 3  [pweight = hhw], ///
							over(wave, lab(labs(large))) title("Nigeria", size(large))  ///
							ytitle("Percent of households", size(vlarge) ) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) saving("$output/stata_graphs/income_nga_waves", replace)
							
	graph bar			(mean) farm_dwn bus_dwn wage_dwn remit_dwn other_dwn if country == 4 [pweight = hhw], ///
							over(wave, lab(labs(large))) title("Uganda", size(large))  ///
							ytitle("Percent of households", size(vlarge) ) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) saving("$output/stata_graphs/income_uga_waves", replace)
							
	grc1leg2 			"$output/stata_graphs/income_eth_waves" "$output/stata_graphs/income_mwi_waves" "$output/stata_graphs/income_nga_waves" ///
							"$output/stata_graphs/income_uga_waves.gph", col(2) iscale(.5) commonscheme title("Households reporting decrease in income", size(huge))
						
	graph export 		"$output/income_all_bar.png", as(png) replace

* LINE OPTION
	foreach var in  farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
	    egen `var'_mean = mean(`var'), by(country wave)
	}


	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 1, sort(wave) title("Ethiopia", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(1 "Wave 1" 2 "Wave 2" 3 "Wave 3" 4 "Wave 4" 5 "Wave 5", ///
							nogrid labs(large) ) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) ///
							saving("$output/stata_graphs/income_eth_waves", replace)
							
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 2, sort(wave) title("Malawi", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(1 "Wave 1" 2 "Wave 2" 3 "Wave 3" 4 "Wave 4", ///
							nogrid labs(large)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) ///
							saving("$output/stata_graphs/income_mwi_waves", replace)
	
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 3, sort(wave) title("Nigeria", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(1 "Wave 1" 4 "Wave 4", ///
							nogrid labs(large)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) ///
							saving("$output/stata_graphs/income_nga_waves", replace)
							
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							if country == 4, sort(wave) title("Uganda", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(1 "Wave 1" 2 "Wave 2" 3 "Wave 3", ///
							nogrid labs(large)) ///
							legend( label (1 "Farm income") label (2 "Business income") ///
							label (3 "Wage income") label (4 "Remittances") label (5 "All else") ///
							pos(6) col(3) size(medsmall)) ///
							saving("$output/stata_graphs/income_uga_waves", replace)

	grc1leg2 			"$output/stata_graphs/income_eth_waves.gph" "$output/stata_graphs/income_mwi_waves.gph" ///
							"$output/stata_graphs/income_nga_waves.gph" "$output/stata_graphs/income_uga_waves.gph" , col(2) iscale(.5) ///
							title("Households reporting decrease in income", span size(huge)) commonscheme 


	graph export 		"$output/income_all_line.png", as(png) replace


* **********************************************************************
* 4 - business revenue
* **********************************************************************

/* Suggest reversing order of bars to easier to see percent making less $ than before */

	preserve

	keep 				bus_emp_inc country wave hhw
	replace				bus_emp_inc = 3 if bus_emp_inc == 4
	gen 				id=_n
	ren 				(bus_emp_inc) (size=)
	reshape long 		size, i(id) j(bus_emp_inc) string
	drop if 			size == .

	colorpalette 		stone maroon, ipolate(15, power(1)) locals

	catplot 			size wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
							var1opts(label(labsize(large))) ///
							var3opts(label(labsize(large))) ///
							var2opts( relabel (1 "May" 2 "June" 3 "July" 4 "Aug" 5 "Sept") label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none))  ///
							bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend( ///
							label (1 "Higher than before") ///
							label (2 "Same as before") ///
							label (3 "Less than before") pos(6) col(3) ///
							size(medsmall)) saving("$output/stata_graphs/eth_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 2, percent(country wave) stack	 ///
							var1opts(label(labsize(large))) ///
							var3opts(label(labsize(large))) ///
							var2opts( relabel (1 "June" 2 "July" 3 "Aug" 4 "Sept") label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none))  ///
							bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
							saving("$output/stata_graphs/mwi_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 3, percent(country wave) stack	 ///
							var1opts(label(labsize(large))) ///
							var3opts(label(labsize(large))) ///
							var2opts( relabel (1 "May" 2 "June" 3 "July" 4 "Aug" 5 "Sept") label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(1, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none))  ///
							bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
							saving("$output/stata_graphs/nga_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 4, percent(country wave) stack	 ///
							var1opts(label(labsize(large))) ///
							var3opts(label(labsize(large))) ///
							var2opts( relabel (1 "June" 2 "July" 3 "Aug") label(labsize(large))) ///
							ytitle("", size(huge)) ///
							bar(1, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none))  ///
							bar(3, fcolor(`15') lcolor(none)) ylabel(, labs(large)) legend(off) ///
							saving("$output/stata_graphs/uga_bus_inc", replace)

	restore

	grc1leg2 			"$output/stata_graphs/eth_bus_inc.gph" "$output/stata_graphs/mwi_bus_inc.gph" ///
							"$output/stata_graphs/nga_bus_inc.gph" "$output/stata_graphs/uga_bus_inc.gph", ///
							col(1) iscale(.5) commonscheme imargin(0 0 0 0) ///
							title("Households reporting change in business revenue (%)", size(large)) 
						
	graph export 		"$output/bus_emp_inc.png", as(png) replace


* **********************************************************************
* 4 - food insecurity 
* **********************************************************************

	foreach 			p in mod sev {	
		forval 			w = 1/5{
		gen 			p_`p'_`w' = p_`p' if wave == `w'
		}
	}

	graph bar 		(mean) p_mod_1 p_mod_2 p_mod_3 p_mod_4 p_mod_5 [pweight = wt_18], ///
						over(country, lab(labs(vlarge)))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
						legend(label (1 "Wave 1")  label (2 "Wave 2") label (3 "Wave 3") label (4 "Wave 4") ///
						label (5 "Wave 5") col(5)) saving("$output/stata_graphs/fies_modsev", replace)
						
	graph bar 		(mean) p_sev_1 p_sev_2 p_sev_3 p_sev_4 p_sev_5 [pweight = wt_18], ///
						over(country, lab(labs(vlarge)))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(cranberry*1.5)) bar(5, color(purple*1.5)) ///
						legend(label (1 "Wave 1")  label (2 "Wave 2") label (3 "Wave 3") label (4 "Wave 4") ///
						label (5 "Wave 5") col(5)) saving("$output/stata_graphs/fies_sev", replace)


	grc1leg2 		"$output/stata_graphs/fies_modsev.gph" "$output/stata_graphs/fies_sev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme title("Prevelence of food insecurity", size(vlarge))
						
	graph export 	"$output/fies.png", as(png) replace


* **********************************************************************
* 5 - concerns 
* **********************************************************************

* (CHECK WEIGHTS!!)

	forval c = 1/2 {

		catplot 			concern_`c' wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts( relabel (1 "May" 2 "June" 3 "July" 4 "Aug" 5 "Sept") label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/eth_conc`c'", replace)
								
		catplot 			concern_`c' wave country [aweight = hhw] if country == 2, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts( relabel (1 "June" 2 "July" 3 "Aug" 4 "Sept") label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/mwi_conc`c'", replace)
								
		catplot 			concern_`c' wave country [aweight = hhw] if country == 3, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts( relabel (1 "May" 2 "June" 3 "July" 4 "Aug" 5 "Sept") label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/nga_conc`c'", replace)
								
		catplot 			concern_`c' wave country [aweight = hhw] if country == 4, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts( relabel (1 "June" 2 "July" 3 "Aug") label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/uga_conc`c'", replace)
		
		if `c' == 1 {
		grc1leg2 			"$output/stata_graphs/eth_conc`c'.gph" "$output/stata_graphs/mwi_conc`c'.gph" ///
								"$output/stata_graphs/nga_conc`c'.gph" "$output/stata_graphs/uga_conc`c'.gph", ///
								col(1) iscale(.5) commonscheme imargin(0 0 0 0)  ///
								title("Concerned that family or self will fall ill with COVID-19 (%)", size(large))		
		graph export 		"$output/concern_`c'.png", as(png) replace
		} 
		else {
		grc1leg2 			"$output/stata_graphs/eth_conc`c'.gph" "$output/stata_graphs/mwi_conc`c'.gph" ///
								"$output/stata_graphs/nga_conc`c'.gph" "$output/stata_graphs/uga_conc`c'.gph", ///
								col(1) iscale(.5) commonscheme imargin(0 0 0 0)  ///
								title("Concerned about the financial threat of COVID-19", size(large))	    
		graph export 		"$output/concern_`c'.png", as(png) replace
		}
	}					


* **********************************************************************
* 6 - coping
* **********************************************************************
	
	forval c = 1/4 {
	graph bar		(mean) cope_11 cope_9 cope_10 cope_3 asst_any cope_1 [pweight = hhw] ///
						if country == `c', over(wave, label(labsize(medlarge))) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(ebblue*1.5)) bar(7, color(purple*1.5)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80", labs(large)) ///
						ytitle("Percent of households", size(large)) ///
						legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
						label (3 "Reduced non-food cons.") label (4 "Help from family") ///
						label (5 "Recieved assistance") label (6 "Sale of asset") /// 
						size(medsmall) pos(6) col(3)) saving("$output/stata_graphs/cope_`c'.gph", replace)
	}
	grc1leg2 		"$output/stata_graphs/cope_1.gph" "$output/stata_graphs/cope_2.gph" ///
					"$output/stata_graphs/cope_3.gph" "$output/stata_graphs/cope_4.gph", ///
					col(2) iscale(.5) commonscheme title("Households reporting use of coping strategy", size(vlarge))
						
	graph export 	"$output/cope.png", as(png) replace

	
* **********************************************************************
* 7 - access
* **********************************************************************
	
	foreach v in med staple soap {
		forval w = 1/5 {
			gen				ac_`v'_`w' = 1 if wave == `w' & ac_`v' == 1
			replace			ac_`v'_`w' = 0 if wave == `w' & ac_`v' == 0
		}
	}

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) ac_med_1 ac_med_2 ac_med_3 ac_med_4 ac_med_5 ///
						[pweight = phw], over(country, label(labsize(medlarge))) ///
						title("Unable to purchase medicine", size(vlarge)) ///
						ytitle("Percent unable to purchase", size(vlarge)) ///
						ylabel(0 "0".2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "Wave 1")  ///
						label (2 "Wave 2") label (3 "Wave 3") label (4 "Wave 4") ///
						label (5 "Wave 5") order( 1 2 3 4 5) pos(6) col(5) size(medsmall)) 	///
						saving("$output/stata_graphs/ac_med", replace)

	graph bar 		(mean) ac_staple_1 ac_staple_2 ac_staple_3 ac_staple_4 ac_staple_5 ///
						[pweight = phw], over(country, label(labsize(medlarge))) ///
						title("Unable to purchase staple foods", size(vlarge))  ///
						ytitle("Percent unable to purchase", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/stata_graphs/ac_staple", replace)

	graph bar 		(mean) ac_soap_1 ac_soap_2 ac_soap_3 ac_soap_4 ac_soap_5 ///
						[pweight = phw], over(country, label(labsize(medlarge))) ///
						title("Unable to purchase soap", size(vlarge))  ///
						ytitle("Percent unable to purchase", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none)) legend(off) ///
						saving("$output/stata_graphs/ac_soap", replace)

	grc1leg2		"$output/stata_graphs/ac_med.gph" "$output/stata_graphs/ac_staple.gph" ///
					"$output/stata_graphs/ac_soap.gph", col(3) iscale(.5) pos(6) ///
					commonscheme title("", size(huge)) 
						
	graph export 	"$output/access.png", as(png) replace


* **********************************************************************
* educational engagement
* **********************************************************************

	gen				edu_act_01 = edu_act if quint == 1
	gen				edu_act_02 = edu_act if quint == 2
	gen				edu_act_03 = edu_act if quint == 3
	gen				edu_act_04 = edu_act if quint == 4
	gen				edu_act_05 = edu_act if quint == 5

	mean			sch_child [pweight = shw] if wave == 1
	mean			edu_none [pweight = shw] if wave == 1
	mean			edu_cont [pweight = shw] if wave == 1
	
	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) edu_act_01 edu_act_02 edu_act_03 edu_act_04 edu_act_05 ///
						[pweight = hhw] if wave == 1, over(country, label(labsize(vlarge)))  ///
						ytitle("Households with children engaged in learning activities (%)", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						saving("$output/edu_quinta", replace)

	grc1leg2  		 "$output/edu_quinta.gph", col(3) iscale(.5) commonscheme ///
						imargin(0 0 0 0) legend() title("C", size(huge))
						
	graph export "$output/edu_quint.eps", as(eps) replace
						

* graph B - education activities
	graph bar		edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 1 ///
						, over(wave, relabel (1 "May" 2 "June" 3 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend( size(medsmall) ///
						label (1 "Listened to educational radio programs") ///
						label (2 "Using mobile learning apps") ///
						label (3 "Watched education television") ///
						label (4 "Session with teacher") pos(6) col(2)) ///
						ytitle("Households with children experiencing educational contact (%)", size(vlarge))  ///
						saving("$output/educont_eth", replace)

	graph bar		 edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 2 ///
						, over(wave, relabel (1 "June" 2 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_mwi", replace)

	graph bar		 edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 3 ///
						, over(wave, relabel (1 "May" 2 "June" 3 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_nga", replace)

	graph bar		edu_04 edu_02 edu_03 edu_05 [pweight = hhw] if country == 4 & wave == 1 ///
						, over(wave, relabel (1 "June" 2 "July") label(labsize(vlarge))) over(country, label(labsize(vlarge))) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(khaki*1.5)) bar(2, color(cranberry*1.5)) ///
						bar(3, color(teal*1.5)) bar(4, color(lavender*1.5)) ///
						bar(5, color(brown*1.5)) legend(off) saving("$output/educont_uga", replace)

	grc1leg2  		 "$output/educont_eth.gph" "$output/educont_mwi.gph" ///
						"$output/educont_nga.gph" "$output/educont_uga.gph", ///
						col(4) iscale(.5) commonscheme imargin(0 0 0 0) legend() title("D", size(huge)) 
						
	graph export 	"$output/educont.eps", as(eps) replace


* **********************************************************************
* 4 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */