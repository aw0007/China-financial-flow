# Chinese Financial Flows: A Lever for Growth in Recipient Economies?

Abdoul Wahid Massaoudou Namata. Master's thesis, CERDI, Université Clermont Auvergne, June 2024, supervised by Vianney Dequiedt and Simone Bertoli.

We estimate the effect of Chinese financial flows on GDP per capita in 147 recipient countries over 2000 to 2021, with a within estimator, an instrumental variable estimator (China's steel production interacted with each country's probability of receiving Chinese finance) and the Arellano-Bond dynamic panel estimator. We then estimate the effect by region and on domestic investment.

## Contents

| Folder | Contents |
|---|---|
| `code/` | the analysis scripts, numbered in run order |
| `code/maps/` | project maps by sector and continent |
| `output/` | regression tables (`.tex`) and figures (`.png`) produced by the scripts |
| `data/raw/` | the downloaded sources, not in the repository |
| `data/derived/` | files the scripts write and read; only `dta_sum_by_year.dta` is in the repository |
| `paper/` | the paper in English (`main.tex`, `main.pdf`) |

## Data

The raw data are not in the repository. Each source goes in `data/raw/`, under the folder name the scripts use (for AidData, `data/raw/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/`). We use:

| Source | Variables |
|---|---|
| AidData, Global Chinese Development Finance Dataset, Version 3.0 | Chinese financial flows by project, with ADM1 and ADM2 locations |
| AidData, China's Global Public Diplomacy Dashboard Dataset | Chinese public diplomacy |
| World Bank, World Development Indicators | GDP per capita, GDP, gross domestic saving, gross fixed capital formation, net FDI inflows, trade, primary and secondary enrolment, population, inflation, domestic credit, labour force |
| World Bank, Worldwide Governance Indicators | rule of law |
| Penn World Table 10.01 | total factor productivity |
| GGDC Economic Transformation Database | sectoral value added and employment |
| CEPII GeoDist | distance to China |
| `steel.xlsx` | China's annual steel production; the source of this file is to be documented |

## Running the analysis

Run the scripts in this order, from the project root. The scripts find the project through the `.project-root` marker: the R scripts source `code/paths.R`, the do-files run `code/config.do`, and the Python scripts derive the root from their own location. Intermediate files go to `data/derived/`, tables and figures to `output/`.

| Script | Language | Reads | Writes |
|---|---|---|---|
| `00_describe_aiddata.R` | R | AidData | descriptive figures |
| `01_clean_aiddata.Rmd` | R | AidData | `dta_sum_by_dta_by_country_year_year3.dta` |
| `02_clean_covariates.Rmd` | R | World Bank, PWT, ETD, CEPII, steel | one `.dta` per covariate |
| `03_merge_datasets.do` | Stata | outputs of 01 and 02 | `BASE2.dta` |
| `04_descriptive_statistics.do` | Stata | `BASE2.dta` | `prob_receive_aid_new.dta`, descriptive tables |
| `05_impute_missing_data.Rmd` | R | `BASE2.dta` | `imputed_data_base2bis.dta`, `missing_rates1.tex`, heat map |
| `06_growth_regressions.do` | Stata | `imputed_data_base2.dta` | `imputed_data_base3.dta`, annual and five-year tables |
| `06_growth_regressions_without_imputation.do` | Stata | `BASE2.dta` | tables without imputation |
| `06_growth_regressions_without_big4.do` | Stata | `imputed_data_base3.dta` | tables without Russia, Venezuela, Argentina and Indonesia |
| `06a_growth_africa.do`, `06b_growth_americas.do`, `06c_growth_asia.do` | Stata | `imputed_data_base3.dta` | regional tables |
| `07_investment_channel.do` | Stata | `imputed_data_base4.dta` | investment channel table |

Supplementary scripts:

| Script | Language | Purpose |
|---|---|---|
| `ax1_merge_project_locations.do` | Stata | merges AidData projects with their administrative locations |
| `ax3_steel_flows_correlation.do` | Stata | correlation between Chinese steel production and Chinese flows by year |
| `ax4_network_graph.py` | Python | network graph of flows between China and recipient countries |
| `ax5_map_by_country.py` | Python | map of total flows by country |
| `ax6_map_projects.py` | Python | map of geolocated projects |
| `code/maps/` | Python | maps by sector and by continent, project summary statistics |

Three links in this chain are to be verified: `05_impute_missing_data.Rmd` writes `imputed_data_base2bis.dta` while `06_growth_regressions.do` reads `imputed_data_base2.dta`; `imputed_data_base4.dta`, read by `07_investment_channel.do`, and `IGRAPHDATA2.xlsx`, read by `ax4_network_graph.py`, are in `data/derived/` but no script writes them. `code/maps/projects_by_continent.py` maps ACLED conflict events in West Africa and reads `data/raw/acled/`, which is not part of this project's data.

## Software

- R: `tidyverse`, `haven`, `readxl`, `mice`, `VIM`, `ggplot2`, `sf`, `leaflet`, `labelled`, `writexl`, `openxlsx`, `FactoMineR`, `factoextra`.
- Stata: `xtivreg2` (with `ivreg2` and `ranktest`) and `estout` from SSC.
- Python: `pandas`, `geopandas` below 1.0 (`ax5_map_by_country.py` and `ax6_map_projects.py` call `geopandas.datasets`, removed in 1.0), `matplotlib`, `seaborn`, `networkx`, `folium`, `scipy`, `scikit-learn`.

Package versions are not recorded.
