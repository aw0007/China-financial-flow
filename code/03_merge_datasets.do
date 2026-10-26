 *****************************************************************************************************
						* Auteur :	MASSAOUDOU NAMATA ABDOUL  WAHID 							
						* Date   :	11/2023
						* 
*****************************************************************************************************
						
// Clear all data and turn off the "more" feature
clear all
set more off, permanently

// Set the working directory to the specified path
cd "C:/Users/massa/Desktop/Repli/data/"


// Close the log file if it's open and continue logging
capture log close

use dta_sum_by_dta_by_country_year_year3.dta , clear // Load the BRI dataset



// Merge the datasets using a many-to-many match on 'country_iso3' and 'year'

rename RecipientISO3 country_iso3
rename CommitmentYear year
rename Recipient country_en


duplicates report country_iso3 year


// Merge with the savings datata base 

merge 	1:1 country_iso3 year using savings1.dta

// after the merge the main not mached from using the saving data was observation for 2022 and 2023 that i dont have for those country in the svaing data base . nevertheleess for afganistan we odnt have data in savings database 

drop if _merge == 2

drop _merge

*bri + savings + FDI
merge 1:1 country_iso3 year using FDI.dta

*tab country_en year if _merge == 1 

// on the 50 not merge from bri + savings , 47 was about 2023 year data that are not available for fdi database the remain 3 not macthed was for cuba in 2005  2014 AND 2018BECAUS we dont have fdi for this country 

drop if _merge == 2

drop _merge


*bri + savings + FDI + gdp per capita
merge 1:1 country_iso3 year using GDP_per_cap.dta

*tab  country_en  year if _merge == 1 

drop if _merge == 2

drop _merge


merge 1:1 country_iso3 year using GDP_current.dta

*tab  country_en  year if _merge == 1 

drop if _merge == 2

drop _merge



*bri + savings + FDI + gdp per capita + GCF

merge 1:1 country_iso3 year using GFCF_all.dta

drop if _merge == 2

drop _merge


*bri + savings + FDI + gdp per capita + GCF +trade

merge 1:1 country_iso3 year using trade.dta

drop if _merge == 2

drop _merge


*bri + savings + FDI + gdp per capita + GCF +trade +PLD


merge 1:1 country_iso3 year using pwt10012.dta

drop if _merge == 2

drop _merge



*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary 
merge 1:1 country_iso3 year using primary_se.dta

drop if _merge == 2

drop _merge



*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary + secondary

merge 1:1 country_iso3 year using secondary_se.dta

drop if _merge == 2

drop _merge


*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary + secondary + wgi

merge 1:1 country_iso3 year using wgidataset2.dta

drop if _merge == 2

drop _merge


*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary + secondary + chinapolidemo

merge 1:1 country_en year using chinapolidemo.dta

drop if _merge == 2

drop _merge

*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary + secondary + chinapolidemo + geodist 

merge m:m country_iso3 using GEODIST.dta


*tab  country_en  year if _merge == 1 

*Romania Montenegro  Serbia  are NOT IN THE BASE GEO DIST

drop if _merge == 2

drop _merge


drop scholarships confucius_classrooms sister_cities_established     ambassador_op_eds journalist_visits outbound_chinese_students inbound_students_to_china expert_deployments joint_resource_developments  training_programs  


*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary + secondary + chinapolidemo + geodist + population

merge 1:1 country_iso3 year using population.dta

drop if _merge == 2

drop _merge


*bri + savings + FDI + gdp per capita + GCF +trade +PLD + primary + secondary + chinapolidemo + geodist  + population + inflation 

merge 1:1 country_iso3 year using inflation.dta

drop if _merge == 2

drop _merge

* finance
merge 1:1 country_iso3 year using finance.dta

drop if _merge == 2

drop _merge


* labor
merge 1:1 country_iso3 year using labor.dta

drop if _merge == 2

drop _merge


* steel production 
merge m:m year using steel.dta

drop if _merge == 2

drop _merge

gen steel_prod = steel_production_in_Million_ton * 1000000

gen log_steel_pro = log(steel_prod)

* Conversion de la production d'acier en pourcentage du PIB
gen steel_percent_GDP = (steel_production_in_Million_ton * 1000000 / GDP_curentus) * 100

* Conversion de la production d'acier par habitant (en tonnes)
gen steel_per_capita = (steel_production_in_Million_ton * 1000000) / Population

* Logarithme de la production d'acier en pourcentage du PIB
gen log_steel_percent_GDP = log(steel_percent_GDP)

