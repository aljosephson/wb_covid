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
* 1a - create tables for Fig. 1A
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
* 1b - create tables for Fig. 1B
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
* 1c - create tables for Fig. 1C
* **********************************************************************



