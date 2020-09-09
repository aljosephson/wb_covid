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

* TO DO:
	* everything


* **********************************************************************
* 0 - setup
* **********************************************************************

* define
	global	ans		=	"$data/analysis"
	global	output	=	"$data/analysis/tables"
	global	logout	=	"$data/analysis/logs"

* open log
	cap log 		close
	log using		"$logout/supp_mat", append

* read in data
	use				"$ans/lsms_panel", clear
	
	
* **********************************************************************
* 1 - create tables for Fig. 1
* **********************************************************************


* **********************************************************************
* 1a - create Table S1 for Fig. 1A
* **********************************************************************

* advised citizens to stay at home
	reg 			gov_01 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", replace excel dec(3) ctitle(S1 Stay at home) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		local 			counter = 1
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* restricted travel within country/area
	reg 			gov_02 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S1 Restricted travel) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* closure of schools
	reg 			gov_04 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S1 Close schools) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore

* curfew/lockdown
	reg 			gov_05 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S1 Lockdown) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* closure of non-essential businesses
	reg 			gov_06 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S1 Close businesses) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore

* stopping or limiting social gatherings
	reg 			gov_10 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S1 Limit social gatherings) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

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
		restore
* make table of test values with significance stars
	* merge	all test tables into one 
		preserve
		clear
		use `temp1'
		forval x = 2/6 {
			merge 1:1 merger using `temp`x'', assert(3) nogen
		}
		format					testgrp* %10.3f
		drop merger 
		
	* add stars for significance
		ds
		foreach var in `r(varlist)' {
			gen 				`var'_star = ""
			replace 			`var'_star = "*" if `var' < 0.1
			replace 			`var'_star = "**" if `var' < 0.05
			replace 			`var'_star = "***" if `var' < 0.01
		}
		gen 					testcountries = ""
		replace 				testcountries = "Ethiopia-Nigeria" in 1
		replace 				testcountries = "Ethipia-Uganda" in 2
		replace 				testcountries = "Nigeria-Uganda" in 3
		order 					testc *
							
		export excel using "paper\intermediate\Supplementary_Materials_Excel_Tables_Test_Results", sheetreplace sheet(testresultsS1) first(var)
		restore

		
/* We would like these regressions results all in one table	somthing like this:

-------------------------------------------------------------------------------------------------
					Stay at 	Restrict	Close		Lockdown	Close			Limit social
					home		travel		schools					Businesses		gatherings
-------------------------------------------------------------------------------------------------
Ethiopia			0.138***
					(0.013)
Nigeria

Uganda			

-------------------------------------------------------------------------------------------------
Ethiopia-Nigeria	0.000***
Ethipia-Uganda
Nigeria-Uganda
-------------------------------------------------------------------------------------------------
Observations
R^2
-------------------------------------------------------------------------------------------------

Do not report estimate of the constant
Report p-value for Wald tests between coefficients
All coefficients and standard errors should be 4 digits. So 0.143 or 143.0 or 14.30
Observations should be whole number with common: 8,576
R^2 should be 4 digits: 0.181
*/


* **********************************************************************
* 1b - create table S2 for Fig. 1B
* **********************************************************************

* handwashing with Soap Reduces Risk of Coronavirus Contraction
	reg 			know_01 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S2 Soap reduces risk) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		local 			counter = 1
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore

* avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract
	reg 			know_02 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S2 Avoid physical greetings) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore

* using Masks or Gloves Reduces Risk of Coronavirus Contraction
	reg 			know_03 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S2 Use masks of gloves) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore

* staying at Home Reduces Risk of Coronavirus Contraction
	reg 			know_05 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S2 Stay at home) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction
	reg 			know_06 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S2 Avoid crowds) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore

* mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Co
	reg 			know_07 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S2 Maintain distance of 1 meter) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* make table of test values with significance stars

	* merge	all test tables into one 
		preserve
		clear
		use `temp1'
		forval x = 2/6 {
			merge 1:1 merger using `temp`x'', assert(3) nogen
		}
		format					testgrp* %10.3f
		drop merger 
		
	* add stars for significance
		ds
		foreach var in `r(varlist)' {
			gen 				`var'_star = ""
			replace 			`var'_star = "*" if `var' < 0.1
			replace 			`var'_star = "**" if `var' < 0.05
			replace 			`var'_star = "***" if `var' < 0.01
		}
		gen 					testcountries = ""
		replace 				testcountries = "Ethiopia-Nigeria" in 1
		replace 				testcountries = "Ethipia-Uganda" in 2
		replace 				testcountries = "Nigeria-Uganda" in 3
		order 					testc *
		export excel using "paper\intermediate\Supplementary_Materials_Excel_Tables_Test_Results", sheetreplace sheet(testresultsS2) first(var)
		restore

