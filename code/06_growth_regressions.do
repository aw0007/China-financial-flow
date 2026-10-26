/*****************************************************************************************************
* Auteur :	MASSAOUDOU NAMATA ABDOUL  WAHID
* Date   :	01/2024
*****************************************************************************************************/

// Installer les packages nécessaires
*ssc install jb
*ssc install xttest3
*findit esttab
*ssc install outreg2
*ssc install ivreg2
*ssc install ranktest 
*ssc install distinct
*ssc install xtabond2
*ssc install moremata

// Effacer toutes les données et désactiver la fonction "more"
clear all
set more off, permanently

// Définir le répertoire de travail
cd "C:\Users\massa\Desktop\Repli\data\"

// Créer un dossier pour les résultats

local resultpath "C:\Users\massa\Desktop\Repli\resultats\"

// Charger la base de données BRI
use imputed_data_base2.dta, clear

// Fusionner avec les données de probabilité de recevoir une aide
merge 1:1 country_iso3 year using prob_receive_aid_new.dta
drop _merge

// Fusionner avec les données des régions
merge m:m country_iso3 using coutry_region_iso.dta
drop _merge

// Sauvegarder la base de données fusionnée
save imputed_data_base3.dta, replace

// Créer un identifiant de groupe pour chaque pays
egen country_id = group(country_iso3)

// Créer des effets fixes annuels
tab year, gen (yr)
sort country_id year

// Définir les données en tant que panel
xtset country_id year
xtdes

********************************************************************************
***************************   LOG PAR TETE   ***********************************
*******************************************************************************

// Calculer les corrélations (non tabulées) entre les variables
pwcorr log_GDPpercap log_bri_per_capita log_saving_per_cap log_FBCF_per_cap log_FDI_per_cap log_trade_precap log_primaryse log_population log_inflation rle log_steel_per_capita, sig sta(.005)

// Créer des graphiques individuels avec étiquettes d'axes mais sans légende
graph twoway (scatter log_GDPpercap log_bri_per_capita, msymbol(circle_hollow)) (lfit log_GDPpercap log_bri_per_capita), name(g1, replace) legend(off) xtitle("BRI") ytitle("GDP")
graph twoway (scatter log_saving_per_cap log_bri_per_capita, msymbol(circle_hollow)) (lfit log_GDPpercap log_bri_per_capita), name(g2, replace) legend(off) xtitle("BRI") ytitle("SAVING")
graph twoway (scatter log_FBCF_per_cap log_bri_per_capita, msymbol(circle_hollow)) (lfit log_FBCF_per_cap log_bri_per_capita), name(g3, replace) legend(off) xtitle("BRI") ytitle("FBCF")

// Combiner les graphiques dans une grille
graph combine g1 g2 g3, cols(3) name(combined, replace)

// Sauvegarder le graphique combiné
graph export "`resultpath'BRI_VS_COVARIATESimp.png", as(png) replace

// Créer des variables globales pour les ensembles de contrôles
global c1 log_saving_per_cap 
global c2 log_saving_per_cap log_FBCF_per_cap 
global c3 log_saving_per_cap log_FBCF_per_cap log_FDI_per_cap log_trade_precap
global c4 log_saving_per_cap log_FBCF_per_cap log_FDI_per_cap log_trade_precap log_primaryse 
global c5 log_saving_per_cap log_FBCF_per_cap log_FDI_per_cap log_trade_precap log_primaryse log_inflation rle

// Estimer l'effet de la BRI sur le PIB par tête avec effets fixes
eststo: xtreg log_GDPpercap log_bri_per_capita yr*, fe r cluster(country_id)
estimate store fe1

eststo: xtreg log_GDPpercap log_bri_per_capita $c1 yr*, fe r cluster(country_id)
estimate store fe2

eststo: xtreg log_GDPpercap log_bri_per_capita $c2 yr*, fe r cluster(country_id)
estimate store fe3

eststo: xtreg log_GDPpercap log_bri_per_capita $c3 yr*, fe r cluster(country_id)
estimate store fe4

eststo: xtreg log_GDPpercap log_bri_per_capita $c4 yr*, fe r cluster(country_id)
estimate store fe5

