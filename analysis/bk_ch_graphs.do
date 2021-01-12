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
	* check waves/months


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
* 1 - behavior
* **********************************************************************

* wave 1 all countries 
	graph bar 			(mean) bh_3 bh_1 bh_2 if wave_orig == 1 [pweight = phw], ///
							over(country, lab(labs(vlarge))) title("", size(large)) ///
							bar(1, color(maroon*1.5)) bar(2, color(navy*1.5)) bar(3, color(stone*1.5)) ///
							bar(4, color(cranberry*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") pos(6) col(3) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_w1", replace)	
		
	grc1leg2   			"$output/stata_graphs/behavior_w1.gph", iscale(.5) commonscheme ///
							 imargin(0 0 0 0) legend()
					
	graph export 		"$output/behavior_w1.png", as(png) replace
	
	* sig tests
		reg 			bh_3 i.country [pweight = phw] if wave_orig == 1 
			test 			2.country = 1.country
			test 			2.country = 3.country
			test 			2.country = 4.country
		reg 			bh_1 i.country [pweight = phw] if wave_orig == 1 
			test 			2.country = 1.country
			test 			2.country = 3.country
			test 			2.country = 4.country
		reg 			bh_2 i.country [pweight = phw] if wave_orig == 1 
			test 			2.country = 1.country
			test 			2.country = 3.country
			test 			2.country = 4.country
			
* over waves in mwi and uga 	
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 2 [pweight = phw], ///
							over(wave, lab(labs(vlarge)))  title("Malawi", size(large)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) ///
							ytitle("Percent of individuals", margin(0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_mwi", replace)
	
		
	graph bar 			(mean) bh_3 bh_1 bh_2 bh_8 if country == 4 [pweight = phw], ///
							over(wave, lab(labs(vlarge))) title("Uganda", size(large)) ///
							bar(1, color(maroon*2)) bar(2, color(navy*1.5)) bar(3, color(stone*1.3)) ///
							bar(4, color(eltgreen*1.5)) ///
							ytitle("Percent of individuals", margin( 0 -1 -1 10) size(large)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(med)) ///
							legend(	label (1 "Avoided crowds") label (2 "Increased hand washing") ///
							label (3 "Avoided physical contact") label (4 "Wore mask in public") pos(6) col(2) ///
							size(medsmall) margin(-2 0 0 0)) saving("$output/stata_graphs/behavior_uga", replace)

	grc1leg2   			"$output/stata_graphs/behavior_mwi.gph" "$output/stata_graphs/behavior_uga.gph", ///
							col(2) iscale(.5) commonscheme imargin(0 0 0 0) legend()
					
	graph export 		"$output/behavior_waves.png", as(png) replace
	
	* sig tests 
		reg 			bh_3 i.wave [pweight = phw] if country == 2
			test 			6.wave = 7.wave
		reg 			bh_3 i.wave [pweight = phw] if country == 4
			test 			6.wave = 9.wave
		reg 			bh_1 i.wave [pweight = phw] if country == 2
			test 			6.wave = 9.wave
		reg 			bh_1 i.wave [pweight = phw] if country == 4
			test 			6.wave = 9.wave
		reg 			bh_2 i.wave [pweight = phw] if country == 4
			test 			6.wave = 9.wave
		reg 			bh_8 i.wave [pweight = phw] if country == 2
			test 			7.wave = 9.wave
		reg 			bh_8 i.wave [pweight = phw] if country == 4
			test 			8.wave = 9.wave
		
		
* **********************************************************************
* 2 - myths (wave 1 only)
* **********************************************************************

	preserve

	drop if				country == 1 | country == 3
	keep 				myth_2 myth_3 myth_4 myth_5 country phw
	gen 				id=_n
	ren 				(myth_2 myth_3 myth_4 myth_5) (size=)
	reshape long 		size, i(id) j(myth) string
	drop if 			size == .
	drop if				size == 3

	catplot 			size country myth [aweight = phw], percent(country myth) ///
							ytitle("Percent", size(vlarge)) var1opts(label(labsize(vlarge))) ///
							var2opts(label(labsize(vlarge))) var3opts(label(labsize(large)) ///
							relabel (1 `""Africans are immune" "to coronavirus"""' ///
							2 `""Coronavirus does not" "affect children"""' ///
							3 `""Coronavirus cannot survive" "warm weather""' ///
							4 `""Coronavirus is just" "common flu""'))  ///
							ylabel(, labs(vlarge)) bar(1, color(khaki*1.5) ) ///
							bar(2, color(emerald*1.5) ) legend( label (2 "True") ///
							label (1 "False") pos(6) col(2) ///
							size(medsmall)) saving("$output/stata_graphs/myth", replace)

	restore
	
	grc1leg2  		 	"$output/stata_graphs/myth.gph", col(3) iscale(.5) commonscheme ///
							imargin(0 0 0 0) legend()	
						
	graph export 		"$output/myth.png", as(png) replace

	
* **********************************************************************
* 3 - income 
* **********************************************************************

	foreach 			var in  farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
	    egen 				`var'_mean = mean(`var'), by(country wave)
	}

	preserve
	keep if country == 1
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 1, sort(wave) title("Ethiopia", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("")  legend( label (1 "Farm income") ///
							label (2 "Business income") label (3 "Wage income") label (4 "Remittances") ///
							label (5 "All else") pos(6) col(3) size(medsmall)) ///
							xlabel(4 "Apr" 5 "May" 6 "June" 7 "July" 8 "Aug" 9 "Sept", ///
							nogrid labs(large)) ///
							saving("$output/stata_graphs/income_eth_waves", replace)
	restore			
	
	preserve
	keep if country == 2
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 2, sort(wave) title("Malawi", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(6 "June" 7 "July" 8 "Aug" 9 "Sept", ///
							nogrid labs(large)) saving("$output/stata_graphs/income_mwi_waves", replace)
	restore			
	
	preserve
	keep if country == 3
	drop if wave == 9
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 3, sort(wave) title("Nigeria", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(5 "May" 6 "June" 7 "July" 8 "Aug", ///
							nogrid labs(large)) saving("$output/stata_graphs/income_nga_waves", replace)
	restore			
	
	preserve
	keep if country == 4						
	line 				farm_dwn_mean bus_dwn_mean wage_dwn_mean remit_dwn_mean other_dwn_mean wave ///
							[pweight = hhw] if country == 4, sort(wave) title("Uganda", size(vlarge)) ///
							lp(solid solid solid solid solid) ///
							lcolor(navy*.6 teal*.6 khaki*.6 cranberry*.6 purple*.6) ///
							lwidth(vthick vthick vthick vthick vthick) ///
							ytitle("Percent of households", size(vlarge)) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
							xtitle("") xlabel(6 "June" 7 "July" 8 "Aug" 9 "Sept", ///
							nogrid labs(large)) saving("$output/stata_graphs/income_uga_waves", replace)
	restore 
	
	grc1leg2 			"$output/stata_graphs/income_eth_waves.gph" "$output/stata_graphs/income_mwi_waves.gph" ///
							"$output/stata_graphs/income_nga_waves.gph" "$output/stata_graphs/income_uga_waves.gph", ///
							col(2) iscale(.5) commonscheme 

	graph export 		"$output/income_all_line.png", as(png) replace
	
	* means and sig tests
		mean farm_dwn [pweight = hhw] if country == 1 & wave == 4
		mean farm_dwn [pweight = hhw] if country == 1 & wave == 9
		reg farm_dwn i.wave [pweight = hhw] if country == 1
		test 4.wave = 9.wave
	
		mean farm_dwn [pweight = hhw] if country == 4 & wave == 6
		mean farm_dwn [pweight = hhw] if country == 4 & wave == 9
		reg farm_dwn i.wave [pweight = hhw] if country == 4
		test 6.wave = 9.wave
		
		mean bus_dwn [pweight = hhw] if country == 1 & wave == 4
		mean bus_dwn [pweight = hhw] if country == 1 & wave == 9
		reg bus_dwn i.wave [pweight = hhw] if country == 1
		test 4.wave = 9.wave
		
		mean bus_dwn [pweight = hhw] if country == 4 & wave == 6
		mean bus_dwn [pweight = hhw] if country == 4 & wave == 9
		reg bus_dwn i.wave [pweight = hhw] if country == 4
		test 6.wave = 9.wave
		
		mean remit_dwn [pweight = hhw] if country == 1 & wave == 4
		mean remit_dwn [pweight = hhw] if country == 1 & wave == 9
		reg remit_dwn i.wave [pweight = hhw] if country == 1
		test 4.wave = 9.wave

	
* **********************************************************************
* 4 - business revenue
* **********************************************************************

	preserve

	keep 				bus_emp_inc country wave hhw
	replace				bus_emp_inc = 3 if bus_emp_inc == 4
	gen 				id=_n
	ren 				(bus_emp_inc) (size=)
	reshape long 		size, i(id) j(bus_emp_inc) string
	drop if 			size == .

	* reverse order of vars
	replace 			size = 4 if size == 1
	replace 			size = 1 if size == 3
	replace 			size = 3 if size == 4
	
	colorpalette 		stone maroon, ipolate(15, power(1)) locals

	catplot 			size wave country [aweight = hhw] if country == 1, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large)))  ///
							ytitle("", size(vlarge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none)) bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(label (3 "Higher than before") label (2 "Same as before") ///
							label (1 "Less than before") pos(6) col(3) ///
							size(medsmall)) saving("$output/stata_graphs/eth_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 2, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none)) bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(off) saving("$output/stata_graphs/mwi_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 3, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large))) ///
							ytitle("", size(vlarge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none)) bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(off) saving("$output/stata_graphs/nga_bus_inc", replace)

	catplot 			size wave country [aweight = hhw] if country == 4, percent(country wave) stack ///
							var1opts(label(labsize(large))) var3opts(label(labsize(large))) ///
							var2opts(label(labsize(large))) ///
							ytitle("", size(huge)) bar(3, fcolor(`1') lcolor(none)) ///
							bar(2, fcolor(`7') lcolor(none))  bar(1, fcolor(`15') lcolor(none)) ///
							ylabel(, labs(large)) legend(off) saving("$output/stata_graphs/uga_bus_inc", replace)

	restore

	grc1leg2 			"$output/stata_graphs/eth_bus_inc.gph" "$output/stata_graphs/mwi_bus_inc.gph" ///
							"$output/stata_graphs/nga_bus_inc.gph" "$output/stata_graphs/uga_bus_inc.gph", ///
							col(1) iscale(.5) commonscheme imargin(0 0 0 0) 
						
	graph export 		"$output/bus_emp_inc.png", as(png) replace


* **********************************************************************
* 4 - food insecurity 
* **********************************************************************
		
	forval 				w = 5/9 {
		gen 			p_mod_`w' = p_mod if wave == `w'
	}

	
	graph bar 			(mean) p_mod_5 p_mod_6 p_mod_7 p_mod_8 p_mod_9 [pweight = wt_18], ///
							over(country, lab(labs(vlarge))) ///
							ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
							ytitle("Prevalence", size(vlarge))  ///
							bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
							bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ///
							legend(label (1 "May") label (2 "June") label (3 "July") label (4 "Aug") ///
							label (5 "Sept") col(5)) saving("$output/stata_graphs/fies_modsev", replace)

	grc1leg2 			"$output/stata_graphs/fies_modsev.gph", iscale(.5) pos(6) commonscheme 
	
	graph export 		"$output/fies.png", as(png) replace
	
	
* **********************************************************************
* 5 - concerns 
* **********************************************************************

* first wave with data available
	preserve 
	keep 					if (country == 1 & wave == 6) | (country == 2 & wave == 6) | ///
								(country == 3 & wave == 5) | (country == 4 & wave == 6)
	
	replace 				wave = 1
								
	catplot 				concern_1 wave [aweight = hhw], over(country) percent(country wave) stack ///
								title("Concerned that family or self will fall ill with COVID-19 (%)", size(large)) ///
								var1opts(label(labsize(large))) legend(col(2)) ///
								var2opts(label(nolab)) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/conc1_w1", replace)
							
	catplot 				concern_2 wave [aweight = hhw], over(country) percent(country wave) stack ///
								title("Concerned about the financial threat of COVID-19 (%)", size(large)) ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts(label(nolab)) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/conc2_w1", replace)						

	restore 
	
	grc1leg2 				"$output/stata_graphs/conc1_w1.gph" "$output/stata_graphs/conc2_w1.gph", ///
								col(1) iscale(.5) commonscheme imargin(0 0 0 0)
														
	graph export 			"$output/concerns_w1.png", as(png) replace

* over waves in mwi and uga 
	forval c = 1/2 {
								
		catplot 			concern_`c' wave country [aweight = hhw] if country == 2, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts(label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/mwi_conc`c'", replace)
								
		catplot 			concern_`c' wave country [aweight = hhw] if country == 4, percent(country wave) stack ///
								var1opts(label(labsize(large))) var3opts(label(labsize(large))) legend(col(2)) ///
								var2opts(label(labsize(large))) ///
								ytitle("", size(vlarge)) bar(1, color(maroon*1.5)) bar(2, color(stone*1.3)) ///
								ylabel(, labs(large)) saving("$output/stata_graphs/uga_conc`c'", replace)
		

		grc1leg2 			"$output/stata_graphs/mwi_conc`c'.gph" "$output/stata_graphs/uga_conc`c'.gph", ///
								col(1) iscale(.5) commonscheme imargin(0 0 0 0)
								
		graph export 		"$output/concern_`c'.png", as(png) replace
	
	}					


* **********************************************************************
* 6 - coping
* **********************************************************************
	
	forval 					c = 1/4 {
	    preserve 
		* excluding months with no data 
		egen 				temp = total(cope_none), by (country wave)
		keep if 			temp != 0 & country == `c'
		if 					`c' == 1 {
			local 			country = "Ethiopia"
		} 
		else if 			`c' == 2 {
			local 			country = "Malawi"
		}
		else if 			`c' == 3 {
			local 			country = "Nigeria"
		} 
		else 				if `c' == 4 {
			local 			country = "Uganda"
		}
	
	graph bar		(mean) cope_11 cope_9 cope_10 cope_3 cope_1 cope_none [pweight = hhw] ///
						if country == `c', over(wave, label(labsize(medlarge))) ///
						title("`country'", size(vlarge)) ///
						bar(1, color(maroon*1.5)) bar(2, color(emidblue*1.5)) ///
						bar(3, color(emerald*1.5)) bar(4, color(brown*1.5)) ///
						bar(5, color(erose*1.5)) bar(6, color(eltgreen*5))  ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Percent of households", size(large)) ///
						legend( label (1 "Relied on savings") label (2 "Reduced food cons.") ///
						label (3 "Reduced non-food cons.") label (4 "Help from family") ///
						 label (5 "Sale of asset") label (6 "Did nothing") /// 
						size(medsmall) pos(6) col(3)) saving("$output/stata_graphs/cope_`c'.gph", replace)
		restore
	}
	grc1leg2 		"$output/stata_graphs/cope_1.gph" "$output/stata_graphs/cope_2.gph" ///
						"$output/stata_graphs/cope_3.gph" "$output/stata_graphs/cope_4.gph", ///
						col(2) iscale(.5) commonscheme 
						
	graph export 	"$output/cope.png", as(png) replace

					
* **********************************************************************
* 7 - assistance
* **********************************************************************
		
	forval 					c = 1/4 {
	    preserve 
		* excluding months with no data 
		egen 				temp = total(asst_any), by (country wave)
		keep if 			temp != 0 & country == `c'
		if 					`c' == 1 {
			local 			country = "Ethiopia"
		} 
		else if 			`c' == 2 {
			local 			country = "Malawi"
		}
		else if 			`c' == 3 {
			local 			country = "Nigeria"
		} 
		else 				if `c' == 4 {
			local 			country = "Uganda"
		}
	
	graph bar				(mean) asst_cash asst_food asst_kind asst_any [pweight = hhw] ///
								if country == `c', over(wave, label(labsize(medlarge))) ///
								title("`country'", size(vlarge)) ///
								bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
								bar(4, color(brown*2.3)) ///
								ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
								ytitle("Percent of households", size(large)) ///
								legend(label (1 "Cash") label (2 "Food") label (3 "In-kind") ///
								label (4 "Any assistance") size(medsmall) pos(6) col(4) ///
								margin(-2 0 0 0)) saving("$output/stata_graphs/asst_`c'.gph", replace)
		restore 
	}
	grc1leg2 				"$output/stata_graphs/asst_1.gph" "$output/stata_graphs/asst_2.gph" ///
								"$output/stata_graphs/asst_3.gph" "$output/stata_graphs/asst_4.gph", ///
								col(2) iscale(.5) commonscheme
						
	graph export 			"$output/asst.png", as(png) replace
	
	
* **********************************************************************
* 8 - access to staple foods and medical services
* **********************************************************************
	
	foreach 				v in ac_medserv ac_staple {
		forval 					c = 1/4 {
			preserve 
			* excluding months with no data 
			egen 				temp = total(`v'), by (country wave)
			keep if 			temp != 0 & country == `c'
			if 					`c' == 1 {
				local 			country = "Ethiopia"
			} 
			else if 			`c' == 2 {
				local 			country = "Malawi"
			}
			else if 			`c' == 3 {
				local 			country = "Nigeria"
			} 
			else 				if `c' == 4 {
				local 			country = "Uganda"
			}
		
			graph bar 			(mean) `v' [pweight = phw], ///
									over(wave, label(labsize(medlarge))) title("`country'", size(vlarge)) ///
									ytitle("Percent unable to purchase", size(med)) ///
									ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
									bar(1, color(navy*1.5)) legend(off) ///
									saving("$output/stata_graphs/`v'`c'", replace)
			restore
		}
			
	
	graph combine			"$output/stata_graphs/`v'1" "$output/stata_graphs/`v'2" ///
								"$output/stata_graphs/`v'3" "$output/stata_graphs/`v'4", ///
								col(2) commonscheme 							
					
	graph export 			"$output/`v'.png", as(png) replace				
	}					
					

* nigeria staple foods
	preserve
	
	keep if wave == 5 | wave == 7
	
	
	graph bar 		(mean) ac_yam ac_rice ac_beans ac_cass  ac_sorg [pweight = phw]  if country == 3, ///
						over(wave, label(labsize(large))) ///
						ytitle("Percent unable to purchase", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) legend( label(1 "Yams") label(2 "Rice") ///
						label(3 "Beans") label(4 "Cassava") label(5 "Sorghum") col(5)) ///
						saving("$output/stata_graphs/ac_staple_nga", replace)

	grc1leg2		"$output/stata_graphs/ac_staple_nga.gph", col(2) iscale(.5) pos(6) commonscheme 
	
	graph export 	"$output/ac_staple_nga.png", as(png) replace
	
	restore 

* Ethipia staple foods 
	graph bar 		(mean) ac_teff ac_oil  ac_wheat ac_maize [pweight = phw]  if country == 1, ///
						over(wave, label(labsize(large))) ///
						ytitle("Percent unable to purchase", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ///
						legend( label(1 "Teff") label(2 "Oil") ///
						label(3 "Wheat") label(4 "Maize") col(4)) ///
						saving("$output/stata_graphs/ac_staple_eth", replace)

	grc1leg2		"$output/stata_graphs/ac_staple_eth.gph", col(2) iscale(.5) pos(6) commonscheme 
	
	graph export 	"$output/ac_staple_eth.png", as(png) replace
	
	
* **********************************************************************
* 9 - educational engagement
* **********************************************************************

	replace 		edu_act = 1 if sch_child_prim == 1 & edu_act_prim == 1 
	replace 		edu_act = 1 if sch_child_sec == 1 & edu_act_sec == 1 
	replace 		edu_act = 0 if (sch_child_sec == 1 & edu_act_sec == 0) & (sch_child_prim == 1 & edu_act_prim == 0)
	
	preserve 
	keep if country == 1
	graph bar 		(mean) edu_act [pweight = hhw], over(wave, label(labsize(large))) ///
						ytitle("Percent of households", size(vlarge)) ///
						title("Ethiopia", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) legend(off) ///
						saving("$output/stata_graphs/edu_eng1", replace)
	restore 
	
	preserve 
	keep if country == 2
	keep if wave == 6 | wave == 7
	graph bar 		(mean) edu_act [pweight = hhw], over(wave, label(labsize(large))) ///
						ytitle("Percent of households", size(vlarge)) ///
						title("Malawi", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) legend(off) ///
						saving("$output/stata_graphs/edu_eng2", replace)
	restore 
	
	preserve 
	keep if country == 3
	graph bar 		(mean) edu_act [pweight = hhw], over(wave, label(labsize(large))) ///
						ytitle("Percent of households", size(vlarge)) ///
						title("Nigeria", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) legend(off) ///
						saving("$output/stata_graphs/edu_eng3", replace)
	restore 
	
	preserve 
	keep if country == 4
	graph bar 		(mean) edu_act [pweight = hhw], over(wave, label(labsize(large))) ///
						ytitle("Percent of households", size(vlarge)) ///
						title("Uganda", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) legend(off) ///
						saving("$output/stata_graphs/edu_eng4", replace)
	restore 
	
	graph combine  	"$output/stata_graphs/edu_eng1.gph" "$output/stata_graphs/edu_eng2.gph" ///
						"$output/stata_graphs/edu_eng3.gph" "$output/stata_graphs/edu_eng4.gph", ///
						iscale(.5) commonscheme imargin(0 0 0 0)
						
	graph export 	"$output/edu_eng.png", as(png) replace
				

* **********************************************************************
* 10 - educational contact 
* **********************************************************************

	forval x = 1/5 {
		replace 		edu_`x' = 1 if edu_`x'_prim == 1 | edu_`x'_sec == 1
		replace 		edu_`x' = 0 if (edu_`x'_prim == 0 & edu_`x'_sec == 0) |  ///
						(edu_`x'_prim == . & edu_`x'_sec == 0) |  (edu_`x'_prim == 0 & edu_`x'_sec == .) 
	} 

	graph bar		edu_4 edu_2 edu_3 edu_5 edu_8 edu_11 [pweight = hhw] if country == 1 ///
						, over(wave, label(labsize(vlarge))) title("Ethiopia", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) bar(6, color(maroon*2.3)) ///
						legend( size(medsmall) ///
						label (1 "Educational radio programs") ///
						label (2 "Using mobile learning apps") ///
						label (3 "Watched education television") ///
						label (4 "Session with teacher") ///
						label (5 "Reading material from government") ///
						label (6 "Revised textbooks and notes") pos(6) col(2)) ///
						ytitle("Percent of households", size(vlarge))  ///
						saving("$output/stata_graphs/educont_eth", replace)
	
	preserve 
	keep if wave == 6 | wave == 7
	graph bar		 edu_4 edu_2 edu_3 edu_5  edu_8 edu_11 [pweight = hhw] if country == 2 ///
						, over(wave, label(labsize(vlarge))) title("Malawi", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ///
						legend(off) saving("$output/stata_graphs/educont_mwi", replace)
	restore 
	
	graph bar		 edu_4 edu_2 edu_3 edu_5  edu_8 edu_11  [pweight = hhw] if country == 3 ///
						, over(wave, label(labsize(vlarge))) title("Nigeria", size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) ///
						legend(off) saving("$output/stata_graphs/educont_nga", replace)

	graph bar		edu_4 edu_2 edu_3 edu_5  edu_8 edu_11  [pweight = hhw] if country == 4 ///
						, over(wave, label(labsize(vlarge))) title("Uganda",size(vlarge)) ///
						ylabel(0 "0" .2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(vlarge)) ///
						bar(1, color(navy*1.5)) bar(2, color(teal*1.5)) bar(3, color(khaki*1.5)) ///
						bar(4, color(brown*2.3)) bar(5, color(eltgreen*5)) bar(6, color(maroon*2.3)) ///
						legend(off) saving("$output/stata_graphs/educont_uga", replace)

	grc1leg2  		 "$output/stata_graphs/educont_eth.gph" "$output/stata_graphs/educont_mwi.gph" ///
						"$output/stata_graphs/educont_nga.gph" "$output/stata_graphs/educont_uga.gph", ///
						col(2) iscale(.5) commonscheme imargin(0 0 0 0) legend() 
						
	graph export 	"$output/edu_how.png", as(png) replace


* **********************************************************************
* 11 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */