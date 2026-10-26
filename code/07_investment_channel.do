// Effacer toutes les données et désactiver la fonction "more"
clear all

// Définir le répertoire de travail
cd "C:\Users\massa\Desktop\Repli\data\"

// Créer un dossier pour les résultats

local resultpath "C:\Users\massa\Desktop\Repli\resultats\"

// Charger la base de données BRI
use imputed_data_base4.dta, clear

// Fusionner avec les données de probabilité de recevoir une aide
merge 1:1 country_iso3 year using prob_receive_aid_new.dta
drop _merge

// Fusionner avec les données des régions
merge m:m country_iso3 using coutry_region_iso.dta
drop _merge

// Créer un identifiant de groupe pour chaque pays
egen country_id = group(country_iso3)

// Créer des effets fixes annuels
tab year, gen(yr)
sort country_id year

// Définir les données en tant que panel
xtset country_id year
xtdes

**********************************************************************

// Définir des ensembles de contrôles
global c11 log_saving_per_cap
global c12 log_saving_per_cap log_FDI_per_cap log_trade_precap
global c13 log_saving_per_cap log_FDI_per_cap log_trade_precap log_primaryse
global c14 log_saving_per_cap log_FDI_per_cap log_trade_precap log_primaryse log_inflation rle

*****************************************************************************

// EFFET DU BRI SUR LES COVARIATES 
// ICI NOUS VOULONS VOIR SI L'EFFET PASSE PAR LA FBCF 
** Within  

// Régression avec effets fixes pour log_FBCF_per_cap2 et log_bri_per_capita
eststo: xtreg log_FBCF_per_cap2 log_bri_per_capita yr*, fe r cluster(country_id)
estimate store fe1

eststo: xtreg log_FBCF_per_cap2 log_bri_per_capita $c11 yr*, fe r cluster(country_id)
estimate store fe2

eststo: xtreg log_FBCF_per_cap2 log_bri_per_capita $c12 yr*, fe r cluster(country_id)
estimate store fe3

eststo: xtreg log_FBCF_per_cap2 log_bri_per_capita $c13 yr*, fe r cluster(country_id)
estimate store fe4

eststo: xtreg log_FBCF_per_cap2 log_bri_per_capita $c14 yr*, fe r cluster(country_id)
estimate store fe5

// Exporter les résultats des régressions avec effets fixes pour FBCF
esttab fe1 fe2 fe3 fe4 fe5 using "`resultpath'TABREG_FBCF_per_cap1.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5") b(3) se(3) style(tex) drop(yr*) booktabs replace

**********  AB 

// Modèle dynamique Arellano-Bond pour log_GDPpercap et log_FBCF_per_cap2
eststo: xtabond2 log_GDPpercap l.log_FBCF_per_cap2 log_bri_per_capita yr*, gmmstyle(log_GDPpercap, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle(yr*, p) noleveleq robust nodiffsargan
estimate store AB1

// Modèles dynamiques Arellano-Bond pour log_FBCF_per_cap2 avec divers ensembles de contrôles
eststo: xtabond2 log_FBCF_per_cap2 l.log_FBCF_per_cap2 log_bri_per_capita $c11 yr*, gmmstyle(log_FBCF_per_cap2, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c11 yr*, p) noleveleq robust nodiffsargan
estimate store AB2

eststo: xtabond2 log_FBCF_per_cap2 l.log_FBCF_per_cap2 log_bri_per_capita $c12 yr*, gmmstyle(log_FBCF_per_cap2, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c12 yr*, p) noleveleq robust nodiffsargan
estimate store AB3

eststo: xtabond2 log_FBCF_per_cap2 l.log_FBCF_per_cap2 log_bri_per_capita $c13 yr*, gmmstyle(log_FBCF_per_cap2, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c13 yr*, p) noleveleq robust nodiffsargan
estimate store AB4

eststo: xtabond2 log_FBCF_per_cap2 l.log_FBCF_per_cap2 log_bri_per_capita $c14 yr*, gmmstyle(log_FBCF_per_cap2, laglimits(1 1)) gmmstyle(log_bri_per_capita, laglimits(1 1)) ivstyle($c14 yr*, p) noleveleq robust nodiffsargan
estimate store AB5

// Exporter les résultats des modèles dynamiques Arellano-Bond
esttab AB1 AB2 AB3 AB4 AB5 using "`resultpath'TABLEABf.tex", se star(* 0.10 ** 0.05 *** 0.01) mtitles("1" "2" "3" "4" "5") b(3) se(3) style(tex) drop(yr*) booktabs replace