* **********************************************************************
* 1c - create tables S3-S5 for Fig. 1C
* **********************************************************************

*** table S3 ***

* handwashed with Soap More Often Since Outbreak
	reg 			bh_01 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S3 Handwashed with soap more often) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		local 			counter = 1
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* avoided Handshakes/Physical Greetings Since Outbreak
	reg 			bh_02 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S3 Avoided physical greetings) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		

* avoided Crowds and Gatherings Since Outbreak
	reg 			bh_03 ib(2).country [pweight = phw] if wave == 1
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S3 Avoided crowds) label
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		local 			test1 = r(p)
		test			1.country = 4.country
		local 			test2 = r(p)
		test			3.country = 4.country
		local 			test3 = r(p)

	* make table of test p-values
		preserve
			clear
			set 			obs 3
			gen 			merger = _n
			gen 			testgrp`counter' = 0
			forval 			x = 1/3 {
				replace 	testgrp`counter' =	`test`x'' in `x'
			}
			tempfile temp`counter'
			save `temp`counter''
			local counter = `counter' +1
		restore
		
* make table of test values with significance stars

	* merge	all test tables into one 
		preserve
		clear
		use `temp1'
		forval x = 2/3 {
			merge 1:1 merger using `temp`x'', assert(3) nogen
		}
		format					testgrp* %10.3f
		drop merger 
		
	* add stars for significance
		ds
		foreach var in `r(varlist)' {
			gen 				`var'_star = ""
			replace 			`var'_star = "*" if `var' < 0.1
			replace 			`var'_star = "**" if `var' < 0.05
			replace 			`var'_star = "***" if `var' < 0.01
		}
		gen 					testcountries = ""
		replace 				testcountries = "Ethiopia-Nigeria" in 1
		replace 				testcountries = "Ethipia-Uganda" in 2
		replace 				testcountries = "Nigeria-Uganda" in 3
		order 					testc *
		export excel using "paper\intermediate\Supplementary_Materials_Excel_Tables_Test_Results", sheetreplace sheet(testresultsS3) first(var)
		restore
	
* table S4		
		
* percentage over time for Malawi and Uganda
	mean			bh_01 bh_02 bh_03 [pweight = phw] if country == 2 | ///
						country == 4, over(country wave)

* table S5

* regressions of behavior on waves in Malawi
	reg				bh_01 i.wave [pweight = phw] if country == 2 
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S5 Malawi Behavior 1) label
	
	reg				bh_02 i.wave [pweight = phw] if country == 2 
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S5 Malawi Behavior 2) label
	
	reg				bh_03 i.wave [pweight = phw] if country == 2 
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S5 Malawi Behavior 3) label
	
* regressions of behavior on waves in Uganda
	reg				bh_01 i.wave [pweight = phw] if country == 4
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S5 Uganda Behavior 1) label
	
	reg				bh_02 i.wave [pweight = phw] if country == 4
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S5 Uganda Behavior 2) label
	
	reg				bh_03 i.wave [pweight = phw] if country == 4		
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S5 Uganda Behavior 3) label	
		
* **********************************************************************
* 1d - create tables S6-S7 for Fig. 1D
* **********************************************************************

preserve
		
	local myth		 myth_01 myth_02 myth_03 myth_04 myth_05
	
	foreach v in `myth' {
	    replace 		`v' = . if `v' == 3
	}	

*** table S6 ***
	
* lemon and alcohol can be used as sanitizers against coronavirus
	reg 			myth_01 i.country [pweight = phw]
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S6 Lemon and alcohol) label
	
* africans are immune to corona virus
	reg 			myth_02 i.country [pweight = phw]
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S6 Africans immune) label
* corona virus does not affect children
	reg 			myth_03 i.country [pweight = phw]
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S6 Not affect children) label
	
* corona virus cannot survive in warm weather
	reg 			myth_04 i.country [pweight = phw]
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S6 Survive warm weather) label
	
* corona virus is just common flu
	reg 			myth_05 i.country [pweight = phw]
	outreg2 		using "paper\intermediate\Supplementary_Materials_Excel_Tables_Reg_Results", append excel dec(3) ctitle(S6 Common flu) label

*** table S7 ***

* totals by myths
	total 			myth_01  [pweight = phw], over(country)
	total 			myth_02  [pweight = phw], over(country)
	total 			myth_03  [pweight = phw], over(country)
	total 			myth_04  [pweight = phw], over(country)
	total 			myth_05  [pweight = phw], over(country)
	
restore

	
* **********************************************************************
* 2 - create tables for Fig. 2
* **********************************************************************


