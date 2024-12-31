*****************************************************************************************************
						* Auteur :	MASSAOUDOU NAMATA ABDOUL  WAHID 							
						* Date   :	11/2023
						* 
*****************************************************************************************************
						
// Clear all data and turn off the "more" feature
clear all
set more off, permanently

// Set the working directory to the specified path
cd "C:\Users\massa\Desktop\MAG 3\MEmoire\Data\AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0\AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0"


// Close the log file if it's open and continue logging
capture log close

use AidDatasGlobalChineseDevelopmentFinance2.dta , clear // Load the BRI dataset

rename AidDataRecordID id

// Merge the datasets using a many-to-many match on 'country_iso3' and 'year'

* merge with country coode 
merge 	m:m id using GCDF_3_0_ADM2_Locations.dta



