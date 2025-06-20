pacman::p_load(sf, rnaturalearth, tidyverse, terra) 
# sf handles geospatial data
# rnaturalearth is the data we're working with

# get world map data as sf object
print("Getting world map data...") # <- cool lil add-on
world_sf <- rnaturalearth::ne_countries(scale = 'medium', returnclass = 'sf')
print("World data loaded.") # <- Good for UX when loading large objects

# Check CRS (coordinate reference system) 
original_crs <- sf::st_crs(world_sf)

print(original_crs)
# Look for EPSG code at bottom of output. CRS code here is 4326 (WGS84 Lat/Lon)

#change CRS to Robinson Projection (often used for world maps)
target_crs_robinson <- "ESRI:54030"
print(paste("Target CRS:", target_crs_robinson))

# use st_transform() to transform data to new CRS
print("Transforming data to Robinson projection...")
world_robinson_sf <- world_sf %>% 
  sf::st_transform(crs = target_crs_robinson)
print("Transformation complete!")

# Check CRS of new, transformed data
print("Checking the new CRS...")
new_crs <- sf::st_crs(world_robinson_sf)
print(new_crs)

#### PLOT COMPARISON
print("Plotting comparison (original vs transformed)...")

par(mfrow = c(1,2)) #set plots side by side

# original sf plot
plot(sf::st_geometry(world_sf),
     main = "Original (EPSG:4326)",
     key.pos = NULL, reset = FALSE,
     border="grey")

plot(sf::st_geometry(world_robinson_sf),
     main = "Transformed (Robinson)",
     key.pos = NULL, reset = FALSE,
     border="blue"
     )

par(mfrow = c(1,1))
print("Plots displayed. Notice the shape difference!")

# updated Robinson plot

######## Chapter 2

# Get world cities data as an sf object 
# This is vector data (points, precision)

print("Getting world cities sf object..")

# Step 2: Get world countries data as an sf object
# This is vector data (polygons)
print("Getting world countries sf object...")

world_countries <- rnaturalearth::ne_countries(
  scale = 'medium', returnclass = 'sf')
print("Data loaded into 'world_countries'.")

world_cities <- rnaturalearth::ne_download(
  scale = "medium",
  type = "populated_places",
  category = "cultural", #interested in what the different categories are
  returnclass = "sf" #return as sf object
)

print("Data loaded into 'world_cities")
print(world_cities)

# Inspect world_countries sf object
# Print the whole object -- seeing table and geometry
print("---Full sf object (first few rows")
print(world_countries)

# Step 5: Check the class. What kind of object is this?
print("---Object Class---")
print(class(world_countries))
print("It's both 'sf' and 'data frame'")

# Step 6: Use glimpse() for a compact summary of attributes
print("--- Attribute Summary using glimpse() ---")

dplyr::glimpse(world_countries)


# Step 7: Look at JUST the attribute table/regular data frame
print("--- Attribute Table only using (st_drop_geometry)")

world_attributes_only <- sf::st_drop_geometry(world_countries)
print(head(world_attributes_only))
print(class(world_attributes_only)) # <- Should only be dataframe

# Step 8: Look ay JUSt the geometry column
print("--- Geometry column only using (st_geometry")

world_geometry_only <- sf::st_geometry(world_countries)
print(world_geometry_only[1:3]) # <- Show geometry info for first 3  countries
print(class(world_geometry_only)) # <- Should be 'sfc' (simple feature column) and sfc_MULTIPOLYGON

# Plot comparison using ggplot

plot_original <- ggplot() + geom_sf(data = world_countries, linewidth = 0.2) + ggtitle("Original (EPSG:4326)") + theme_minimal()
plot_original

plot_transformed <- ggplot() + geom_sf(data = world_robinson_sf, linewidth = 0.2) + ggtitle("Transformed (Robinson)") + theme_minimal()
plot_transformed

#Print side-by-side comparison (use patchwork package)
pacman::p_load(patchwork)
print(plot_original / plot_transformed)
