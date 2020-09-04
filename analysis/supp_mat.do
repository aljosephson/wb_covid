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
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* restricted travel within country/area
	reg 			gov_02 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* closure of schools
	reg 			gov_04 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* curfew/lockdown
	reg 			gov_05 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country
		
* closure of non-essential businesses
	reg 			gov_06 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* stopping or limiting social gatherings
	reg 			gov_10 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country
	
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
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* avoiding Handshakes/Physical Greetings Reduces Risk of Coronavirus Contract
	reg 			know_02 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* using Masks or Gloves Reduces Risk of Coronavirus Contraction
	reg 			know_03 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* staying at Home Reduces Risk of Coronavirus Contraction
	reg 			know_05 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country
		
* avoiding Crowds and Gatherings Reduces Risk of Coronavirus Contraction
	reg 			know_06 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* mainting Social Distance of at least 1 Meter Reduces Risk of Coronavirus Co
	reg 			know_07 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country


* **********************************************************************
* 1c - create tables S3-S5 for Fig. 1C
* **********************************************************************

* table S3

* handwashed with Soap More Often Since Outbreak
	reg 			bh_01 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* avoided Handshakes/Physical Greetings Since Outbreak
	reg 			bh_02 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* avoided Crowds and Gatherings Since Outbreak
	reg 			bh_03 ib(2).country [pweight = phw] if wave == 1
	
	* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

		
* table S4		
		
* percentage over time for Malawi and Uganda
	mean			bh_01 bh_02 bh_03 [pweight = phw] if country == 2 | ///
						country == 4, over(country wave)
		

* table S5

* regressions of behavior on waves in Malawi
	reg				bh_01 i.wave [pweight = phw] if country == 2 
	
	reg				bh_02 i.wave [pweight = phw] if country == 2 
		
	reg				bh_02 i.wave [pweight = phw] if country == 2 

* regressions of behavior on waves in Uganda
	reg				bh_01 i.wave [pweight = phw] if country == 4
	
	reg				bh_02 i.wave [pweight = phw] if country == 4
		
	reg				bh_02 i.wave [pweight = phw] if country == 4		
		
		
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

* africans are immune to corona virus
	reg 			myth_02 i.country [pweight = phw]

* corona virus does not affect children
	reg 			myth_03 i.country [pweight = phw]

* corona virus cannot survive in warm weather
	reg 			myth_04 i.country [pweight = phw]

* corona virus is just common flu
	reg 			myth_05 i.country [pweight = phw]

* table S7

* totals by myths
	total 			myth_01 myth_02 myth_03 myth_04 myth_05 [pweight = phw], over(country)
	
restore
	
	
* **********************************************************************
* 2 - create tables for Fig. 2
* **********************************************************************
	
* **********************************************************************
* 2a - create Table S8 and S9 for Fig. 2A
* **********************************************************************

* table S8

* summary statistics on losses of income

	preserve
	
	keep if			wave == 1

	total 			dwn farm_dwn bus_dwn wage_dwn remit_dwn ///
						other_dwn [pweight = phw], over (country)

	mean 			dwn farm_dwn bus_dwn wage_dwn remit_dwn ///
						other_dwn [pweight = phw], over (country)
						
	restore 

* table S9 					
						
* regressions for income loss: farm 

	reg 			farm_dwn i.sector ib(2).country [pweight = phw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: business  

	reg 			bus_dwn i.sector ib(2).country [pweight = phw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: wage   

	reg 			wage_dwn i.sector ib(2).country [pweight = phw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: remittances   

	reg 			remit_dwn i.sector ib(2).country [pweight = phw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country

* regressions for income loss: other   

	reg 			other_dwn i.sector ib(2).country [pweight = phw] 
	
* Wald test for differences between other countries
		test			1.country = 3.country
		test			1.country = 4.country
		test			3.country = 4.country


* **********************************************************************
* 2b - create Table S10 AND for Fig. 2B
* **********************************************************************




	
	