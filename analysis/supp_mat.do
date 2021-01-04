* Project: WB COVID
* Created on: September 2020 
* Created by: amf
* Edited by: jdm, alj 
* Last edit: 29 September 2020 
* Stata v.16.1

* does
	* runs regressions and produces tables for supplemental material

* assumes
	* cleaned country data
	* palettes and colrspace installed	

* TO DO:
	* add in new waves and update with any revisions
	* QC based on old version


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global					ans		=	"$data/analysis"
	global					output	=	"$data/analysis/tables"
	global					logout	=	"$data/analysis/logs"
	local 					tabnum  =   1
	
* open log
	cap 					log close
	log 					using "$logout/supp_mat", append

* read in data
	use						"$ans/lsms_panel", clear
	

* **********************************************************************
* 1 - create tables for Fig. 1
* **********************************************************************


* **********************************************************************
* 1a - create Table S1 for Fig. 1A
* **********************************************************************

* regressions for advised citizens to stay at home
	local 					counter = 1
		reg 				gov_1 ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							replace excel dec(3) ctitle(S`tabnum' gov_1) label alpha(0.001, 0.01, 0.05)
						
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)
		
	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = .
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore
	
* regressions for restricted travel within country/area, closure of schools,
	* curfew/lockdown, closure of non-essential businesses, stopping or limiting social gatherings

	foreach 				var in gov_2 gov_4 gov_5 gov_6 gov_10 {
		reg 				`var' ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' `var') label
						
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)
		
	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = .
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore
	}

* merge	all test tables into one and export
	preserve
		clear
		use 				`temp1'
		forval 				x = 2/6 {
			merge 			1:1 merger using `temp`x'', assert(3) nogen
		}
		format				testgrp* %10.3f
		drop 				merger 
		gen 				testcountries = ""
		replace 			testcountries = "Ethiopia-Nigeria" in 1
		replace 			testcountries = "Ethiopia-Uganda" in 2
		replace 			testcountries = "Nigeria-Uganda" in 3
		order 				testc *
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							replace sheet(testresultsS`tabnum') first(var)
	restore


* **********************************************************************
* 1b - create table S2 for Fig. 1B
* **********************************************************************

local tabnum = `tabnum' + 1

* regressions for handwashing with Soap Reduces Risk of Coronavirus Contraction, 
	* avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract, 
	* using Masks or Gloves Reduces Risk of Coronavirus Contraction, 
	* staying at Home Reduces Risk of Coronavirus Contraction, 
	* avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction, 
	* mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Common
	local 					counter = 1
	foreach 				var in know_1 know_2 know_3 know_5 know_6 know_7 {
		reg 				`var' ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' `var') label
								
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore

	}
		
* merge	all test tables into one and export
	preserve
		clear
		use 				`temp1'
		forval 				x = 2/6 {
			merge 			1:1 merger using `temp`x'', assert(3) nogen
		}
		format				testgrp* %10.3f
		drop 				merger 
		gen 				testcountries = ""
		replace 			testcountries = "Ethiopia-Nigeria" in 1
		replace 			testcountries = "Ethiopia-Uganda" in 2
		replace 			testcountries = "Nigeria-Uganda" in 3
		order 				testc *
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore
	

* **********************************************************************
* 2 - create tables for Fig. 2
* **********************************************************************	
	
* **********************************************************************
* 2a - create tables S3-S5 for Fig. 2A
* **********************************************************************

*** table S3 ***

local tabnum = `tabnum' + 1

* handwashed with Soap More Often Since Outbreak
	reg 					bh_1 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Handwashed with soap more often) label
	
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		local 				counter = 1
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore
		
* avoided Handshakes/Physical Greetings Since Outbreak
	reg 					bh_2 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Avoided physical greetings) label
	
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore	

* avoided Crowds and Gatherings Since Outbreak
	reg 					bh_3 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Avoided crowds) label
	
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				test1 = r(p)
		test				1.country = 4.country
		local 				test2 = r(p)
		test				3.country = 4.country
		local 				test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile 		temp`counter'
			save 			`temp`counter''
			local 			counter = `counter' +1
		restore
		
* make table of test values 
	preserve
	clear
	use 					`temp1'
	forval 					x = 2/3 {
		merge 				1:1 merger using `temp`x'', assert(3) nogen
	}
	format					testgrp* %10.3f
	drop 					merger 
	
	gen 					testcountries = ""
	replace 				testcountries = "Ethiopia-Nigeria" in 1
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	order 					testc *
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore

*** table S4 ***

local tabnum = `tabnum' + 1
		
