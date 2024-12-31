import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import re
from pathlib import Path

# File paths
file_path = "C:/Users/massa/Desktop/MiniProjet/Carto aid data/AidDatas_Global_Chinese_Development_Finance.xlsx"
figures_dir = "C:/Users/massa/Desktop/MiniProjet/Carto aid data/Figures/"
Path(figures_dir).mkdir(parents=True, exist_ok=True)

# Load dataset with only relevant columns
try:
    columns_to_load = ['id', 'SectorName', 'centroid_longitude', 'centroid_latitude']
    data = pd.read_excel(file_path, engine='openpyxl', usecols=columns_to_load)
except FileNotFoundError:
    print(f"Error: File not found at {file_path}")
    exit(1)
except Exception as e:
    print(f"An error occurred: {e}")
    exit(1)

# Display basic information
print("Dataset Information:")
print(data.info())
print("\nFirst 5 rows:")
print(data.head())

# Filter out rows with missing coordinates
data_filtered = data.dropna(subset=['centroid_longitude', 'centroid_latitude'])

# Convert filtered data to GeoDataFrame
gdf = gpd.GeoDataFrame(
    data_filtered,
    geometry=gpd.points_from_xy(data_filtered.centroid_longitude, data_filtered.centroid_latitude)
)

# Load world shapefile
try:
    world = gpd.read_file('C:/Users/massa/Desktop/MiniProjet/Carto aid data/NaturalEarth/ne_110m_admin_0_countries.shp')
except FileNotFoundError:
    print("Error: World shapefile not found. Please download from Natural Earth Data.")
    exit(1)

# Global map - Enhanced visualization
fig, ax = plt.subplots(figsize=(15, 10))
world.plot(ax=ax, color='white', edgecolor='black')
gdf.plot(ax=ax, column='SectorName', cmap='tab20', markersize=5, legend=True)
plt.title('Cartographie des Projets', fontsize=16)
plt.xlabel('Longitude', fontsize=14)
plt.ylabel('Latitude', fontsize=14)
fig.savefig(figures_dir + 'Cartographie_Projets_Enhanced.png')
plt.close(fig)




# Generate sector-specific maps
for sector in gdf['SectorName'].unique():
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

    # Sanitize sector name for file naming
    safe_sector_name = re.sub(r'[^\w\-_\.]', '_', sector)
    fig.savefig(figures_dir + f'Cartographie_Projets_Secteur_{safe_sector_name}.png')
    plt.close(fig)

print("Mapping completed. Figures saved to:", figures_dir)
