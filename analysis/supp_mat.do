* Project: WB COVID
* Created on: September 2020 
* Created by: amf
* Edited by: jdm, alj 
* Last edit: 5 September 2020 
* Stata v.16.1

* does
	* runs regressions and produces tables for supplemental material

* assumes
	* cleaned country data
	* palettes and colrspace installed
	/*ssc install palettes
	ssc install colrspace */
	

* TO DO:
	* everything


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global					ans		=	"$data/analysis"
	global					output	=	"$data/analysis/tables"
	global					logout	=	"$data/analysis/logs"

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
		reg 				gov_01 ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							replace excel dec(3) ctitle(S1 gov_01) label
						
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

	foreach 				var in gov_02 gov_04 gov_05 gov_06 gov_10 {
		reg 				`var' ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S1 `var') label
						
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
							replace sheet(testresultsS1) first(var)
	restore

	
* **********************************************************************
* 1b - create table S2 for Fig. 1B
* **********************************************************************

* regressions for handwashing with Soap Reduces Risk of Coronavirus Contraction, 
	* avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract, 
	* using Masks or Gloves Reduces Risk of Coronavirus Contraction, 
	* staying at Home Reduces Risk of Coronavirus Contraction, 
	* avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction, 
	* mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Common
	local 					counter = 1
	foreach 				var in know_01 know_02 know_03 know_05 know_06 know_07 {
		reg 				`var' ib(2).country [pweight = phw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S2 `var') label
								
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
							sheetreplace sheet(testresultsS2) first(var)
	restore
	

* **********************************************************************
* 1c - create tables S3-S5 for Fig. 1C
* **********************************************************************

*** table S3 ***

* handwashed with Soap More Often Since Outbreak
	reg 					bh_01 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S3 Handwashed with soap more often) label
	
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
	reg 					bh_02 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S3 Avoided physical greetings) label
	
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
	reg 					bh_03 ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S3 Avoided crowds) label
	
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
							sheetreplace sheet(testresultsS3) first(var)
	restore

*** table S4 ***
		
* percentage over time for Malawi and Uganda

	* calculate statistics and store results
		foreach				c in 2 4 {
			forval 			b = 1/3 {
				forval 		w = 1/2 {
					mean			bh_0`b' [pweight = phw] if country == `c', over(wave)	
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
							sheetreplace sheet(sumstatsS4) first(var)
		restore	
		
*** table S5 ***

* regressions of behavior on waves in Malawi
	reg						bh_01 i.wave [pweight = phw] if country == 2, vce(robust) 
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S5 Malawi Behavior 1) label
	
	reg						bh_02 i.wave [pweight = phw] if country == 2, vce(robust) 
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S5 Malawi Behavior 2) label
	
	reg						bh_03 i.wave [pweight = phw] if country == 2, vce(robust) 
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S5 Malawi Behavior 3) label
	
* regressions of behavior on waves in Uganda
	reg						bh_01 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S5 Uganda Behavior 1) label
	
	reg						bh_02 i.wave [pweight = phw] if country == 4, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S5 Uganda Behavior 2) label
	
	reg						bh_03 i.wave [pweight = phw] if country == 4, vce(robust)		
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S5 Uganda Behavior 3) label	
		
* **********************************************************************
* 1d - create tables S6-S7 for Fig. 1D
* **********************************************************************

preserve
		
	local 					myth myth_01 myth_02 myth_03 myth_04 myth_05
	foreach 				v in `myth' {
	    replace 			`v' = . if `v' == 3
	}	

*** table S6 ***
	
* lemon and alcohol can be used as sanitizers against coronavirus
	reg 					myth_01 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S6 Lemon and alcohol) label
	
* africans are immune to corona virus
	reg 					myth_02 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S6 Africans immune) label
* corona virus does not affect children
	reg 					myth_03 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S6 Not affect children) label
	
* corona virus cannot survive in warm weather
	reg 					myth_04 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S6 Survive warm weather) label
	