* Logarithme de la production d'acier par habitant
gen log_steel_per_capita = log(steel_per_capita)


label variable totalAmountyc "Montant total consentit pour l'investement"


label variable  GDPpercap  "GDP per capita (current US$)"

*label variable Gross_Fixed_CF "Formation Brute du Capital Fixe (% of GDP)"

label variable FDI_flows "FDI net inflows (% of GDP)"

rename savings_percent_gdp saving

label variable saving "Gross Domestic Savings (%of GDP)"

*label variable investment "Net investment in nonfinancial assets (% of GDP)


label variable Gross_Fixed_CF "Gross fixed capital formation (% of GDP)"

label variable trade_MX "Trade (import + export) (% of GDP)"

label variable primaryse "School enrollment rate, primary (% gross)"

label variable secondaryse "School enrollment rate, secondary (% gross)"

label variable confucius_institutes "Confucius Institutes (CIs) are non-profit, but government-operated organizations with the mandate to promote Chinese language and culture"

label variable content_sharing_partnerships "Number of new content sharing partnerships established in a country in a given year"

gen bri_per_gdp = totalAmountyc/GDP_curentus * 100

label variable bri_per_gdp "Montant total consentit pour l'investement en pourcentage du pib"
 


* BRI
gen bri_per_capita = totalAmountyc/Population
gen log_bri_per_capita = ln(bri_per_capita)
gen log_bri_per_gdp = log(bri_per_gdp)
gen logbri = log(totalAmountyc)

*gen log_VA_usd_per_gdp = log(VA_usd_per_gdp



* TRADE
gen log_trade_MX = log(trade_MX)
gen trade = trade_MX*GDP_curentus/100
gen trade_precap = trade/Population
gen log_trade_precap = log(trade_precap)
gen log_trade = log(trade)


* FBCF
gen Gross_Fixed_CF_current = Gross_Fixed_CF*GDP_curentus/100
gen Gross_Fixed_CF_per_cap = Gross_Fixed_CF_current/Population
gen log_FBCF_per_cap = log(Gross_Fixed_CF_per_cap)
gen log_FBCF_Per_GDP = log(Gross_Fixed_CF)
gen log_FBCF = log(Gross_Fixed_CF_current)


* FBCF-BRI
gen Gross_Fixed_CF_per_cap2 = Gross_Fixed_CF_per_cap - bri_per_capita
gen log_FBCF_per_cap2 = log(Gross_Fixed_CF_per_cap2)



*saving
gen savings_current = saving*GDP_curentus/100
gen saving_per_cap = savings_current/Population
gen log_saving_per_cap = log(saving_per_cap)
gen log_saving_per_gdp = log(saving)
gen log_saving = log(savings_current)



* FDI 
gen FDI_flows_cur = FDI_flows*GDP_curentus/100
gen FDI_flows_percap = FDI_flows_cur/Population
gen log_FDI_per_cap = log(FDI_flows_percap)
gen log_FDI_flows = log(FDI_flows)
gen log_FDI =log(FDI_flows_cur)

*GDP
gen log_GDPpercap = log(GDPpercap)
gen loggdp = log(GDP_curentus)
gen log_primaryse = log(primaryse)
gen log_secondaryse = log(secondaryse)


* FINANCING 
gen financing_cr = financing*GDP_curentus/100
gen log_financing = log(financing_cr)
gen financing_per_cap = financing_cr/Population
gen log_financing_per_cap = log(financing_per_cap)
gen log_financing_per_gdp = log(financing)

* Population
gen log_population = log(Population)
gen log_inflation = log(inflation)


* distance 
gen log_distw = log(distw)


foreach var in confucius_institutes  outbound_political_visits inbound_political_visits broader_cadre_visits ccp_visits {
    tostring `var', replace
    replace `var' = "" if `var' == "N/A"
    destring `var', replace ignore("N/A")
}

destring confucius_institutes outbound_political_visits inbound_political_visits broader_cadre_visits ccp_visits, replace 


gen log_inbound_political_visits = log(inbound_political_visits)

gen log_rle = log(rle)

gen log_ctfp = log(ctfp)

* Region


merge m:m country_iso3 using coutry_code.dta

drop if _merge == 2

drop _merge

merge m:m country_iso3 using coutry_region_iso.dta

drop if _merge == 2

drop _merge


*save briaiddata_savings_FDI_gdppercapita_investement_gcf_trade_PLD_primary_secondary_wgi_chinapolidemo_geodist1.dta, replace

save BASE2.dta,replace



