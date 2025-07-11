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

#adjust plot margins
par(mar = c(1, 1, 1, 1))

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

######## Chapter 3
# Step 2: Load the GeoPackage file using st_read()
# We provide the RELATIVE PATH from the project root folder.
# Our file is inside the 'data' subfolder.

# Step 1: Load necessary packages
print("Loading packages...")
# Ensure pacman is installed and loaded if you use it
if (
  !requireNamespace("pacman", quietly = TRUE)
) install.packages("pacman")
pacman::p_load(sf, dplyr) # Need sf for st_read,
# dplyr for glimpse later
print("Packages ready.")
# Step 2: Load the GeoPackage file using st_read()
# We provide the RELATIVE PATH from the project root folder.
# Our file is inside the 'data' subfolder.
print(
  "Loading vector data from data/world_boundaries.gpkg..."
)
world_boundaries_loaded <- sf::st_read(
  "data/world_boundaries.gpkg"
)

# Step 3: Inspect the loaded data
print("Inspecting the data...")
print(class(world_boundaries_loaded))
print("First few rows:")
print(head(world_boundaries_loaded))
print("Coordinate Reference System:")
print(sf::st_crs(world_boundaries_loaded))
# Make the object available outside the chunk if needed
assign(
  "world_boundaries_loaded",
  world_boundaries_loaded,
  envir = .GlobalEnv
)

# --- Script: chapter_3_load_csv.R --- #
# (Can be in the same script file)
# Step 1: Load necessary packages
print("Loading packages...")
pacman::p_load(readr, dplyr) # readr for read_csv, dplyr for glimpse
print("Packages ready.")
# Step 2: Load the CSV file using read_csv()
# Again, use the relative path from the project root.
print(
  "Loading tabular data country_indicators.csv..."
)
country_indicators_loaded <- readr::read_csv(
  "data/country_indicators.csv"
)
# Step 3: Inspect the loaded data
print("CSV data loaded successfully!")
print("--- Object Class ---")
print(
  class(country_indicators_loaded)
) # Should be 'spec_tbl_df', 'tbl_df', 'tbl', 'data.frame'
print("--- First few rows ---")
print(head(country_indicators_loaded))
print("--- Column Summary (glimpse) ---")
dplyr::glimpse(
  country_indicators_loaded
) # Useful for seeing column types
# Make the object available outside the chunk if needed
assign(
  "country_indicators_loaded",
  country_indicators_loaded, envir = .GlobalEnv)

# --- Script: chapter_3_cleaning.R --- #
# (Can be in the same script file)
# Step 1: Ensure packages and data are ready
print("Loading packages...")
pacman::p_load(sf, dplyr, rnaturalearth) # Need rnaturalearth for continent join

# Step 2: Select only needed columns
# Let's imagine we only need name, iso code,
# and geometry for our map
# Load world_boundaries.gpkg
world_boundaries_loaded <- sf::st_read("data/world_boundaries.gpkg")
sf::st_geometry(
  world_boundaries_loaded
) <- "geometry" # name geometry field
print("Selecting specific columns...")
# Use the pipe |> to pass the data through steps
world_selected <- world_boundaries_loaded %>% 
  # Keep only these columns
  # (adjust names based on your actual data!)
  # Use any_of() to avoid errors if a column doesn't exist
  # Ensure the geometry column is always included when selecting
  dplyr::select(
    dplyr::any_of(
      c("NAME_ENGL", "ISO3_CODE")), geometry)
print("Columns selected:")
print(head(world_selected))
# Step 3: Rename columns for easier use
print("Renaming columns...")
world_renamed <- world_selected %>% 
  dplyr::rename(
    country_name = NAME_ENGL, # New name = Old name
    iso3 = ISO3_CODE) # Adjust old names based on your data!
