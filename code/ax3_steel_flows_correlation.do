

*****************************************************************************************************
						* Auteur :	MASSAOUDOU NAMATA ABDOUL  WAHID 							
						* Date   :	01/2024
						* 
*****************************************************************************************************

*ssc install jb
*ssc install xttest3
*findit esttab
*ssc install outreg2
*ssc install ivreg2
*ssc install ranktest 
*ssc install distinct
*ssc install xtabond2
*ssc install moremata

						
// Clear all data and turn off the "more" feature
clear all
set more off, permanently

// Set the working directory to the specified path
cd "C:\Users\massa\Desktop\Memoire MAG3\data\"

use dta_sum_by_year.dta , clear // Load the BRI dataset

gen log_bri = log(TotalAmount)

rename CommitmentYear year

merge 1:1 year using steel.dta
 
drop if  _merge ==2

gen log_steel = log(steel_production_in_Million_ton)


twoway (scatter log_bri log_steel) (lfit log_bri log_steel ), ///
    title("") ///
    xtitle("") ///
    ytitle("Logarithme des Flux Financiers ") ///
    legend(label(1 "Log PROD STEEL") label(2 "Fit"))

