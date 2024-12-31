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
cd "C:\Users\massa\Desktop\Repli\data\"

// Créer un dossier pour les résultats

local resultpath "C:\Users\massa\Desktop\Repli\resultats\"


// Close the log file if it's open and continue logging
capture log close
log using fichier_log.log, text replace   


use imputed_data_base3.dta , clear // Load the BRI dataset


egen country_id = group(country_iso3)

tab year, gen (yr)			       //Création des EF annuels
sort country_id year 


xtset country_id year				//Déclaration du panel
xtdes




********************************************************************************
***************************   LOG PAR TETE   ***********************************
*******************************************************************************


* Créer une nouvelle variable pour compter les pays uniques par région
*bysort region (country_iso3): gen unique = country_iso3[1]

* Créer une variable indiquant la première observation de chaque pays dans chaque région
*by region country_iso3: gen first = _n == 1

* Compter le nombre de premières observations de chaque pays par région
*bysort region: egen num_countries = total(first)

* Garder une seule ligne par région
*bysort region: gen tokeep = _n == 1
*keep if tokeep == 1

* Afficher le résultat
*list region num_countries



**Set of controls

global c1 log_saving_per_cap 

global c2 log_saving_per_cap log_FBCF_per_cap 
 
global c3 log_saving_per_cap log_FBCF_per_cap  log_FDI_per_cap log_trade_precap

global c4 log_saving_per_cap log_FBCF_per_cap  log_FDI_per_cap log_trade_precap  log_primaryse 

global c5 log_saving_per_cap log_FBCF_per_cap  log_FDI_per_cap log_trade_precap  log_primaryse  log_inflation rle



* EFFET SUR DU BRI SUR LE GDP 
** Within  
eststo: xtreg log_GDPpercap  log_bri_per_capita yr* if region == "Africa", fe r cluster(country_id)
estimate store fe1

eststo: xtreg log_GDPpercap  log_bri_per_capita $c1 yr* if region == "Africa", fe r cluster(country_id)
estimate store fe2

eststo: xtreg log_GDPpercap  log_bri_per_capita $c2 yr* if region == "Africa", fe r cluster(country_id)
estimate store fe3

eststo: xtreg log_GDPpercap  log_bri_per_capita $c3 yr* if region == "Africa", fe r cluster(country_id)
estimate store fe4

eststo: xtreg log_GDPpercap   log_bri_per_capita $c4 yr* if region == "Africa", fe r cluster(country_id)
estimate store fe5

eststo: xtreg log_GDPpercap log_bri_per_capita $c5 yr* if region == "Africa", fe r cluster(country_id)
estimate store fe6


esttab fe1 fe2 fe3 fe4 fe5 fe6  using "`resultpath'TABREGwithinAF.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3"  "4" "5" "6") b(3) se(3) style(tex) drop(yr*)booktabs replace


*******************  	IV

gen Z=log_steel_per_capita*prob_receive_aid

xtivreg2 log_GDPpercap  (log_bri_per_capita = Z)  if region == "Africa" ,  fe robust  
estimate store Steel1

xtivreg2 log_GDPpercap  (log_bri_per_capita = Z)  $c1  if region == "Africa", fe robust  
estimate store Steel2


xtivreg2 log_GDPpercap  (log_bri_per_capita = Z)  $c2  if region == "Africa", fe robust  
estimate store Steel3


xtivreg2 log_GDPpercap  (log_bri_per_capita = Z)  $c3 if region == "Africa" , fe robust  
estimate store Steel4

xtivreg2 log_GDPpercap  (log_bri_per_capita = Z)  $c4  if region == "Africa", fe robust  
estimate store Steel5


xtivreg2 log_GDPpercap  (log_bri_per_capita = Z)  $c5 if region == "Africa" , fe robust  
estimate store Steel6


esttab Steel1 Steel2 Steel3 Steel4 Steel5 Steel6  using "`resultpath'TABLEABSteelxtivAF.tex" , se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex)  booktabs replace

**********  AB 

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita yr* if region == "Africa" , gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle( yr*, p) noleveleq robust nodiffsargan
estimate store AB1


eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c1 yr* if region == "Africa" , gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c1 yr*, p) noleveleq robust nodiffsargan
estimate store AB2

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c2 yr* if region == "Africa" , gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c2 yr*, p) noleveleq robust nodiffsargan
estimate store AB3

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c3 yr* if region == "Africa" , gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c3 yr*, p) noleveleq robust nodiffsargan
estimate store AB4

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c4 yr* if region == "Africa" , gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c4 yr*, p) noleveleq robust nodiffsargan
estimate store AB5


eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c5 yr*  if region == "Africa" , gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c5 yr*, p) noleveleq robust nodiffsargan
estimate store AB6



esttab AB1 AB2 AB3 AB4 AB5 AB6  using "`resultpath'TABLEABAF.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4""5" "6") b(3) se(3) style(tex) drop(yr*) booktabs replace