# geometry column usually keeps its name)
print("Columns renamed:")
print(head(world_renamed))
# Store the cleaned data (before filtering for Africa)
# for the next step
assign("world_renamed", world_renamed, envir = .GlobalEnv)
# Step 4: Filter rows - e.g., keep only African countries
# First, we need continent info, which wasn't in our
# simplified gpkg.
# Let's reload the rnaturalearth data which has continents.
print("Reloading rnaturalearth data to get continents for
filtering example...")
world_ne <- rnaturalearth::ne_countries(
  scale = "medium", returnclass = "sf") |>
  dplyr::select(adm0_a3, continent) |> # Keep ISO and continent
  sf::st_drop_geometry() # We only need the table for joining

# join continent info to renamed boundaries
world_renamed_with_cont <- world_renamed %>% 
  dplyr::left_join(world_ne, by = c("iso3" = "adm0_a3"))

###### SPATIAL DATA CLEANING ##########
africa_only <- world_renamed_with_cont |>
  dplyr::filter(continent == "Africa")
print("Filtered data for Africa:")
print(africa_only) # Show the filtered sf object

nrow(africa_only)


africa_valid_geom <- africa_only %>% 
  dplyr::filter(!sf::st_is_empty(geometry)) %>% #remove features where geometry is empty
  sf::st_make_valid() %>%  #try to make geometries valid
  # one more filter in case st_make_valid resulted in empty ones
  dplyr::filter(!sf::st_is_empty(geometry))

nrow(africa_valid_geom)


######### JOINING DATA ############
## load country indicator data
country_indicators_loaded <- read_csv("data/country_indicators.csv")

# preview common values
print(head(world_renamed$iso3))
print(head(country_indicators_loaded$iso3c))

# Perform the left join
world_data_joined <- world_renamed %>% 
  left_join(
    country_indicators_loaded,
    by = c("iso3" = "iso3c")
  )

# QC the result

## glimpse
glimpse(world_data_joined)

## NA count, number of countries with NA in population, indicates no match
na_count <- sum(is.na(world_data_joined$population))

print(na_count)

###### SAVE THE JOINED/CLEANED DATA #######

# Make the joined object available in the global environment
assign(
  "world_data_joined", world_data_joined,
  envir = .GlobalEnv
)

# save object to a .gpkg file format

# define file path
output_filename <- "world_data_cleaned_joined.gpkg"
message("Saving cleaned data to: ", output_filename)

# Write the GeoPackage
st_write(world_data_joined, output_filename, delete_layer = TRUE)
message("Data saved successfully!")

####### CHAPTER 4

map_plot_basic <- ggplot(world_data_joined) + #new layer with +
  geom_sf(
    mapping = aes(fill = gdp_per_capita),
    color = "white",
    linewidth = 0.1
  ) + #layer
  labs(
    title = "GDP per Capita (2020)",
    fill = "US Dollars"
  ) +
  theme_minimal()

map_plot_basic

# --- Script: chapter_4_custom_colors.R ---
# Ensure required packages are installed and loaded
pacman::p_load(sf, ggplot2, scales)
# Create a choropleth using the Viridis 'rocket' palette with log10
# scaling
map_plot_viridis <- ggplot2::ggplot(data = world_data_joined) +
  ggplot2::geom_sf(
    mapping = ggplot2::aes(fill = gdp_per_capita),
    color = "white",
    linewidth = 0.1
  ) +
  scale_fill_viridis_c(
    option = "rocket", # Choose a specific Viridis palette
    direction = -1, # reverse palette so that lighter colors are
    # associated with lower values, and darker with higher
    name = "US dollars", # legend title
    na.value = "grey80", # color for missing values
    trans = "log10", # Apply log10 transformation because density
    # is highly skewed (many low values, few very high values)
    # Use special labels for log scale
    # (requires scales package)
    labels = scales::label_log(digits = 2) # Use special labels for
    # log scale (requires scales package)
  ) +
  ggplot2::labs(title = "GDP per capita") +
  ggplot2::theme_minimal() +
  ggplot2::theme(legend.position = "bottom",
                 legend.key.width = grid::unit(1.5, "cm"))
# Display the map
print(map_plot_viridis)