* **********************************************************************
* 2a - create Table S8-S10 for Fig. 2A
* **********************************************************************

*** table S8 ***
* summary statistics on losses of income
	mean 			dwn [pweight = phw] if wave == 1 
	mean 			farm_dwn [pweight = phw] if wave == 1 
	mean 			bus_dwn [pweight = phw] if wave == 1 
	mean 			wage_dwn [pweight = phw] if wave == 1 
	mean 			remit_dwn [pweight = phw] if wave == 1  
	mean			other_dwn [pweight = phw]  if wave == 1 


*** table S9 ***				
* regressions for cross-country comparisons 
					
* regressions for income loss: farm 
	reg 			farm_dwn ib(2).country [pweight = hhw] if wave == 1 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: business  
	reg 			bus_dwn ib(2).country [pweight = hhw] if wave == 1 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: wage   
	reg 			wage_dwn ib(2).country [pweight = hhw] if wave == 1 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: remittances   
	reg 			remit_dwn ib(2).country [pweight = hhw] if wave == 1 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: other   
	reg 			other_dwn ib(2).country [pweight = hhw] if wave == 1 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

*** table s10 ***
* regressions comparing rural urban, controlling for country

* regressions for income loss: farm 
	reg 			farm_dwn i.sector ib(2).country [pweight = hhw] if wave == 1
	
* regressions for income loss: business 
	reg 			bus_dwn i.sector ib(2).country [pweight = hhw] if wave == 1
	
* regressions for income loss: wage  
	reg 			wage_dwn i.sector ib(2).country [pweight = hhw] if wave == 1
	
* regressions for income loss: wage  
	reg 			remit_dwn i.sector ib(2).country [pweight = hhw] if wave == 1
	
* regressions for income loss: wage  
	reg 			other_dwn i.sector ib(2).country [pweight = hhw] if wave == 1
	

* **********************************************************************
* 2b - create Table S11 for Fig. 2B
* **********************************************************************

preserve 

	drop if bus_emp_inc == -99
	drop if bus_emp_inc == -98

* regression for business revenue loss - by country and wave 
	ologit bus_emp_inc i.wave ib(2).country [pweight = phw]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country	
		
* Wald test for differences between other wave
		test 			2.wave = 3.wave 

restore 


* **********************************************************************
* 2c - create Table S12-S14 for Fig. 2C
* **********************************************************************

*** table s12 ***
* summary statistics on moderate and severe food insecurity: means and totals

preserve
	
	drop if country == 1 & wave == 2
	drop if country == 2 & wave == 1
	
* means of food insecurity status 	
	mean p_mod [pweight = wt_18] 
	mean p_sev [pweight = wt_18] 
	mean p_mod [pweight = wt_18], over (country) 
	mean p_sev [pweight = wt_18], over (country) 
	
* totals of food insecurity status 	
	total p_mod [pweight = wt_18] 
	total p_sev [pweight = wt_18] 
	total p_mod [pweight = wt_18], over (country)  
	total p_sev [pweight = wt_18], over (country)  
	
restore 
	
*** table s13 ***
preserve
	
	drop if country == 1 & wave == 2
	drop if country == 2 & wave == 1

* regression for moderate food insecurity 
	reg p_mod ib(5).quint ib(2).country [pweight = wt_18]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country	

*** table s14 ***		
* regression for moderate food insecurity 
	reg p_sev ib(5).quint ib(2).country [pweight = wt_18]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country	
					
restore 
	

* **********************************************************************
* 2D - create Table S15 for Fig. 2C
* **********************************************************************

*** table s15 ***
* regression for concerns and food insecurity: moderate  	

preserve
	
	drop if			country == 2 & wave == 1
	
	reg p_mod concern_01 concern_02 ib(5).quint ib(2).country [pweight = wt_18]
	
* Wald test for differences between other countries
		test			1.country = 4.country
		
restore 

*** table s16 ***
* regression for concerns and food insecurity: severe  	

preserve
	
	drop if			country == 2 & wave == 1
	
	reg p_sev concern_01 concern_02 ib(5).quint ib(2).country [pweight = wt_18]
	
* Wald test for differences between other countries
		test			1.country = 4.country
		
restore 


*** table s17 ***
* summary statistics for concerns 

preserve
	
	drop if			country == 2 & wave == 1
	
	total concern_01 [pweight = wt_18]
	total concern_02 [pweight = wt_18]		
	total concern_01 [pweight = wt_18], over (country)  
	total concern_02 [pweight = wt_18], over (country)  			
	
restore 


*** figure s1 ***