* corona virus is just common flu
	reg 					myth_05 i.country [pweight = phw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results", ///
							append excel dec(3) ctitle(S6 Common flu) label
restore

*** table S7 ***

* totals by myths
	forval 					x = 1/5 {
	    gen 				myth_0`x'y = cond(myth_0`x' == 1,1,cond(myth_01 == 0 | myth_01 == 3, 0,.))
	    gen 				myth_0`x'n = cond(myth_0`x' == 0,1,cond(myth_01 == 1 | myth_01 == 3, 0,.))
	    gen 				myth_0`x'k = cond(myth_0`x' == 3,1,cond(myth_01 == 0 | myth_01 == 1, 0,.))
	}

	forval 					m = 1/5 {
		total 				myth_0`m'y myth_0`m'n myth_0`m'k [pweight = phw], over(country)
			local			n_m`m' = e(N)
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
	
	* format table
		preserve
			clear
			set 			obs 7
			gen 			response = cond(_n<3,"y",cond(_n>2 & _n<5,"n",cond(_n>4 & _n<7,"k","")))
			gen 			stat = cond(mod(_n,2)==0,"se","tot")
			replace 		stat = "Observations" in 7
			expand 			2
			gen 			country = cond(_n<8,2,4)
			forval 			x = 1/5 {
							gen myth_0`x' = .
			}
		* replace values with stored locals
			foreach 		c in 2 4 {
				forval 		m = 1/5 {
					foreach s in tot se {
						foreach r in y n k {
							replace myth_0`m' = ``r'`s'_c`c'm`m'' if response == "`r'" & stat == "`s'" & country == `c' 
						}
					}
				}
			}
			forval 			x = 1/5 {
				replace 	myth_0`x' = `n_m`x'' if stat == "Observations"
			} 
		
			export 			excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS7) first(var)
		restore

* **********************************************************************
* 2 - create tables for Fig. 2
* **********************************************************************


* **********************************************************************
* 2a - create Table S8-S10 for Fig. 2A
* **********************************************************************

*** table S8 ***

* summary statistics on losses of income
	foreach 				var in dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		mean 				`var' [pweight = phw] if wave == 1 
			local 			n_`var' = e(N)
			local 			mean_`var' = el(e(b),1,1)
			local 			sd_`var' = sqrt(el(e(V),1,1))
	}	
	* format table
		preserve
			keep 			dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn
			drop 			if dwn < 2 //drop all observations
			label 			variable dwn "Any type of income loss"
			label 			variable remit_dwn "Remittances reduced"
			label 			variable other_dwn "Other income sources reduced"
			set 			obs 3
			gen 			stat = cond(_n == 1, "mean",cond(_n == 2, "sd","n"))
			order 			stat dwn *
			foreach 		var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn{
				decode 		`var', gen(`var'_de)
				destring 	`var'_de, replace
				drop 		`var'
			}
	* populate table with stored results
			foreach 		var in dwn farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
			    foreach 	s in n mean sd {
					replace `var' = ``s'_`var'' if stat == "`s'"
				}
			}
			
		export 				excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS8) first(varlabels)
		restore				
			
*** table S9 ***	
			
* regressions for cross-country comparisons 
					
* regressions for income loss: farm
	reg 					farm_dwn ib(2).country [pweight = hhw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							replace excel dec(3) ctitle(S9 farm_dwn) 
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
							append excel dec(3) ctitle(S9 `var') 
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
							sheetreplace sheet(testresultsS9) first(var)
	restore
	
*** table s10 ***

* regressions comparing rural urban, controlling for country

* regressions for income loss: farm, business, wage, remittances, other
	foreach 				var in farm_dwn bus_dwn wage_dwn remit_dwn other_dwn {
		reg 				`var' i.sector ib(2).country [pweight = hhw] if wave == 1, vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S10 `var') 	
	}


* **********************************************************************
* 2b - create Table S11 for Fig. 2B
* **********************************************************************

preserve 

	drop 					if bus_emp_inc == -99
	drop 					if bus_emp_inc == -98

* regression for business revenue loss - by country and wave 
	ologit 					bus_emp_inc i.wave ib(2).country [pweight = phw]
	local 					loglike = e(ll)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S11 bus rev loss)
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
	replace 				test = "Log Likelihood" in 5
	gen 					result = cond(_n == 1, `ct1', cond(_n == 2, `ct2',cond(_n == 3, `ct3',`wt')))
	replace 				result = `loglike' in 5
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS11) first(var)
restore 


* **********************************************************************
* 2c - create Table S12-S14 for Fig. 2C
* **********************************************************************

*** table s12 ***

* summary statistics on moderate and severe food insecurity: means and totals

preserve
	drop					if country == 1 & wave == 2
	drop 					if country == 2 & wave == 1
	
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
							sheetreplace sheet(sumstatsS12) first(var)
restore 
	
*** table s13 ***

preserve
	
	drop 					if country == 1 & wave == 2
	drop 					if country == 2 & wave == 1