* percentage over time for Malawi and Uganda

	* calculate statistics and store results
		foreach				c in 2 4 {
			forval 			b = 1/3 {
				forval 		w = 1/2 {
					mean			bh_`b' [pweight = phw] if country == `c', over(wave)	
						local		n_c`c'b`b' = e(N)
						local 		mean_c`c'b`b'w`w' = el(e(b),1,`w')
						local		sd_c`c'b`b'w`w' = sqrt(el(e(V),`w',`w'))
				}
			}
		}
			
	* create table S4 with stored locals
		preserve
			clear
			set 			obs 5
			gen 			wave = cond(_n<3,"w1",cond(_n<5,"w2",""))
			gen 			stat = cond(_n == 1 | _n == 3, "mean",cond(_n == 5, "Observations","sd"))
			foreach 		country in c2 c4 {
				foreach 	behavior in 1 2 3 {
					gen 	`country'_b`behavior' = .
				}
			}
			foreach 		c in 2 4 {
				forval 		b = 1/3 {
					forval	w = 1/2 {
						foreach stat in mean sd {
						  replace c`c'_b`b' = ``stat'_c`c'b`b'w`w'' if wave == "w`w'" & stat == "`stat'"  
						}
					}
				}
			}
			foreach 		c in 2 4 {
				forval 		b = 1/3 {
					replace c`c'_b`b' = `n_c`c'b`b'' if stat == "Observations"
				}
			}
			export 			excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
		restore	
		
*** table S5 ***

local tabnum = `tabnum' + 1

* regressions of behavior on waves in Malawi
	reg						bh_1 i.wave [pweight = phw] if country == 2, vce(robust) 
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Malawi Behavior 1) label
	
	reg						bh_2 i.wave [pweight = phw] if country == 2, vce(robust) 
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Malawi Behavior 2) label
	
	reg						bh_3 i.wave [pweight = phw] if country == 2, vce(robust) 
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Malawi Behavior 3) label
	
* regressions of behavior on waves in Uganda
	reg						bh_1 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Uganda Behavior 1) label
	
	reg						bh_2 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Uganda Behavior 2) label
	
	reg						bh_3 i.wave [pweight = phw] if country == 4, vce(robust)		
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Uganda Behavior 3) label	
		
		
* **********************************************************************
* 2b - create tables S6-S7 for Fig. 2B
* **********************************************************************

preserve
		
	local 					myth myth_2 myth_3 myth_4 myth_5
	foreach 				v in `myth' {
	    replace 			`v' = . if `v' == 3
	}	

*** table S6 ***

local tabnum = `tabnum' + 1
	
* africans are immune to corona virus
	reg 					myth_2 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Africans immune) label
							
* corona virus does not affect children
	reg 					myth_3 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Not affect children) label
	
* corona virus cannot survive in warm weather
	reg 					myth_4 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Survive warm weather) label
	
* corona virus is just common flu
	reg 					myth_5 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S`tabnum' Common flu) label
restore

*** table S7 ***

local tabnum = `tabnum' + 1

* totals by myths
	forval 					x = 2/5 {
	    gen 				myth_`x'y = cond(myth_`x' == 1,1,cond(myth_1 == 0 | myth_1 == 3, 0,.))
	    gen 				myth_`x'n = cond(myth_`x' == 0,1,cond(myth_1 == 1 | myth_1 == 3, 0,.))
	    gen 				myth_`x'k = cond(myth_`x' == 3,1,cond(myth_1 == 0 | myth_1 == 1, 0,.))
	}

	forval 					m = 2/5 {
		total 				myth_`m'y myth_`m'n myth_`m'k [pweight = phw], over(country)
			local 			ytot_c2m`m' = el(e(b),1,1)
			local 			ytot_c4m`m' = el(e(b),1,2)
			local 			ntot_c2m`m' = el(e(b),1,3)
			local 			ntot_c4m`m' = el(e(b),1,4)
			local 			ktot_c2m`m' = el(e(b),1,5)
			local 			ktot_c4m`m' = el(e(b),1,6)
			local			yse_c2m`m' = sqrt(el(e(V),1,1))
			local			yse_c4m`m' = sqrt(el(e(V),2,2))
			local			nse_c2m`m' = sqrt(el(e(V),3,3))
			local			nse_c4m`m' = sqrt(el(e(V),4,4))	
			local			kse_c2m`m' = sqrt(el(e(V),5,5))
			local			kse_c4m`m' = sqrt(el(e(V),6,6))			
	}	
		
	forval 					m = 2/5 {
		total 				myth_`m'y myth_`m'n myth_`m'k [pweight = phw] if country == 2
		local				c2_n_m`m' = e(N)
		total 				myth_`m'y myth_`m'n myth_`m'k [pweight = phw] if country == 4
		local				c4_n_m`m' = e(N)
	}
		
	* format table
		preserve
			clear
			set 			obs 7
			gen 			response = cond(_n<3,"y",cond(_n>2 & _n<5,"n",cond(_n>4 & _n<7,"k","")))
			gen 			stat = cond(mod(_n,2)==0,"se","tot")
			replace 		stat = "Observations" in 7
			expand 			2
			gen 			country = cond(_n<8,2,4)
			forval 			x = 2/5 {
							gen myth_`x' = .
			}
			
		* replace values with stored locals
			foreach 		c in 2 4 {
				forval 		m = 2/5 {
					foreach s in tot se {
						foreach r in y n k {
							replace myth_`m' = ``r'`s'_c`c'm`m'' if response == "`r'" & stat == "`s'" & country == `c' 
						}
					}
				}
			}
			foreach c in 2 4 {
				forval 			x = 2/5 {
					replace 	myth_`x' = `c`c'_n_m`x'' if stat == "Observations" & country == `c'
				} 
			}
			export 			excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
		restore

		
* **********************************************************************
* 3 - create tables for Fig. 3
* **********************************************************************

* **********************************************************************
* 3a - create Table S8-S10 for Fig. 3A
* **********************************************************************

*** table S8 ***

local tabnum = `tabnum' + 1

* summary statistics on losses of income
	foreach 				var in dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		mean 				`var' [pweight = phw] if wave == 1 
			local 			n_`var' = e(N)
			local 			mean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
		total 				`var' [pweight = phw]
			local 			tot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
	}	
	* format table
		preserve
			keep 			dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn
			drop 			if dwn < 2 //drop all observations
			label 			variable dwn "Any type of income loss"
			label 			variable remit_dwn "Remittances reduced"
			label 			variable other_dwn "Other income sources reduced"
			set 			obs 5
			gen 			stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
			order 			stat dwn *
			foreach 		var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
				decode 		`var', gen(`var'_de)
				destring 	`var'_de, replace
				drop 		`var'
			}
	* populate table with stored results
			foreach 		var in dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
			    foreach 	s in n mean msd tot tsd {
					replace `var' = ``s'_`var'' if stat == "`s'"
				}
			}
			
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(varlabels)
		restore
		

