* Project: WB COVID
* Created on: September 2020 
* Created by: amf
* Edited by: jdm
* Last edit: 3 September 2020 
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

* table S3

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

* table S6
	
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

* table S7

* totals by myths
	total 			myth_01 myth_02 myth_03 myth_04 myth_05 [pweight = phw], over(country)
	
restore

	
* **********************************************************************
* 2 - create tables for Fig. 2
* **********************************************************************
	
	
	
	