* regression for moderate food insecurity 
	reg 					p_mod ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S13 mod food insecurity)

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
							append excel dec(3) ctitle(S13 sev food insecurity)
	
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
							sheetreplace sheet(testresultsS13) first(var)
restore 


* **********************************************************************
* 2D - create Table S14 for Fig. 2C
* **********************************************************************

*** table s14 ***

* regression for concerns and food insecurity: moderate  	

preserve
	
	drop if					country == 2 & wave == 1

	reg 					p_mod concern_01 concern_02 ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S14 concerns & food insec mod)
					
* Wald test for differences between other countries
	test					1.country = 4.country
	local 					t_mod = r(p)

* regression for concerns and food insecurity: severe  	
	
	reg 					p_sev concern_01 concern_02 ib(2).country [pweight = wt_18], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S14 concerns & food insec sev)	
					
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
							sheetreplace sheet(testresultsS14) first(var)
restore 

*** table s15 ***

preserve
	
	drop if					country == 2 & wave == 1
	drop if					country == 4 & wave == 2
	
* summary statistics for concerns 
	foreach 				var in concern_01 concern_02 {
	    total 				`var' [pweight = phw]
			local			n_`var'_ca = e(N)
			local 			tot_`var'_ca = el(e(b),1,1)
			local 			sd_`var'_ca = sqrt(el(e(V),1,1))
	}
	foreach 				var in concern_01 concern_02 {
	    foreach 			c in 1 2 4 {
		    total 			`var' [pweight = phw] if country == `c'
				local		n_`var'_c`c' = e(N)
				local 		tot_`var'_c`c' = el(e(b),1,1)
				local		sd_`var'_c`c' = sqrt(el(e(V),1,1)) 
		}
	}
	
* create table of stored results
	clear
	set 					obs 6
	gen 					concern = cond(_n<4,"concern_01","concern_02")
	gen 					stat = cond(_n==1|_n==4,"tot",cond(_n==2|_n==5,"sd","n"))
	foreach 				c in a 1 2 4 {
		gen 				c`c' = .
	}
	foreach 				c in a 1 2 4 {
	    foreach 			stat in tot sd n {
		    foreach 		con in concern_01 concern_02 {
				replace 	c`c' = ``stat'_`con'_c`c'' if concern == "`con'" & stat == "`stat'"
			}
		}
	}
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS15) first(var)	
restore 


*** figure s1 ***

