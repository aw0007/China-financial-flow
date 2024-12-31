import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import networkx as nx
import geopandas as gpd
import os
from scipy.cluster.hierarchy import dendrogram, linkage
from sklearn.preprocessing import StandardScaler
from pathlib import Path


# Chemin du fichier de données
file_path = "C:/Users/massa/Desktop/Repli/data/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatasGlobalChineseDevelopmentFinance3GEO.dta"

# Chargement des données
data = pd.read_stata(file_path)

# Répertoire pour enregistrer les figures
figures_dir = "C:/Users/massa/Desktop/Memoire MAG3/data/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/Carthographie/"
Path(figures_dir).mkdir(exist_ok=True)

# Affichage des informations de base et des premières lignes du jeu de données
print("Informations sur le jeu de données :")
data.info()
print("\nPremières lignes du jeu de données :")
print(data.head())

# Filtrage pour éliminer les valeurs manquantes dans les colonnes de coordonnées
data_filtered = data.dropna(subset=['centroid_longitude', 'centroid_latitude'])

# Conversion des données en GeoDataFrame
gdf = gpd.GeoDataFrame(
    data_filtered,
    geometry=gpd.points_from_xy(data_filtered.centroid_longitude, data_filtered.centroid_latitude)
)

# Création de la première carte
fig, ax = plt.subplots(figsize=(15, 10))
world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres'))
world.plot(ax=ax, color='white', edgecolor='black')
gdf.plot(ax=ax, color='red', markersize=2)
plt.title('Cartographie des Projets')
plt.xlabel('Longitude')
plt.ylabel('Latitude')
fig.savefig(figures_dir + 'Cartographie_Projets_1.png')



# Création de la deuxième carte
fig, ax = plt.subplots(figsize=(15, 10))
world.plot(ax=ax, color='lightgray', edgecolor='black')
gdf.plot(ax=ax, color='blue', markersize=1, alpha=0.3)
plt.title('Cartographie des Projets', fontsize=16)
plt.xlabel('Longitude', fontsize=14)
plt.ylabel('Latitude', fontsize=14)
fig.savefig(figures_dir + 'Cartographie_Projets_2.png')

# Création des cartes par secteur
unique_sectors = data_filtered['SectorName'].unique()
for sector in unique_sectors:
    data_sector = data_filtered[data_filtered['SectorName'] == sector]
    gdf_sector = gpd.GeoDataFrame(
        data_sector,
        geometry=gpd.points_from_xy(data_sector.centroid_longitude, data_sector.centroid_latitude)
    )

    fig, ax = plt.subplots(figsize=(15, 10))
    world.plot(ax=ax, color='lightgray', edgecolor='black')
    gdf_sector.plot(ax=ax, markersize=5, alpha=0.6, color='blue')
    plt.title(f'Cartographie des Projets par Secteur: {sector}', fontsize=16)
    plt.xlabel('Longitude', fontsize=14)
    plt.ylabel('Latitude', fontsize=14)
    # Replace slashes (or any other unwanted characters) in the sector name with underscores
    safe_sector_name = sector.replace("/", "_").replace("\\", "_")

    # Now use the sanitized sector name in the file name
    fig.savefig(figures_dir + f'Cartographie_Projets_Secteur_{safe_sector_name}.png')
    plt.close(fig)