eststo: xtreg log_GDPpercap log_bri_per_capita $c5 yr*, fe r cluster(country_id)
estimate store fe6

// Exporter les résultats des régressions avec effets fixes
esttab fe1 fe2 fe3 fe4 fe5 fe6 using "`resultpath'TABREGwithin1imp.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex) drop(yr*) booktabs replace

// Créer une variable instrumentale pour l'analyse IV
gen Z=log_steel_per_capita*prob_receive_aid

// Estimer l'effet de la BRI sur le PIB par tête avec IV
xtivreg2 log_GDPpercap (log_bri_per_capita = Z), fe robust
estimate store Steel1

xtivreg2 log_GDPpercap (log_bri_per_capita = Z) $c1, fe robust
estimate store Steel2

xtivreg2 log_GDPpercap (log_bri_per_capita = Z) $c2, fe robust
estimate store Steel3

xtivreg2 log_GDPpercap (log_bri_per_capita = Z) $c3, fe robust
estimate store Steel4

xtivreg2 log_GDPpercap (log_bri_per_capita = Z) $c4, fe robust
estimate store Steel5

xtivreg2 log_GDPpercap (log_bri_per_capita = Z) $c5, fe robust
estimate store Steel6

// Exporter les résultats des régressions IV
esttab Steel1 Steel2 Steel3 Steel4 Steel5 Steel6 using "`resultpath'TABLEABSteelxtiv2imp.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex) booktabs replace

// Estimer un modèle dynamique Arellano-Bond
eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle(yr*, p) noleveleq robust nodiffsargan
estimate store AB1

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c1 yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c1 yr*, p) noleveleq robust nodiffsargan
estimate store AB2

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c2 yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c2 yr*, p) noleveleq robust nodiffsargan
estimate store AB3

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c3 yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c3 yr*, p) noleveleq robust nodiffsargan
estimate store AB4

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c4 yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c4 yr*, p) noleveleq robust nodiffsargan
estimate store AB5

eststo: xtabond2 log_GDPpercap l.log_GDPpercap log_bri_per_capita $c5 yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c5 yr*, p) noleveleq robust nodiffsargan
estimate store AB6

// Exporter les résultats des régressions Arellano-Bond
esttab AB1 AB2 AB3 AB4 AB5 AB6 using "`resultpath'TABLEABimp.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex) drop(yr*) booktabs replace

// Créer des moyennes sur 5 ans pour les variables
g avgL5lnGDPpc = (log_GDPpercap + l.log_GDPpercap + l2.log_GDPpercap + l3.log_GDPpercap + l4.log_GDPpercap) / 5
g avgL5log_bri_per_capita = (log_bri_per_capita + l.log_bri_per_capita + l2.log_bri_per_capita + l3.log_bri_per_capita + l4.log_bri_per_capita) / 5
g avgL5Z = (Z + l.Z + l2.Z + l3.Z + l4.Z) / 5

// Estimer les modèles avec des moyennes sur 5 ans
eststo: xtreg F4.avgL5lnGDPpc avgL5log_bri_per_capita yr*, fe r cluster(country_id)
estimate store fe51

eststo: xtreg F4.avgL5lnGDPpc avgL5log_bri_per_capita $c1 yr*, fe r cluster(country_id)
estimate store fe52

eststo: xtreg F4.avgL5lnGDPpc avgL5log_bri_per_capita $c2 yr*, fe r cluster(country_id)
estimate store fe53

eststo: xtreg F4.avgL5lnGDPpc avgL5log_bri_per_capita $c3 yr*, fe r cluster(country_id)
estimate store fe54

eststo: xtreg F4.avgL5lnGDPpc avgL5log_bri_per_capita $c4 yr*, fe r cluster(country_id)
estimate store fe55

eststo: xtreg F4.avgL5lnGDPpc avgL5log_bri_per_capita $c5 yr*, fe r cluster(country_id)
estimate store fe56

// Exporter les résultats des régressions avec moyennes sur 5 ans
esttab fe51 fe52 fe53 fe54 fe55 fe56 using "`resultpath'TABREGAVG5imp.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex) drop(yr*) booktabs replace

