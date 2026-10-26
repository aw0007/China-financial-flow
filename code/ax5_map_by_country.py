import pandas as pd
import geopandas as gpd
from pathlib import Path
import matplotlib.pyplot as plt

# Load the dataset
file_path = "C:/Users/massa/Desktop/Repli/data/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatas_Global_Chinese_Development_Finance_Dataset_Version_3_0/AidDatasGlobalChineseDevelopmentFinance3GEO.dta"
data = pd.read_stata(file_path)

# Step 1: Filter out rows with missing values
data_filtered = data.dropna(subset=['AmountNominalUSD', 'centroid_longitude', 'centroid_latitude'])
# Step 2: Adjust AmountNominalUSD to be in millions and update agg_data accordingly
data_filtered['AmountNominalUSD'] = data_filtered['AmountNominalUSD'] / 1e9
agg_data = data_filtered.groupby('Recipient', as_index=False).agg({
    'AmountNominalUSD': 'sum',
    'centroid_longitude': 'mean',
    'centroid_latitude': 'mean'
})

# Step 3: Convert to GeoDataFrame with updated amounts
gdf = gpd.GeoDataFrame(
    agg_data,
    geometry=gpd.points_from_xy(agg_data.centroid_longitude, agg_data.centroid_latitude)
)
# Load your world map
world = gpd.read_file(gpd.datasets.get_path('naturalearth_lowres'))

# Merge the world GeoDataFrame with your aggregated data
world = world.merge(agg_data, left_on='name', right_on='Recipient', how='left')

# Plot the choropleth map
# Plot the choropleth map with an adjusted legend

fig, ax = plt.subplots(figsize=(15, 10))
world.plot(column='AmountNominalUSD', ax=ax, legend=True, cmap='OrRd',
           legend_kwds={'label': "",
                        'orientation': "horizontal",
                        'shrink': 0.5,  # Adjusts the width of the color bar
                        'aspect': 40,   # Adjusts the height of the color bar
                        'pad': 0.04     # Adjusts the padding between the map and the color bar
                        })




# Add title and axis labels
plt.title("Total des investissements par pays en milliards de dollars américains (2000-2014)")
plt.xlabel('Longitude')
plt.ylabel('Latitude')

# Remove axis
ax.axis('off')

# Save the figure if needed
plt.savefig('C:/Users/massa/Desktop/Repli/resultats/Total des investissements par pays en milliards de dollars américains (2000-2014).png', bbox_inches='tight')

plt.show()