* Project: WB COVID
* Created on: July 2020
* Created by: jdm
* Stata v.16.1

* does
	* establishes an identical workspace between users
	* sets globals that define absolute paths
	* serves as the starting point to find any do-file, dataset or output
	* runs all do-files needed for data work. ([!] Eventually)
	* loads any user written packages needed for analysis

* assumes
	* access to all data and code

* TO DO:
	* add all do-files


* **********************************************************************
* 0 - setup
* **********************************************************************

* set $pack to 0 to skip package installation
	global 			pack 	0
		
* Specify Stata version in use
    global stataVersion 16.1    // set Stata version
    version $stataVersion

	
* **********************************************************************
* 0 (a) - Create user specific paths
* **********************************************************************


* Define root folder globals
    if `"`c(username)'"' == "jdmichler" {
        global 		code  	"C:/Users/jdmichler/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

    if `"`c(username)'"' == "aljosephson" {
        global 		code  	"C:/Users/aljosephson/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
    }

	if `"`c(username)'"' == "annfu" {
		global 		code  	"C:/Users/annfu/git/wb_covid"
		global 		data	"G:/My Drive/wb_covid/data"
	}
	
	
* **********************************************************************
* 0 (b) - Check if any required packages are installed:
* **********************************************************************

* install packages if global is set to 1
if $pack == 1 {
	
	* for packages/commands, make a local containing any required packages
		loc userpack "blindschemes mdesc estout distinct winsor2 palettes catplot grc1leg2 colrspace" 
	
	* install packages that are on ssc	
		foreach package in `userpack' {
			capture : which `package', all
			if (_rc) {
				capture window stopbox rusure "You are missing some packages." "Do you want to install `package'?"
				if _rc == 0 {
					capture ssc install `package', replace
					if (_rc) {
						window stopbox rusure `"This package is not on SSC. Do you want to proceed without it?"'
					}
				}
				else {
					exit 199
				}
			}
		}

	* install -xfill- package
		net install xfill, replace from(https://www.sealedenvelope.com/)

	* update all ado files
		ado update, update

	* set graph and Stata preferences
		set scheme plotplain, perm
		set more off
}


* **********************************************************************
* 1 - run household data cleaning .do file
* **********************************************************************

	do 			"$code/ethiopia/eth_build.do"			//	builds Ethiopia panel
	do 			"$code/malawi/mwi_build.do"				//	builds Malawi panel
	do 			"$code/nigeria/nga_reshape.do"			//	reshapes Nigeria wide data
	do 			"$code/nigeria/nga_build.do"			//	builds Nigeria panel
	do 			"$code/uganda/uga_build.do"				//	builds Uganda panel
		
* **********************************************************************
* 2 - run analysis .do files
* **********************************************************************

	do			"$code/analysis/covid_data.do"			//  reads in covid data
	do			"$code/analysis/pnl_cleaning.do"		//	builds 4 country panel
*	do			"$code/analysis/analysis_graphs.do"		//	produces graphs in paper
*	do			"$code/analysis/supp_mat.do"			//	produces tables in supplemental material


/* END */