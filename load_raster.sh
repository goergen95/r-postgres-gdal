psql -U postgis -d postgis <<EOF
create extension postgis_raster;
EOF

raster2pgsql -C -b 1 /home/postgis/L7_ETMs.tif postgis_raster| psql -U postgis -d postgis