*** table S9 ***	

local tabnum = `tabnum' + 1

* mean and total (with std errors) for all countries for the income receipt variable for each country 
		
	foreach 				var in farm_inc bus_inc wage_inc remit_inc other_inc {
		mean 				`var' [pweight = hhw] if wave == 1 
			local 			n_`var'_call = e(N)
			local 			mean_`var'_call = el(e(b),1,1)
			local 			msd_`var'_call = sqrt(el(e(V),1,1))
		total 				`var' [pweight = hhw]
			local 			tot_`var'_call = el(e(b),1,1)
			local 			tsd_`var'_call = sqrt(el(e(V),1,1))
	}	
	
	forval c = 1/4 {	
		foreach 				var in farm_inc bus_inc wage_inc remit_inc other_inc {
			mean 				`var' [pweight = hhw] if wave == 1 & country == `c'
				local 			n_`var'_c`c' = e(N)
				local 			mean_`var'_c`c' = el(e(b),1,1)
				local 			msd_`var'_c`c' = sqrt(el(e(V),1,1))
			total 				`var' [pweight = hhw] if wave == 1 & country == `c'
				local 			tot_`var'_c`c' = el(e(b),1,1)
				local 			tsd_`var'_c`c' = sqrt(el(e(V),1,1))
		}	
	}

