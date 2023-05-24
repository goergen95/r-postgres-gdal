# r-postgres-gdal

This repository contains the source code for a contribution to a discussion at [r-spatial](https://github.com/r-spatial/discuss/issues/58) about the possibilities to read/write to a PostGIS server using R packages relying on the GDAL drivers.

## Results

For vector data, the GDAL [PostgreSQL](https://gdal.org/drivers/vector/pg.html) driver allows to read and write to a database using both `sf` and `terra`.

For raster data, the [GDAL driver](https://gdal.org/drivers/raster/postgisraster.html#raster-postgisraster) states that currently read-only support is implemented but that the `GDALDriver::CreateCopy() operation is available. 
Using stars, the error message `Error: driver does not support Create() method.` is thrown, indicating that the path over `CreateCopy()` is not taken and writing a raster to a PostGIS database fails. 

Using terra, the second error message reads: 

```bash
2: In x@ptr$writeRaster(opt) :
  GDAL Error 6: PostGISRasterDataset::CreateCopy() only works on source datasets that are PostGISRaster
```

Indicating that writing a raster to a PostGIS database fails, but copying an already existing PostGISRaster might be feasible with terra.
Using the driver to read from a database connection works for both `stars` and `terra`. 
A naive approach of copying a PostGISRaster source seems to fail for both packages despite that the GDAL drivers seems to support it.

## How to run the example?

Assuming that git, docker, and docker-compose are installed on your system run the following commands:

```bash
git clone https://github.com/goergen95/r-postgres-gdal
cd r-postgres-gdal
docker-compose up -d
docker exec -ti postgres bash /home/postgis/load_raster.sh
docker exec -it r-studio Rscript /home/rstudio/r-postgres-gdal/postgres_io.R
```

or go to `localhost:8787` using `rstudio` as username and `supersecret` as password to run the script interactively in R-Studio.

To shut down the docker containers run:

```bash
docker-compose down
```
