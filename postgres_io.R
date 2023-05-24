library(sf)

# specify connection inputs (see docker-compose.yaml)
host <- "postgres" 
port <- '5432' 
db <- 'postgis' 
db_user <- "postgis"  
db_pass <- "postgis" 


# read data
vector <- system.file("gpkg/nc.gpkg", package = "sf")
tif <- system.file("tif/L7_ETMs.tif", package = "stars")

vector_sf <- sf::read_sf(vector)
vector_terra <- terra::vect(vector)
raster_terra <- terra::rast(tif)[[1]]
raster_stars <- stars::read_stars(tif)[,,,1]

# write/read vector data with sf - works 
con_str <- glue::glue("postgresql://{db_user}:{db_pass}@{host}:{port}/{db}")
sf::st_write(obj = vector_sf[1:50,], dsn = con_str, layer = "vector_sf", driver = "PostgreSQL", delete_dsn = TRUE)
(sf::st_read(con_str, layer = "vector_sf"))
(terra::vect(con_str, layer = "vector_sf"))


# write/read vector data with terra - works as expected
terra::writeVector(vector_terra[51:100,], filename = con_str, filetype = "PostgreSQL", layer = "vector_terra", options = "OVERWRITE=YES")
(terra::vect(con_str, layer = "vector_terra"))
(sf::st_read(con_str, layer = "vector_terra"))


# write/read raster data with stars - does not work
base_str <- glue::glue("PG:host={host} port={port} dbname='{db}' user='{db_user}' password='{db_pass}'")
try(stars::write_stars(raster_stars, dsn = glue::glue(paste0(base_str, " table='{table}'"), table = "raster_stars"), driver = "PostGISRaster"))

# write/read raster data with terra - does not work
try(terra::writeRaster(raster_terra, filename = glue::glue(paste0(base_str, " table='{table}'"), table = "raster_terra"), filetype = "PostGISRaster"))

# read existing raster from postgis - works
(org_stars <- stars::read_stars(glue::glue(paste0(base_str, " table='{table}'"), table = "postgis_raster")))
(org_terra <- terra::rast(glue::glue(paste0(base_str, " table='{table}'"), table = "postgis_raster")))

# copy a PostGISRaster with stars - does not work
try(stars::write_stars(org_stars, dsn = glue::glue(paste0(base_str, " table='{table}'"), table = "postgis_raster_stars"), driver = "PostGISRaster"))

# copy a PostGISRaster with terra - does not work
try(terra::writeRaster(org_terra, filename = glue::glue(paste0(base_str, " table='{table}'"), table = "postgis_raster_terra"), filetype = "PostGISRaster"))