* create table from stored results
	preserve
		clear
		set 				obs 5
		gen 				c = _n 
		tostring 			c, replace
		replace 			c = "all" in 5
		expand 				5
		sort 				c
		gen 				stat = ""
		local 				q = 1
		foreach c in 1 2 3 4 all {
			replace 		stat = cond(_n==`q',"tot",cond(_n==`q'+1,"tsd",cond(_n==`q'+2,"mean", ///
							cond(_n==`q'+3,"msd", cond(_n==`q'+4,"n",""))))) if c == "`c'"
			local 			q = `q' + 5
		}
		foreach 			var in farm_inc bus_inc wage_inc remit_inc other_inc {
			gen 			`var' = .
			foreach c in 1 2 3 4 all {
				foreach 		s in tot tsd mean msd n {
					replace 	`var' = ``s'_`var'_c`c'' if stat == "`s'" & c == "`c'"
				}
			}
		}
		
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(varlabels)			
	restore				
		

*** table S10 ***	

local tabnum = `tabnum' + 1
			
* regressions for cross-country comparisons 
					
* regressions for income loss: farm
	reg 					farm_dwn ib(2).country [pweight = hhw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							replace excel dec(3) ctitle(S`tabnum' farm_dwn) 
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				t1_farm_dwn = r(p)
		test				1.country = 4.country
		local 				t2_farm_dwn = r(p)
		test				3.country = 4.country
		local 				t3_farm_dwn = r(p)	

* regressions for income loss: business, wage, remittances, other 						
	foreach 				var in bus_dwn wage_dwn remit_dwn other_dwn {
		reg 				`var' ib(2).country [pweight = hhw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' `var') 
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				t1_`var' = r(p)
		test				1.country = 4.country
		local 				t2_`var' = r(p)
		test				3.country = 4.country
		local 				t3_`var' = r(p)
	}

	preserve 
		clear
		set obs 3
		gen 				testcountries =  "Ethiopia-Nigeria"
		replace 			testcountries = "Ethiopia-Uganda" in 2
		replace 			testcountries = "Nigeria-Uganda" in 3
		foreach 			var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
							gen `var' = cond(_n == 1, `t1_`var'', cond(_n == 2, `t2_`var'',`t3_`var''))
		}
	
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore
	
*** table s11 ***

local tabnum = `tabnum' + 1

* regressions comparing rural urban, controlling for country

* regressions for income loss: farm, business, wage, remittances, other
	foreach 				var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		reg 				`var' i.sector ib(2).country [pweight = hhw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' `var') 	
	}

	
* **********************************************************************
* 3b - create Table S12 for Fig. 3B
* **********************************************************************

local tabnum = `tabnum' + 1

preserve 

	drop 					if bus_emp_inc == -99
	drop 					if bus_emp_inc == -98

* regression for business revenue loss - by country and wave 
	ologit 					bus_emp_inc i.wave ib(2).country [pweight = phw]
	local 					pr2 = e(r2_p)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' bus rev loss)
* Wald test for differences between other countries
	test					1.country = 3.country
	local 					ct1 = r(p)
	test					1.country = 4.country
	local 					ct2 = r(p)
	test					3.country = 4.country	
	local 					ct3 = r(p)
		
* Wald test for differences between other wave
	test 					2.wave = 3.wave 
	local 					wt = r(p)
		
* create table using stored test results
	clear
	set 					obs 5
	gen 					test =  "Ethiopia-Nigeria"
	replace 				test = "Ethiopia-Uganda" in 2
	replace 				test = "Nigeria-Uganda" in 3 
	replace 				test = "Wave 2-Wave 3" in 4
	replace 				test = "Pseudo R-Squared" in 5
	gen 					result = cond(_n == 1, `ct1', cond(_n == 2, `ct2',cond(_n == 3, `ct3',`wt')))
	replace 				result = `pr2' in 5
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore 

		
* **********************************************************************
* 4 - create tables for Fig. 4
* **********************************************************************

* **********************************************************************
* 4a - create Table S13-S15 for Fig. 4A
* **********************************************************************

*** table s13 ***

local tabnum = `tabnum' + 1

* summary statistics on moderate and severe food insecurity: means and totals

preserve
	drop					if country == 1 & wave == 2
	drop 					if country == 2 & wave == 1
	drop 					if country == 4 & wave == 1
	
* means of food insecurity status 	
	foreach 				var in p_mod p_sev {
		mean				`var' [pweight = wt_18] 
			local 			mmean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
	}
	foreach 				var in p_mod p_sev {
		forval 				c= 1/4 {
			mean 			`var' [pweight = wt_18] if country == `c'
				local 		mmean_`var'_c`c' = el(e(b),1,1)
				local		msd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	} 
	
* totals of food insecurity status 	
	foreach 				var in p_mod p_sev {
		total				`var' [pweight = wt_18] 
			local			tn_`var' = e(N)
			local 			ttot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
	}
	foreach 				var in p_mod p_sev {
		forval 				c= 1/4 {
			total 			`var' [pweight = wt_18] if country == `c'
				local		tn_`var'_c`c' = e(N)
				local 		ttot_`var'_c`c' = el(e(b),1,1)
				local		tsd_`var'_c`c' = sqrt(el(e(V),1,1))
		}
	} 

* create table of stored results
	clear
	set 					obs 9
	gen 					func = cond(_n<5,"m",cond(_n==9,"","t"))
	gen 					var = cond(_n ==1|_n==2|_n==5|_n==6,"p_mod",cond(_n==9,"","p_sev"))
	gen 					stat = cond(mod(_n,2)!=0,"mean","sd")
	replace 				stat = "tot" if _n == 5 | _n == 7
	replace 				stat = "Observations" in 9
	gen 					all_countries = .
	foreach 				stat in mean sd {
		foreach 			var in p_mod p_sev {
			replace			all_countries = `m`stat'_`var'' if var=="`var'" &stat=="`stat'" &func=="m"
		}
	}
	foreach					stat in tot sd {
		foreach 			var in p_mod p_sev {
			replace 		all_countries = `t`stat'_`var'' if var=="`var'" &stat=="`stat'" &func=="t"
		}
	}
	replace 				all_countries = `tn_p_mod' if stat == "Observations"
	forval 					c = 1/4 {
	    gen 				c`c' = .
		foreach 			stat in mean sd {
			foreach 		var in p_mod p_sev {
				replace		c`c' = `m`stat'_`var'_c`c'' if var=="`var'" &stat=="`stat'" &func=="m"
			}
		}
		foreach				stat in tot sd {
			foreach 		var in p_mod p_sev {
				replace 	c`c' = `t`stat'_`var'_c`c'' if var=="`var'" &stat=="`stat'" &func=="t"
			}
		}
		replace 			c`c' = `tn_p_mod_c`c'' if stat == "Observations"
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)
restore 
	
*** table s14 ***

local tabnum = `tabnum' + 1

preserve
	
	drop 					if country == 1 & wave == 2
	drop 					if country == 2 & wave == 1
	drop 					if country == 4 & wave == 1
	
* regression for moderate food insecurity 
	reg 					p_mod ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' mod food insecurity)

* Wald test for differences between other countries
		test				1.country = 3.country
		local 				tm1 = r(p)
		test				1.country = 4.country
		local 				tm2 = r(p)
		test				3.country = 4.country
		local 				tm3 = r(p)
			
* regression for severe food insecurity 
	reg 					p_sev ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' sev food insecurity)
	
* Wald test for differences between other countries
		test				1.country = 3.country
		local 				ts1 = r(p)
		test				1.country = 4.country
		local 				ts2 = r(p)
		test				3.country = 4.country	
		local 				ts3 = r(p)
			
* create table of stored test results
	clear
	set obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	gen 					modresult = .
	forval 					x = 1/3 {
		replace 			modresult = `tm`x'' if _n == `x'
	}
	gen 					sevresult = .
	forval 					x = 1/3 {
		replace 			sevresult = `ts`x'' if _n == `x'
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore 


* **********************************************************************
* 4b - create Table S15 for Fig. 4B
* **********************************************************************

*** table s15 ***

local tabnum = `tabnum' + 1

* regression for concerns and food insecurity: moderate  	

preserve
	
	drop if 				country == 1 & wave == 2
	drop if 				country == 2 & wave == 1
	drop if 				country == 4 & wave == 1

	reg 					p_mod concern_1 concern_2 ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' concerns & food insec mod)
					
* Wald test for differences between other countries
	test					1.country = 4.country
	local 					t_mod = r(p)

* regression for concerns and food insecurity: severe  	
	
	reg 					p_sev concern_1 concern_2 ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' concerns & food insec sev)	
					
* Wald test for differences between other countries
	test					1.country = 4.country
	local 					t_sev = r(p)

* create table of stored test results 
	clear
	set 					obs 1
	gen 					test = "Ethiopia-Uganda"
	gen 					result_mod = `t_mod'
	gen 					result_sev = `t_sev'
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore 

*** table s16 ***

local tabnum = `tabnum' + 1

preserve
	
	drop if 				country == 1 & wave == 2
	drop if 				country == 2 & wave == 1
	drop if 				country == 4 & wave == 1
	
* summary statistics for concerns 
	foreach 				var in concern_1 concern_2 {
	    total 				`var' [pweight = phw]
			local			n_`var'_ca = e(N)
			local 			tot_`var'_ca = el(e(b),1,1)
			local 			sd_`var'_ca = sqrt(el(e(V),1,1))
	}
	foreach 				var in concern_1 concern_2 {
	    foreach 			c in 1 2 3 4 {
		    total 			`var' [pweight = phw] if country == `c'
				local		n_`var'_c`c' = e(N)
				local 		tot_`var'_c`c' = el(e(b),1,1)
				local		sd_`var'_c`c' = sqrt(el(e(V),1,1)) 
		}
	}
	
* create table of stored results
	clear
	set 					obs 6
	gen 					concern = cond(_n<4,"concern_1","concern_2")
	gen 					stat = cond(_n==1|_n==4,"tot",cond(_n==2|_n==5,"sd","n"))
	foreach 				c in a 1 2 3 4 {
		gen 				c`c' = .
	}
	foreach 				c in a 1 2 3 4 {
	    foreach 			stat in tot sd n {
		    foreach 		con in concern_1 concern_2 {
				replace 	c`c' = ``stat'_`con'_c`c'' if concern == "`con'" & stat == "`stat'"
			}
		}
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)	
restore 


*** figure s1 ***

preserve

	drop if 			country == 1 & wave == 2
	drop if 			country == 2 & wave == 1
	drop if 			country == 4 & wave == 1

	gen					p_mod_1 = p_mod if quint == 1
	gen					p_mod_2 = p_mod if quint == 2
	gen					p_mod_3 = p_mod if quint == 3
	gen					p_mod_4 = p_mod if quint == 4
	gen					p_mod_5 = p_mod if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_mod_1 p_mod_2 p_mod_3 p_mod_4 p_mod_5 ///
						[pweight = wt_18], over(concern_1, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned that family/self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/fiesq1_modsev", replace)
						
	graph bar 		(mean) p_mod_1 p_mod_2 p_mod_3 p_mod_4 p_mod_5 ///
						[pweight = wt_18], over(concern_2, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned about the financial threat of COVID-19", size(vlarge)) ///
						saving("$output/fiesq2_modsev", replace)

	restore

	grc1leg2 		"$output/fiesq1_modsev.gph" "$output/fiesq2_modsev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme

	graph export 	"$output/fiesquintetc1.emf", as(emf) replace

* figure s2 ***
 
preserve

	drop if 		country == 2 & wave == 1
	drop if 		country == 4 & wave == 1

	gen				p_sev_1 = p_sev if quint == 1
	gen				p_sev_2 = p_sev if quint == 2
	gen				p_sev_3 = p_sev if quint == 3
	gen				p_sev_4 = p_sev if quint == 4
	gen				p_sev_5 = p_sev if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_sev_1 p_sev_2 p_sev_3 p_sev_4 p_sev_5 ///
						[pweight = wt_18], over(concern_1, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned that family/self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/fiesq1_sev", replace)
						
	graph bar 		(mean) p_sev_1 p_sev_2 p_sev_3 p_sev_4 p_sev_5 ///
						[pweight = wt_18], over(concern_2, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned about the financial threat of COVID-19", size(vlarge)) ///
						saving("$output/fiesq2_sev", replace)

	restore

	grc1leg2 		"$output/fiesq1_sev.gph" "$output/fiesq2_sev.gph", ///
						col(3) iscale(.5) pos(6) commonscheme

	graph export 	"$output/fiesquintetc12.emf", as(emf) replace


*** table s17 ***

local tabnum = `tabnum' + 1

preserve
	
	drop 					if country == 2 & wave == 1
	drop 					if country == 4 & wave == 1
	
* regression for concern 1, by quintile and country 
	reg 					concern_1 ib(1).quint ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' concern 1 by quintile)
					
* Wald test for differences between other countries
		test				1.country = 3.country
		local 				c1_t1 = r(p)
		test				1.country = 4.country
		local 				c1_t2 = r(p)
		test				3.country = 4.country
		local 				c1_t3 = r(p)
	
		
* regression for concern 2, by quintile and country 	
	reg 					concern_2 ib(1).quint ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S`tabnum' concern 2 by quintile)
	
* Wald test for differences between other countries
		test				1.country = 3.country
		local 				c2_t1 = r(p)
		test				1.country = 4.country
		local 				c2_t2 = r(p)
		test				3.country = 4.country
		local 				c2_t3 = r(p)
				
* create table of stored results
	clear
	set 					obs 3
	gen 					testcountries =  cond(_n==1,"Ethiopia-Nigeria","")
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	forval 					c = 1/2 {
		gen 				result_concern_`c' = .
		forval 				t = 1/3 {
		    replace 		result_concern_`c' = `c`c'_t`t'' if _n == `t'
		}
	}
	
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)	
		
restore 


		
* **********************************************************************
* 5 - create tables for Fig. 5
* **********************************************************************

* **********************************************************************
* 5a - create Table S18-S21 for Fig. 5A
* **********************************************************************


*** table s18 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

* total and mean for any shock 1) for all countries and 2) by country/area		
	total					shock_any [pweight = hhw]
		local 				tot_call = el(e(b),1,1)
		local 				tsd_call = sqrt(el(e(V),1,1))
	mean					shock_any [pweight = hhw]	
		local 				n_call = e(N)
		local 				mean_call = el(e(b),1,1)
		local 				msd_call = sqrt(el(e(V),1,1))
	
	forval 					c = 1/4 {
		total					shock_any [pweight = hhw] if country == `c'
			local 				tot_c`c' = el(e(b),1,1)
			local 				tsd_c`c' = sqrt(el(e(V),1,1))
		mean					shock_any [pweight = hhw] if country == `c'
			local 			n_c`c' = e(N)
			local 			mean_c`c' = el(e(b),1,1)
			local 			msd_c`c' = sqrt(el(e(V),1,1))
	}
	
* create table of stored results
	clear
	set 					obs 5 
	gen 					stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
	foreach 				c in 1 2 3 4 all {
		gen 				c`c' = . 
		foreach 			s in tot tsd mean msd n {
			replace 			c`c' = ``s'_c`c'' if stat == "`s'"
		}
	}
		
	export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
						sheetreplace sheet(sumstatsS`tabnum') first(varlabels)						
restore							
							
							
*** table s19 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_3 = 1 if cope_3 == 1 | cope_4 == 1
	replace					cope_5 = 1 if cope_5 == 1 | cope_6 == 1 | cope_7 == 1

* total and mean for any, relied on savings, sale of assets, reduced food consumption
  * reduced non_food consumption, assistance from friends & family, any assistance
	foreach 				var in cope_any cope_11 cope_1 cope_9 cope_10 cope_3 asst_any {
	    total 				`var' [pweight = hhw]
			local 			n_`var' = e(N)
			local 			tot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
		mean 				`var' [pweight = hhw]
			local 			mean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
	}
	
* create table of stored results
	clear
	set 					obs 5
	gen 					stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
	foreach 				var in cope_any cope_11 cope_1 cope_9 cope_10 cope_3 asst_any {
	    gen 				`var' = .
		foreach 			s in tot tsd mean msd n {
			replace 		`var' = ``s'_`var'' if stat == "`s'"
		}
	}
	
export 						excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)	
restore

*** table S20 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_3 = 1 if cope_3 == 1 | cope_4 == 1
	replace					cope_5 = 1 if cope_5 == 1 | cope_6 == 1 | cope_7 == 1
	
* regressions for cross-country comparisons 
					
* regressions for  relied on savings, sale of assets, reduced food consumption
  * reduced non_food consumption, assistance from friends & family, any assistance
	reg 					cope_11  ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							replace excel dec(3) ctitle(S`tabnum'_cope_11 )
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				cope_11_t1 = r(p)
		test				1.country = 4.country
		local 				cope_11_t2 = r(p)
		test				3.country = 4.country
		local 				cope_11_t3 = r(p)
	
	foreach 				var in cope_1 cope_9 cope_10 cope_3 asst_any {
		reg 				`var' ib(2).country [pweight = hhw], vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum'_`var')
		* Wald test for differences between other countries
			test			1.country = 3.country
			local 			`var'_t1 = r(p)
			test			1.country = 4.country
			local 			`var'_t2 = r(p)
			test			3.country = 4.country
			local 			`var'_t3 = r(p)
	}	
	
* create table of stored results
	clear
	set 					obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	foreach					var in cope_11 cope_1 cope_9 cope_10 cope_3 asst_any {
	    gen 				`var' = .
		forval 				t = 1/3 {
		    replace 		`var' = ``var'_t`t'' in `t'
		}
	}
export 						excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)	
restore
		
*** table s21 ***

local tabnum = `tabnum' + 1

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_3 = 1 if cope_3 == 1 | cope_4 == 1
	replace					cope_5 = 1 if cope_5 == 1 | cope_6 == 1 | cope_7 == 1
	
* regressions comparing rural urban

* regressions for relied on savings, sale of assets,reduced food consumption, reduced non_food consumption
	* received assistance from friends & family, recieved any assistance 
	foreach 				var in cope_11 cope_1 cope_9 cope_10 cope_3 asst_any {
	reg 					`var' i.sector ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum'_`var')
	}	
				
restore


* **********************************************************************
* 5b - create Table S22-S23 for Fig. 5B
* **********************************************************************

*** table s22 ***

local tabnum = `tabnum' + 1

* table of means and totals

* total and mean for access to medicine, staple, soap
	foreach 				var in ac_med ac_staple ac_soap {
	    total 				`var' [pweight = hhw] if wave == 1
			local 			n_`var' = e(N)
			local 			tot_`var' = el(e(b),1,1)
			local 			tsd_`var' = sqrt(el(e(V),1,1))
		mean 				`var' [pweight = hhw] if wave == 1
			local 			mean_`var' = el(e(b),1,1)
			local 			msd_`var' = sqrt(el(e(V),1,1))
	}

* create table of stored results
	preserve
		clear
		set 				obs 5
		gen 				stat = cond(_n==1,"tot",cond(_n==2,"tsd",cond(_n==3,"mean",cond(_n==4,"msd","n"))))
		foreach 			var in ac_med ac_staple ac_soap {
			gen 			`var' = .
			foreach 		s in tot tsd mean msd n {
				replace 	`var' = ``s'_`var'' if stat == "`s'"
			}
		}
		
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS`tabnum') first(var)	
						
	restore

*** table s23 ***

local tabnum = `tabnum' + 1

* regressions across quintiles

* regression on access to medicine
	reg						ac_med i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' access to medicine)
	
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				med_t1 = r(p)
		test				1.country = 4.country
		local 				med_t2 = r(p)
		test				3.country = 4.country
		local 				med_t3 = r(p)		
		
* regression on access to staple
	reg						ac_staple i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' access to staple)
	
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				stap_t1 = r(p)
		test				1.country = 4.country
		local 				stap_t2 = r(p)
		test				3.country = 4.country
		local 				stap_t3 = r(p)	
		
* regression on access to soap
	reg						ac_soap i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' access to soap)
	
	* Wald test for differences between other countries
		test				3.country = 4.country
		local 				soap_t3 = r(p)		
		
* create table of stored results
preserve
	clear
	set 					obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	foreach					var in med stap {
	    gen 				`var' = .
		forval 				t = 1/3 {
		    replace 		`var' = ``var'_t`t'' in `t'
		}
	}
	gen 					soap = `soap_t3' in 3
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)	
restore					



		
* **********************************************************************
* 6 - create tables for Fig. 6
* **********************************************************************


* **********************************************************************
* 6a - create Table S24-S25 for Fig. 6A
* **********************************************************************

*** table s24 ***

local tabnum = `tabnum' + 1