preserve

	drop if				country == 2 & wave == 1

	gen					p_mod_01 = p_mod if quint == 1
	gen					p_mod_02 = p_mod if quint == 2
	gen					p_mod_03 = p_mod if quint == 3
	gen					p_mod_04 = p_mod if quint == 4
	gen					p_mod_05 = p_mod if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_mod_01 p_mod_02 p_mod_03 p_mod_04 p_mod_05 ///
						[pweight = wt_18], over(concern_01, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of moderate or severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned that family/self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/fiesq1_modsev", replace)
						
	graph bar 		(mean) p_mod_01 p_mod_02 p_mod_03 p_mod_04 p_mod_05 ///
						[pweight = wt_18], over(concern_02, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
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
						col(3) iscale(.5) pos(6) commonscheme  ///
						saving("$output/fiesquintetc1.gph", replace)

	graph export 	"$output/fiesquintetc1.emf", as(emf) replace

* figure s2 ***
 
preserve

	drop if			country == 2 & wave == 1

	gen				p_sev_01 = p_sev if quint == 1
	gen				p_sev_02 = p_sev if quint == 2
	gen				p_sev_03 = p_sev if quint == 3
	gen				p_sev_04 = p_sev if quint == 4
	gen				p_sev_05 = p_sev if quint == 5

	colorpalette edkblue khaki, ipolate(15, power(1)) locals

	graph bar 		(mean) p_sev_01 p_sev_02 p_sev_03 p_sev_04 p_sev_05 ///
						[pweight = wt_18], over(concern_01, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
						.2 "20" .4 "40" .6 "60" .8 "80" 1 "100", labs(large)) ///
						ytitle("Prevalence of severe food insecurity", size(vlarge))  ///
						bar(1, fcolor(`1') lcolor(none)) bar(2, fcolor(`4') lcolor(none))  ///
						bar(3, fcolor(`7') lcolor(none)) bar(4, fcolor(`10') lcolor(none))  ///
						bar(5, fcolor(`13') lcolor(none))  legend(label (1 "First Quintile")  ///
						label (2 "Second Quintile") label (3 "Third Quintile") label (4 "Fourth Quintile") ///
						label (5 "Fifth Quintile") order( 1 2 3 4 5) pos(6) col(3) size(medsmall)) ///
						title("Concerned that family/self will fall ill with COVID-19", size(vlarge)) ///
						saving("$output/fiesq1_sev", replace)
						
	graph bar 		(mean) p_sev_01 p_sev_02 p_sev_03 p_sev_04 p_sev_05 ///
						[pweight = wt_18], over(concern_02, lab(labs(vlarge))) over(country, lab(labs(vlarge))) ylabel(0 "0" ///
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
						col(3) iscale(.5) pos(6) commonscheme  ///
						saving("$output/fiesquintetc2.gph", replace)

	graph export 	"$output/fiesquintetc12.emf", as(emf) replace


*** table s16 ***

preserve
	
	drop if				country == 2 & wave == 1
	drop if				country == 4 & wave == 2
	
* regression for concern 1, by quintile and country 
	reg 					concern_01 ib(5).quint ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S16 concern 1 by quintile)
					
* Wald test for differences between other countries
		test				1.country = 3.country
		local 				c1_t1 = r(p)
		test				1.country = 4.country
		local 				c1_t2 = r(p)
		test				3.country = 4.country
		local 				c1_t3 = r(p)
		
* Wald test for differences between quintiles
		test 				1.quint = 2.quint
		local 				con1_t12 = r(p)
		test 				1.quint = 3.quint
		local 				con1_t13 = r(p)
		test 				1.quint = 4.quint
		local 				con1_t14 = r(p)
		test 				2.quint = 3.quint
		local 				con1_t23 = r(p)
		test 				2.quint = 4.quint
		local 				con1_t24 = r(p)
		test 				3.quint = 4.quint
		local 				con1_t34 = r(p)
		
* regression for concern 2, by quintile and country 	
	reg 					concern_02 ib(5).quint ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig2", ///
							append excel dec(3) ctitle(S16 concern 2 by quintile)
	
* Wald test for differences between other countries
		test				1.country = 3.country
		local 				c2_t1 = r(p)
		test				1.country = 4.country
		local 				c2_t2 = r(p)
		test				3.country = 4.country
		local 				c2_t3 = r(p)
		
* Wald test for differences between quintiles
		test 				1.quint = 2.quint
		local 				con2_t12 = r(p)
		test 				1.quint = 3.quint
		local 				con2_t13 = r(p)
		test 				1.quint = 4.quint
		local 				con2_t14 = r(p)
		test 				2.quint = 3.quint
		local 				con2_t23 = r(p)
		test 				2.quint = 4.quint
		local 				con2_t24 = r(p)
		test 				3.quint = 4.quint
		local 				con2_t34 = r(p)
				
* create table of stored results
	clear
	set 					obs 9
	gen 					testcountries =  cond(_n==1,"Ethiopia-Nigeria","")
	replace 				testcountries = "Ethiopia-Uganda" in 2
	replace 				testcountries = "Nigeria-Uganda" in 3
	forval 					c = 1/2 {
		gen 				result_concern_`c' = .
		forval 				t = 1/3 {
		    replace 		result_concern_`c' = `c`c'_t`t'' if _n == `t'
		}
	}
	local 					counter = 4
	foreach 				t in 12 13 14 23 24 34 {
		replace 			test = "quint_`t'" in `counter'
		forval 				c = 1/2 {
			replace 		result_concern_`c' = `con`c'_t`t'' in `counter'
		}
		local				 counter = `counter'+1
	}
	
	export 					excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS16) first(var)	
		
restore 


* **********************************************************************
* 3 - create tables for Fig. 3
* **********************************************************************


* **********************************************************************
* 3a - create Table S17-S19 for Fig. 3A
* **********************************************************************

*** table s17 ***

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace					cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1

* total and mean for any, relied on savings, sale of assets, reduced food consumption
  * reduced non_food consumption, assistance from friends & family, any assistance
	foreach 				var in cope_any cope_11 cope_01 cope_09 cope_10 cope_03 asst_any {
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
	foreach 				var in cope_any cope_11 cope_01 cope_09 cope_10 cope_03 asst_any {
	    gen 				`var' = .
		foreach 			s in tot tsd mean msd n {
			replace 		`var' = ``s'_`var'' if stat == "`s'"
		}
	}
	
export 						excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(sumstatsS17) first(var)	
restore

*** table S18 ***

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace					cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1
	
* regressions for cross-country comparisons 
					
* regressions for  relied on savings, sale of assets, reduced food consumption
  * reduced non_food consumption, assistance from friends & family, any assistance
	reg 					cope_11  ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							replace excel dec(3) ctitle(S18_cope_11 )
	* Wald test for differences between other countries
		test				1.country = 3.country
		local 				cope_11_t1 = r(p)
		test				1.country = 4.country
		local 				cope_11_t2 = r(p)
		test				3.country = 4.country
		local 				cope_11_t3 = r(p)
	
	foreach 				var in cope_01 cope_09 cope_10 cope_03 asst_any {
		reg 				`var' ib(2).country [pweight = hhw], vce(robust)
		outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S18_`var')
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
	foreach					var in cope_11 cope_01 cope_09 cope_10 cope_03 asst_any {
	    gen 				`var' = .
		forval 				t = 1/3 {
		    replace 		`var' = ``var'_t`t'' in `t'
		}
	}
export 						excel using "$output/Supplementary_Materials_Excel_Tables_Test_Results", ///
							sheetreplace sheet(testresultsS18) first(var)	
restore
		
*** table s19 ***

preserve

	drop if 				country == 1 & wave == 1
	drop if 				country == 1 & wave == 2
	drop if					country == 2 & wave == 1
	drop if					country == 3 & wave == 1
	drop if					country == 3 & wave == 2
	drop if					country == 4 & wave == 2

	replace					cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace					cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1
	
* regressions comparing rural urban

* regressions for relied on savings, sale of assets,reduced food consumption, reduced non_food consumption
	* received assistance from friends & family, recieved any assistance 
	foreach 				var in cope_11 cope_01 cope_09 cope_10 cope_03 asst_any {
	reg 					`var' i.sector ib(2).country [pweight = hhw], vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S19_`var')
	}	
				
restore


* **********************************************************************
* 3b - create Table S20-S21 for Fig. 3B
* **********************************************************************

*** table s20 ***

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
							sheetreplace sheet(sumstatsS20) first(var)	
						
	restore

*** table s21 ***

* regressions across quintiles

* regression on access to medicine
	reg						ac_med i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S21 access to medicine)
							
* regression on access to staple
	reg						ac_staple i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S21 access to staple)
							
* regression on access to soap
	reg						ac_soap i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S21 access to soap)

					
* **********************************************************************
* 3c - create Table S22-S23 for Fig. 3C
* **********************************************************************

*** table s22 ***

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
								sheetreplace sheet(sumstatsS22) first(var)	
	restore

*** table s23 ***

* regression of educational activity on quintile
	reg						edu_act i.quint ib(2).country [pweight = phw] if wave == 1, vce(robust)
	outreg2 				using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S23 edu act on quint)
	
	
* **********************************************************************
* 3d - create Figure S3 and Table S24-S25 for Fig. 3D
* **********************************************************************

*** figure s3 ***
	preserve
	
	
	graph bar 			p_mod p_sev [pweight = wt_18], over(edu_act, lab(labs(vlarge))) ///
							over(country, lab(labs(vlarge))) ylabel(0 "0" .2 "20" .4 "40" .6 "60" ///
							.8 "80" 1 "100", labs(large)) ytitle("Prevalence of food insecurity", size(large)) ///
							bar(1, color(stone*1.5)) bar(2, color(maroon*1.5)) ///
							legend(label (1 "Moderate or severe")  ///
							label (2 "Severe") pos(6) col(2) size(medsmall)) ///
							title("Children engaged in learning activities (yes/no)", size(vlarge)) ///
							saving("$output/fies_edu", replace)
						
	grc1leg2 			"$output/fies_edu.gph", ///
							col(3) iscale(.5) pos(6) commonscheme  ///
							saving("$output/fies_edu1.gph", replace)						
						
	graph export 		"$output/fies_edu1.emf", as(emf) replace

*** table s24 ***

* fies and educational activity
	preserve
	
	drop if				country == 2 & wave == 1

	reg					p_mod edu_act ib(2).country [pweight = shw], vce(robust)
	outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S24 edu act mod)
					
	reg					p_sev edu_act ib(2).country [pweight = shw], vce(robust)
	outreg2 			using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S24 edu act sev)
	
	restore
	
*** table s25 ***

* changes in educational activity over time by country
	foreach 				var in edu_act edu_04 edu_02 edu_03 edu_05 {
	    forval 				c = 1/3 {
			reg				`var' i.wave [pweight = shw] if country == `c', vce(robust)	
			outreg2 		using "$output/Supplementary_Materials_Excel_Tables_Reg_Results_fig3", ///
							append excel dec(3) ctitle(S25 `var' country `c')
		}
	}
