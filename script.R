pacman::p_load(sf, rnaturalearth) 
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