* total number of children NOT engaged in Learning Activities After Outbreakover all four countries
	total 					edu_none [pweight = shw] if wave == 1
		local 				n_all = e(N)
		local 				tot_all = el(e(b),1,1)
		local 				tsd_all = sqrt(el(e(V),1,1))

* by country
	forval 					c = 1/4 {
		total 				edu_none [pweight = shw] if wave == 1 & country == `c'
			local 			n_c`c' = e(N)
			local 			tot_c`c' = el(e(b),1,1)
			local 			tsd_c`c' = sqrt(el(e(V),1,1))
	}
	
* create table of stored results
	preserve
		clear
		set 					obs 3
		gen 					stat = cond(_n==1,"tot",cond(_n==2,"tsd","n"))
		foreach 				var in all c1 c2 c3 c4 {
			gen 				`var' = .
			foreach 			stat in tot tsd n {
				replace 		`var' = ``stat'_`var'' if stat == "`stat'"
			}
		}
		export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
								sheetreplace sheet(sumstatsS`tabnum') first(var)	
	restore

*** table s25 ***

local tabnum = `tabnum' + 1

* regression of educational activity on quintile
	reg						edu_act i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' edu act on quint)
		
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				t1 = r(p)
		test				1.country = 4.country
		local 				t2 = r(p)
		test				3.country = 4.country
		local 				t3 = r(p)		
		
* create table of stored results
preserve
	clear
	set 					obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	gen 					pval = .
	forval 					t = 1/3 {
		replace 			pval = `t`t'' in `t'
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
restore

		
* **********************************************************************
* 6b - create Figure S3 and Table S26-S27 for Fig. 6B
* **********************************************************************

*** figure s3 ***	
	graph bar 			p_mod p_sev [pweight = wt_18], over(edu_act, lab(labs(vlarge))) ///
							over(country, lab(labs(vlarge))) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
							.8 "80" 1 "100", labs(large)) ytitle("Prevalence of food insecurity", size(large)) ///
							bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
							legend(label (1 "Moderate or severe")  ///
							label (2 "Severe") pos(6) col(2) size(medsmall)) ///
							title("Children engaged in learning activities (yes/no)", size(vlarge)) ///
							saving("$output/fies_edu", replace)
						
	grc1leg2 			"$output/fies_edu.gph", ///
							col(3) iscale(.5) pos(6) commonscheme						
						
	graph export 		"$output/fies_edu1.emf", as(emf) replace

	
*** table s26 ***

local tabnum = `tabnum' + 1

* fies and educational activity
	preserve
	
	drop if					country == 2 & wave == 1
	drop if					country == 4 & wave == 2

	reg						p_mod edu_act ib(2).country [pweight = shw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' edu act mod)

	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				mod_t1 = r(p)
		test				1.country = 4.country
		local 				mod_t2 = r(p)
		test				3.country = 4.country
		local 				mod_t3 = r(p)		

	reg						p_sev edu_act ib(2).country [pweight = shw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' edu act sev)
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				sev_t1 = r(p)
		test				1.country = 4.country
		local 				sev_t2 = r(p)
		test				3.country = 4.country
		local 				sev_t3 = r(p)		
		
* create table of stored results
	clear
	set 					obs 3
	gen 					testcountries =  "Ethiopia-Nigeria"
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	foreach					var in mod sev {
	    gen 				`var' = .
		forval 				t = 1/3 {
		    replace 		`var' = ``var'_t`t'' in `t'
		}
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS`tabnum') first(var)
	restore
	
*** table s27 ***

local tabnum = `tabnum' + 1

* changes in educational activity over time by country
	foreach 				var in edu_act edu_4 edu_2 edu_3 edu_5 {
	    forval 				c = 1/3 {
			reg				`var' i.wave [pweight = shw] if country == `c', vce(robust)	
			outreg2 		using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S`tabnum' `var' country `c')
		}
	}

	
* **********************************************************************
* 7 - end matter, clean up to save
* **********************************************************************

* close the log
	log	close

/* END */