preserve

	drop if			country == 2 & wave == 1

	gen				p_mod_01 = p_mod if quint == 1
	gen				p_mod_02 = p_mod if quint == 2
	gen				p_mod_03 = p_mod if quint == 3
	gen				p_mod_04 = p_mod if quint == 4
	gen				p_mod_05 = p_mod if quint == 5

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


*** table s20 ***
* regression for concern 1, by quintile and country 

preserve
	
	drop if			country == 2 & wave == 1
	
	reg concern_01 ib(5).quint ib(2).country [pweight = wt_18]
	
* Wald test for differences between other countries
		test			1.country = 4.country
		
restore 


*** table s21 ***

preserve
	
	drop if			country == 2 & wave == 1
	
	reg concern_02 ib(5).quint ib(2).country [pweight = wt_18]
	
* Wald test for differences between other countries
		test			1.country = 4.country
		
restore 


* **********************************************************************
* 3 - create tables for Fig. 3
* **********************************************************************


* **********************************************************************
* 3a - create Table S22-S24 for Fig. 3A
* **********************************************************************

*** table s22 ***
preserve

	drop if country == 1 & wave == 1
	drop if country == 1 & wave == 2
	drop if country == 3 & wave == 1

	replace			cope_03 = 1 if cope_03 == 1 | cope_04 == 1
	replace			cope_05 = 1 if cope_05 == 1 | cope_06 == 1 | cope_07 == 1

* total and mean for any
	total cope_any [pweight = hhw]
	mean cope_any [pweight = hhw]

* total and mean for relied on savings
	total cope_11 [pweight = hhw]
	mean cope_11 [pweight = hhw]

* total and mean for sale of assets
	total cope_01 [pweight = hhw]
	mean cope_01 [pweight = hhw]

* total and mean for reduced food consumption
	total cope_09 [pweight = hhw]
	mean cope_09 [pweight = hhw]

* total and mean for reduced non_food consumption
	total cope_10 [pweight = hhw]
	mean cope_10 [pweight = hhw]

* total and mean for received assistance from friends & family
	total cope_03 [pweight = hhw]
	mean cope_03 [pweight = hhw]

* total and mean for recieved any assistance
	total asst_any [pweight = hhw]
	mean asst_any [pweight = hhw]

*** table S23 ***				
* regressions for cross-country comparisons 
					
* regressions for relied on savings
	reg 			cope_11 ib(2).country [pweight = hhw]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for sale of assets
	reg 			cope_01 ib(2).country [pweight = hhw]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for reduced food consumption 
	reg 			cope_09 ib(2).country [pweight = hhw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for reduced non_food consumption
	reg 			cope_10 ib(2).country [pweight = hhw]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for received assistance from friends & family  
	reg 			cope_03 ib(2).country [pweight = hhw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for recieved any assistance
	reg 			asst_any ib(2).country [pweight = hhw]
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country
		
		
*** table s24 ***
* regressions comparing rural urban

* regressions for relied on savings
	reg 			cope_11 i.sector ib(2).country [pweight = hhw]

* regressions for sale of assets
	reg 			cope_01 i.sector ib(2).country [pweight = hhw]

* regressions for reduced food consumption 
	reg 			cope_09 i.sector ib(2).country [pweight = hhw]

* regressions for reduced non_food consumption
	reg 			cope_10 i.sector ib(2).country [pweight = hhw]

* regressions for received assistance from friends & family 
	reg 			cope_03 i.sector ib(2).country [pweight = hhw]

* regressions for recieved any assistance 
	reg 			asst_any i.sector ib(2).country [pweight = hhw]
	
restore


* **********************************************************************
* 3b - create Table S25-S26 for Fig. 3B
* **********************************************************************

*** table s25 ***
* table of means and totals

* total and mean for access to medicine
	total ac_med [pweight = phw] if wave == 1
	mean ac_med [pweight = phw] if wave == 1

* total and mean for access to staple
	total ac_staple [pweight = phw] if wave == 1
	mean ac_staple [pweight = phw] if wave == 1

* total and mean for access to soap
	total ac_soap [pweight = phw] if wave == 1
	mean ac_soap [pweight = phw] if wave == 1

*** table s26 ***
* regressions across quintiles

* regression on access to medicine
	reg			ac_med i.quint [pweight = phw] if wave == 1

* regression on access to staple
	reg			ac_staple i.quint [pweight = phw] if wave == 1
	
* regression on access to soap
	reg			ac_soap i.quint [pweight = phw] if wave == 1


* **********************************************************************
* 3c - create Table S25-S26 for Fig. 3C
* **********************************************************************


mean sch_child [pweight = shw] if wave == 1

mean edu_act [pweight = shw] if wave == 1

mean edu_cont [pweight = shw] if wave == 1

* **********************************************************************
* 3d - create Table S ... for Fig. 3D
* **********************************************************************


/*END*/