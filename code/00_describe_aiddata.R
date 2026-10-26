library(readxl)
library(tidyverse)
setwd("C:/Users/massa/Desktop/Repli/data/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/")
# Charger le fichier Excel pour en examiner la structure
file_path <- "AidDatasGlobalChineseDevelopmentFinanceDataset_v3.0 - Copy.xlsx"
data <- read_excel(file_path)

# Afficher les premières lignes du dataframe pour comprendre sa structure
head(data)

# Charger les données de la feuille spécifique "GCDF_3.0"
data_gcdf <- read_excel(file_path, sheet = "GCDF_3.0")

# Afficher les premières lignes du dataframe pour comprendre sa structure
head(data_gcdf)


data_gcdf2 <- data_gcdf %>%
  select( c(
    "Recipient", "Recipient Region", "Commitment Year",
    "Implementation Start Year", "Completion Year", "Flow Type",
    "Sector Name", "Amount (Constant USD 2021)", "OECD ODA Income Group","Sector Name"
  ))

# Filtrer les données pour exclure les lignes avec des valeurs manquantes dans les colonnes pertinentes
data_gcdf2_filtered <- data_gcdf2[complete.cases(data_gcdf2$`Recipient Region`, data_gcdf2$Amount_Millions), ]


# Diviser les montants par 1 million
data_gcdf2_filtered <- data_gcdf2_filtered %>%
  mutate(Amount_Millions = `Amount (Constant USD 2021)` / 1e6)

summary(data_gcdf2_filtered$Amount_Millions)

# Calculer la somme des montants par région
sum_by_region <- data_gcdf2_filtered %>%
  group_by(`Recipient Region`) %>%
  summarize(Total_Amount_Millions = sum(Amount_Millions, na.rm = TRUE)) %>%
  arrange(desc(Total_Amount_Millions))


data_gcdf2=data_gcdf2_filtered
# Afficher les résultats
print(sum_by_region)

# Calculer la somme des montants par pays
sum_by_country <- data_gcdf2 %>%
  group_by(Recipient) %>%
  summarize(Total_Amount_Millions = sum(Amount_Millions, na.rm = TRUE)) %>%
  arrange(desc(Total_Amount_Millions))

# Afficher les cinq pays qui reçoivent le plus
print(head(sum_by_country, 10))



# Afficher les cinq pays qui reçoivent le moins
print(tail(sum_by_country, 5))



# Calculer la somme totale de tous les montants
total_amount <- sum(sum_by_country$Total_Amount_Millions, na.rm = TRUE)

# Extraire les quatre premiers pays
top_4_countries <- head(sum_by_country, 4)

# Calculer le pourcentage relatif des montants des quatre premiers pays
top_4_countries <- top_4_countries %>%
  mutate(Percentage_of_Total = (Total_Amount_Millions / total_amount) * 100)

# Afficher les résultats
print(top_4_countries)

library(dplyr)

# Assurer que les colonnes de l'année sont numériques
data_gcdf2 <- data_gcdf2 %>%
  mutate(
    Commitment_Year = as.numeric(`Commitment Year`),
    Implementation_Start_Year = as.numeric(`Implementation Start Year`),
    Completion_Year = as.numeric(`Completion Year`)
  )

# Calculer les différences en années
data_gcdf2 <- data_gcdf2 %>%
  mutate(
    Commitment_to_Start_Diff = Implementation_Start_Year - Commitment_Year,
    Start_to_Completion_Diff = Completion_Year - Implementation_Start_Year,
    Commitment_to_Completion_Diff = Completion_Year - Commitment_Year
  )

# Calculer la moyenne des différences
average_diffs <- data_gcdf2 %>%
  summarize(
    Average_Commitment_to_Start = mean(Commitment_to_Start_Diff, na.rm = TRUE),
    Average_Start_to_Completion = mean(Start_to_Completion_Diff, na.rm = TRUE),
    Average_Commitment_to_Completion = mean(Commitment_to_Completion_Diff, na.rm = TRUE)
  )

# Afficher les résultats
print(average_diffs)



library(dplyr)

# Calculer la somme des montants par type de flux
sum_by_flow_type <- data_gcdf2 %>%
  group_by(`Flow Type`) %>%
  summarize(Total_Amount_Millions = sum(Amount_Millions, na.rm = TRUE)) %>%
  ungroup() # Retirer le grouping pour calculer la somme totale

# Calculer la somme totale de tous les montants
total_funds <- sum(sum_by_flow_type$Total_Amount_Millions)

# Calculer le pourcentage de chaque type de flux par rapport au total
sum_by_flow_type <- sum_by_flow_type %>%
  mutate(Percentage_of_Total = (Total_Amount_Millions / total_funds) * 100)

# Afficher les résultats avec les pourcentages
print(sum_by_flow_type)



# Calculer la somme des montants par secteur
sum_by_sector <- data_gcdf2 %>%
  group_by(`Sector Name`) %>%
  summarize(Total_Amount_Millions = sum(Amount_Millions, na.rm = TRUE)) %>%
  ungroup()  # Retirer le grouping pour calculer la somme totale

# Calculer la somme totale de tous les montants
total_funds_sector <- sum(sum_by_sector$Total_Amount_Millions)

# Calculer le pourcentage de chaque secteur par rapport au total
sum_by_sector <- sum_by_sector %>%
  mutate(Percentage_of_Total = (Total_Amount_Millions / total_funds_sector) * 100)

print(sum_by_sector, n = 26)



# Création du graphique en barres sans légende avec étiquettes de pourcentages
graph <- ggplot(sum_by_sector, aes(x = reorder(`Sector Name`, -Total_Amount_Millions), y = Percentage_of_Total, fill = `Sector Name`)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = sprintf("%.2f", Percentage_of_Total)), position = position_stack(vjust = 0.5), color = "white", size = 3.5) +
  theme_minimal() +
  labs(title = "Distribution des Financements par Secteur",
       x = "Nom du Secteur",
       y = "Pourcentage du Total (%)") +
  theme(axis.text.x = element_text(size=7,angle = 45, hjust = 1),
        legend.position = "none")  # Suppression de la légende

# Afficher le graphique
print(graph)

# Sauvegarder le graphique dans un fichier
ggsave("sector_funding_distribution_with_labels.png", plot = graph, width = 5, height = 5, dpi = 300)


# Calculer la somme des montants par région
sum_by_year<- data_gcdf2_filtered %>%
  group_by(`Commitment Year`) %>%
  summarize(Total_Amount_Millions = sum(Amount_Millions, na.rm = TRUE)) %>%
  arrange(desc(Total_Amount_Millions))


# Create the ggplot
p<- ggplot(sum_by_year, aes(x = `Commitment Year`, y = Total_Amount_Millions)) +
  geom_line(group=1, color="blue", size=0.5) +  # Adds a line graph
  geom_point(color="red", size=2 , alpha=0.5) +  # Adds points at each year data
  labs(title = "Trend of Total Commitments by Year",
       x = "Year",
       y = "Total Amount (in Millions)",
       caption = "Data source: Your Data Name") +
  theme_classic() +  # Uses a minimal theme
  theme(plot.title = element_text(hjust = 0.5),
        axis.text.x = element_text(size = 18, angle = 45, hjust = 1),
        axis.text.y = element_text(size = 18, hjust = 1))  # Center aligns the plot title

print(p)
# Sauvegarder le graphique dans un fichier
ggsave("evolutionanuelffc.png", plot = p, width = 5, height = 5, dpi = 300)


