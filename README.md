# Linking NDW and NWB

## Software prerequisites

Install PostgreSQL/PostGIS, Ruby, Ruby gems:

```sh
brew install postgis
brew install ruby

gem install sequel
gem install ox
```
 
Create database `ndw`, install PostGIS extension: `CREATE EXTENSION postgis;`  

Download data, convert to shapefiles, import into database:

```sh
cd data
./create_tables.sh
```
