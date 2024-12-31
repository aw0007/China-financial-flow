
*****************************************************************************************************
*  Author: MASSAOUDOU NAMATA ABDOUL WAHID
*  Date: 01/2024
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
cd "C:\Users\massa\Desktop\Repli\data\"


use BASE2.dta , clear // Load the BRI dataset




egen country_id = group(country_iso3)

tab year, gen (yr)			       //Création des EF annuels
sort country_id year 


xtset country_id year				//Déclaration du panel
xtdes
 

tab country_en

// Count the number of unique countries
distinct country_iso3

// Output the count of unique countries
di "Number of unique countries: `r(ndistinct)'"

// Create a binary variable indicating if the country received aid from China in a given year
gen received_aid = (totalAmountyc > 0)


// Calculate the number of years each country received aid
bysort country_id: egen years_received_aid = total(received_aid)

// Calculate the total number of years in the dataset (2000-2021)
local total_years = 22

// Calculate the probability of receiving aid for each country
gen prob_receive_aid = years_received_aid / `total_years'


// Keep only one observation per country for the probability calculation
*by country_id: keep if _n == 1

keep country_iso3 year prob_receive_aid

// Save the results to a new dataset
save prob_receive_aid_new.dta, replace

use BASE2.dta , clear // Load the  dataset

// Country fixed effect
egen country_id = group(country_iso3)

//Yera fixed effect
tab year, gen (yr)			       
sort country_id year 


// Panel dataset
xtset country_id year				
xtdes


// Missing percentage for all varibles
mdesc log_GDPpercap bri_per_capita log_bri_per_capita saving_per_cap log_saving_per_cap Gross_Fixed_CF_per_cap log_FBCF_per_cap FDI_flows_percap log_FDI_per_cap trade_precap log_trade_precap financing_per_cap log_financing_per_cap primaryse log_primaryse secondaryse log_secondaryse log_population inflation log_inflation rle log_rle ctfp log_ctfp steel_per_capita log_steel_per_capita

// Program for the comand XTSUM2

program define xtsum2, eclass

syntax varlist

foreach var of local varlist {
    xtsum `var'

    tempname mat_`var'
    matrix mat_`var' = J(3, 5, .)
    matrix mat_`var'[1,1] = (`r(mean)', `r(sd)', `r(min)', `r(max)', `r(N)')
    matrix mat_`var'[2,1] = (., `r(sd_b)', `r(min_b)', `r(max_b)', `r(n)')
    matrix mat_`var'[3,1] = (., `r(sd_w)', `r(min_w)', `r(max_w)', `r(Tbar)')
	
    matrix colnames mat_`var'= Mean "Std. Dev." Min Max "N/n/T-bar"
    matrix rownames mat_`var'= `var' " " " "

    local matall `matall' mat_`var'
    local obw `obw' overall between within
}

if `= wordcount("`varlist'")' > 1 {
    local matall = subinstr("`matall'", " ", " \ ",.)
    matrix allmat = (`matall')
    ereturn matrix mat_all = allmat
}
else ereturn matrix mat_all = mat_`varlist'
ereturn local obw = "`obw'"

end


xtsum2 log_GDPpercap log_bri_per_capita log_saving_per_cap log_FBCF_per_cap log_FDI_per_cap log_trade_precap log_financing_per_cap log_primaryse log_secondaryse log_population log_inflation log_rle log_ctfp steel_per_capita
esttab e(mat_all), mlabels(none) labcol2(`e(obw)') varlabels(r2 " " r3 " ") tex


xtsum2 bri_per_capita GDPpercap saving_per_cap Gross_Fixed_CF_per_cap  trade_precap  FDI_flows_percap steel_per_capita primaryse   inflation rle financing_per_cap ctfp
esttab e(mat_all), mlabels(none) labcol2(`e(obw)') varlabels(r2 " " r3 " ") tex