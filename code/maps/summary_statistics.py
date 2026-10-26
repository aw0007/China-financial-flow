import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import re
from pathlib import Path
from scipy.stats import zscore, ttest_ind
from sklearn.cluster import KMeans
import folium

# File paths
file_path = "C:/Users/massa/Desktop/MiniProjet/Carto aid data/AidDatas_Global_Chinese_Development_Finance.xlsx"
figures_dir = "C:/Users/massa/Desktop/MiniProjet/Carto aid data/Figures/"
Path(figures_dir).mkdir(parents=True, exist_ok=True)  # Create the output directory if it doesn't exist

# Load dataset with only relevant columns
try:
    columns_to_load = ['id', 'SectorName', 'AmountNominalUSD', 'centroid_longitude', 'centroid_latitude']
    data = pd.read_excel(file_path, engine='openpyxl', usecols=columns_to_load)
except FileNotFoundError:
    print(f"Error: File not found at {file_path}")
    exit(1)
except Exception as e:
    print(f"An error occurred: {e}")
    exit(1)

# Display basic dataset information
print("Dataset Information:")
print(data.info())
print("\nFirst 5 rows:")
print(data.head())

# Filter out rows with missing coordinates and AmountNominalUSD
data_filtered = data.dropna(subset=['AmountNominalUSD', 'centroid_longitude', 'centroid_latitude'])

# Convert AmountNominalUSD to billions
data_filtered['AmountNominalUSD'] = data_filtered['AmountNominalUSD'] / 1e9

# Create a dynamic marker size column based on AmountNominalUSD
data_filtered['marker_size'] = data_filtered['AmountNominalUSD'] * 50

# Convert the filtered data into a GeoDataFrame
gdf = gpd.GeoDataFrame(
    data_filtered,
    geometry=gpd.points_from_xy(data_filtered.centroid_longitude, data_filtered.centroid_latitude)
)

# Load the world shapefile for map visualization
try:
    world = gpd.read_file('C:/Users/massa/Desktop/MiniProjet/Carto aid data/NaturalEarth/ne_110m_admin_0_countries.shp')
except FileNotFoundError:
    print("Error: World shapefile not found. Please download it from Natural Earth Data.")
    exit(1)

# ---------------------------
# 1. Sectoral Analysis
# ---------------------------
sector_analysis = data_filtered.groupby('SectorName')['AmountNominalUSD'].sum().sort_values(ascending=False)
sector_analysis.plot(kind='bar', figsize=(12, 6))
plt.title("Sectoral Distribution of Chinese Development Finance (in billions USD)")
plt.ylabel("Finance (in billions USD)")
plt.xlabel("Sector")
plt.tight_layout()
plt.savefig(figures_dir + 'Sectoral_Distribution.png', dpi=300)
plt.show()

# ---------------------------
# 2. Temporal Analysis
# ---------------------------
if 'year' in data.columns:
    year_analysis = data_filtered.groupby('year')['AmountNominalUSD'].sum()
    year_analysis.plot(kind='line', figsize=(12, 6), marker='o')
    plt.title("Trends in Chinese Development Finance Over Time (in billions USD)")
    plt.ylabel("Finance (in billions USD)")
    plt.xlabel("Year")
    plt.grid()
    plt.tight_layout()
    plt.savefig(figures_dir + 'Temporal_Trends.png', dpi=300)
    plt.show()

# ---------------------------
# 3. Regional Analysis
# ---------------------------
continents = {
    "Africa": {"xlim": [-20, 55], "ylim": [-40, 40]},
    "Asia": {"xlim": [50, 150], "ylim": [-10, 70]},
    "Europe": {"xlim": [-25, 50], "ylim": [35, 75]},
    "America": {"xlim": [-170, -30], "ylim": [-55, 70]},
    "Oceania": {"xlim": [110, 180], "ylim": [-50, 10]},
}

for continent, limits in continents.items():
    fig, ax = plt.subplots(figsize=(15, 10))
    world.plot(ax=ax, color='white', edgecolor='black')
    gdf.plot(
        ax=ax,
        column='SectorName',
        cmap='tab20',
        markersize=gdf['marker_size'],
        legend=True,
        legend_kwds={'fontsize': 8}
    )
    ax.set_xlim(limits['xlim'])
    ax.set_ylim(limits['ylim'])
    ax.axis('off')
    plt.title(f'Chinese Development Finance in : {continent}', fontsize=16)
    plt.text(
        0.5, -0.1,
        "Created by A.Wahid MNS | Data Source: https://www.aiddata.org/datasets | Visualization: Python (GeoPandas & Matplotlib)",
        fontsize=10, style='italic', ha='center', va='center', transform=ax.transAxes
    )
    safe_continent_name = re.sub(r'[^\w\-_\.]', '_', continent)
    fig.savefig(figures_dir + f'Project_Map_{safe_continent_name}.png', bbox_inches='tight', dpi=300)
    plt.close(fig)

# ---------------------------
# 4. Correlation Analysis
# ---------------------------
plt.figure(figsize=(10, 5))
plt.scatter(data_filtered['centroid_longitude'], data_filtered['AmountNominalUSD'], alpha=0.5)
plt.title("Correlation Between Longitude and Funding Amount")
plt.xlabel("Longitude")
plt.ylabel("Finance (in billions USD)")
plt.grid()
plt.tight_layout()
plt.savefig(figures_dir + 'Longitude_Correlation.png', dpi=300)
plt.show()

# ---------------------------
# 5. Cluster Analysis
# ---------------------------
coordinates = data_filtered[['centroid_longitude', 'centroid_latitude']]
kmeans = KMeans(n_clusters=5, random_state=42)
data_filtered['cluster'] = kmeans.fit_predict(coordinates)
fig, ax = plt.subplots(figsize=(15, 10))
world.plot(ax=ax, color='white', edgecolor='black')
gdf.plot(ax=ax, column='cluster', cmap='tab10', legend=True)
plt.title("Clusters of Chinese Development Finance Projects")
plt.savefig(figures_dir + 'Cluster_Analysis.png', dpi=300)
plt.show()

# ---------------------------
# 6. Outlier Detection
# ---------------------------
data_filtered['z_score'] = zscore(data_filtered['AmountNominalUSD'])
outliers = data_filtered[data_filtered['z_score'].abs() > 3]
print("Outliers:")
print(outliers)

# ---------------------------
# 7. Interactive Map
# ---------------------------
m = folium.Map(location=[0, 0], zoom_start=2)
for idx, row in data_filtered.iterrows():
    folium.CircleMarker(
        location=(row['centroid_latitude'], row['centroid_longitude']),
        radius=row['marker_size'] / 10,
        popup=f"Sector: {row['SectorName']}<br>Amount: {row['AmountNominalUSD']:.2f} billion USD",
        color="blue",
        fill=True,
        fill_color="blue",
    ).add_to(m)
m.save(figures_dir + "Interactive_Map.html")

# ---------------------------
# 8. Hypothesis Testing
# ---------------------------
sector_a = data_filtered[data_filtered['SectorName'] == 'Sector A']['AmountNominalUSD']
sector_b = data_filtered[data_filtered['SectorName'] == 'Sector B']['AmountNominalUSD']
if not sector_a.empty and not sector_b.empty:
    t_stat, p_value = ttest_ind(sector_a, sector_b, equal_var=False)
    print(f"T-statistic: {t_stat}, P-value: {p_value}")