// Estimer les modèles IV avec des moyennes sur 5 ans
xtivreg2 F4.avgL5lnGDPpc avgL5log_bri_per_capita (avgL5log_bri_per_capita = avgL5Z), fe robust
estimate store Steel1

xtivreg2 F4.avgL5lnGDPpc avgL5log_bri_per_capita (avgL5log_bri_per_capita = avgL5Z) $c1, fe robust
estimate store Steel2

xtivreg2 F4.avgL5lnGDPpc avgL5log_bri_per_capita (avgL5log_bri_per_capita = avgL5Z) $c2, fe robust
estimate store Steel3

xtivreg2 F4.avgL5lnGDPpc avgL5log_bri_per_capita (avgL5log_bri_per_capita = avgL5Z) $c3, fe robust
estimate store Steel4

xtivreg2 F4.avgL5lnGDPpc avgL5log_bri_per_capita (avgL5log_bri_per_capita = avgL5Z) $c4, fe robust
estimate store Steel5

xtivreg2 F4.avgL5lnGDPpc avgL5log_bri_per_capita (avgL5log_bri_per_capita = avgL5Z) $c5, fe robust
estimate store Steel6

// Exporter les résultats des régressions IV avec moyennes sur 5 ans
esttab Steel1 Steel2 Steel3 Steel4 Steel5 Steel6 using "`resultpath'TABLEABSteelxtiv55imp.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex) booktabs replace

// Estimer les modèles dynamiques Arellano-Bond avec moyennes sur 5 ans
eststo: xtabond2 F4.avgL5lnGDPpc L.avgL5lnGDPpc avgL5log_bri_per_capita yr*, gmmstyle(avgL5lnGDPpc, laglimits(1 1)) gmmstyle(avgL5log_bri_per_capita, laglimits(1 1)) ivstyle(yr*, p) noleveleq robust nodiffsargan
estimate store AB1

eststo: xtabond2 F4.avgL5lnGDPpc L.avgL5lnGDPpc avgL5log_bri_per_capita $c1 yr*, gmmstyle(avgL5lnGDPpc, laglimits(1 1)) gmmstyle(avgL5log_bri_per_capita, laglimits(1 1)) ivstyle($c1 yr*, p) noleveleq robust nodiffsargan
estimate store AB2

eststo: xtabond2 F4.avgL5lnGDPpc L.avgL5lnGDPpc avgL5log_bri_per_capita $c2 yr*, gmmstyle(avgL5lnGDPpc, laglimits(1 1)) gmmstyle(avgL5log_bri_per_capita, laglimits(1 1)) ivstyle($c2 yr*, p) noleveleq robust nodiffsargan
estimate store AB3

eststo: xtabond2 F4.avgL5lnGDPpc L.avgL5lnGDPpc avgL5log_bri_per_capita $c3 yr*, gmmstyle(avgL5lnGDPpc, laglimits(1 1)) gmmstyle(avgL5log_bri_per_capita, laglimits(1 1)) ivstyle($c3 yr*, p) noleveleq robust nodiffsargan
estimate store AB4

eststo: xtabond2 F4.avgL5lnGDPpc L.avgL5lnGDPpc avgL5log_bri_per_capita $c4 yr*, gmmstyle(avgL5lnGDPpc, laglimits(1 1)) gmmstyle(avgL5log_bri_per_capita, laglimits(1 1)) ivstyle($c4 yr*, p) noleveleq robust nodiffsargan
estimate store AB5

eststo: xtabond2 F4.avgL5lnGDPpc L.avgL5lnGDPpc avgL5log_bri_per_capita $c5 yr*, gmmstyle(avgL5lnGDPpc, laglimits(1 1)) gmmstyle(avgL5log_bri_per_capita, laglimits(1 1)) ivstyle($c5 yr*, p) noleveleq robust nodiffsargan
estimate store AB6

// Exporter les résultats des régressions dynamiques Arellano-Bond avec moyennes sur 5 ans
esttab AB1 AB2 AB3 AB4 AB5 AB6 using "`resultpath'TABLEAB5imp.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5" "6") b(3) se(3) style(tex) drop(yr*) booktabs replace
