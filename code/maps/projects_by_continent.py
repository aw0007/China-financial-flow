import pandas as pd
import geopandas as gpd
import matplotlib.pyplot as plt
import re
from pathlib import Path

# File paths
file_path = "C:/Users/massa/Desktop/MiniProjet/Acled/2021-12-14-2024-12-17-Western_Africa.csv"
figures_dir = "C:/Users/massa/Desktop/MiniProjet/Western_Africa_Maps/"
Path(figures_dir).mkdir(parents=True, exist_ok=True)  # Create output directory if it doesn't exist

# Load dataset
try:
    columns_to_load = ['event_id_cnty', 'event_date', 'event_type', 'fatalities', 'latitude', 'longitude', 'country']
    data = pd.read_csv(file_path, delimiter=';', usecols=columns_to_load, parse_dates=['event_date'])
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

# Filter out rows with missing coordinates
data_filtered = data.dropna(subset=['latitude', 'longitude'])

# Add a column for marker size based on fatalities
data_filtered['marker_size'] = data_filtered['fatalities'].apply(lambda x: 10 if x == 0 else x * 3)

# Convert the filtered data into a GeoDataFrame
gdf = gpd.GeoDataFrame(
    data_filtered,
    geometry=gpd.points_from_xy(data_filtered.longitude, data_filtered.latitude)
)

# Load the world shapefile
try:
    world = gpd.read_file('C:/Users/massa/Desktop/MiniProjet/Carto aid data/NaturalEarth/ne_110m_admin_0_countries.shp')
except FileNotFoundError:
    print("Error: World shapefile not found. Please download it from Natural Earth Data.")
    exit(1)

# Define Western Africa region bounds
western_africa_bounds = {"xlim": [-20, 20], "ylim": [0, 25]}

# Create a map for Western Africa
fig, ax = plt.subplots(figsize=(15, 10))

# Plot the base world map
world.plot(ax=ax, color='white', edgecolor='black')

# Plot the events with dynamic marker size and color by event type
gdf.plot(
    ax=ax,
    column='event_type',  # Color by event type
    cmap='tab20',         # Color palette
    markersize=gdf['marker_size'],
    legend=True,
    legend_kwds={'fontsize': 10}
)

# Set zoom level for Western Africa
ax.set_xlim(western_africa_bounds['xlim'])
ax.set_ylim(western_africa_bounds['ylim'])

# Add axes labels
ax.set_xlabel("Longitude", fontsize=12)
ax.set_ylabel("Latitude", fontsize=12)

# Add a signature at the bottom in italics
signature = (
    "Created by A.Wahid MNS | Data Source: ACLED | Visualization: Python (GeoPandas & Matplotlib)"
)
plt.text(
    0.5, -0.1, signature, fontsize=10, style='italic', ha='center', va='center', transform=ax.transAxes
)

# Add title
plt.title('Event Mapping: Western Africa (2021-2024)', fontsize=16)

# Save the map
fig.savefig(figures_dir + 'Western_Africa_Events_Map.png', bbox_inches='tight', dpi=300)
plt.close(fig)

print("Western Africa map created and saved successfully!")
