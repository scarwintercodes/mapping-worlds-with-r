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
     ))

# updated Robinson plot